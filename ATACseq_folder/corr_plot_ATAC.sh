#!/bin/bash
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
##QC Analysis: Correlation plot by replicates 
##corr_plot_ATAC.sh
##To execute use chmod 755
##ATAC-Seq NGS data analysis
##Author Name: Andressa Oliveira de Lima
##Email:aolima@uw.edu & eng.agro.andressa@gmail.com
###***************************************************************



##matrix corr
multiBamSummary bins -b $1 $2 --smartLabels  -p ${NSLOTS} -v \
				-o ${1%%_treat.bam}_${2%%_treat.bam}_results.npz

##plot
  plotCorrelation -in ${1%%_treat.bam}_${2%%_treat.bam}_results.npz \
                --corMethod pearson --skipZeros --plotTitle "ATAC-seq Corr (${1%%_treat.bam}_${2%%_treat.bam})" \
				--whatToPlot heatmap --colorMap PRGn --plotNumbers \
				-o heatmap_PearsonCorr_${1%%_treat.bam}_${2%%_treat.bam}.png \
				--outFileCorMatrix Pearson_corr_${1%%_treat.bam}_${2%%_treat.bam}.tab
