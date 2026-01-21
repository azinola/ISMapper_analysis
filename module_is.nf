process ISMAPPER {
    //conda "/path/conda/ismapper2"
    publishDir 'OUTPUT', mode:'copy', pattern: "*txt"
    tag "$acc"
    errorStrategy 'ignore'

    input:
    tuple val(acc), path(r1), path(r2)
    path is_fastas
    path reference

    output:
	tuple val (acc), path("*txt")
    val 'done', emit:done

    script:
    """
    ismap --reads $r1 $r2 --queries ${is_fastas.join(' ')}  --reference $reference --output_dir ${acc}
    for is_dir in ${acc}/*; do name=\$(echo "\$is_dir" |tr '/' '_');mv "\$is_dir"/*txt "\$name".txt;done
    """

}

