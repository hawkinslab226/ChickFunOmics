#!/bin/bash
#**************************************
##Calculate FRiP score
#frip_score.sh
##To execute use chmod 755
##ATAC-Seq NGS data analysis
##Author Name: Andressa Oliveira de Lima
##Email:aolima@uw.edu & eng.agro.andressa@gmail.com
###***************************************************************


#prepare ###use bam file
#convert BAM (BAM used to call peaks) to BED

bedtools bamtobed -i  $s1 | \
 awk 'BEGIN{OFS="\t"}{$4="N";$5="1000";print $0}' \
 > ${s1}_tagAlign.bed

#total reads in BAM
samtools view -c  $s1 \
 > ${s1}_samtools.txt

#sort the tag.Align.bed
bedtools sort -i ${s1}_tagAlign.bed \
 >  ${s1}_tagAlign.sorted.bed

#count reads in peak regions

  
##narrow-ATAC
bedtools sort -i $s2  | \
 bedtools merge -i stdin |\
 bedtools intersect -u -a ${s1}_tagAlign.sorted.bed -b stdin | \
 wc -l > ${s2}_total.narrow-string.txt

 ##calculate  the FRiPs
 v1=$(<"${s2}_total.narrow-string.txt")
    v2=$(<"${s1}_samtools.txt")
 #result=$(($v1 / $v2))
   result=$(awk "BEGIN {print $v1/$v2}")
        echo "$result" > "${s2}_result-narrow.txt"
