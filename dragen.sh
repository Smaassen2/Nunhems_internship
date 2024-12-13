crop=$1
variant=$2
study_accession=$3
run_accession=$4

# This script executes the Dragen analysis

cd /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant"/"$study_accession"
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant"/"$study_accession"/"$run_accession"

if [[ "$crop" == "Okra" ]] || [[ "$crop" == "Bottle_Gourd" ]]; then
	ref_load_hash_bin=true
	dragen_dir="/data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant"/dragen"
else
	ref_load_hash_bin=false
	dragen_dir="/data/prod/Tools/VariantRepository/prod/resources/map/"$crop"/"$variant"/dragen/"
fi

/opt/edico/bin/dragen -r "$dragen_dir" \
-1 "$run_accession"_1.fastq.gz \
-2 "$run_accession"_2.fastq.gz \
--RGID "$run_accession" \
--RGSM "$run_accession" \
--output-directory ./"$run_accession" \
--output-file-prefix "$run_accession" \
--enable-map-align-output true \
--enable-duplicate-marking true \
--output-format BAM \
--enable-rna true \
--ref-load-hash-bin="$ref_load_hash_bin"
