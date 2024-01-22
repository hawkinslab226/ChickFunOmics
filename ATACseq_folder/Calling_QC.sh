#!/bin/bash
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##Calling Peaks using MAC2
##Calling_QC.sh
##To execute use chmod 755 
##ATAC-Seq NGS data analysis 
##Author Name: Andressa Oliveira de Lima
##Email:aolima@uw.edu & eng.agro.andressa@gmail.com
###***************************************************************

#
##macs2-atac
macs2 callpeak  -t  $1  \
        -f BAM  -g 1.1e9 --nomodel --shift -100 --extsize 200 \
        -n ${1%%_treat.bam}_atac --keep-dup all -q 0.05 \
        -B --nolambda --trackline --SPMR  \
        --outdir /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825 2> /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/${1%%_treat.bam}_atac_macs2.log
