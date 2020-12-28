#!/bin/bash

# WES_Angel_GB_GEMM_CNV_calling_CNVkit.sh
#
# script to take aligned WES reads and do CNVkit CNV calling on them
#
# 20201228
# by Mike
#
# (code from ipynb 20191126)
#
###########################################################################
# cluster job settings
###########################################################################
#
# decent-sized job: can parallelise #cores highly in each sample (per-chr calcs I guess?) or across samples 
#	 	qsub -I -l walltime=24:00:00,mem=32g,nodes=1:ppn=24
#
# need modules:
# load Python 3 module used during installation of CNVkit as a virtualenv:
# 		module load Python/3.7.0-foss-2018b
# activate the CNVkit virtualenv:
#   	source /icgc/dkfzlsdf/analysis/B060/fletcher/RNAseq_Angel_GB_GEMMs/tools/CNVkit/env_CNVkit/bin/activate
# load R 3.5.1 for segmentation step:
#		module load R-bundle/20180702-foss-2017a-R-3.5.1
#
###########################################################################
# define paths for analysis:
###########################################################################
# base dir for analysis
BASE_DIR="/icgc/dkfzlsdf/analysis/B060/fletcher/RNAseq_Angel_GB_GEMMs/"
# analysis output dir - for this run today
OUTPUT_DIR="${BASE_DIR}/analysis/CNVkit_WES_panelNormals"
mkdir -p ${OUTPUT_DIR} # create output dir.
# genome fasta file, use mm10
GENOME_FA="/icgc/ngs_share/assemblies/mm10/indexes/bwa/bwa06/bwa06_GRCm38mm10/GRCm38mm10.fa"
# capture regions for the sureselect; use the one in the ngs_share and symlinked
TARGET_REGIONS="${BASE_DIR}/annotation/S0276129_Covered_mm10_liftover_nochr.bed"
# flat annotation file (from UCSC) for target region annotation
ANNO_FLAT="${BASE_DIR}/annotation/mm10_refFlat_nochr.txt"

###############
# calculate an accessibility file 
###############
cnvkit.py access ${GENOME_FA} -s 10000 -o ${OUTPUT_DIR}/access-10kb.mm10.bed

###############
# now run the 'batch' mode:
#
# 20191127: add in the additional normals
###############
# define normals:
# first get from our analysis, remove the library ID _015_
NORMAL_BAMS=$(echo -e $(ls ${BASE_DIR}/bwa/*/*_NOR_*.sorted.mdup.bam | grep -v _015_) $(ls /icgc/dkfzlsdf/analysis/B060/chromothripsis/results/mMB_mice/results_per_pid/mMBc_WR_MP_*/alignment/control_brain*merged.mdup.bam) )
# run:
cnvkit.py batch ${BASE_DIR}/bwa/*/*_DIS_*.sorted.mdup.bam \
--normal ${NORMAL_BAMS} \
--processes 24 --targets ${TARGET_REGIONS} --fasta ${GENOME_FA} \
--output-reference ${BASE_DIR}/CNVkit_WES/CNVkit_reference_panelNormals.cnn \
--access ${OUTPUT_DIR}/access-10kb.mm10.bed \
--annotate ${ANNO_FLAT} --drop-low-coverage \
--output-dir ${OUTPUT_DIR} --scatter --diagram

# save copy of the cnrs in case shit hits the fan, which it always seems to, with this analysis
mkdir ${OUTPUT_DIR}/cnrs_backup
cp ${OUTPUT_DIR}/*.cnr ${OUTPUT_DIR}/cnrs_backup

###############
# now need to call segments for all the individual .cns files, produce output .call.cns files:
#
# as per https://cnvkit.readthedocs.io/en/stable/tumor.html 
#
# i can't figure this out, so just run call without any options irght now, sigh
###############
# define samples to process: input .cnr files, save as a text file
ls ${OUTPUT_DIR}/*.cnr | sed s/.cnr// > ${OUTPUT_DIR}/sample_list
#
# now for each of the next steps:
# parallelise with freakin XARGS!!! with 1 cpu each
#
# do segmentation calling
cat ${OUTPUT_DIR}/sample_list | xargs -P 12 -I '{}' \
  bash -c "echo '{}'; cnvkit.py call '{}'.cnr -o '{}'.call.cns" 

# per Pavle's request: write "genemetrics"
SAMPLES=( $(cat ${OUTPUT_DIR}/sample_list) )
for s in ${SAMPLES[@]}
do
  cnvkit.py genemetrics ${s}.cnr -s ${s}.cns -o ${s}_genemetrics.txt
done

# output per-sample scatter: with trend line + defined ylims
for s in ${SAMPLES[@]}
do
  cnvkit.py scatter ${s}.cnr -s ${s}.cns -t --y-min -4 --y-max 4 -o ${s}_scatter_polished.png
done

###############
# do whole-cohort heatmap also
###############
# make heatmap, -d: scale to remove spurious CNAs; output to this dir
cnvkit.py heatmap ${OUTPUT_DIR}/*.mdup.cns -d -o ${OUTPUT_DIR}/$(date -I)_GB_GEMMs_CNVkit_heatmap.pdf