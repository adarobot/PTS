#!/bin/bash

#download from NCBI
wget -o ./in_files/assembly_summary_bacteria.txt ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/bacteria/assembly_summary.txt 
#cp assembly_summary.txt ./in_files/assembly_summary_bacteria.txt

wget -o ./in_files/assembly_summary_archaea.txt ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/archaea/assembly_summary.txt
#cp assembly_summary.txt ./in_files/assembly_summary_archaea.txt
#rm assembly_summary.txt

#generate wget links for each genome
awk -F "\t" '$12=="Complete Genome"{print $20}' ./in_files/assembly_summary_bacteria.txt > ./in_files/ftp_folder_bacteria.txt
awk 'BEGIN{FS=OFS="/";filesuffix="protein.faa.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print "wget "ftpdir,file}' ./in_files/ftp_folder_bacteria.txt > ./in_files/faa_files_bacteria.sh

awk -F "\t" '$12=="Complete Genome"{print $20}' ./in_files/assembly_summary_archaea.txt > ./in_files/ftp_folder_archaea.txt
awk 'BEGIN{FS=OFS="/";filesuffix="protein.faa.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print "wget "ftpdir,file}' ./in_files/ftp_folder_archaea.txt > ./in_files/faa_files_archaea.sh

#download faa files from NCBI
echo downloading...
source ./in_files/faa_files_archaea.sh > ./in_files/download_log
#source ./in_files/faa_files_bacteria.sh >./in_files/download_log
#mv *.gz ./in_files
gzip -d *.gz
echo merging indexed faa...
#add genome index to each faa
awk '/>/ {$0=$0" "FILENAME}1' *protein.faa > ./in_files/indexed_merged_protein.faa 
rm -r GCA*.faa
#rm assembly*
echo Finished!!!
