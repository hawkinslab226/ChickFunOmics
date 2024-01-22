#!/bin/bash
#$ -S /bin/bash
#$ -pe serial 1
#$ -l mfree=85G -l h_rt=100:00:00
#$ -o /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825
#$ -e /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825
###**************************************************************************************************
##Job Name: ATAC-Seq - Step1
##Project Name: FAANG - Chicken Funtional Annotation
##Process & Mapping ATAC-Seq data 
##Nextseq_230825
##Author Name: Andressa Oliveira de Lima
##Email: aolima@uw.edu
##****************************************************************************************************
  
##path
input=/net/hawkins/vol1/NEXTSEQ_runs/Nextseq_230825/atac
out=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825
process=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/script/Processing_data.sh
out_qc=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/output/QC
out_bam=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/output/bam
out_bw=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/output/bw

input_combinations=(
"Tx10_ProximalCecum_M129_ATAC_S10_R1.fastq,Tx10_ProximalCecum_M129_ATAC_S10_R2.fastq"
"Tx1_Bursa_M129_ATAC_S1_R1.fastq,Tx1_Bursa_M129_ATAC_S1_R2.fastq"
"Tx2_Bursa_M139_ATAC_S2_R1.fastq,Tx2_Bursa_M139_ATAC_S2_R2.fastq"
"Tx3_Thymus_M129_ATAC_S3_R1.fastq,Tx3_Thymus_M129_ATAC_S3_R2.fastq"
"Tx4_Thymus_M139_ATAC_S4_R1.fastq,Tx4_Thymus_M139_ATAC_S4_R2.fastq"
"Tx5_Jejunum_M129_ATAC_S5_R1.fastq,Tx5_Jejunum_M129_ATAC_S5_R2.fastq"
"Tx6_Jejunum_M139_ATAC_S6_R1.fastq,Tx6_Jejunum_M139_ATAC_S6_R2.fastq"
"Tx7_Ileum_M129_ATAC_S7_R1.fastq,Tx7_Ileum_M129_ATAC_S7_R2.fastq"
"Tx8_Ileum_M139_ATAC_S8_R1.fastq,Tx8_Ileum_M139_ATAC_S8_R2.fastq"
"Tx9_ProximalCecum_M120_ATAC_S9_R1.fastq,Tx9_ProximalCecum_M120_ATAC_S9_R2.fastq"
)


cd $input

##remove the *.gz
cp  -r *.gz $out

##

##start the job

cd $out

gunzip *.gz 

##Step1 
##Data Clean & Mapping & Convert to bw
#Processing_data.sh

##tools
module load java/1.8.0
module load samtools/1.9
module load bowtie2/2.4.1
conda activate ATAC

for files in ${input_combinations[@]}; do
IFS=',' read -r file1 file2 <<< $files
bash $process $file1 $file2
done

##
conda deactivate

##remember to change the folder name in the script
#end

#END STEP 1****************************************************************
##move files
mv *_qc *.pdf $out_qc
mv *.bw $out_bw

##
##remove files
rm *.fastq
rm *.sam
rm *_nodups.bam
rm *_nodups.txt 
rm *_filter.bam
rm *_sorted.bam



