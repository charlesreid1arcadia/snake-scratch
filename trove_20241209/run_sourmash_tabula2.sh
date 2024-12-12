#!/bin/bash

echo "================ sourmash sketch k=21 ==================="
time sourmash sketch dna -p k=21 TSP12_Heart_atria_SS2_B133721_B134036_Unknown_P9_L003_R1.fastq.gz TSP12_Heart_atria_SS2_B133721_B134036_Unknown_P9_L003_R2.fastq.gz --name "TSP12_Heart_atria_SS2_B133721_B134036_Unknown_P9_L003" -o TSP12_Heart_atria_SS2_B133721_B134036_Unknown_P9_L003.zip

