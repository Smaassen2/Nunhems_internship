crop=$1
variant_name=$2

# This script build the RNA hashtable

/opt/edico/bin/dragen --build-hash-table true \
--ht-reference /data/prod/Tools/VariantRepository/prod/resources/map/"$crop"/"$variant_name"/"$variant_name".fa \
--output-directory  /data/run/Projects/Vegetables/XXX/Shahiel_internship_fastq/"$crop"/"$variant_name"/dragen \
--ht-build-rna-hashtable true \
--ht-write-hash-bin=1
