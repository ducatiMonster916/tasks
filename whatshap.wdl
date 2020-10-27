version 1.0

# Copyright (c) 2018 Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


task Phase {
    input {
        String outputVCF
        File? reference
        File? referenceIndex
        String? tag
        String? algorithm
        Boolean? indels
        String? sample
        String? chromosome
        String? threshold
        String? ped
        File vcf
        File vcfIndex
        File phaseInput
        File phaseInputIndex

        String memory = "4G"
        Int timeMinutes = 120
        # Whatshap 1.0, tabix 0.2.5
        String dockerImage = "quay.io/biocontainers/mulled-v2-5c61fe1d8c284dd05d26238ce877aa323205bf82:89b4005d04552bdd268e8af323df83357e968d83-0"
    }

    command {
        whatshap phase \
        ~{vcf} \
        ~{phaseInput} \
        ~{if defined(outputVCF) then ("--output " +  '"' + outputVCF + '"') else ""} \
        ~{if defined(reference) then ("--reference " +  '"' + reference + '"') else ""} \
        ~{if defined(tag) then ("--tag " +  '"' + tag + '"') else ""} \
        ~{if defined(algorithm) then ("--algorithm " +  '"' + algorithm + '"') else ""} \
        ~{true="--indels" false="" indels} \
        ~{if defined(sample) then ("--sample " +  '"' + sample + '"') else ""} \
        ~{if defined(chromosome) then ("--chromosome " +  '"' + chromosome + '"') else ""} \
        ~{if defined(threshold) then ("--threshold " +  '"' + threshold + '"') else ""} \
        ~{if defined(ped) then ("--ped " +  '"' + ped + '"') else ""} \
        tabix -p vcf ~{outputVCF}
    }

    output {
        File phasedVCF = outputVCF
        File phasedVCFIndex = outputVCF + ".tbi"
    }

    runtime {
        docker: dockerImage
        time_minutes: timeMinutes
        memory: memory
    }

    parameter_meta {
        outputVCF: {description: "Output VCF file. Add .gz to the file name to get compressed output. If omitted, use standard output.", category: "common"}
        reference: {description: "Reference file. Provide this to detect alleles through re-alignment. If no index (.fai) exists, it will be created", category: "common"}
        tag: {description: "Store phasing information with PS tag (standardized) or HP tag (used by GATK ReadBackedPhasing) (default: {description: PS)", category: "common"}
        algorithm: {description: "Phasing algorithm to use (default: {description: whatshap)", category: "advanced"}
        indels: {description: "Also phase indels (default: {description: do not phase indels)", category: "common"}
        sample: {description: "Name of a sample to phase. If not given, all samples in the input VCF are phased. Can be used multiple times.", category: "common"}
        chromosome: {description: "Name of chromosome to phase. If not given, all chromosomes in the input VCF are phased. Can be used multiple times.", category: "common"}
        threshold: {description: "The threshold of the ratio between the probabilities that a pair of reads come from the same haplotype and different haplotypes in the read merging model (default: {description: 1000000).", category: "advanced"}
        ped: {description: "Use pedigree information in PED file to improve phasing (switches to PedMEC algorithm). Columns 2, 3, 4 must refer to child, mother, and father sample names as used in the VCF and BAM/CRAM. Other columns are ignored.", category: "advanced"}
        vcf: {description: "VCF or BCF file with variants to be phased (can be gzip-compressed)", category: "required"}
        vcfIndex: {description: "Index for the VCF or BCF file with variants to be phased", category: "required"}
        phaseInput: {description: "BAM, CRAM, VCF or BCF file(s) with phase information, either through sequencing reads (BAM, CRAM) or through phased blocks (VCF, BCF)", category: "required"}
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.", category: "advanced"}
    }
}

task Stats {
    input {
        String? gtf
        String? sample
        String? tsv
        String? blockList
        String? chromosome
        File vcf

        String memory = "4G"
        Int timeMinutes = 120
        # Whatshap 1.0, tabix 0.2.5
        String dockerImage = "quay.io/biocontainers/mulled-v2-5c61fe1d8c284dd05d26238ce877aa323205bf82:89b4005d04552bdd268e8af323df83357e968d83-0"
      }

    command {
        whatshap stats \
        ~{vcf} \
        ~{if defined(gtf) then ("--gtf " +  '"' + gtf + '"') else ""} \
        ~{if defined(sample) then ("--sample " +  '"' + sample + '"') else ""} \
        ~{if defined(tsv) then ("--tsv " +  '"' + tsv + '"') else ""} \
        ~{if defined(blockList) then ("--block-list " +  '"' + blockList + '"') else ""} \
        ~{if defined(chromosome) then ("--chromosome " +  '"' + chromosome + '"') else ""}
    }

    output {
        File? phasedGTF = gtf
        File? phasedTSV = tsv
        File? phasedBlockList = blockList
    }

    runtime {
        docker: dockerImage
        time_minutes: timeMinutes
        memory: memory
    }

    parameter_meta {
        gtf: "Write phased blocks to GTF file."
        sample: "Name of the sample to process. If not given, use first sample found in VCF."
        tsv: "Filename to write statistics to (tab-separated)."
        blockList: "Filename to write list of all blocks to (one block per line)."
        chromosome: "Name of chromosome to process. If not given, all chromosomes in the input VCF are considered."
        vcf: "Phased VCF file"
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.", category: "advanced"}
    }
}

task Haplotag {
    input {
        String outputFile
        File? reference
        File? referenceFastaIndex
        String? regions
        String? sample
        File vcf
        File vcfIndex
        File alignments
        File alignmentsIndex

        String memory = "4G"
        Int timeMinutes = 120
        # Whatshap 1.0, tabix 0.2.5
        String dockerImage = "quay.io/biocontainers/mulled-v2-5c61fe1d8c284dd05d26238ce877aa323205bf82:89b4005d04552bdd268e8af323df83357e968d83-0"
    }

    command {
        whatshap haplotag \
          ~{vcf} \
          ~{alignments} \
          ~{if defined(outputFile) then ("--output " +  '"' + outputFile+ '"') else ""} \
          ~{if defined(reference) then ("--reference " +  '"' + reference + '"') else ""} \
          ~{if defined(regions) then ("--regions " +  '"' + regions + '"') else ""} \
          ~{if defined(sample) then ("--sample " +  '"' + sample + '"') else ""} \
          python3 -c "import pysam; pysam.index('~{outputFile}')"
    }

    output {
          File bam = outputFile
          File bamIndex = outputFile + ".bai"
    }

    runtime {
        docker: dockerImage
        time_minutes: timeMinutes
        memory: memory
    }

    parameter_meta {
        outputFile: "Output file. If omitted, use standard output."
        reference: "Reference file. Provide this to detect alleles through re-alignment. If no index (.fai) exists, it will be created."
        referenceFastaIndex: "Index for the reference file."
        regions: "Specify region(s) of interest to limit the tagging to reads/variants overlapping those regions. You can specify a space-separated list of regions in the form of chrom:start-end, chrom (consider entire chromosome), or chrom:start (consider region from this start to end of chromosome)."
        sample: "Name of a sample to phase. If not given, all samples in the input VCF are phased. Can be used multiple times."
        vcf: "VCF file with phased variants (must be gzip-compressed and indexed)."
        vcfIndex: "Index for the VCF or BCF file with variants to be phased."
        alignments: "File (BAM/CRAM) with read alignments to be tagged by haplotype."
        alignmentsIndex: "Index for the alignment file."
        memory: {description: "The amount of memory this job will use.", category: "advanced"}
        timeMinutes: {description: "The maximum amount of time the job will run in minutes.", category: "advanced"}
        dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.", category: "advanced"}
    }
}
