# A set of cell lines derived from a genetic murine glioblastoma model recapitulates molecular and morphological characteristics of human tumors


Barbara Costa\*, Michael Fletcher, Pavle Boskovic, Ekaterina L. 
Ivanova, Tanja Eisemann, Sabrina Lohr, Lukas Bunse, Martin Löwer, Stefanie 
Burchard, Andrey Korshunov, Nadia Coltella, Melania Cusimano, Luigi Naldini, 
Hai-Kun Liu, Michael Platten, Bernhard Radlwimmer, Peter Angel\*, Heike 
Peterziel

*\* co-corresponding authors [contact emails: b.costa [OR] p.angel [AT] dkfz-heidelberg.de]*



## Introduction

Kia ora! Welcome to the code repository, containing the RNAseq and WES analysis scripts for our paper.

All computational analyses were performed by Mike Fletcher [email: m.fletcher [AT] dkfz-heidelberg.de OR sci [AT] dismissed.net.nz]

For general enquiries, please contact the corresponding authors, Barbara and Peter (see above).


## Analysis overview

A brief summary of how it all fits together:

**For the RNAseq analysis**:
1. `RNAseq_Angel_GB_GEMMs_process.sh`: as it says on the tin, do basic processing (STAR alignment to Gencode M2 transcriptome, featureCounts)
2. `RNAseq_Angel_GB_GEMM_analysis.Rscript`: takes the per-sample counts from featureCounts, and does the transcriptome characterisation, comparison to Wang 2017 GB signatures, aNSC signature activity 

**For the WES analysis**:
1. `WES_Angel_GB_GEMMs_process.sh` and `WES_SE_Angel_GB_GEMMs_process.sh`: again, basic processing (bwa alignment), for paired or single end data respectively
2. `WES_Angel_GB_GEMMs_SNV_mpileup.sh`: use `bcftools mpileup` to check whether the Idh1/2 hotspot mutations appear in the genomic DNA
3. `WES_Angel_GB_GEMM_CNV_calling_CNVkit.sh`: call CNVs using CNV kit on WES data
4. `WES_Angel_GB_GEMM_CNV_visualisation_excludeSegDupes.Rscript`: visualise CNVkit CNV calls as Circos plots


