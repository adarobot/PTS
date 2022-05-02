# PTS
The phosphoenolpyruvate (PEP) :carbohydrate phosphotransferase system (PTS) is mainly involved in the uptake of carbohydrates and regulation of microbial metabolism. Here we performed genome mining for PTS relevant components in sequenced prokaryotic genomes. The number of homologs in each genome was examined by hmm search (E<0.01) against the in-house protein database, and then grouped into two categories based on protein architecture, including singular or modulary/fused forms. Counts of each architecture-specific homolog in each genome, along with corresponding genome identification and taxonomic information, were summarized in a single master file for visualization and additional analyses.<br/>


**Step 1 Genome mining using Ubuntu/linux scripts**

  1.1 Mannually download hmm files from PDB database (https://www.rcsb.org/). PTS relevant hmm files have been pre-installed here in the folder, 'hmm_files'.
  
  1.2 Run the following script to download protein sequences from sequenced prokaryotes (including bacteria and archaea) from NCBI database. Only complete genomes are downloaded and included for downstream analysis. This funtion will generates five files in the folder, 'in_files'. The indexed protein database from all downloaded genomes is named "indexed_merged_protein.fas".
  
  ```ruby
  source download_from_NCBI.sh
  ```
  
  1.3 Perform the hmmsearch function for each hmm file by running the follow command. It will generate a ready-to-process output for each hmm query, which is located in the directory, './hmm_out/hmm_raw'.

  ```ruby
  sh batch_hmmsearch.sh -q ./hmm_files -o ./hmm_out/hmm_raw -d ./in_files/indexed_merged_protein.faa
  ```
  
  
  1.4 Optional: Download processed_out outputs to your local computer if you run genome mining on a server. <br/>
  
  
  
**Step 2 Data processing using R scripts**
  
     2.1 Download this R folder and set your R working directory to this folder. 
  
     2.2 Transfer hmm outputs that are postfixed with processed_out to the folder, tbl_processed.
  
     2.3 Download the list of genomes anlayzed by step 1 from the aforementioned folder, in_files. There are two files including assembly_summary_bacteria.txt and assembly_summary_archaea.txt. Then, move these files to the folder, genome_list. 
  
     2.4 Run the R script, hmm_search_data_matrix.R. It will collect the taxonomic information for all genomes by using taxize, then save it to the folder, taxonomy. In the end, it generate a single output file containing the number of each hmm per genome, genome ID, and  corresponding taxnomic information.<br/>
  
  
  
**Step 3 Data visualization and statistics**
   
     3.1 Use iTOL (https://itol.embl.de/) to make the phylogenetic tree. The abundance of PTS components are incorporated into different tracks.
   
     3.2 The integrated visualization of a heatmap showing averaged counts of each hmm profiles in genomes of all Classes, and their phylogeny displayed by cladogram, is plotted by complex heatmap.
  

