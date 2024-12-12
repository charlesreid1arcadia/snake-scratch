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
        [f"sourmash_k{k}/{gkey}.zip" for g in config['input_file_groups'] for gkey in g.keys() for k in config['sourmash_ks']]




#############################
# Rule to download files from S3
rule download_from_s3:
    output:
        "downloads/{filename}"
    params:
        bucket=config['s3_bucket'],
        # This lambda turns the shortened filename back into the full path
        full_path=lambda wildcards:  [g[gkey] for g in config['input_file_groups'] for gkey in g.keys() if wildcards.filename in g[gkey]]
    shell:
        """
        echo {params.full_path}
        echo {output}
        echo aws s3 cp s3://{params.bucket}/{params.full_path} {output}
        touch {output}
        """
#############################


# Rule to generate sketches with sourmash
rule sourmash_sketch:
    input:
        left=lambda wildcards:  [os.path.join("downloads", get_filename(g[gkey][0])) for g in config['input_file_groups'] for gkey in g.keys()],
        right=lambda wildcards: [os.path.join("downloads", get_filename(g[gkey][1])) for g in config['input_file_groups'] for gkey in g.keys()]
    output:
        "sourmash_k{k}/{groupname}.zip"
    params:
        bucket=config['s3_bucket'],
    shell:
        """
        echo sourmash -k={wildcards.k} {wildcards.groupname} {input.left} {input.right} -o {wildcards.groupname}
        touch {output}
        """
