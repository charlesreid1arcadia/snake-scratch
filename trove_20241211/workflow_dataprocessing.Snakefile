# Workflow for downloading a file from S3 and processing it with sourmash

import os

# Configuration parameters
#configfile: "config_tabulasapiens.yaml"

# Function to extract basename from full path
def get_filename(filepath):
    try:
    	return os.path.basename(filepath)
    except TypeError:
        return [os.path.basename(j) for j in filepath]


# Default target rule
rule all:
    input:
        # # Use this input to download the files to downloads/ only
        # [f"downloads/{get_filename(f)}" for f in config['input_files']]
        [f"downloads/{get_filename(f)}" for g in config['input_file_groups'] for f in g]
        # Use this input to process the files in sourmash_k{k}/
        # [f"results/sourmash_{get_filename(f)}.zip" for f in g for g in config['input_file_groups']]

# Rule to download files from S3
rule download_from_s3:
    output:
        "downloads/{filename}"
    params:
        bucket=config['s3_bucket'],
        # This lambda turns the shortened filename back into the full path
        full_path=lambda wildcards: [f for g in config['input_file_groups'] for f in g if get_filename(f) == wildcards.filename][0]
    shell:
        # Fake rule
        """
        echo aws s3 cp s3://{params.bucket}/{params.full_path} {output}
        touch {output}
        """
        ## Real rule
        #"""
        #aws s3 cp s3://{params.bucket}/{params.full_path} {output}
        #"""

# Rule to process the downloaded files
rule process_file:
    input:
        "downloads/{filename}"
    output:
        #"results_k{params.sourmash_k}/processed_{filename}.zip"
        "results/sourmash_{filename}.zip"
    params:
        sourmash_k=config['sourmash_k']
    shell:
        # Fake rule
        """
        echo sourmash -k={params.sourmash_k} {input} -o {output}
        touch {output}
        """

