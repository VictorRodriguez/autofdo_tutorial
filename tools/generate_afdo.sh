#!/bin/bash

# Copyright (c) <year> Intel Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at//
#   http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

for i in "$@"
do
case $i in
    -i=*|--installation_path=*)
    INSTALLATION_PATH="${i#*=}"
    shift
    ;;
    -b=*|--binaries=*)
    BINARIES="${i#*=}"
    shift
    ;;
    --default)
    DEFAULT=YES
    shift
    ;;
    *)
    ;;
esac
done

INSTALLATION_PATH=${INSTALLATION_PATH:-"/tmp"}

# echo $INSTALLATION_PATH
# echo $BINARIES

if [ ! -z "$BINARIES" ]; then

	echo "Verifying files"
	CWD="$(pwd)"
	while IFS=',' read -ra ADDR; do
    	for i in "${ADDR[@]}"; do
        	# echo $i
        	if [ ! -f $i ]; then
        		echo "$i doesn't exist"
        		exit 1
        	fi
    	done
	done <<< "$BINARIES"

	which create_gcov
	if [ $? -eq 0 ]; then
		CREATE_GCOV="$(which create_gcov)"
		PROFILE_MERGER="$(which profile_merger)"
	else
		if [ ! -f $INSTALLATION_PATH/autofdo/create_gcov ]; then
			echo "Installing autofdo"
			cd $INSTALLATION_PATH
			git clone https://github.com/google/autofdo
			cd autofdo
			./configure
			make
		fi
		CREATE_GCOV=$INSTALLATION_PATH/autofdo/create_gcov
	fi

	which ocperf.py
	if [ $? -eq 0 ]; then
		OCPERF="$(which ocperf.py)"
	else
		if [ ! -f $INSTALLATION_PATH/pmu-tools/ocperf.py ]; then
			echo "Installing pmu-tools"
			cd $INSTALLATION_PATH
			git clone https://github.com/andikleen/pmu-tools
		fi
		OCPERF=$INSTALLATION_PATH/pmu-tools/ocperf.py
	fi

	echo "Generating profiles"
	cd $CWD
	while IFS=',' read -ra ADDR; do
    	for i in "${ADDR[@]}"; do
    		$OCPERF record -b -g -e br_inst_retired.near_taken -o $CWD/$i.data -- $CWD/$i
    		#$CREATE_GCOV --binary=$CWD/$i --profile=perf.data --gcov=$CWD/$i.afdo -gcov_version=1
    	done
	done <<< "$BINARIES"
	echo "Merging profiles"
	#$PROFILE_MERGER $(echo *.afdo) -gcov_version=1

else
	echo "No binaries provided, use -b=binary option"
fi
