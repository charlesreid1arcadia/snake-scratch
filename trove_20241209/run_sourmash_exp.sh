#!/bin/bash

#echo "================ sourmash sketch k=21 ==================="
#time sourmash sketch dna -p k=21 Both91_5HT_1_1.fq.gz Both91_5HT_1_2.fq.gz --name "Both91_5HT_comb21" -o Both91_5HT_comb21.zip
#
#echo "================ sourmash sketch k=31 ==================="
#time sourmash sketch dna -p k=31 Both91_5HT_1_1.fq.gz Both91_5HT_1_2.fq.gz --name "Both91_5HT_comb31" -o Both91_5HT_comb31.zip
#
#echo "================ sourmash sketch k=51 ==================="
#time sourmash sketch dna -p k=51 Both91_5HT_1_1.fq.gz Both91_5HT_1_2.fq.gz --name "Both91_5HT_comb51" -o Both91_5HT_comb51.zip

echo "================ sourmash sketch k=21,k=31,k=51 ==================="
time sourmash sketch dna -p k=21,k=31,k=51,abund Both91_5HT_1_1.fq.gz Both91_5HT_1_2.fq.gz --name "Both91_5HT_comb213151" -o Both91_5HT_comb213151.zip
