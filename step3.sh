crop=$1
variant_name=$2

# This script loops over all files on which quality assessment needs to be performed

# Perform quality control on the gene models of the gene prediction pipelines
for method_path in /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/*
do
        method=$(basename "$method_path")
	qig step4_pipelines.sh "$crop" "$variant_name" "$method" -zmem 50G -zslots 20
done

# Perform quality control on Nunhems sourced gene model and on NCBI gene model if available
for gff3_source in NCBI sourced
do
	if [ -f /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/sources/"$gff3_source"/*.gff* ]; then
		qig step4_gff3_source.sh "$crop" "$variant_name" "$gff3_source" -zmem 50G -zslots 20
	fi
done
