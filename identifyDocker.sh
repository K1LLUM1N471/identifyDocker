#!/bin/bash
# 2021-12-14 14:12

################
# CONFIGURATON #
################

HITS="hits.txt"
HITS_CLEANED="hits_cleaned.txt"
DOCKER_NAMES="docker-names.txt"
LOG4J_DETECTOR="log4j-detector-2021.12.13.jar"

#############
# FUNCTIONS #
#############

########
# MAIN #
########

clear

# https://github.com/mergebase/log4j-detector
if [ ! -f $HITS ]
then
   java -jar $LOG4J_DETECTOR /var > $HITS
fi

# Skip first lines and all problems
cat $HITS | grep -v "Problem" | grep -v "\-\-" > $HITS_CLEANED

docker ps -a --format {{.Names}} > $DOCKER_NAMES

while read FOUND_LINE
do
#   echo "FOUND_LINE: '$FOUND_LINE'"

   LAYER_ID=$(echo "$FOUND_LINE" | cut -d"/" -f6)
#   echo "LAYER_ID: '$LAYER_ID'"

   while read DOCKER_NAME
   do
#      echo "DOCKER_NAME: '$DOCKER_NAME'"

      if [ ! -z "$(docker inspect $DOCKER_NAME | grep $LAYER_ID)" ]
      then
         echo "$FOUND_LINE"
         echo "Found in '$DOCKER_NAME'"
         echo ""
      fi
   done < $DOCKER_NAMES
done < $HITS_CLEANED
