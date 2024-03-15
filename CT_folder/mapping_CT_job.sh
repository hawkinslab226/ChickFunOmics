#!/bin/bash
#$ -S /bin/bash
#$ -pe serial 1
#$ -l mfree=30G -l h_rt=200:00:00
#$ -o /net/hawkins/vol1/home/aolima/data_chicken_faang
#$ -e /net/hawkins/vol1/home/aolima/data_chicken_faang
####**************************************************************************************************
##Job Name: mapping & processing data
##Project Name: FAANG - Chicken Funtional Annotation
##Process & Mapping CUT&TAG data
##Author Name: Andressa Oliveira de Lima
##Email: aolima@uw.edu
##****************************************************************************************************

module load java/1.8.0
module load samtools/1.9
module load bowtie2/2.4.1
conda activate ATAC 

##
dir=/net/hawkins/vol1/C_T_chicken_data
out=/net/hawkins/vol1/home/aolima/data_chicken_faang ##final data

sample=(
"bcell")

cd $dir/${file}

##run the trim 
ls -1 *_R1.fastq | awk -F '_R1.fastq' '{print $1}' > sample.txt

list=$dir/${file}/sample.txt
for SAMPLE_ID in `cat $list`; do 

	# Run Trimmomatic
	java -Xmx30g -jar  /net/hawkins/vol1/home/aolima/tools/Trimmomatic-0.39/trimmomatic-0.39.jar \
	PE $dir/${file}/${SAMPLE_ID}_R1.fastq $dir/${file}/${SAMPLE_ID}_R2.fastq \
	$dir/${file}/${SAMPLE_ID}_cleanead_R1.fastq $dir/${file}/${SAMPLE_ID}_unpaired_R1.fastq $dir/${file}/${SAMPLE_ID}_cleanead_R2.fastq $dir/${file}/${SAMPLE_ID}_unparied_R2.fastq \
	ILLUMINACLIP:/net/hawkins/vol1/genome2/chicken/vectors_contaminants/CT_illumina_Univec.fa:2:30:10 LEADING:10 TRAILING:10 SLIDINGWINDOW:4:24 MINLEN:10  

##run the CT mapping 
index=/net/hawkins/vol1/home/aolima/genome_ncbi/bowtie/gal7-ncbi #index files

##mapping CT
bowtie2 -q --threads ${NSLOTS} -x $index \
              --very-sensitive --end-to-end \
                -I 10 -X 700 --no-discordant \
                --no-mixed --no-unal \
                -1 ${SAMPLE_ID}_cleanead_R1.fastq -2 ${SAMPLE_ID}_cleanead_R2.fastq \
                -S ${SAMPLE_ID}_CT.sam


##convert to bam
samtools view -@ ${NSLOTS} -Su ${SAMPLE_ID}_CT.sam | samtools sort -@ ${NSLOTS} -o ${SAMPLE_ID}_CT.bam #sort

##remove duplicates
samtools index  ${SAMPLE_ID}_CT.bam #remove duplicates
java -Xmx30g -jar /net/hawkins/vol1/home/aolima/tools/picard/picard.jar MarkDuplicates \
             REMOVE_DUPLICATES=true \
             I=${SAMPLE_ID}_CT.bam \
             O=${SAMPLE_ID}_CT_nodups.bam \
             M=${SAMPLE_ID}_CT_nodups.txt \
            VALIDATION_STRINGENCY=LENIENT
##sort again
samtools view -@ ${NSLOTS} -Su ${SAMPLE_ID}_CT_nodups.bam | samtools sort -@ ${NSLOTS} -o ${SAMPLE_ID}_CT_nodups_sorted.bam

##remove the chrm
samtools index ${SAMPLE_ID}_CT_nodups_sorted.bam
samtools idxstats ${SAMPLE_ID}_CT_nodups_sorted.bam | cut -f1 | grep -v NC_053523.1 | grep -v NW_* | xargs samtools view -b ${SAMPLE_ID}_CT_nodups_sorted.bam > ${SAMPLE_ID}_bowtie_treat.bam #final bam file

##convert to bw
samtools index ${SAMPLE_ID}_bowtie_treat.bam
bamCoverage -p max -b ${SAMPLE_ID}_bowtie_treat.bam  --normalizeUsing RPKM  -v  -o ${SAMPLE_ID}_bowtie_norm.bw

rm *_unpaired_R*.fastq
rm *.sam 
rm *_CT_nodups.bam 
rm *_CT_nodups.txt
rm *_CT_nodups_sorted.bam
mv *_bowtie_treat.bam $out
mv *_bowtie_treat.bam.bai $out
mv *_bowtie_norm.bw $out 
mv *_CT.bam $out 

done 
