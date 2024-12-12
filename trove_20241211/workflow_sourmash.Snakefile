# Workflow for creating combined sketches from paired end reads using sourmash

import os

# Configuration parameters are set in a YAML file
# snakemake --configfile config.yaml

# Function to extract basename from full path
def get_filename(filepath):
    return os.path.basename(filepath)


############## Rules ################

# Default target rule
rule all:
    input:
        [f"sourmash_k{k}/{g}.zip" for g in config['input_file_groups'] for k in config['sourmash_ks']]


# Rule to generate sketches with sourmash
rule sourmash_sketch:
    input:
        "downloads/{filename}"
    output:
        "sourmash_k{k}/{groupname}.zip"
    params:
        bucket=config['s3_bucket'],
        paired_inputs=lambda wildcards: [get_filename(f) for g in config['input_file_groups'] for f in g if wildcards.filename in g]
    shell:
        """
        echo sourmash -k={wildcards.k} {wildcards.groupname} params.paired_inputs -o {wildcards.groupname}
        """
