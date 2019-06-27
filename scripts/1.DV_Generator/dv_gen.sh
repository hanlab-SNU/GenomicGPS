#!/bin/bash

# Define a timestamp function
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Usage info
show_help() {
cat << EOF
Usage: ./${0##*/} [-h] [-n <220|...> ] [-k <11|2504> ] [-d FILE_PATH_PREFIX ] [+ optional parameter]
        Please give us at least three arguments.
        -h      display this help and exit

        (Required)
        -n      # of loci (snps).
        -k      # of satellites (references).
        -d      Your plink file (.bed/.bim/.fam or .map/.ped) : data path and prefix

        (+optional)
        -r      Reference file (.ref) from the previous result
        -p      Reference p file (.ref.p) from the previous result

EOF
}

# Check argument not empty
if [ $# -eq 0 ]
then
        echo ""
        echo " No arguments supplied. It requires at least three arguments."
        echo " Please pass the arguments!."
        echo ""
        show_help
        exit 0
fi

# Dash(-) argument parameter
while getopts "hn:k:d:r:p:" opt; do
    case $opt in
        h)
                show_help
                exit 0
                ;;
        n)
                N=$OPTARG
                ;;
        k)
                K=$OPTARG
                ;;
        d)
                mydata=$OPTARG
                ;;
        r)
                refdata=$OPTARG
                ;;
        p)
                refmaf=$OPTARG
                ;;
        \?)
                echo " WARNING: Unknown option (ignored): %s\n" "$1" >&2
                ;;

        *)
                show_help
                exit 1
		;;
    esac
done

# If any required element (3 elements) is missing..
if [ ! ${N} ] || [ ! ${K} ] || [ ! "${mydata}" ]
then
        echo ""
        echo " Not all required arguments supplied. It requires at least three arguments."
        echo " Please pass the right number of arguments!"
        echo ""
        show_help
        exit 0
fi

# Reference folder Uncompressing
if [ ! -d "../../Reference" ]
then
	echo "Reference folder uncompressing..."
	tar -xzvf Reference.tar.gz
fi

echo " Application 1. Making Distance Vector ----------"
echo " ------------- (1.DV_Generator) -----------------"
echo ""

echo " - Your N (# of loci) : ${N}"
echo " - Your K (# of refrence) : ${K}"
echo " - Your data path and prefix : ${mydata}"

# If reference & reference p file exist
if [ "${refdata}" ] && [ "${refmaf}" ]
then
    echo "Your reference data is not default."
    echo " - Your reference data path : ${refdata}"
    echo " - You put the reference p path : ${refmaf}"
fi
echo ""

# Check N/K >20
if [ $(expr $N / $K)  -ge 20 ]
then
	echo " Start Distance Vector Generating..."

else
	echo "If you want to get a good result, you should change to change the N and K ( N / K > 20 )"
	read -p "Will you change the argument? (y/n)" CONFT
	if [ "$CONFT" = "n" ]; then
		echo "Start Distance Generating..."
	else
		kill -INT $$
	fi
fi

# 1. Start Parsing
echo " -----------------********--------------------"
echo " Step 1. Parse the data to input data"
echo ""

if [ -f "${mydata}.ped" ]
then
	echo " You have plink regular text file (.map/.ped) for input"
	echo " ---------------------------------------------"
	echo ""
	plink --file "${mydata}" --recode A --allow-no-sex --keep-allele-order --out "${mydata}"

elif [ -f "${mydata}.bed" ]
then
	echo " You have plink binary file (.bed/.bim/.fam) for input"
	echo " ---------------------------------------------"
	echo ""
	plink --bfile "${mydata}" --recode A --allow-no-sex --keep-allele-order --out "${mydata}"

else
	echo " Data does not exist. Please check your data path and prefix again."
	exit 128
fi

rm -f "${mydata}*.log"
rm -f "${mydata}*.nosex"

cat "${mydata}.raw" | cut -d ' ' -f7- | awk 'NR == 1 {gsub(/\_[a-zA-Z0-9]/,"")}; {print}' > "${mydata}.input"

echo ""
echo " Your input data (.input) is ready for next step!"
chmod +x dv_gen.py


# 2. Making Distance Vector
echo ""
echo " -----------------********--------------------"
echo " Step 2. Distance Generating"
echo ""

if [ -f "${refdata}" ] && [ -f "${refmaf}" ]
then
	./dv_gen.py ${N} ${K} "${mydata}" "${refdata}" "${refmaf}"
else
	./dv_gen.py ${N} ${K} "${mydata}"
fi

echo " End time : ${timestamp}"
echo " Finished Distance Generating..."
echo " ------------------------------------------------"
echo " ------------------------------------------------"
echo ""
