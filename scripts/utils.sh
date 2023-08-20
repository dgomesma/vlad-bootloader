#!/bin/bash
# Common utility functions that may be reused among scripts.

program_exists() {
	local PROGRAM=$1
	local IS_REQUIRED=$2
	
	type ${PROGRAM} &> /dev/null
	if [ $? -ne 0 ]; then
		echo 	"${PROGRAM} was not found. Make sure ${PROGRAM} is installed "\
				"and is located in \$PATH."
		if [ ${IS_REQUIRED} == "true" ]; then
			exit 1
		fi
	fi
}

assert_nargs() {
	local NARGS=$1
	local MIN_NARGS=$2

	if [[ "$NARGS" -lt "$MIN_NARGS" ]]; then
		echo	"Insufficient number of arguments. Please, run $0 with --help "\
				"flag for information on its usage." 
		exit 1
	fi
}

assert_file_exists() {
	local FILE=$1

	if [ ! -e ${FILE} ]; then
		echo "${FILE} does not exist."
		exit 1
	fi
}