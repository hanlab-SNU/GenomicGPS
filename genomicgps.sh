#!/bin/bash

# Define a timestamp function
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

echo "*------------------------------------------------*"
echo "*------------- GenomicGPS Software --------------*"
echo "*---- v.1.0 Seoul National University Hanlab ----*"
echo "*------------------------------------------------*"
echo " - Start time : ${timestamp}"

# Usage info
show_help() {
cat << EOF
Usage: ./${0##*/} [-h] [-n <220|...> ] [-k <11|2504> ] [-d1 FILE_PATH_PREFIX ] [-d2 FILE_PATH_PREFIX ] [+ optional parameter]
	Please give us at least four arguments.
	-h	display this help and exit

	(Required)
	-n	# of loci (snps).
	-k	# of satellites (references).
	-d1	Your plink file (.bed/.bim/.fam or .map/.ped) : first data path and prefix
	-d2	Your plink file (.bed/.bim/.fam or .map/.ped) : second data path and prefix
	
	(+optional)
	-r	Reference file (.ref) from the previous result
	-p	Reference p file (.ref.p) from the previous result
	-t	Multiple testing threshold p-value

EOF
}

# Check argument not empty
if [ $# -eq 0 ]
then
	echo ""
	echo " No arguments supplied. It requires at least four arguments."
	echo " Please pass the arguments."
	echo ""
	show_help
	exit 0
fi

# Dash(-) argument parameter
while [ $# -gt 0 ]; do
case "$1" in
	-h)
		show_help
		exit 0
		;;
	-n)
		echo ""
		echo " Check the parameter. Before the software implementation :"
		N=$2
		echo "  -n parameter: ${N}"
		shift
		;;
	-k)
		K=$2
		echo "  -k parameter: ${K}"
		shift
		;;
	-d1)
		data1=$2
		echo "  -d1 parameter: ${data1}"
		shift
		;;
	-d2)
		data2=$2
		echo "  -d2 parameter: ${data2}"
		shift
		;;
	-r)
		REF=$2
		echo "  -r parameter: ${REF}"
		shift
		;;
	-p)
		REF_P=$2
		echo "  -p parameter: ${REF_P}"
		shift
		;;
	-t)
		THR=$2
		echo "  -t parameter: ${THR}"
		shift
		;;

	\?)
		echo " WARNING: Unknown option (ignored): %s\n" "$1" >&2
		;;

	:)
		echo " Option -$2 requires an argument." >&2
		exit 1
		;;
esac
shift
done

# If any required element (4 elements) is missing..
if [ ! ${N} ] || [ ! ${K} ] || [ ! ${data1} ] || [ ! ${data2} ]
then
        echo ""
	echo " Not all required arguments supplied. It requires at least four arguments."
        echo " Please pass the right number of arguments!"
        echo ""
        show_help
        exit 0
fi

# Before use Readlink
unameOut="$(uname -s)"
case "${unameOut}" in
        Linux*)         machine=Linux
        Darwin*)        machine=Mac
			echo ""
                        echo "Your PC OS is ${machine}"
                        echo "We are downloading the coreutils and gcut for using linux bash command..."
                        brew install coreutils
                        ln -s /usr/local/bin/greadlink /usr/local/bin/readlink
			echo ""
                        ;;
        CYGWIN*)        machine=Cygwin
			echo ""
                        echo "Your PC OS is ${machine}. This software is not supported for your system."
			exit 0;;
        MINGW*)         machine=MinGw
			echo ""
                        echo "You are using ${machine}. This software is not supported for your system."
			exit 0;;
        windows*)       machine=Windows
			echo ""
                        echo "Your PC OS is ${machine}. This software is not supported for your system."
			exit 0;;
        *)              machine=UNKOWN
			echo ""
                        echo "UNKNOWN:Your PC OS is not recognized : ${machine}."
			exit 0;;
esac


# Relative path handling
if [[ ${data1} == /* ]]; then 
	:
else 
	echo ""
	echo " You put relative path for data 1."
	echo " We will get the absoulte path for data 1."
	data1=`readlink -e -m ${data1}`
fi

if [[ ${data2} == /* ]]; then
	:
else 
	echo ""
        echo " You put relative path for data 2."
        echo " We will get the absoulte path for data 2."
        data2=`readlink -e -m ${data2}`
fi

# Reference folder Uncompressing
if [ ! -d "./Reference" ]
then
	echo ""
	echo "Reference folder uncompressing..."
	tar -xzvf Reference.tar.gz
	echo ""
fi

cd ./scripts/1.DV_Generator
chmod +x dv_gen.*

echo ""
# First step : Making Distance Vector (1.DV_Generator)

if [ ! ${REF} ] && [ ! ${REF_P} ]
then 
	./dv_gen.sh -n ${N} -k ${K} -d ${data1}
	./dv_gen.sh -n ${N} -k ${K} -d ${data2} -r ${data1}.ref -p ${data1}.ref.p
else
	./dv_gen.sh -n ${N} -k ${K} -d ${data1} -r ${REF} -p ${REF_P}
	./dv_gen.sh -n ${N} -k ${K} -d ${data2} -r ${REF} -p ${REF_P}
fi

cd ../2.DV_Comp_Detct/
chmod +x comp_det.*

echo ""
# Second step : Duplication Detection (2.DV_Comp_Detct)
if [ ! ${THR} ]
then
	if [ ! ${REF} ] && [ ! ${REF_P} ]
	then
		./comp_det.sh -d1 ${data1}.out -d2 ${data2}.out -p ${data1}.ref.p
	else
		./comp_det.sh -d1 ${data1}.out -d2 ${data2}.out -p ${REF_P}
	fi
else
	if [ ! ${REF} ] && [ ! ${REF_P} ]
	then	
		./comp_det.sh -d1 ${data1}.out -d2 ${data2}.out -p ${data1}.ref.p -t ${THR}
	else
		./comp_det.sh -d1 ${data1}.out -d2 ${data2}.out -p ${REF_P} -t ${THR}
	fi
fi
echo " All steps are finished."
echo " End time : ${timestamp}"
echo "*------------------------------------------------*"
echo "*------------------------------------------------*"
