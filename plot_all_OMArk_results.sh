taxon=$1
completeness_threshold=$2
consistency_threshold=$3

ml matplotlib

# This script plots the unfiltered proteome dataset and the filtered proteome dataset of a certain taxon using OMArk

/data/workspace/u10103530/tools/OMArk/plot_all_results.py -i /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_quality -o /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_quality/"$taxon"_omark.png

/data/workspace/u10103530/tools/OMArk/plot_all_results.py -i /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/OMArk_quality -o /data/workspace/u10103530/refseq_ncbi_data/ncbi_"$taxon"_dataset/OMArk/OMArk_"$completeness_threshold"_"$consistency_threshold"_quality/all_species/OMArk_quality/"$taxon"_omark.png
