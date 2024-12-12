# Workflow for creating combined sketches from paired end reads using sourmash

import os

# Configuration parameters are set in a YAML file
# snakemake --configfile config.yaml

# Function to extract basename from full path
def get_filename(filepath):
    return os.path.basename(filepath)

# Config function to get base filenames from a groupname
# (example: TP12_Heart --> [TP12_Heart_Z001.fastq.gz, TP12_Heart_Z002.fastq.gz]
def get_filenames(groupname):
    groups = config['input_file_groups']
    # Iterate through each group name, find matching group
    for g in groups:
        for group_name in g.keys():
             if groupname == group_name:
                 # If group name matches, return list of 2 fullpaths
                 return [get_filename(j) for j in g[group_name]]
    return ["", ""]

# Config function to get full (bucket) path from a base filename
# (example: TP12_Heart_Z001.fastq.gz --> TP12/sequence/10X/TP12_Heart_Z001.fastq.gz)
def get_full_path(filename):
    groups = config['input_file_groups']
    # Iterate through each group, then each fullpath of each group
    for g in groups:
        for group_name in g.keys():
            group_elements = g[group_name]
            for group_element in group_elements:
                # For each fullpath in each group, get the base filename
                # If it matches input, return full path and corresponding group name
                if filename == get_filename(group_element):
                    return [group_element, group_name]
    return ["", ""]



############## Rules ################

# Default target rule
rule all:
    input:
        [f"sourmash/k{k}/{gkey}.zip" for g in config['input_file_groups'] for gkey in g.keys() for k in config['sourmash_ks']]


# Rule to download files from S3
rule download_from_s3:
    output:
        "downloads/{filename}"
    params:
        bucket=config['s3_bucket'],
        full_path=lambda wildcards: get_full_path(wildcards.filename)[0],
    shell:
        """
        echo aws s3 cp s3://{params.bucket}/{params.full_path} {output}
        touch {output}
        """


# Rule to generate sketches with sourmash
rule sourmash_sketch:
    input:
        left= lambda wildcards:  [os.path.join("downloads", get_filenames(wildcards.groupname)[0])][0],
        right=lambda wildcards:  [os.path.join("downloads", get_filenames(wildcards.groupname)[1])][0]
    output:
        "sourmash/k{k}/{groupname}.zip"
    params:
        bucket=config['s3_bucket']
    shell:
        """
        echo sourmash -k={wildcards.k} {wildcards.groupname} {input.left} {input.right} -o {wildcards.groupname}
        touch {output}
        """
