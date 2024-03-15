#!/bin/bash
#$ -S /bin/bash
#$ -pe serial 1
#$ -l mfree=50G -l h_rt=100:00:00
#$ -o /net/hawkins/vol1/home/aolima/data_chicken_faang
#$ -e /net/hawkins/vol1/home/aolima/data_chicken_faang
####**************************************************************************************************
##Job Name: QC & Variant Calling
##Project Name: FAANG - Chicken Funtional Annotation
##Process & Mapping CUT&TAG data
##Author Name: Andressa Oliveira de Lima
##Email: aolima@uw.edu
##****************************************************************************************************
module load java/1.8.0
conda activate

dir=/net/hawkins/vol1/home/aolima/data_chicken_faang

sample=(
"1j_H3K27me3_AM_S1"
"2j_H3K27ac_AM_S2"
"3j_H3K9me3_AM_S3"
"4j_H3K4me1_AM_S4"
"5j_H3K4me3_AM_S5"
"6j_CTCF_AM_S6"
"7j_Neg_Control_S7"
)

cd $dir 
for file in ${sample[@]}; do
##qualimap
mkdir  ${file}_qc
  qualimap bamqc \
      --java-mem-size=50G -bam $dir/${file}_bowtie_treat.bam \
      -outdir $dir -outfile $dir/${file}.pdf \
      -outformat PDF
	  
	  mv  $dir/genome_results.txt  ${file}_qc
##macs2-narrow
macs2 callpeak  -t  ${file}_bowtie_treat.bam  \
        -f BAM  -g 1.1e9 --nomodel --shift -100 --extsize 200 \
        -n ${file}_narrow --keep-dup all -q 0.05 \
        -B --nolambda --trackline --SPMR  \
	--outdir $dir 2> $dir/${file}_narrow_macs2.log
		
##macs2-broad 
macs2 callpeak  -t  ${file}_bowtie_treat.bam  \
        -f BAM  -g 1.1e9 --nomodel --shift -100 --extsize 200 \
        -n ${file}_broad --keep-dup all --broad --broad-cutoff 0.1\
        -B --nolambda --trackline --SPMR  \
         --outdir $dir 2> $dir/${file}_broad_macs2.log
done 
