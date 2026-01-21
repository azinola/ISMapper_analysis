nextflow.enable.dsl = 2
autoMounts = true
//Sample list to analyze
params.samples = "$baseDir/list_samp.txt"
//Where to find sample's Illumina reads
params.fastq_dir = file("$baseDir/samp/")
//Reference genome (default in dir DB)
params.reference = "$baseDir/DB/H37Rv.gb" 
// Is list
params.is_list = "$baseDir/list_is.txt"
// Database folder
params.db_dir = "$baseDir/DB"
//Conda env
params.conda_env = params.conda_env

include {
    ISMAPPER
} from "$baseDir/module_is.nf"

workflow {

    Channel
        //Check if sample exists
        .fromPath(params.samples)
        .splitText()
        .map { it.trim() }
        .filter { it }
        .map { acc ->
            def r1 = file("${params.fastq_dir}/${acc}_R1.fastq.gz")
            def r2 = file("${params.fastq_dir}/${acc}_R2.fastq.gz")

            if (!r1.exists() || !r2.exists()) {
                exit 1, "FASTQ files not found for accession: ${acc}"
            }
            tuple(acc, r1, r2)
        }
        .set { reads_ch }

    //IS CHANNEL
    Channel
        .fromPath(params.is_list)
        .splitText()
        .map { it.trim() }
        .filter { it }
        .map { is_name ->
            def fasta = file("${params.db_dir}/${is_name}.fasta")
            if (!fasta.exists()) {
                exit 1, "IS fasta not found: ${fasta}"
            }
            fasta
        }
        .collect()
        .set { is_fasta_list_ch }

ISMAPPER(reads_ch,is_fasta_list_ch,params.reference)

}

