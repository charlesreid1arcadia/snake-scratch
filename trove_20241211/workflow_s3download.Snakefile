# Workflow for downloading files from S3

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
        [f"downloads/{get_filename(f)}" for g in config['input_file_groups'] for f in g]

# Rule to download files from S3
rule download_from_s3:
    output:
        "downloads/{filename}"
    params:
        bucket=config['s3_bucket'],
        # This lambda turns the shortened filename back into the full path
        full_path=lambda wildcards: [f for g in config['input_file_groups'] for f in g if get_filename(f) == wildcards.filename][0]
    shell:
        """
        echo aws s3 cp s3://{params.bucket}/{params.full_path} {output}
        touch {output}
        """
