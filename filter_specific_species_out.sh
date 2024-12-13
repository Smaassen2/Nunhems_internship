taxon=$1
species=$2
completeness=$3
consistency=$4

# This script is used to remove a species from a proteome dataset on which gene prediction will be performed. This is needed because it will prevent bias during gene prediction.

# Copy OMArk quality directories and the proteomes
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed
cp -r /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/all_species/OMArk_quality /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed/protein_database
cp -r /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/all_species/protein_database/proteomes /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed/protein_database/proteomes

# Get directory belonging to the unneeded species
for OMArk_quality_dir_path in /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed/OMArk_quality/*
do
	OMArk_quality_dir_name="$(basename "$OMArk_quality_dir_path")"
	if [[ "$OMArk_quality_dir_name" == "$species"*  ]]; then		
		IFS='_' read -ra OMArk_quality_dir_name_array <<< "$OMArk_quality_dir_name"
		GCF="${OMArk_quality_dir_name_array[$((len - 4))]}_${OMArk_quality_dir_name_array[$((len - 3))]}"
		unneeded_OMArk_quality_dir_path="$OMArk_quality_dir_path"
	fi
done

# Remove files belonging to the unneeded species
rm -r "$unneeded_OMArk_quality_dir_path"
rm /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed/protein_database/proteomes/"$GCF".faa

# Make the protein database that excludes the unneeded species
cat /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed/protein_database/proteomes/* > /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness"_"$consistency"_quality/"$species"_removed/protein_database/"$taxon"_protein_database.faa
