#!/bin/bash

# Usage
#
#   # from the the ZINC_mirror base directory
#   source setup_environment.sh
#
#   # given that there is a file 'tranches/<tranches_id>.tsv'
#   # with columns (no header)
#         origin_file_path
#         destination_file_path
#
#   ./scripts/globus_zinc.sh tranches/<tranches_id>.tsv
#   # if it asks, authenticate by visiting the given url and entering credentials
#   # it will then initiate an asyncrhonous globus file transfer for each of the requted files
#   
#   # check status with
#   globus task show ${task_id}
#
#
#   # see README.md for more context


# check that we've initialized the environment
if [ -z ${ZINC_MIRROR_BASE+x} ]; then
    echo "ERROR: The ZINC Mirror environment has not been initialized"
    echo "ERROR: please run 'source setup_environment_dataden.sh'"
    exit 1
fi


TRANCHES_PATH=$1

echo "######################"
echo "# Authenticating ... #"
echo "######################"

# I'm not sure if it requires login in twice to authenticate for both the origin and destination?
#globus login

#globus login --gcs $ORIGIN_ID
# copy url to browser and login...

#globus login --gcs ${ORIGIN_ID}
#globus login --gcs ${DESTINATION_ID}


globus endpoint activate --web ${ORIGIN_ID}

# To anticipate the following error:
# The collection you are trying to access data on requires you to grant consent for the Globus CLI to access it.
globus session consent "urn:globus:auth:scope:transfer.api.globus.org:all[*https://auth.globus.org/scopes/${DESTINATION_ID}/data_access]"


#if [ -z ${DESTINATION_PATH} ]; then
#    echo "Creating destination path ${DESTINATION_PATH}} ..."
#    mkdir -p ${DESTINATION_PATH}
#fi

echo "Retriving tranches from ZINC"
echo "Globus label: ${GLOBUS_LABEL}"




echo "###################"
echo "# Origin Endpoint #"
echo "###################"
globus collection show ${ORIGIN_ID}
echo "Origin path:             ${ORIGIN_PATH}"

echo ""
echo ""
echo "########################"
echo "# Destination Endpoint #"
echo "########################"
globus collection show ${DESTINATION_ID}
echo "Destination path:        ${DESTINATION_ID}"


echo ""
echo "tranches filename: ${TRANCHES_PATH}"
echo "retriving $(wc -l < ${TRANCHES_PATH}) .tar files"


cmd="globus transfer \
  $ORIGIN_ID:${ORIGIN_PATH} \
  $DESTINATION_ID:${DESTINATION_PATH} \
  --sync-level checksum \
  --jmespath task_id \
  --format=UNIX \
  --preserve-mtime \
  --skip-source-errors \
  --batch ${TRANCHES_PATH} \
  --label \"${GLOBUS_LABEL}\" \
  --verbose "

echo "#globus command:"
echo $cmd

task_id=$($cmd)
echo "Task ID: ${task_id}"
echo "Check status with 'globus task show ${task_id}'"
return ${task_id}
