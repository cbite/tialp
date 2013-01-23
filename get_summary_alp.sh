#!/bin/bash
SQLCMD='select I.Image_Metadata_ArrayNumber as Array, avg(ALPCytoplasm_Intensity_IntegratedIntensity_ALP4Corr) as meanALP, median(ALPCytoplasm_Intensity_IntegratedIntensity_ALP4Corr) as medALP, stddev(ALPCytoplasm_Intensity_IntegratedIntensity_ALP4Corr) as stdALP, count(*) as ncells from TiALP_Per_Image as I, TiALP_Per_Object as O where I.ImageNumber = O.ImageNumber group by I.Image_Metadata_ArrayNumber'
set -x
mysql -A -u cpuser -pcPus3r -h imgdb02 2012_08_20_TopoChipScreening_deBoerLab  -e "$SQLCMD"| gsed 's/\t/,/g' > ../input/TIALP-B1/summary_alp.csv
