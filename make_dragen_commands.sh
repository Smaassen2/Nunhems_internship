crop=$1
variant=$2

# This script executes the dragen.sh script for all fastq files for a given crop variant

for study_accession_dir in /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant"/*
do
	for run_accession_dir in "$study_accession_dir"/*
	do
		if [[ "$run_accession_dir" == *"_1.fastq.gz"* ]]; then
			run_accession=$(basename "$run_accession_dir")
			run_accession="$(echo "$run_accession" | cut -d '_' -f1)"
			study_accession=$(basename "$study_accession_dir")
			qig ./dragen.sh "$crop" "$variant" "$study_accession" "$run_accession" -zqueue illumina.dragen -zslots 40 -zmem 240G -zasync
		fi
	done
done
