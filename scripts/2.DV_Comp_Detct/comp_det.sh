#!/bin/bash

# Usage info
show_help() {
cat << EOF
Usage: ./${0##*/} [-h] [-d1 FILE_PATH_PREFIX ] [-d2 FILE_PATH_PREFIX ] [-p Float] [+ optional parameter]
        Please give us at least three arguments.
        -h      display this help and exit

        (Required)
        -d1	Your first data file path from first application result (.out)
        -d2     Your second data file path from first application result (.out)
        -p      Reference p file (.ref.p) from Application 1 result or used one
        
        (+optional)
        -t      Multiple testing threshold p-value

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
while [ $# -gt 0 ]; do
case "$1" in
        -h)
                show_help
                exit 0
                ;;
        -d1)
                data1=$2
                shift
		;;
        -d2)
                data2=$2
                shift
		;;
        -p)
                refmaf=$2
		shift
                ;;
        -t)
                thresh=$2
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

# If any required element (3 elements) is missing..
if [ ! "${data1}" ] || [ ! "${data2}" ] || [ ! "${refmaf}" ]
then
        echo ""
        echo " Not all required arguments supplied. It requires at least three arguments."
        echo " Please pass the right number of arguments!"
        echo ""
        show_help
        exit 0
fi

echo " Application 2 : Duplicate Detection ------------"
echo " ------------ (2.DV_Comp_Detct) -----------------"
echo ""
echo " We will compare two distance vectors from each data and calculate our statistics."
echo ""

echo " - Your first distance vector file path : ${data1}"
echo " - Your second distance vector file path : ${data2}"
echo " - Your reference p file path : ${refmaf}"
echo ""

chmod +x comp_det.py

if [ ${thresh} ]
then
	echo " - Your multiple testing threshold : ${thresh}"
	./comp_det.py "${data1}" "${data2}" "${refmaf}" ${thresh}
else
	./comp_det.py "${data1}" "${data2}" "${refmaf}"
fi

echo " Finished Duplicate Detection..."
echo " ------------------------------------------------"
echo " ------------------------------------------------"
