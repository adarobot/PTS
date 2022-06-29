setwd("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final")

out_stat<-c()
foldchange_cuttoff=2
expression_cuttoff=0.05
probe_percentage=0.25
library(limma)
targets<-readTargets("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/filename.txt")
dim(targets)
out_stat<-append(out_stat,paste("No_files_analyzed=", dim(targets)[1], sep = ""))
filter<-function (x){
  okgreen <-(x[,"gMeanSignal"]-x[,"gBGMeanSignal"])/x[,"gBGPixSDev"]>2
  okred <-(x[,"rMeanSignal"]-x[,"rBGMeanSignal"])/x[,"rBGPixSDev"]>2
  gforvsback<-(x[,"gMeanSignal"]/x[,"gBGMeanSignal"])>1.3
  rforvsback<-(x[,"rMeanSignal"]/x[,"rBGMeanSignal"])>1.3
  gcv<- (x[,"gBGPixSDev"]/x[,"gMeanSignal"])<0.8
  rcv<- (x[,"rBGPixSDev"]/x[,"rMeanSignal"])<0.8
  gsignal<- x[,"gMeanSignal"]>150
  rsignal<- x[,"rMeanSignal"]>50 
  #ceiling<-x[,"gMeanSignal"]<65535
  as.numeric(okgreen & okred & gforvsback & rforvsback & gcv & rcv & gsignal & rsignal)}

def<-read.maimages(targets,columns=list(R="rMeanSignal",G="gMeanSignal",Rb="rBGMeanSignal",Gb="gBGMeanSignal"),annotation=c("Row","Col","ProbeName","SystematicName","GeneName"),path = "E:/All microarray data_Xuanyu Tao_07042020/Incubation_cellulose_microarray results_07042020/0630incubation100%/final",wt.fun=filter)

#pass.check=data.frame(def$genes,weights=def$weights,stringsAsFactors = FALSE)

#write.csv(pass.check,file = "test.csv",row.names = FALSE,col.names = TRUE)

RG<-backgroundCorrect(def,method="subtract")
MA<-normalizeWithinArrays(RG,method="median")
MA.pAq<-normalizeBetweenArrays(MA,method="quantile")

#extract the normalized data
heat<-MA.pAq[!grepl("16S", MA.pAq$genes$ProbeName),]
heat<-MA.pAq[grepl("H10", MA.pAq$genes$ProbeName),]


heat.final=data.frame(heat$genes,A=heat$A,stringsAsFactors = FALSE)
heat.final=data.frame(heat$genes,heat$A,stringsAsFactors = FALSE)
heat.final[is.na(heat.final)]=0
write.csv(heat.final,file = "try2.csv",row.names = FALSE,col.names = TRUE)

plotMA(MA.pAq)
# Choices are "none", "scale", "quantile", "Aquantile", "Gquantile", "Rquantile", "Tquantile" or "vsn".

#conduct pairwise comparison to extract differentially expressed probes_internal
design<-modelMatrix(targets, ref="reference")
fit<-lmFit(MA.pAq,design)
all.contrast.matrix<-makeContrasts(CKT3-CKT1,CKT6-CKT3,CKT12-CKT6,S1005T3-S1005T1,S1005T6-S1005T3,S1005T12-S1005T6,
                                   S0806T3-S0806T1,S0806T6-S0806T3,S0806T12-S0806T6,
                                   levels=design)
DE.OUT<-c("DE.CKT3VST1","DE.CKT6VST3","DE.CKT12VST6","DE.S1005T3VST1","DE.S1005T6VST3","DE.S1005T12VST6","DE.S0806T3VST1","DE.S0806T6VST3","DE.S0806T12VST6")

all.contrast.matrix<-makeContrasts(CKT12-CKT1,CKT12-CKT3,S1005T12-S1005T1,S1005T12-S1005T3,
                                   S0806T12-S0806T1,S0806T12-S0806T3,
                                   levels=design)
DE.OUT<-c("DE.CKT12VST1","DE.CKT12VST3","DE.S1005T12VST1","DE.S1005T12VST3","DE.S0806T12VST1","DE.S0806T12VST3")



#conduct pairwise comparison to extract differentially expressed probes_with CK
design<-modelMatrix(targets, ref="reference")
fit<-lmFit(MA.pAq,design)
all.contrast.matrix<-makeContrasts(S1005T0-CKT0,S0806T0-CKT0,S1005T1-CKT1,S1005T3-CKT3,S1005T6-CKT6,S1005T12-CKT12,
                                   S0806T1-CKT1,S0806T3-CKT3,S0806T6-CKT6,S0806T12-CKT12,
                                   levels=design)
DE.OUT<-c("DE.S1005T0VSCKT0","DE.S0806T0vsCKT0","DE.S1005T1VSCKT1","DE.S1005T3VSCKT3","DE.S1005T6VSCKT6","DE.S1005T12VSCKT12","DE.S0806T1VSCKT1","DE.S0806T3VSCKT3","DE.S0806T6VSCKT6","DE.S0806T12VSCKT12")
#DE.OUT<-c("DE.1","DE.2","DE.3","DE.4","DE.5","DE.6","DE.7","DE.8","DE.9","DE.10")

#conduct pairwise comparison to extract differentially expressed probes
all.fit2<-contrasts.fit(fit,all.contrast.matrix)
all.fit2<-eBayes(all.fit2)
dim(all.fit2)
all.fit2<- all.fit2[!grepl("16S", all.fit2$genes$ProbeName),]
all.fit2<- all.fit2[!grepl(":", all.fit2$genes$ProbeName),]
all.fit2<- all.fit2[grepl("H10", all.fit2$genes$ProbeName),]
dim(all.fit2)

#merge H10 GO terms with gene annotations.
targets2<-readTargets("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10annotation_new_mannualupdated.txt")
go<-readTargets("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10_blast2go_go_table_20160812_0926.txt") #blast2go h10GO.txt was generated by interproscan program.
go<-data.frame(go)
mm<-merge.data.frame(targets2,go,by="Locus",all=TRUE)
exp<-subset(mm, select=c("Locus","start"))
length(mm$GO_terms)  #It tells the total number of genes in the genome.
sum(is.na(mm$GO_terms)) #It tells the total number of genes without assigned GO terms.
out_stat<-append(out_stat,paste("No_H10genes =", length(mm$GO_terms) , sep = ""))
out_stat<-append(out_stat, paste("Percentage_expressed_genes=", 100*sum(!is.na(exp$Exp))/length(mm$GO_terms), sep = ""))
out_stat<-append(out_stat,paste("No_H10genes_w/o GO =", sum(is.na(mm$GO_terms)), sep = ""))

#merge expression status with the annotation_GO file
mm2<-merge.data.frame(mm,exp,by="Locus",all=TRUE)
write.table(mm2,file="~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/merged_GO_Exp.txt",sep="\t", row.names=F)

#export a genome-wide GO file irrespective of gene expression status
mm2<-mm2[!is.na(mm2$GO_terms),]
dim(mm2)
locus2go<-function(mm2) {
  out<-c()
  for (x in 1:length(mm2$Locus)) { 
    lo<-mm2$Locus[x]
    gg<-mm2[grepl(lo, mm2$Locus),"GO_terms"]
    gg<-strsplit(as.character(gg), ";")
    for (y in 1:length(gg[[1]])) {
      tem<-paste(lo, "=",gg[[1]][y],collapse="")
      out<-append(out, tem)
    }
  }
  return(out)
}

ok<-locus2go(mm2)
length(ok) #count genomewide GO terms assigned to genes
write.table(ok,file="~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/locus2go.txt", row.names=F,col.names=F)

#extract differentially expressed probes from pairwise comparisons to generate gene lists for Venn diagram analysis
dfgene2<-function(toptab,exp,mm,cutoff,foldchange_cuttoff,probe_percentage,MA.pAq){
  genes<-list()
  toptab<-toptab[!grepl("16S", toptab$ProbeName),]
  toptab<-toptab[!grepl(":", toptab$ProbeName),]
  toptab<-toptab[grepl("H10", toptab$ProbeName),]
  gene.id<-gsub('.*_(.*)_.*','\\1',toptab$ProbeName)
  det.p<-unique(gene.id)
  det.p<-sort(det.p, decreasing=FALSE)
  det.p<- paste("H10_",det.p,sep = "")
  all<-MA.pAq$genes$ProbeName
  all<-all[!grepl(":",all)]
  all<-all[!grepl("16S",all)]
  all<-all[grepl("H10",all)]
  anno<-read.csv("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10annotation_new_mannualupdated.csv",header=TRUE,as.is = TRUE)  
  anno<-data.frame(anno,stringsAsFactors=FALSE)
  cog<-read.csv("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10annotation.csv",header=TRUE,as.is = TRUE)  
  cog<-data.frame(cog,stringsAsFactors=FALSE)
  signal<-read.csv("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10genewithsignalP.csv",header=TRUE,as.is = TRUE)  
  operon<-read.csv("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10operon.csv",header=TRUE,as.is = TRUE)  
  cazy<-read.csv("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/hmmer_CAZY.csv",header=TRUE,as.is = TRUE)  
  cellwall<-read.csv("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/h10cellwall.csv",header=TRUE,as.is = TRUE)  
  
  go<-mm
  
  for (x in 1:length(det.p)) {
    i<-det.p[x]	
    detprobes<-toptab$ProbeName[grep(i,toptab$ProbeName)]
    allprobes<-all[grepl(i,all)]
    ratio<-length(detprobes)/length(allprobes)
    if (ratio>=probe_percentage){
      i<-gsub('.*_(.*)','\\1',i)
      cel<- paste("Ccel_",i,sep = "")
      #print(cel)
      got<-go[go$Locus==cel,"GO_terms"]
      ss<-c()
      for (y in 1:length(detprobes)) {ss<-append(ss, toptab[toptab$ProbeName==detprobes[y],"logFC"])}
      jus<- mean(ss)
      if (jus>log(foldchange_cuttoff,2)|jus<(-log(foldchange_cuttoff,2))) {
        genes$ProbeType[length(genes$ProbeType)+1]<- "u"
        genes$Operon_No[length(genes$Operon_No)+1] <-operon[grepl(cel,operon$Gene),"Operon"]
        genes$Locus[length(genes$Locus)+1]<- cel
        genes$COG[length(genes$COG)+1]<- gsub('.*[0-9](.*)','\\1',cog[cog$Locus==cel,"COG"])
        genes$GO_terms[length(genes$GO_terms)+1]<- as.character(got)              	
        genes$Product[length(genes$Product)+1]<-mm[mm$Locus==cel,"Product"]
        caz<-cazy[cazy$Gene_ID==cel, "HMM_Profile"]
        if (length(caz)==0) {
          genes$CAZYmes[length(genes$CAZYmes)+1]<- " "
        }
        else {
          caz<-paste(caz, collapse=", ")
          genes$CAZYmes[length(genes$CAZYmes)+1]<-caz
        }
        
        H10cellwall<-cellwall[cellwall$sseqid==cel, "qprotein"]
        if (length(H10cellwall)==0) {
          genes$Cell_wall[length(genes$Cell_wall)+1]<- " "
        }
        else {
          H10cellwall<-paste(H10cellwall, collapse=", ")
          genes$Cell_wall[length(genes$Cell_wall)+1]<- H10cellwall
        }
        
        sp=signal[signal$ID==cel,"SignalP"]
        if (length(sp)==0) {
          genes$SignalP4.1[length(genes$SignalP4.1)+1] <- " "
        }
        else {
          genes$SignalP4.1[length(genes$SignalP4.1)+1]<-as.character(sp)
        }
        genes$avelogFC[length(genes$avelogFC)+1]<- jus
        genes$sd_logFC[length(genes$sd_logFC)+1]<-sd(ss,na.rm=TRUE)
        genes$logvalue[length(genes$logvalue)+1]<- paste(ss,collapse =";")
        genes$detprobes[length(genes$detprobes)+1]<- paste(detprobes,collapse =";")
        genes$allprobes[length(genes$allprobes)+1]<- paste(allprobes,collapse =";")
      }
    }
  }
  return(genes)
}

t<-lapply(DE.OUT, function(x) {assign(x, topTable(all.fit2,coef=which(DE.OUT==x),number=14634,sort.by="logFC",p.value=0.05,lfc=log(foldchange_cuttoff,2),adjust.method="BH")) 
})

lapply(seq(1,length(DE.OUT),1), function(x) dim(t[[x]]))
listname<-c("Locus")
y=1

interest_set<-c("DE.CKT1","DE.CKT3","DE.CKT6","DE.CKT12","DE.S1005T1","DE.S1005T3","DE.S1005T6","DE.S1005T12","DE.S0806T1","DE.S0806T3","DE.S0806T6","DE.S0806T12")
interest_set<-c("DE.CKT3VST1","DE.CKT6VST3","DE.CKT12VST6","DE.S1005T3VST1","DE.S1005T6VST3","DE.S1005T12VST6","DE.S0806T3VST1","DE.S0806T6VST3","DE.S0806T12VST6")
interest_set<-c("DE.CKT12VST1","DE.CKT12VST3","DE.S1005T12VST1","DE.S1005T12VST3","DE.S0806T12VST1","DE.S0806T12VST3")

for (x in DE.OUT) {name_DE=paste(x,toString(foldchange_cuttoff), toString(probe_percentage),sep = "@", collapse = NULL)
di_DE=paste("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/",name_DE,".csv", sep = "", collapse = NULL)
dfgene.in<-dfgene2(t[[which(DE.OUT==x)]],exp,mm,expression_cuttoff,foldchange_cuttoff,probe_percentage,MA.pAq)
write.csv(dfgene.in,file=di_DE, row.names=F)
dfgene.in<-data.frame(dfgene.in)
if (any(interest_set==x)){
  listname=append(listname,x)
  if (y==1){out1<-dfgene.in[grepl("hmm",dfgene.in$CAZYmes), c("Locus","avelogFC")]
  out2<-dfgene.in[grepl("_",dfgene.in$Cell_wall), c("Locus","avelogFC")]
  y=y+1}
}
else {out1<-merge(out1, dfgene.in[grepl("hmm",dfgene.in$CAZYmes), c("Locus","avelogFC")], "Locus", all=TRUE)
out2<-merge(out2, dfgene.in[grepl("_",dfgene.in$Cell_wall), c("Locus","avelogFC")], "Locus", all=TRUE)
y=y+1}
}


colnames(out1)<-listname
out1 <-out1[order(substr(out1$Locus,6,9)),]
dim(out1)
out1

colnames(out2)<-listname
out2 <-out2[order(substr(out2$Locus,6,9)),]
dim(out2)
out2


colnames(out1)<-listname
out1 <-out1[order(substr(out1$Locus,6,9)),]
dim(out1)
out1

colnames(out2)<-listname
out2 <-out2[order(substr(out2$Locus,6,9)),]
dim(out2)
out2

for (x in DE.OUT) { name_DE=paste(x,toString(foldchange_cuttoff), toString(expression_cuttoff),sep = "@", collapse = NULL)
di_DE=paste("~/Incubation_cellulose_microarray results_07042020/0630incubation100%/final/",name_DE,".csv", sep = "", collapse = NULL)
dfgene.in<-dfgene2(t[[which(DE.OUT==x)]],exp,mm,expression_cuttoff,foldchange_cuttoff,probe_percentage,MA.pAq)
write.csv(dfgene.in,file=di_DE, row.names=F)
dfgene.in<-data.frame(dfgene.in)
if (any(interest_set==x)) {
  listname=append(listname,x)
  if (y==1){interest_out<-dfgene.in[grepl("hmm",dfgene.in$CAZYmes), c("Locus","avelogFC")]
  out2<-dfgene.in[!grepl(" ",dfgene.in$Cell_wall), c("Locus","avelogFC")]
  y=y+1}
}
else {
  interest_out<-merge(interest_out, dfgene.in[grepl("hmm",dfgene.in$CAZYmes), c("Locus","avelogFC")], "Locus", all=TRUE)
  out2<-merge(out2, dfgene.in[!grepl(" ",dfgene.in$Cell_wall), c("Locus","avelogFC")], "Locus", all=TRUE)
  y=y+1
}
}
colnames(interest_out)<-listname
interest_out <-data.frame(interest_out)
interest_out <-interest_out[order(substr(interest_out$Locus,6,9)),]

