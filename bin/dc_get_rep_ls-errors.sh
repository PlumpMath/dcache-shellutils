#!/bin/bash
#################################################################
# dc_get_rep_ls-errors.sh
#
# Author: Derek Feichtinger <derek.feichtinger@psi.ch>
#
# $Id$
#################################################################

myname=$(basename $0)

usage() {
    cat <<EOF
Synopsis:
          $myname [-r] poolname
Description:
          returns an ID list of files with error states
          The -r option will return the raw output.
EOF
}

if test x"$1" = x-h; then
    usage
    exit 0
fi
if test x"$1" = x-r; then
    raw=1
    shift
fi
poolname=$1

source $DCACHE_SHELLUTILS/dc_utils_lib.sh

if test x"$poolname" = x; then
   echo "Error: you need to provide a pool name" >&2
   exit 1
fi
check_poolname $poolname
if test $? -ne 0; then
    usage
    echo "Error: No such pool: $poolname" >&2
    exit 1
fi


#outfile=reperrors-$poolname-`date +%Y%m%d`.lst
cmdfile=`mktemp /tmp/get_pnfsname-$USER.XXXXXXXX`
if test $? -ne 0; then
    echo "Error: Could not create a cmdfile" >&2
    exit 1
fi
cat > $cmdfile <<EOF
\c $poolname
rep ls -l=e
\q
EOF

execute_cmdfile -f $cmdfile retfile
rm -f $cmdfile

if test x"$raw" != x1; then
    sed -i -ne 's/^\(0[0-9A-Z]*\).*/\1/p' $retfile
fi

cat $retfile
rm -f $retfile
