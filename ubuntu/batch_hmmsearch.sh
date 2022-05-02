#!/bin/bash
while getopts q:o:d: flag
do
    case "${flag}" in
        q) hmmfile_dir=${OPTARG};; ### the directory to hmm files
        o) out_dir=${OPTARG};; ###the directory to save outputs
        d) database=${OPTARG};; ###database should be the indexed_merged_protein.faa
    esac
done

function linebreaks_removal {
	awk '!/^#/' $1 | tr -d "\n" | awk '{gsub(".faa", "\n", $0)}1'
	echo  $0
}

FILES=$hmmfile_dir/*.hmm
for f in $FILES
do
	file=$(basename $f)
	echo processing $file	
	tbl_file=$out_dir"/tbl_"$file".out"
	std_output=$out_dir"/"$file"_e0.01.out"
	hmmsearch --cpu 8 -E 0.01 --textw 300 --tblout $tbl_file $f $database > $std_output
	linebreaks_removal $tbl_file > $out_dir"/tbl_"$file"_processed.out"
	#rm $tbl_file

done

rm $out_dir/*_e0.01.out
echo Finished!!!

# an exmaple to execute 'sh batch_hmmsearch.sh -q ./hmm_files -o ./hmm_out/hmm_raw -d ./in_files/indexed_merged_protein.faa'
