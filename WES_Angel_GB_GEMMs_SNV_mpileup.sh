#!/bin/bash

# WES_Angel_GB_GEMMs_SNV_mpileup.sh
#
# script to take WES calls and do basic SNV calling on the Idh1/2 mutation hotspots
#		using bcftools mpileup
#
# 20201228
# by Mike
#
# (code from ipynb 20200117)
#
###########################################################################
# cluster job settings
###########################################################################
#
# small job; v. quick as only a single position (Idh mut hotspots)
# qsub -I -l walltime=24:00:00,mem=8g,nodes=1
# module load BCFtools/1.9-foss-2017a # BCFtools for mpileup
# module load matplotlib # for visualisation
#
###########################################################################
# define paths for analysis:
###########################################################################
# mm10 fasta reference for bcftools mpileup:
REFERENCE_FA="/icgc/ngs_share/assemblies/mm10/sequence/GRCm38mm10/GRCm38mm10.fa"
# use previous output dir
OUTPUT_DIR="/icgc/dkfzlsdf/analysis/B060/fletcher/RNAseq_Angel_GB_GEMMs/mpileup_Idh1-2_hotspots/"

# go to dir with input bams:
cd /icgc/dkfzlsdf/analysis/B060/fletcher/RNAseq_Angel_GB_GEMMs/bwa/

# find input .sorted.mdup.bams, store as array
INPUTS=( $(find ${PWD} -name *sorted.mdup.bam ) )

# do calling on the hotspots
bcftools mpileup -Ou --regions 1:65170977-65170979,7:80099112-80099114,7:80099016-80099018 --fasta-ref ${REFERENCE_FA} ${INPUTS[@]} | bcftools call -c \
            > ${OUTPUT_DIR}/GB_GEMMs_Idh1-Idh2_hotspots_SNV_calling_WES.vcf
            
# calculate stats:
bcftools stats -F ${REFERENCE_FA} -s - ${OUTPUT_DIR}/GB_GEMMs_Idh1-Idh2_hotspots_SNV_calling_WES.vcf > ${OUTPUT_DIR}/GB_GEMMs_Idh1-Idh2_hotspots_SNV_calling_WES.vcf.stats
mkdir plots # plots dir
# load matplotlib dependency for next step, else errors!
plot-vcfstats -p plots/ GB_GEMMs_Idh1-Idh2_hotspots_SNV_calling_WES.vcf.stats
