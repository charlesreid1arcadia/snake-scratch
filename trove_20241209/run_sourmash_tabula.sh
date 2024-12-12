#!/bin/bash

echo "================ sourmash sketch k=21 ==================="
time sourmash sketch dna -p k=21 TSP12_Heart_Ventricle_10X_1_1_S12_L001_R1_001.fastq.gz TSP12_Heart_Ventricle_10X_1_1_S12_L001_R2_001.fastq.gz --name "TSP12_Heart_Ventricle_10X_1_1_S12_L001" -o TSP12_Heart_Ventricle_10X_1_1_S12_L001.zip

