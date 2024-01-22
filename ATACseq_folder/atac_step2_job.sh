#!/bin/bash
#$ -S /bin/bash
#$ -pe serial 1
#$ -l mfree=85G -l h_rt=100:00:00
#$ -o /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825
#$ -e /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825
###**************************************************************************************************
##Job Name: ATAC-Seq - Step2
##Project Name: FAANG - Chicken Funtional Annotation
##Correlation plot & Calling Peaks ATAC-Seq data
##Nextseq_230825
##Author Name: Andressa Oliveira de Lima
##Email: aolima@uw.edu
##****************************************************************************************************

##path
dir=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825
corr=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/script/corr_plot_ATAC.sh
out_corr=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/output/corr
out_peak=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/output/bam
cal=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/script/Calling_QC.sh
frip=/net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/script/frip_score.sh



input_combinations=(
"Tx10_ProximalCecum_M129_ATAC_S10_treat.bam,Tx9_ProximalCecum_M120_ATAC_S9_treat.bam"
"Tx1_Bursa_M129_ATAC_S1_treat.bam,Tx2_Bursa_M139_ATAC_S2_treat.bam"
"Tx3_Thymus_M129_ATAC_S3_treat.bam,Tx4_Thymus_M139_ATAC_S4_treat.bam"
"Tx5_Jejunum_M129_ATAC_S5_treat.bam,Tx6_Jejunum_M139_ATAC_S6_treat.bam"
"Tx7_Ileum_M129_ATAC_S7_treat.bam,Tx8_Ileum_M139_ATAC_S8_treat.bam"
)


##part1
####QC for each replicate (correlation bam) - deeptools
#corr_plot_ATAC.sh

##tools
conda activate ATAC

cd $dir

for files in ${input_combinations[@]}; do
IFS=',' read -r file1 file2 <<< $files
bash $corr $file1 $file2
done
##
conda deactivate

##end
##**********************************************************************

##part2
##Calling Peaks 
##Calling_QC.sh

module load java/1.8.0
conda activate

ls -1 *_treat.bam  > list1.txt
list=list1.txt

for SAMPLE_ID in `cat $list`; do
bash $cal  $SAMPLE_ID
done

##need to change the folder name 
##end
##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#part3
##FRiPs
#frip_score.sh

ls -1 *_treat.bam | awk -F '_treat.bam' '{print $1}' > list2.txt
list2=list2.txt

for file in `cat $list2`; do

s1=${file}_treat.bam
s2=${file}_atac_peaks.narrowPeak
bash $frip $s1 $s2
done




#move files 
mv *_results.npz  *.png   *.tab $out_corr
mv *_treat.bam *_treat.bam.bai $out_peak
mv *.xls *.bed *.log *Peak *.bdg *_result-narrow.txt $out_peak


#remove files

rm *_tagAlign.bed
rm *_samtools.txt
rm *_tagAlign.sorted.bed
rm *_total.narrow-string.txt
rm *.bai
