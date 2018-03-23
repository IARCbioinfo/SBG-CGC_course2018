#$ -S /bin/sh

#-------------------------
# quanTIseq pipeline 
#-------------------------

# setup variables

echo $PWD
localDir=$PWD

tumor=TRUE
#
fname=$(basename "$1" .bam)
fnamefq="${1%.bam}"
f1=$fnamefq"_1.fq"
f2=$fnamefq"_2.fq"
echo "samtools collate -uOn 128 $1 tmp_$fname | samtools fastq -1 $f1 -2 $f2 -"
samtools collate -uOn 128 $1 tmp_$fname | samtools fastq -1 $f1 -2 $f2 -

prefix=$fname

# create input file
mkdir -p /home/Input
echo "Sample "$fname"_1.fq "$fname"_2.fq" > /home/Input/inputfile.txt

echo "Sample "$fname"_1.fq "$fname"_2.fq"

echo $f1
echo $f2

# set initial pipelinesteps to FALSE:
preproc="FALSE"
expr="FALSE"
decon="FALSE"

if [ $help == "TRUE" ]; then
    cat /home/quanTIseq_usage.txt >&2
    exit
fi

# check if inputfile exists:
if [ -f /home/Input/inputfile.txt ]; then
  inputfile=/home/Input/inputfile.txt
else
  echo "ERROR: please specify input files as described in quanTIseq documentation. To inspect this image call: docker run -it --entrypoint=/bin/bash icbi/quantiseq" >&2
  exit
fi

ln -s $f1 /home/Input/.
ln -s $f2 /home/Input/.

# Get number of available threads from the system and take the minimum of user input and available threads:
maxthreads=$(grep -c ^processor /proc/cpuinfo)
nthreads=$(($maxthreads<$threads?$maxthreads:$threads))

#-----------------------------------
# Preprocessing / Trimmomatic
#-----------------------------------

preprocpath="/home/Output/out_preproc/"

echo "Rscript /home/trimmomatic/quanTIseq_preproc.R $inputfile $preprocpath $nthreads $phred $adapters $adapterSeed $palindromeClip $simpleClip $trimLead $trimTrail $minlen $crop"

if [ $pipelinestart == "preproc" ]; then

  Rscript /home/trimmomatic/quanTIseq_preproc.R $inputfile $preprocpath $nthreads $phred $adapters $adapterSeed $palindromeClip $simpleClip $trimLead $trimTrail $minlen $crop
  
  rm -f ${preprocpath}*nopair
     
  pipelinestart="expr"
  preproc="TRUE"
  arrays="FALSE"
fi

#--------------------------------------
# Transcript expression / Kallisto
#--------------------------------------

exprpath="/home/Output/out_expr/"

if [ $pipelinestart == "expr" ]; then
  
    cat $inputfile
  # Run kallisto:
  echo "Rscript /home/kallisto/quanTIseq_expr.R $inputfile $exprpath $nthreads $preproc $preprocpath"
  Rscript /home/kallisto/quanTIseq_expr.R $inputfile $exprpath $nthreads $preproc $preprocpath
  fileexpr=`ls $exprpath/*.tsv`
  ls $exprpath
  # Map transcripts to human gene symbols:
  echo "Rscript /home/kallisto/mapTranscripts.R $fileexpr "${exprpath}${prefix}
  Rscript /home/kallisto/mapTranscripts.R $fileexpr "${exprpath}${prefix}"
  #rm ${exprpath}*.tsv
  
  # Remove rawcount file if not needed:
  #if [ $rawcounts == "FALSE" ]; then
  #  rm ${exprpath}*gene_count.txt
  #fi
  
  pipelinestart="decon"
  expr="TRUE"
  arrays="FALSE"
  inputfile="${exprpath}${prefix}_gene_tpm.txt"
  
  cp -r ${exprpath}. /home/user_output/
  chmod a+rwx -R /home/user_output
  
fi

#-------------------------------------
# Deconvolution / R
#-------------------------------------

deconpath="/home/Output/out_decon/"

if [ $pipelinestart == "decon" ]; then
  # Run deconvolution:
    echo "Rscript /home/deconvolution/quanTIseq_decon.R $inputfile $deconpath $expr $arrays $signame $tumor $mRNAscale $method $prefix $btotalcells $rmgenes"
  Rscript /home/deconvolution/quanTIseq_decon.R $inputfile $deconpath $expr $arrays $signame $tumor $mRNAscale $method $prefix $btotalcells $rmgenes
  decon="TRUE"

  cat ${deconpath}${prefix}_cell_fractions.txt

  cp "${deconpath}${prefix}_cell_fractions.txt" /
  cp "${deconpath}${prefix}_cell_fractions.txt" ~/
  cp "${deconpath}${prefix}_cell_fractions.txt" $localDir/
  
  if [ $btotalcells == "TRUE" ]; then
  cp "${deconpath}${prefix}_cell_densities.txt" /
  fi
  
fi
