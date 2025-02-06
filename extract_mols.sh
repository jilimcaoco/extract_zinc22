#!/bin/bash

get_tranch() {
    
   # Inputs: TRANCH : str example : "H21M000"
   # 	    OUTPUT_DIR : str example : "~/foo/fun/"
   #	    DESIRED_TYPE : str example : "sdf",  "db2", "smi"
   
    TRANCH=${1}
    OUTPUT_DIR=${2}
    DESIRED_TYPE=${3}
    
    ATOM_COUNT=${TRANCH:1:2}
    LOGP=${TRANCH:4:3}

    if [ "${DESIRED_TYPE}" = "db2" ] || [ "${DESIRED_TYPE}" = "sdf" ]; then
#	echo "GRABBING: ${DESIRED_TYPE} in ${TRANCH}..."
	for ZINC_LETTER_TRANCH in zinc-22* ; do
#	    echo "DEBUGGING: ${ZINC_LETTER_TRANCH}"
	    for ZINC_2D_TRANCH in ${ZINC_LETTER_TRANCH}/"H${ATOM_COUNT}"/* ; do
#		echo "DEBUGGING: ${ZINC_2D_TRANCH}"
		BASE_2D=$(basename "${ZINC_2D_TRANCH}" )
		if [ "${BASE_2D}" = "${TRANCH}" ]; then
#		    echo "DEBUGGING: TRANCH MATCH!"
		    for DIR in ${ZINC_2D_TRANCH}/* ; do
#			echo "DEBUGGING: ${DIR}"
			if [ -d "${DIR}" ]; then
			    for FILE in ${DIR}/*".${DESIRED_TYPE}.tgz"; do
#				echo " mv ${FILE} ${OUTPUT_DIR}"
				cp ${FILE} ${OUTPUT_DIR}
			    done
			fi      
		    done		
		fi
	    done
	done
    fi
	
    if [ "${DESIRED_TYPE}" = "smi" ]; then
	for ZINC_LETTER_TRANCH in zinc-22* ; do
	    for ZINC_2D_TRANCH in ${ZINC_LETTER_TRANCH}/"H${ATOM_COUNT}"/*; do
#		echo "${ZINC_2D_TRANCH}"
		BASE_2D=$(basename "${ZINC_2D_TRANCH}" )
		if [ "${BASE_2D}" = "${TRANCH}" ]; then
#		    echo "HIT HIT HIT"
		    for FILE in ${ZINC_2D_TRANCH}/*.gz; do
#			echo " mv ${FILE} ${OUTPUT_DIR}"
			cp ${FILE} ${OUTPUT_DIR}
                    done
		fi
	    done
	done
    fi
}

main () {
    
    #usage: extract_mols.sh heavy_atom_start heavy_atom_end logp_start logp_end 
   # 	   desired_type /path/to/output 
    HEAVY_ATOM_START=${1}
    HEAVY_ATOM_END=${2}
    LOGP_START=${3}
    LOGP_END=${4}
    OUTPUT_DIR=${6}
    DESIRED_TYPE=${5}

    if [ "${DESIRED_TYPE}" != "sdf" ] && \
	   [ "${DESIRED_TYPE}" != "db2" ] && \
	   [ "${DESIRED_TYPE}" != "smi" ]; then
	echo "ERROR: DESIRED_TYPE must be sdf, db2, or smi"
	exit 1
    fi

    mkdir -p ${OUTPUT_DIR}

    LOGP_START_LETTER=${LOGP_START::1}
    LOGP_START_NUM=${LOGP_START:1}
    LOGP_START=${LOGP_START_NUM}
    
    LOGP_END_LETTER=${LOGP_END::1}
    LOGP_END_NUM=${LOGP_END:1}
    LOGP_END=${LOGP_END_NUM}

    cd ${DESTINATION_PATH}
    if [[ "$LOGP_START_LETTER" == "P" && "$LOGP_END_LETTER" == "P" ]]; then 
	for ((HEAVY_VAL=${HEAVY_ATOM_START} ; HEAVY_VAL<=${HEAVY_ATOM_END} ; HEAVY_VAL++  )); do
	    for (( LOGP_VAL=${LOGP_START} ; LOGP_VAL<=${LOGP_END} ; LOGP_VAL += (LOGP_VAL < 500 ? 10 : 100)  )); do
		FORMATTED_PVAL=$(printf "%03d" "${LOGP_VAL}")
		#if LOGP_START_LETTER =
		TRANCH="H${HEAVY_VAL}P${FORMATTED_PVAL}"
		echo "now extracting ${TRANCH}"
		get_tranch ${TRANCH} ${OUTPUT_DIR} ${DESIRED_TYPE}
	    done
	done
    fi

    if [[ "$LOGP_START_LETTER" == "M" && "$LOGP_END_LETTER" == "M" ]]; then
	for ((HEAVY_VAL=${HEAVY_ATOM_START} ; HEAVY_VAL<=${HEAVY_ATOM_END} ; HEAVY_VAL++  )); do
	    for (( LOGP_VAL=${LOGP_START} ; LOGP_VAL>=${LOGP_END} ; LOGP_VAL -= 100)); do

		FORMATTED_PVAL=$(printf "%03d" "${LOGP_VAL}")
		
		TRANCH="H${HEAVY_VAL}M${FORMATTED_PVAL}"
		echo "now extracting ${TRANCH}"
		get_tranch ${TRANCH} ${OUTPUT_DIR} ${DESIRED_TYPE}
	    done
	done
    fi

    if [[ "$LOGP_START_LETTER" == "M" && "$LOGP_END_LETTER" == "P" ]]; then

	#doing M first until you hit "M000"
	for ((HEAVY_VAL=${HEAVY_ATOM_START} ; HEAVY_VAL<=${HEAVY_ATOM_END} ; HEAVY_VAL++  )); do
	    for (( LOGP_VAL=${LOGP_START} ; LOGP_VAL>=0 ; LOGP_VAL = LOGP_VAL - 100)); do

		FORMATTED_PVAL=$(printf "%03d" "${LOGP_VAL}")
		
		TRANCH="H${HEAVY_VAL}M${FORMATTED_PVAL}"
		echo "now extracting ${TRANCH}"
		get_tranch ${TRANCH} ${OUTPUT_DIR} ${DESIRED_TYPE}
	    done
	done

	#now doing P
        for ((HEAVY_VAL=${HEAVY_ATOM_START} ; HEAVY_VAL<=${HEAVY_ATOM_END} ; HEAVY_VAL++  )); do
	    for (( LOGP_VAL=0 ; LOGP_VAL<=${LOGP_END} ; LOGP_VAL += (LOGP_VAL < 500 ? 10 : 100) )); do
		FORMATTED_PVAL=$(printf "%03d" "${LOGP_VAL}")
		#if LOGP_START_LETTER =
		TRANCH="H${HEAVY_VAL}P${FORMATTED_PVAL}"
		echo "now extracting ${TRANCH}"
		get_tranch ${TRANCH} ${OUTPUT_DIR} ${DESIRED_TYPE}

	    done
	done
    fi

    echo "finished extracting files..."
    cd -
    
}

echo "usage: extract_mols.sh heavy_atom_start heavy_atom_end logp_start logp_end desired_type /path/to/output"
echo "example usage: ./extract_mols.sh 11 13 M300 M300 db2 /home/limcaoco/tubro/ZINC_mirror/DOCK6_demo"

HEAVY_ATOM_START=${1}
HEAVY_ATOM_END=${2}
LOGP_START=${3}
LOGP_END=${4}
OUTPUT_DIR=${6}
DESIRED_TYPE=${5}

main ${HEAVY_ATOM_START} ${HEAVY_ATOM_END} ${LOGP_START} ${LOGP_END} \
     ${DESIRED_TYPE} \
     ${OUTPUT_DIR}
