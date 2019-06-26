## GenomicGPS `v1.0`

## Introduction

` GenomicGPS`  is a command line tool for appling multilateration technique to genomic data. It aims to achieve a balance between data sharing and privacy protection. The software includes modules <ins>(1) to generate distance vectors given genomic data</ins> and <ins>(2) to detect overlapping samples given distance vectors</ins>.

Below we briefly describe short instructions for using the software.

## Instructions

### Download the packages
In order to download `GenomicGPS`, you can clone this repository via the commands.

Before use 'git clone' command, please install extension of git called [Git Large File Storage (LFS)](https://git-lfs.github.com/) before cloning for reference file (>100MB). Since it has many different ways to install the LFS for various OS, please refer [this page](https://github.com/git-lfs/git-lfs/wiki/Installation).

```
$ git clone https://github.com/hanlab-SNU/GenomicGPS.git
$ cd GenomicGPS
```

### Input data format
The current implementation can import data from [PLINK 1 binary / PLINK 1 text](https://www.cog-genomics.org/plink2/input)
format. <br>
Please ensure the `.bed/.bim/.fam` filesets or `.map/.ped` filesets are all present in the same path. When you implement the code, you should give the path and prefix for the data.

### Executing the whole code at one go
If you want to make distance vector only in this time, then check '[Making Distance Vector](https://github.com/hanlab-SNU/GenomicGPS#1-making-distance-vector-1dv_generator-)' part below.
```
$ chmod +x genomicgps.sh
$ ./genomicgps.sh -n N(#snps) -k K(#satellites) -d1 mydata1 -d2 mydata2
                   (+ optional parameter : -t threshold)
```
### Executing the codes by each step

#### 1. Making Distance Vector (1.DV_Generator) :
```
$ cd 1.DV_Generator
$ chmod +x dv_gen.sh

# without Reference (default)
$ ./dv_gen.sh -n N(#snps) -k K(#satellites) -d mydata1

or

# with Reference
$ ./dv_gen.sh -n N(#loci) -k K(#satellites) -d mydata2 -r refdata(.ref) -p refdata.p(ref.p)
```
Above mentioned, user can put PLINK filesets as input. Before the examination, user should provide the number of reference SNP loci (N) and number of references (K), also user can optionally provide the reference genotype data and reference allele frequency (`.ref/.ref.p`) from the result of previous implementation. <br>
 - **Tips for choosing N and K** : We found that at least K > 10 references were needed. Also, the ratio N / K needs to be sufficiently large (>20) for accurate approximations. If you haven't decide it yet, then use N = 1000, K = 20.

#### 2. Sample Overlap Detection (2.DV_Comp_Detct) :
```
$ cd 2.DV_Comp_Detct
$ chmod +x comp_det.sh
$ ./comp_det.sh -d1 mydata1.out -d2 mydata2.out -p refdata.p(ref.p) (+ optional : -t threshold)
```
This code compares two distance vectors from different studies to detect sample overlap. In first step, distance vector (`.out`) and the subset of reference allele frequency file (`.ref.p`) , which is output from the DV_Generator, will be used. From the subset of reference allele frequency (`.ref.p`), the &Sigma; (variance-covariance matrix) will be calculated. Then, statistic and p-value will be calculated. You can get the statistic matix (`.stat`) and sigma matrix (`.sigma`) for result.
<br>
<br>
In addition, It is also optional to put the threshold p-value for the multiple testing. By default, it generates a random threshold between the range of null and alternative simulated statistics.

#### 3. JAVA code : click >> [Greedy Algorithm package](https://github.com/hanlab-SNU/GenomicGPS/tree/master/scripts/Java/greedy_algorithm_package)

### Reference data
`1000 Genomes phase 3` dataset was used for the satellites reference.

### Sample data
* PATH : `./sample_data/`

### LICENSE
This project is licensed under the terms of the MIT license.

### Dependencies
Please make sure the software called [PLINK](http://zzz.bwh.harvard.edu/plink/download.shtml) is installed. Also, the installed plink path should be added to system path. <br>
You can verify by

```
$ plink --version
```

Also, you should install [python3](https://www.python.org/downloads/) and [pip](https://pip.pypa.io/en/stable/installing/) or [anaconda](https://www.anaconda.com/distribution/#download-section) for downloading the following necessary packages :

- numpy
- pandas
- scipy
- [datatable](https://github.com/h2oai/datatable#Installation) (It only supports MacOS, linux)

If you are using Python, you can install the required packages with:

```
$ pip install -U numpy pandas scipy datatable
```

If you are using Anaconda, you can install the required packages with:

```
$ conda install -c conda-forge numpy pandas scipy pip
$ pip install datatable
```

## Citation
If you use the software `genomicGPS`, please cite [Kim et al. Genomic GPS: using genetic distance for genomic analysis without disclosing personal genome. xxxxx (2019)](www.)

## Reference
1. [PLINK v1.9](www.cog-genomics.org/plink/2.0/) | Chang CC, Chow CC, Tellier LCAM, Vattikuti S, Purcell SM, Lee JJ Second-generation PLINK: rising to the challenge of larger and richer datasets. GigaScience, 4. (2015) doi:10.1186/s13742-015-0047-8
2. [1000 Genome Phase 3 data](https://www.cog-genomics.org/plink/2.0/resources) | A global reference for human genetic variation, The 1000 Genomes Project Consortium, Nature 526, 68-74 (2015) doi:10.1038/nature15393

## Support
Please contact [hanlab.snu@gmail.com](mailto:hanlab.snu@gmail.com)
