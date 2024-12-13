crop=$1
variant_name=$2
method=$3

ml gffread
ml OMArk/0.3.0
ml BUSCO

# This script performs quality assessment on the gene models of the gene prediction pipelines

# Rename BRAKER3 gff3 files
if [[ "$method" == "BRAKER3"* ]]; then
	mv /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/"$method"_output/braker.gff3 /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/"$method"_output/"$variant_name"_"$method".gff3
fi

# Only keep the longest isoforms in the gene model
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/AGAT
# The cd command is needed so that the AGAT log file is in the AGAT directory
cd /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/AGAT
singularity run --bind /data/workspace/u10103530 --bind /data/run/Projects/Vegetables/XXX/Shahiel_internship --bind /data/run/Tools/tmp/users/u10103530 /data/workspace/u10103530/tools/AGAT/agat_1.0.0--pl5321hdfd78af_0.sif agat_sp_keep_longest_isoform.pl -f /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/"$method"_output/"$variant_name"_"$method".gff3 [ -o /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/AGAT/"$variant_name"_"$method"_longest_isoforms.gff3 ]

# Derive protein sequences from the gene model and reference genome
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/gffread
gffread /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/AGAT/"$variant_name"_"$method"_longest_isoforms.gff3 -g /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked -y /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/gffread/"$variant_name"_"$method"_longest_isoforms.faa

# Compare protein sequences derived from the gene model against all known protein sequences using OMArk
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/OMArk
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/OMArk/omamer
omamer search --db /data/workspace/u10103530/tools/OMArk/LUCA.h5 --query /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/gffread/"$variant_name"_"$method"_longest_isoforms.faa --out /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/OMArk/omamer/"$variant_name"_"$method"_longest_isoforms.omamer

# Create OMArk stats/reports/images
omark -f /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/OMArk/omamer/"$variant_name"_"$method"_longest_isoforms.omamer -d /data/workspace/u10103530/tools/OMArk/LUCA.h5 -o /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/OMArk/"$variant_name"_"$method"_longest_isoforms_OMArk_quality

mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/OMArk
cp -r /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/OMArk/"$variant_name"_"$method"_longest_isoforms_OMArk_quality /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/OMArk
 
# Run BUSCO
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/BUSCO
cd /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/BUSCO
busco -i /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/gffread/"$variant_name"_"$method"_longest_isoforms.faa -c 4 -o "$variant_name"_"$method"_longest_isoforms_BUSCO_quality -m prot -l eudicots_odb10 -f

mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/BUSCO
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/BUSCO/short_summaries
cp /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/pipelines/"$method"/quality_assessment/BUSCO/"$variant_name"_"$method"_longest_isoforms_BUSCO_quality/short_summary*.txt  /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/BUSCO/short_summaries
