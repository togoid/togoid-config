#!/bin/bash

#
#  select_offset_limit.sh
#    This script retrieves more than 1,000,000 records by making multiple requests with increasing offsets.
#

QUERY=$1
ENDPOINT=$2

# Create a temporary file to save the retrieved records
TMPFILE=`mktemp /tmp/tmp-select_offset_limit.XXXXXX`

# Initialize variables
LIMIT=100000
offset=0
num_results=0
VERBOSE=0 # Show the cumulative number of the retrieved records in stderr at each request if VERBOSE=1

# Retrieve $LIMIT records by each request
while :
do 

  if [ $VERBOSE -eq 1 ]; then echo $offset `date` >&2 ; fi

  # Request to the SPARQL endpoint
  cat $QUERY | echo $(cat) "OFFSET $offset LIMIT $LIMIT" | curl -s -H "Accept: text/csv" --data-urlencode "query@-" "$ENDPOINT" | sed -E 1d | perl -pe 's/,/\t/g; s/\"//g' >> $TMPFILE  

  # Count the cumulative number of the retrieved records
  this_num_results=`wc -l $TMPFILE | awk '{print $1}'`

  # Determine if the next query should be requested
  if [ $this_num_results -eq $num_results ] ; then break; fi

  offset=$(( $offset+$LIMIT )) 
  num_results=$this_num_results

done

# Output the retrieved records to stdout
cat $TMPFILE

rm -f $TMPFILE

if [ $VERBOSE -eq 1 ]; then echo "Completed `date`"; fi >&2
