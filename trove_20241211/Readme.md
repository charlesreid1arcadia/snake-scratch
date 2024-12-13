# S3 Download workflow

Workflow useful for downloading data from a bucket. Specify the name of a bucket, and
a list of objects in that bucket, and this workflow will download them if they have not
already been downloaded.

## Configuring

The configuration file for this workflow can be re-used for
the sourmash post-processing workflow too. To ensure paired end
reads are processed together in sourmash, provide input files
in the S3 bucket in pairs. Each pair should have a top-level name
that wil be used to name the sourmash output file. For example:

```
s3_bucket: "s3://czb-tabula-sapiens"

input_file_groups:
  - "TSP12_Heart_Atria_10X_1_1_S13_L003":
    - "TabulaSapiens_v2/TSP12/fastqs/10X/TSP12_Heart_Atria_10X_1_1/TSP12_Heart_Atria_10X_1_1_S13_L003_R1_001.fastq.gz"
    - "TabulaSapiens_v2/TSP12/fastqs/10X/TSP12_Heart_Atria_10X_1_1/TSP12_Heart_Atria_10X_1_1_S13_L003_R2_001.fastq.gz"
```

When the S3 Download workflow is run on this input file, it will
download the two fastq.gz files at the specified paths in the 
bucket `czb-tabula-sapiens`.

## Running

To run the workflow, specify the configuration file, the Snakefile, and the rule to run (`all`):

```
snakemake --configfile config_tabulasapiens.yaml -s workflow_s3download.Snakefile all
```

