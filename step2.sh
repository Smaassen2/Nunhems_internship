crop=$1
variant_name=$2
taxon=$3
completeness_threshold=$4
consistency_threshold=$5

# This script performs the gene prediction pipelines

# Make the directory where all the pipelines will be stored
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines

# Make the pipeline directories for gene prediction pipelines that do not use RNA-seq data
for method in BRAKER3_ab_initio BRAKER3_RNA_seq BRAKER3_protein_database BRAKER3_both Helixer
do
	if [[ "$method" != BRAKER3_RNA_seq && "$method" != BRAKER3_both ]]; then
		mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"
        	mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/"$method"_output
		# Copy unmodifed Augustus config into BRAKER3 pipeline directories
        	if [[ "$method" == "BRAKER3"* ]]; then
                	cp -r /data/workspace/u10103530/tools/Augustus/config/ /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/Augustus_config
        	fi
	fi
done

# Define path to the protein database of the specified taxon that does not include the species itself
declare -A species_protein_database
species_protein_database["Artichoke"]="/data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/Cynara_cardunculus_var._scolymus_removed/protein_database/"$taxon"_protein_database.faa"
species_protein_database["Pepper"]="/data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/Capsicum_annuum_removed/protein_database/"$taxon"_protein_database.faa"
species_protein_database["Tomato"]="/data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/Solanum_lycopersicum_removed/protein_database/"$taxon"_protein_database.faa"

if [[ -v "species_protein_database["$crop"]" ]]; then
        protein_database="${species_protein_database["$crop"]}"
else
        protein_database="/data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/protein_database/"$taxon"_protein_database.faa"
fi

# BRAKER3 ab initio
qig singularity exec --bind /data/workspace/u10103530 --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship --bind /data/run/Tools/tmp/users/u10103530 /data/workspace/u10103530/tools/Braker3/braker3.sif braker.pl --genome=/data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked --AUGUSTUS_CONFIG_PATH=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_ab_initio/Augustus_config --workingdir=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_ab_initio/BRAKER3_ab_initio_output --species="$crop" --gff3 --threads 20 -zmem 50G -zslots 20

# BRAKER3 protein database
qig singularity exec --bind /data/workspace/u10103530 --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship --bind /data/run/Tools/tmp/users/u10103530 /data/workspace/u10103530/tools/Braker3/braker3.sif braker.pl --genome=/data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked --prot_seq="$protein_database" --AUGUSTUS_CONFIG_PATH=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_protein_database/Augustus_config --workingdir=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_protein_database/BRAKER3_protein_database_output --species="$crop" --gff3 --threads 20 -zmem 50G -zslots 20

# Certain variants did not have RNA-seq data available directly. The RNA-seq data for these variants was made using Dragen and stored in /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant_name"/RNA_seq_bams
# BRAKER3 takes bam files as one long list seperated by commas, therefore this variable is defined as such.
if [ -d /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams/"$crop"/"$variant_name" ]; then
        bam_files=$(ls -d /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams/"$crop"/"$variant_name"/* | tr '\n' ',')
else
        bam_files=$(ls -d /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant_name"/RNA_seq_bams/* | tr '\n' ',')
fi

# BRAKER3 RNA-seq
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_RNA_seq
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_RNA_seq/BRAKER3_RNA_seq_output
# Copy unmodifed Augustus config into BRAKER3 RNA-seq pipeline directory
cp -r /data/workspace/u10103530/tools/Augustus/config/ /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_RNA_seq/Augustus_config

qig singularity exec --bind /data/workspace/u10103530 --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship --bind /data/run/Tools/tmp/users/u10103530 --bind /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq /data/workspace/u10103530/tools/Braker3/braker3.sif braker.pl --genome=/data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked --bam="$bam_files" --AUGUSTUS_CONFIG_PATH=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_RNA_seq/Augustus_config --workingdir=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_RNA_seq/BRAKER3_RNA_seq_output --species="$crop" --gff3 --threads 20 -zmem 50G -zslots 20

# BRAKER3 RNA-seq + protein database
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_both
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_both/BRAKER3_both_output
# Copy unmodifed Augustus config into BRAKER3_both pipeline directory
cp -r /data/workspace/u10103530/tools/Augustus/config/ /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_both/Augustus_config
qig singularity exec --bind /data/workspace/u10103530 --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship --bind /data/run/Tools/tmp/users/u10103530 --bind /data/prod/Projects/Vegetables/BioInformatics/XXX/RNA_seq_bams --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq /data/workspace/u10103530/tools/Braker3/braker3.sif braker.pl --genome=/data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked --prot_seq="$protein_database" --bam="$bam_files" --AUGUSTUS_CONFIG_PATH=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_both/Augustus_config --workingdir=/data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/BRAKER3_both/BRAKER3_both_output --species="$crop" --gff3 --threads 20 -zmem 50G -zslots 20

# Helixer
qig singularity run --bind /data/workspace/u10103530 --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship --bind /data/run/Tools/tmp/users/u10103530 --nv /data/workspace/u10103530/tools/Helixer/helixer-docker_helixer_v0.3.3_cuda_11.8.0-cudnn8.sif Helixer.py --fasta-path /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked --lineage land_plant --gff-output-path /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/Helixer/Helixer_output/"$variant_name"_Helixer.gff3 -zmem 400G -zslots 1 -zqueue gpu.l40 -zgpu -zgpuslots 4
