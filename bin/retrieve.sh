#!/usr/bin/bash
set -euo pipefail

CURL=/usr/bin/curl

ENDPOINT=""
WORKDIR=temp  # Directory to keep pair files temporarily

LIMIT=1000000
QUERY_FILE=query.rq
QUERY_COUNT_FILE=query_count.rq
while (( $# > 0 ))
do
    case $1 in
        -l)
            LIMIT=$2
            shift
            ;;
        -q)
            QUERY_FILE=$2
            shift
            ;;
        -c)
            QUERY_COUNT_FILE=$2
            shift
            ;;
        *)
            ENDPOINT=$1
            ;;
    esac
    shift
done

if [ "$ENDPOINT" = "" ]; then
    echo "Error: No endpoint is specified." 1>&2
    exit 1
fi
if [ ! -e $QUERY_FILE ]; then
    echo "Error: File not found: $QUERY_FILE" 1>&2
    exit 1
fi
if [ ! -e $QUERY_COUNT_FILE ]; then
    echo "Error: File not found: $QUERY_COUNT_FILE" 1>&2
    exit 1
fi

if [ ! -e $WORKDIR ]; then
    mkdir $WORKDIR
else
    rm -f ${WORKDIR}/*
fi

TOTAL=$($CURL -sSH "Accept: text/csv" --data-urlencode query@$QUERY_COUNT_FILE $ENDPOINT | tail -1)
LOOP=$((TOTAL / LIMIT))

for i in $(seq 0 ${LOOP}); do
    # Repeat as long as the output file does not include a header line like '"source_id"\t"target_id"'.
    # If failed $TRY_LIMIT times, exit with error.
    HEADER=""
    n=0
    TRY_LIMIT=3
    while ! [[ ${HEADER} =~ ^\"[[:alnum:]_]+\"$'\t'\"[[:alnum:]_]+\"$ ]]; do
        if [[ $n = $TRY_LIMIT ]]; then
            echo "Error: Tried query #${i} ${n} times, but failed all." 1>&2
            exit 1
        fi
        OFFSET=$((i * LIMIT))
        QUERY=$(sed -e "$ a OFFSET ${OFFSET} LIMIT ${LIMIT}" $QUERY_FILE)
        $CURL -o ${WORKDIR}/${i}.txt -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT
        HEADER=`head -1 ${WORKDIR}/${i}.txt`
        n=$(($n+1))
    done
done

tail -qn +2 ${WORKDIR}/*.txt | sed -e 's/"//g'
