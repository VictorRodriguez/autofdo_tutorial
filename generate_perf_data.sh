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
	-c=*|--command=*)
	COMMAND="${i#*=}"
	shift
	;;
	*)
	;;
esac
done

INSTALLATION_PATH=${INSTALLATION_PATH:-"/tmp"}

if [ ! -z "$COMMAND" ]; then

	CWD="$(pwd)"
	IFS=' ' read -a c_array <<< "$COMMAND"
	BINARY=${c_array[0]}
	IFS='/' read -a b_array <<< "$BINARY"
	NAME=${b_array[-1]}

	which ocperf.py > /dev/null 2>&1
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
	$OCPERF record -b -g -e br_inst_retired.near_taken -o $CWD/$NAME.data -- $COMMAND

else
	echo "No command provided, use -c=\"tool --params\" option"
fi

