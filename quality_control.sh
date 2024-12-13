taxon=$1

# This script loops over all species of a taxon to perform OMArk

# Make OMArk directories for storing OMArk results
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/omamer
mkdir /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_quality

# Perform OMArk on all NCBI proteomes of species of a certain taxon
for species_dir in /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/ncbi_refseq_dataset/data/*/
do
        qig NCBI_OMArk.sh "$taxon" "$species_dir" -zmem 10G -zslots 4
done
