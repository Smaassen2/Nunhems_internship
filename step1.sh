crop=$1
variant_name=$2

ml SAMtools

# This script sets up files and directories that are needed for gene prediction

# Make a directory for the variant
mkdir /data/workspace/u10103530/data_structured/"$crop"
mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"

# Get genome sequence and sourced gff3 files
mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources
mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/Nunhems
cp /data/prod/Tools/VariantRepository/prod/resources/map/"$crop"/"$variant_name"/"$variant_name".fa /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/Nunhems

if [ -f /data/prod/Tools/VariantRepository/prod/resources/map/"$crop"/"$variant_name"/"$variant_name".gff3 ]; then
	mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/sourced
	cp /data/prod/Tools/VariantRepository/prod/resources/map/"$crop"/"$variant_name"/"$variant_name".gff3 /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/sourced
fi

# Link the crops to their NCBI gene model file if available
declare -A variant_NCBI_files
variant_NCBI_files["CUCSA_ChineseLong9930_chr_3_0"]="/data/prod/Tools/VariantRepository/prod/Apollo_custom/ncbi_refseq/CUCSA_9930_3/CUCSA_9930_3_ncbi_refseq.gff"
variant_NCBI_files["LACSA_Salinas_chr_11_0"]="/data/prod/Tools/VariantRepository/prod/Apollo_custom/ncbi_refseq/LACSA_11/LACSA_11_ncbi_refseq.gff"

if [[ -v "variant_NCBI_files["$variant_name"]" ]]; then
	ncbi_gene_model_path="${variant_NCBI_files["$variant_name"]}"
	mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/NCBI
	cp "$ncbi_gene_model_path" /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/NCBI
fi

# Convert Cram to Bam using Samtools
mkdir /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams
if [ -d /data/prod/Tools/VariantRepository/prod/resources/analysis/"$crop"/"$variant_name"/rna_seq_sample_dragen ]; then
	mkdir /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams/"$crop"
	mkdir /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams/"$crop"/"$variant_name"
	for vsda_dir in /data/prod/Tools/VariantRepository/prod/resources/analysis/"$crop"/"$variant_name"/rna_seq_sample_dragen/*
	do
		if [ -f "$vsda_dir"/*.bam ]; then
			qig cp "$vsda_dir"/*.bam /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams/"$crop"/"$variant_name"
		else
			file_path="$(ls "$vsda_dir"/*.cram)"
			cram_filename=$(basename "$file_path")
			qig samtools view -b -T /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/Nunhems/"$variant_name".fa -o /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams/"$crop"/"$variant_name"/"${cram_filename%cram}bam" "$file_path"
		fi
	done
fi

# Make directories for repeat masking
mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking
mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatModeler
mkdir /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker

# Copy the template repeat masking file into the repeat masking directory of the variant
cp /data/workspace/u10103530/scripts/complete_pipeline/repeatmasking.sh /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking

# Perform repeat masking
qig singularity exec --bind /data/workspace/u10103530/ --bind /data/run/Tools/tmp/users/u10103530 /data/workspace/u10103530/tools/TETools/dfam-tetools-latest.sif /bin/sh /data/workspace/u10103530/data_structured/$crop/$variant_name/repeatmasking/repeatmasking.sh "$crop" "$variant_name" --threads 100 -zmem 400G -zslots 100
