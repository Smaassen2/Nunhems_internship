taxon=$1
completeness_threshold=$2
consistency_threshold=$3

# This script finds the NCBI gene models that are of high quality and stores these in a new directory

# Association array keeps track of which GCF of a species is the best scoring in OMArk
declare -A best_species_occurence_dict


for detailed_summary in /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_quality/*OMArk_quality/*_detailed_summary.txt
do
	# Get completeness% and consistency% from detailed_summary file
	missing_perc="$(grep "Missing" "$detailed_summary" | cut -d "(" -f2 | cut -d "%" -f1)"
        completeness_perc=$(echo "(100-$missing_perc)"| bc -l)
	consistency_perc="$(grep "Total Consistent" "$detailed_summary" | cut -d "(" -f2 | cut -d "%" -f1)"
	
	# Check if completeness% and consistency% meet the defined thresholds
	if (($(echo ""$completeness_perc" > "$completeness_threshold"" |bc -l) )) && (( $(echo ""$consistency_perc" > "$consistency_threshold"" |bc -l) )); then
		
		OMArk_quality_dir=$(dirname "$detailed_summary")
		species_accession=$(basename "$detailed_summary")
		species_name="$(echo "$species_accession" |grep -oP ".*(?=_GCF_)")"
		
		# Add entry to association array if species name is not in the association array
		if [ ! -v best_species_occurence_dict["$species_name"] ]; then
			best_species_occurence_dict["$species_name"]=""$OMArk_quality_dir" "$completeness_perc" "$consistency_perc""
		# Compare assemblies of the same species and keep the one with higher completeness% + consistency%
		else
			read -a species_value_array <<< ""${best_species_occurence_dict["$species_name"]}""
			new_quality_score=$(echo "$completeness_perc"+"$consistency_perc" | bc)
			old_quality_score=$(echo "${species_value_array[1]}"+"${species_value_array[2]}" | bc)
			
			if (($(echo "$new_quality_score > $old_quality_score" | bc -l))); then
				best_species_occurence_dict["$species_name"]=""$OMArk_quality_dir" "$completeness_perc" "$consistency_perc""
			fi
		fi
	fi
done

# Copy the filtered proteome dataset to a seperate directory
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/protein_database/
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/protein_database/proteomes
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/OMArk_quality
for i in "${!best_species_occurence_dict[@]}"
do
	read -a species_value_array <<< "${best_species_occurence_dict[$i]}"
	cp -r "${species_value_array[0]}" /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/OMArk_quality
	OMArk_quality_dir=$(basename "${species_value_array[0]}")
	protein_dir="${OMArk_quality_dir#*GCF}"
	protein_dir="GCF$protein_dir"	
	protein_dir="${protein_dir%%_OMArk_quality*}"
	cp /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/ncbi_refseq_dataset/data/"$protein_dir"/protein.faa /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/protein_database/proteomes/"$protein_dir".faa
done

# Make the protein database
cat /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/protein_database/proteomes/* > /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/protein_database/"$taxon"_protein_database.faa
