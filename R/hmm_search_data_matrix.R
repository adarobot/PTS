setwd("/Users/tao/Downloads/test_hmm")

####################################################################
####################################################################
####################################################################
#process hmmsearch tbl results and combine all together.############
####################################################################
####################################################################
####################################################################
library(tidyr)
df <- data.frame(matrix(ncol = 1, nrow = 0))
colnames(df) <- c("strain_id")
col_name<-c("strain_id")
files <- list.files(path="./tbl_processed", pattern="*_processed.out", full.names=TRUE, recursive=FALSE)
for (x in files){
  out <- hmm2count(x)
  print(x)
  hmm_name=gsub('.*tbl_(.*).hmm.out_processed.out*','\\1',x)
  col_name<-append(col_name,c(hmm_name,paste(hmm_name,"-wth",sep = ""),paste(hmm_name,"-all",sep = "")))
  df<-merge(df,out,by="strain_id",all = TRUE)
  output<-paste("./final_matrix/",hmm_name,"_matrix.csv",sep="")
  write.csv(out, file =output, sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)
}

df<-data.frame(df)
colnames(df)<-col_name
df[is.na(df)]<-0
write.csv(df, file ="./final_matrix/all_combined_matrix.csv")

hmm2count<-function(tbl.out){
  tt=read.table(tbl.out,skip=0,fill = TRUE,sep = "",header = FALSE)
  tt<- tt %>% unite("Description", 19:dim(tt)[2], remove = FALSE,sep=" ")
  tt=tt[,1:19]
  tt$strain_id<-gsub(".*[]] (.*)\\_protein.*", "\\1", tt$Description)
  tt=subset(tt, select=-c(V2))
  colnames(tt)<-c("target_aa","query_hmm","query_id","fs_e","fs_bs","fs_bias","no_1_domain_e","no_1_domain_bs","no_1_domain_bias","dom_exp","dom_reg","dom_clu","dom_ov","dom_env","dom_dom","dom_rep","dom_inc","Description","strain_id")
  all<-c()
  id=unique(tt$strain_id)
  id=id[!nchar(id, type = "chars", allowNA = FALSE, keepNA = NA)>45]
  id=id[!nchar(id, type = "chars", allowNA = FALSE, keepNA = NA)<15]
  
  for (x in 1:length(id)){
    all$strain_id[length(all$strain_id)+1]<-id[x]
    sub=tt[tt$strain_id==id[x],]
    all$hmm[length(all$hmm)+1]<-dim(sub[as.numeric(as.character(sub$dom_dom))==1,])[1]
    all$hmm_included[length(all$hmm_included)+1]<-dim(sub[as.numeric(as.character(sub$dom_dom))>1,])[1]
    all$hmm_all[length(all$hmm_all)+1]<-dim(sub)[1]
  }
  all<-data.frame(all)
  return(all)
}

####################################################################
####################################################################
####################################################################
#retrieve updated taxonomic information for each taxon analyzed in hmmsearch.
####################################################################
####################################################################
####################################################################
library("taxize")
library("myTAI")
library("plyr")
library("stringr")

taxid2taxonomy("./genome_list/assembly_summary_archaea_complete.csv","./taxonomy/archaea_tax_lineage_all_complete.csv","e287a18fad12ff365f4030c70bc290d2ca08")
taxid2taxonomy("./genome_list/assembly_summary_bacteria_complete.csv","./taxonomy/bacteria_tax_lineage_all_complete.csv","e287a18fad12ff365f4030c70bc290d2ca08")

taxid2taxonomy<-function(in_file,out_file,key){
  info<-read.csv(in_file,header = TRUE)
  info$unique_id<-paste(info$assembly_accession,info$asm_name,sep = "_")
  taxids <-info$taxid
  taxids<-as.vector(taxids)
  taxids<-as.numeric(taxids)
  taxon_summary <- ncbi_get_taxon_summary(id = taxids,key)
  df_list <- list()
  tax_name_id<-c()
  for (i in 1:nrow(taxon_summary)){
    tax  <- taxonomy(organism = taxon_summary[i,]$name, db = "ncbi",output = "classification")
    if (!is.na(tax[[1]])){
      df <- data.frame(lapply(tax$name, function(x) data.frame(x)))
      name<-paste(taxon_summary[i,]$name,taxon_summary[i,]$uid,sep = "|")
      print(name)
      print(i)
      print("Processed")
      tax_name_id<-append(tax_name_id, name)
      colnames(df) <- tax$rank
      df_list[[i]] <- df
      print(df)
    }
    else{
      tax  <- taxonomy(organism = word(taxon_summary[i,]$name, 1, 2), db = "ncbi",output = "classification")
      if (!is.na(tax[[1]])){
        df <- data.frame(lapply(tax$name, function(x) data.frame(x)))
        name<-paste(taxon_summary[i,]$name,taxon_summary[i,]$uid,sep = "|")
        print(name)
        print(i)
        print("Processed")
        tax_name_id<-append(tax_name_id, name)
        colnames(df) <- tax$rank
        df_list[[i]] <- df
        print(df)      
      }
    }
    Sys.sleep(0.1)
  }
  combined_df <- do.call(rbind.fill, df_list)
  combined_df2<-combined_df
  combined_df2$name_id<-tax_name_id
  write.csv(combined_df2,file = out_file)
}

####################################################################
####################################################################
####################################################################
#assign taxonomic info and strain info to hmmsearch data matrix
####################################################################
####################################################################
####################################################################
hmm<-read.csv("./final_matrix/all_combined_matrix.csv",header = TRUE)
bacteria_archaea<-rbind(read.csv("./genome_list/assembly_summary_bacteria.csv",header = TRUE),read.csv("./genome_list/assembly_summary_archaea.csv",header = TRUE)) ####all strain info combined
bacteria_archaea$strain_id<-paste(bacteria_archaea$assembly_accession,bacteria_archaea$asm_name,sep = "_")
bacteria_archaea$name_id<-paste(bacteria_archaea$organism_name,bacteria_archaea$taxid,sep = "|")
lineage<-rbind(read.csv("./taxonomy/bacteria_tax_lineage_all_complete.csv",header = TRUE),read.csv("./taxonomy/archaea_tax_lineage_all_complete.csv",header = TRUE))
#lineage<-read.csv("all_tax_lineage_all_complete.csv",header = TRUE)
outall<-merge(hmm,bacteria_archaea[,c("strain_id","taxid","organism_name","name_id","refseq_category")],by="strain_id",all.x = TRUE)
outall<-merge(outall,lineage,by="name_id",all.x = TRUE)
write.csv(outall,file = "./output/data_matrix_id_lineage.csv")

