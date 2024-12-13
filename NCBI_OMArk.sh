taxon=$1
species_dir=$2

ml OMArk/0.3.0

# This script performs OMArk

# Get the scientific name of the species and the assembly accession
species_name_assembly_accession=$(python /data/workspace/u10103530/refseq_ncbi_data/get_species_names.py /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/ncbi_refseq_dataset/data/data_summary.tsv "$species_dir")

# Compare protein sequences derived from gene model against all known protein sequences
omamer search --db /data/workspace/u10103530/tools/OMArk/LUCA.h5 --query "$species_dir"protein.faa --out /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/omamer/"$species_name_assembly_accession".omamer

# Create OMArk stats/reports/images
omark -f /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/omamer/"$species_name_assembly_accession".omamer -d /data/workspace/u10103530/tools/OMArk/LUCA.h5 -o /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_quality/"$species_name_assembly_accession"_OMArk_quality
