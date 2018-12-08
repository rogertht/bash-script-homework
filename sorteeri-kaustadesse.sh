#!/bin/bash
set -e

if  [ "${1}" == "-h" ] || 
    [ "${1}" == "--help" ] || 
    [ "${1}" == "--h" ] || 
    [ "${1}" == "-help" ]
    [ "${1}" == "/?" ]
then
    echo ""
    echo "Programm otsib esimese argumendina antud kaustast
ülejäänud argumentidega määratud laienditega faile.
Selliste laienditega failide leidmisel tekitab programm
need kaustad ja liigutab need failid vastavatesse kaustadesse.

Leidub failinimesid, mida programm käsitseda ei suuda."
    echo ""
    echo "Kasutamine: `basename ${0}` kaust laiend1 laiend2 ..."
    echo ""
    exit 0
fi

if [ -d "${1}" ]
then
    cd "${1}"
    shift

    for laiend in "$@"
    do
        loendur=-1
		exec 9< <( find . -maxdepth 1 -type f -iname "*.${laiend}" -print0 )
		while IFS= read -r -d '' -u 9
		do
            loendur=$(($loendur+1))

			file_path="$(readlink -fn -- "$REPLY"; echo x)"
			file_path="${file_path%x}"

			JADA[$loendur]="${file_path}"
		done
        unset IFS

        if [ ! -z "${JADA[0]}" ]
        then
            if [ ! -e "${laiend}" ]
            then
                if [ ! -d "${laiend}" ]
                then
                    mkdir "${laiend}"
                    echo 
                fi

                i=0
                while [ $i -lt $(($loendur+1)) ]
                do            
                    mv "${JADA[$i]}" "${laiend}"
                    i=$(($i+1))
                done

            else
                echo "Kausta ${laiend} ei saanud luua, sest selline nimi on juba kasutuses."
            fi
        else
            echo "Laiendiga .${laiend} faile ei leidu korrastatavas kaustas."
        fi


    done
else
    echo "Kausta ${1} ei leidu."
    echo "Kasutamine: `basename ${0}` kaust laiend1 laiend2 ..."
fi

