#!/usr/bin/bash
set -euo pipefail

function usage {
    echo "Usage: $0 [OPTIONS] ENDPOINT

  To get all results of a SPARQL query whose result reaches the limit set by the endpoint, repeatedly execute the query with OFFSET / LIMIT.
  Firstly, query_count.rq in the working directory or the query specified by -c option is executed.
  This is supposed to count the total number of result that query.rq retrieves.
  The number of the repetition is determined according to the result and the limit number for each retrieval (1000000 or number specified by -l).
  Then query.rq in the working directory or the query specified by -q option is repeatedly executed with OFFSET / LIMIT.
  The results for each retrieval are output to temp/ directory.
  If results are considered to be failed, the query is retried. If a query is failed for 3 consective times, exit with error.
  Finally, all results are output to stdout.

Argument:
  ENDPOINT   : URI of SPARQL endpoint.

Options:
  -l NUM     : Number of result lines to be retrieved for each query execution. (default: 1000000)
  -c FILE    : Filepath of SPARQL query to count total number of the result. (default: query_count.rq)
  -q FILE    : Filepath of SPARQL query to be executed repeatedly. (default: query.rq)" 1>&2
    exit 1
}

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
        -h)
            usage
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
    while ! [[ ${HEADER} =~ ^\"[[:alnum:]_]+\"($'\t'\"[[:alnum:]_]+\")*$ ]]; do
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
