crop=$1
variant_name=$2

ml miniprot
ml BUSCO
ml MultiQC/1.14

#This script combines the OMArk quality assessments from the different gene methods into one image. After BUSCO is applied to the reference genome, the same is done for BUSCO.

# Plot multiple OMArk results in order to compare them against each other
/data/workspace/u10103530/tools/OMArk/plot_all_results.py -i  /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/OMArk -o /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/OMArk/"$variant_name"_omark.png

# Perform BUSCO on reference genome so it can be used as a benchmark
if [ ! -d /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources ]; then
	mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources
fi

mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources/Nunhems
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources/Nunhems/quality_assessment
mkdir /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources/Nunhems/quality_assessment/BUSCO

cd /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources/Nunhems/quality_assessment/BUSCO
busco -i /data/workspace/u10103530/data_structured/"$crop"/"$variant_name"/repeatmasking/RepeatMasker/"$variant_name".fa.masked -c 4 -o "$variant_name"_Nunhems_BUSCO_quality -m geno -l eudicots_odb10 -f

cp /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/sources/Nunhems/quality_assessment/BUSCO/"$variant_name"_Nunhems_BUSCO_quality/short_summary*.txt /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/BUSCO/short_summaries

# Plot multiple BUSCO results using MultiQC in order to compare them against the reference genome
cd /data/run/Projects/Vegetables/XXX/Shahiel_internship/"$crop"/"$variant_name"/quality_assessment/BUSCO
multiqc ./
