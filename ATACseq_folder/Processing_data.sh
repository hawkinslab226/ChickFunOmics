#!/bin/bash
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##Pre & Processing *.fastq files 
##Mapping data 
##Processing_data.sh
##To execute use chmod 755
##ATAC-Seq NGS data analysis
##Author Name: Andressa Oliveira de Lima
##Email:aolima@uw.edu & eng.agro.andressa@gmail.com
###***************************************************************

##Mapping, processing data
#Processing_data.sh

##clean data
java -Xmx80g -jar  /net/hawkins/vol1/home/aolima/tools/Trimmomatic-0.39/trimmomatic-0.39.jar \
        PE $1 $2 \
        ${1%%_R1.fastq}_cleanead_R1.fastq ${1%%_R1.fastq}_unpaired_R1.fastq ${2%%_R2.fastq}_cleanead_R2.fastq ${2%%_R2.fastq}_unparied_R2.fastq \
        ILLUMINACLIP:/net/hawkins/vol1/genome2/chicken/vectors_contaminants/CT_illumina_Univec.fa:2:30:10 LEADING:10 TRAILING:10 SLIDINGWINDOW:4:24 MINLEN:10

#aligment
bowtie2 -q --threads ${NSLOTS} \
		-x /net/hawkins/vol1/home/aolima/genome_ncbi/bowtie_gal7/bowtie/gal7-ncbi \
		--end-to-end --very-sensitive -X 1000 \
		-1  ${1%%_R1.fastq}_cleanead_R1.fastq -2 ${2%%_R2.fastq}_cleanead_R2.fastq -S ${1%%_R1.fastq}.sam

##convert to bam
samtools view -@ ${NSLOTS} -Su  ${1%%_R1.fastq}.sam | samtools sort -@ ${NSLOTS} -o  ${1%%_R1.fastq}.bam


##remove duplicates
samtools index   ${1%%_R1.fastq}.bam #remove duplicates
java -Xmx80g -jar /net/hawkins/vol1/home/aolima/tools/picard/picard.jar MarkDuplicates \
             REMOVE_DUPLICATES=true \
             I=${1%%_R1.fastq}.bam \
             O=${1%%_R1.fastq}_nodups.bam \
             M=${1%%_R1.fastq}_nodups.txt \
             VALIDATION_STRINGENCY=LENIENT

##sort
samtools sort  -@ ${NSLOTS} ${1%%_R1.fastq}_nodups.bam -o ${1%%_R1.fastq}_sorted.bam

##genome browse files 
samtools index ${1%%_R1.fastq}_sorted.bam
samtools idxstats  	${1%%_R1.fastq}_sorted.bam | cut -f1 | grep -v  NC_053523.1 | grep -v  NW_* | xargs samtools view -b  \
			${1%%_R1.fastq}_sorted.bam >  ${1%%_R1.fastq}_filter.bam
					
					
##sort again 
samtools sort   ${1%%_R1.fastq}_filter.bam -@ ${NSLOTS} -o  ${1%%_R1.fastq}_treat.bam
##convert to bw
samtools index  ${1%%_R1.fastq}_treat.bam
bamCoverage -p max -b ${1%%_R1.fastq}_treat.bam  --normalizeUsing RPKM  -v  -o  ${1%%_R1.fastq}_norm.bw ##you can use this on the genome browser

#qualimap
mkdir  ${1%%_R1.fastq}_qc
  qualimap bamqc \
      --java-mem-size=80G -bam ${1%%_R1.fastq}_bowtie_treat.bam \
      -outdir /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825 -outfile /net/hawkins/vol1/home/aolima/atac_seq_chicken/seq_230825/${1%%_R1.fastq}.pdf \
      -outformat PDF
##
mv  genome_results.txt  ${1%%_R1.fastq}_qc

