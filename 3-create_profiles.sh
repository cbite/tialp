#!/bin/bash

lsfdir=.compute_`date +%s%N` \
dataset_name=$1

if [ $dataset_name = "TIALP-B1" ]
then
    properties_file=2012_08_20_TopoChipScreening_deBoerLab_TiALP.properties
    cache_dir=cache-2012-11-28
else
    echo Dataset $dataset_name does not exist.
    exit
fi;

datadir=../input/${dataset_name}/
curdir=`pwd`
OS=`uname`
if [ $OS == "Darwin" ]
then
    PYTHONBIN=/Users/shsingh/work/software/CPhomebrew/Cellar/cellprofiler-dev/1/cpdev/bin/python
    SED=gsed
    parallel_option=multiprocessing
else
    PYTHONBIN=python
    SED=sed
    parallel_option=lsf-directory=$lsfdir
#    parallel_option=multiprocessing
fi
cd $datadir


# ---------- Create profiles  ----------

function run_profile_gen {
  rm -rf $lsfdir
  echo $PYTHONBIN -m cpa.profiling.profile_mean -c -o $csvname  --${parallel_option} --normalization=$normalization --method=$method $properties_file $cache_dir Design
  echo $SED -i 's/Design,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,/Image_Metadata_ArrayNumber,Image_Metadata_CA,Image_Metadata_CCD,Image_Metadata_CCDunsc,Image_Metadata_ChipCOL,Image_Metadata_ChipROW,Image_Metadata_CircArea,Image_Metadata_CircDiam,Image_Metadata_DC,Image_Metadata_DL,Image_Metadata_DT,Image_Metadata_FCP,Image_Metadata_FCPLOG,Image_Metadata_FCPLOGN0_1,Image_Metadata_FCPLOGN0_3,Image_Metadata_FCPN01,Image_Metadata_FCPN03,Image_Metadata_FeatSize,Image_Metadata_FileName_ALP_w_array_name,Image_Metadata_FileName_Actin_w_array_name,Image_Metadata_FileName_DNA_w_array_name,Image_Metadata_LA,Image_Metadata_LineArea,Image_Metadata_LineLen,Image_Metadata_NUM,Image_Metadata_NumCirc,Image_Metadata_NumLine,Image_Metadata_NumTri,Image_Metadata_ROT,Image_Metadata_RotSD,Image_Metadata_Split,Image_Metadata_TA,Image_Metadata_TriArea,Image_Metadata_TriSize,Image_Metadata_WN0_1,Image_Metadata_WN0_2,Image_Metadata_WN0_3,Image_Metadata_WN0_4,Image_Metadata_WN0_5,Image_Metadata_WN0_7,Image_Metadata_WN1,Image_Metadata_WN1_5,Image_Metadata_WN2,Image_Metadata_WN3,Image_Metadata_WN4,Image_Metadata_colidxbottom,Image_Metadata_colidxtop,Image_Metadata_featureidx,Image_Metadata_imageidxbottom,Image_Metadata_imageidxtop,Image_Metadata_internalidx,Image_Metadata_rowidxbottom,Image_Metadata_rowidxtop,Image_Metadata_unitidxbottom,Image_Metadata_unitidxtop,/1' $csvname
}

####
echo Computing profiles without normalization - median+mad
profile_method=profile_mean
normtype=no_norm
method=median+mad
csvname=well-${method}-${normtype}.csv
normalization=DummyNormalization
run_profile_gen

####
echo Computing profiles without normalization - mean
profile_method=profile_mean
normtype=no_norm
method=mean
csvname=well-${method}-${normtype}.csv
normalization=DummyNormalization
run_profile_gen

