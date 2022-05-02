# PTS
The phosphoenolpyruvate (PEP) :carbohydrate phosphotransferase system (PTS) is mainly involved in the uptake of carbohydrates and regulation of microbial metabolism. Here we performed genome mining for PTS relevant components in sequenced prokaryotic genomes.


Step 1 Genome mining using Ubuntu/linux scripts

  1.1 Mannually download hmm files from database. PTS relevant hmm files have been pre-installed here in the folder, '''hmm_files'''.
  
  1.2 Run the following script to download protein sequences from sequenced prokaryotes (including bacteria and archaea) from NCBI database. Only complete genomes are downloaded and included for downstream analysis. This funtion will generates five files in the folder '''in_files'''. The indexed protein database from all downloaded genomes is named "indexed_merged_protein.fas".
  
  '''
  source download_from_NCBI.sh
  '''
  
  1.3 Perform the hmmsearch function for each hmm file by running the follow command. It will generate a ready-to-process output for each hmm query, which is located in the directory, '''./hmm_out/hmm_raw'''.
  
  1.4 Optional: Download processed_out outputs to your local computer if you run genome mining on a server. 
  
Step 2 Data processing using R scripts
  2.1 T

