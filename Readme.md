# Recipe for Trove Analysis: Setting Up The Machine

## AWS Permissions

The Arcadia AWS administrator will need to attach the following policies to the IAM user you are using:
* EC2FullAccess
* IAMReadOnlyAccess

## EC2 Preparation

Use the AWS console to create an EC2 instance. Use the following:
* Amazon Linux AMI
* 30 GB EBS drive
* Pick "large" instance size
* Pick an existing SSH key or create a new one

Start up the EC2 instance and SSH into the machine.

## AWS CLI Preparation

Once you are onboard the machine, set up the AWS CLI to use your IAM user's access key and secret access key.

```
aws configure
```

Verify you can access the necessary buckets:

```
aws s3 ls s3://trove-omics

aws s3 ls s3://czb-tabula-sapiens

aws s3 ls aws s3 cp s3://czb-tabula-sapiens/TabulaSapiens_v2/TSP12/fastqs/10X/TSP12_Heart_Ventricle_10X_1_1/TSP12_Heart_Ventricle_10X_1_1_S12_L001_R1_001.fastq.gz
```

## Conda Installation

Install Python, then install conda via miniforge:

```
sudo yum install -y python3

# https://github.com/conda-forge/miniforge?tab=readme-ov-file
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "${HOME}/conda"
```

To use conda, run these two commands:

```
source "${HOME}/conda/etc/profile.d/conda.sh"
conda activate
```

Alternatively, add the first command to your .bashrc, then you can activate the conda environment by just typing `conda activate`.

## Sourmash Installation

Once you have actiavted the conda environment, add the bioconda channel, which will allow you to install sourmash:

```
conda config --env --add channels bioconda

conda install sourmash
```

# Recipe for Trove Analysis: Manual Steps

## Creating Sourmash Sketches

To create a sourmash sketch from a single file with DNA sequence data, use this command:

```
sourmash sketch dna -p k=31 sample.fq.gz
```

For paired end reads, create a [combined sketch](https://sourmash.readthedocs.io/en/latest/sourmash-sketch.html#building-a-combined-sketch-from-two-or-more-files) and specify an output file name:

```
sourmash sketch dna -p k=31 sample_R1.fq.gz sample_R2.fq.gz \
  --name "sample" -o sample.sig
```

## Sourmash Sketch Timing and Performance

To get information about the performance of sourmash, you can add the `time` command in front of the above sourmash command, and see how long the command took:

```
time sourmash sketch dna -p k=31 Both91_5HT_1_1.fq.gz, Both91_5HT_1_2.fq.gz \
  --name "Both91_5HT" -o Both91_5HT_comb31.zip


================ sourmash sketch k=31 ===================

== This is sourmash version 4.8.12. ==
== Please cite Irber et. al (2024), doi:10.21105/joss.06830. ==

computing signatures for files: Both91_5HT_1_1.fq.gz, Both91_5HT_1_2.fq.gz
Computing a total of 1 signature(s) for each input.
... reading sequences from Both91_5HT_1_1.fq.gz
... Both91_5HT_1_1.fq.gz 29986494 sequences
... reading sequences from Both91_5HT_1_2.fq.gz
... Both91_5HT_1_2.fq.gz 29986494 sequences
calculated 1 signature for 59972988 sequences taken from 2 files
saved 1 signature(s) to 'Both91_5HT_comb31.zip'

real    12m20.704s
user    12m16.183s
sys     0m3.103s
```

Timing information:

* `Both91_5HT_1_1.fq.gz, Both91_5HT_1_2.fq.gz` (1.9 GB each) took 6 min to process individually, 12 min to process together

* `TSP12_Heart_atria_SS2_B133721_B134036_Unknown_P9_L003_R1.fastq.gz, TSP12_Heart_atria_SS2_B133721_B134036_Unknown_P9_L003_R2.fastq.gz` (30 MB each) took 30 sec to process individually, 1 min together.

* `TSP12_Heart_Ventricle_10X_1_1_S12_L001_R1_001.fastq.gz, TSP12_Heart_Ventricle_10X_1_1_S12_L001_R2_001.fastq.gz` (4.1G and 9.7G, respectively) took (TBD)

## Sourmash Comparisons

Once each sample has a sourmash signature calculated, signatures can be compared one-to-one or many-to-many.

To compare two samples, provide their signature files:

```
sourmash compare exp_Both91/signatures/92c1a064afd6b7fba916dabd6faa7915.sig.gz ts_TSP12_Heart_Ventricle/signatures/9dc36545f2cdeb55da70f8838df044a1.sig.gz -o cmp.dist
```

This will output a distance matrix:

```
== This is sourmash version 4.8.12. ==
== Please cite Irber et. al (2024), doi:10.21105/joss.06830. ==

loaded 2 signatures total.

0-Both91_5HT_comb21 	[1.    0.041]
1-TSP12_Heart_Ven...	[0.041 1.   ]
min similarity in matrix: 0.041
saving labels to: cmp.dist.labels.txt
saving comparison matrix to: cmp.dist
```

The distance between signatures will depend on the parameters used when generating the sketch. The k parameter has a big effect, but so do other parameters such as scaled (how the bag of k-mers is subsampled) or weighting (by abundance or not).

# Recipe for Trove Analysis: Automated Steps

## Snakemake Workflow

To automate the steps described above, we have a simple workflow in this repository
