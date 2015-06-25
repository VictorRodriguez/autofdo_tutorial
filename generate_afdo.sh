#!/bin/bash

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
    		$OCPERF record -b -e br_inst_retired.near_taken -- $CWD/$i
    		$CREATE_GCOV --binary=$CWD/$i --profile=perf.data --gcov=$CWD/$i.afdo -gcov_version=1
    	done
	done <<< "$BINARIES"
	echo "Merging profiles"
	$PROFILE_MERGER $(echo *.afdo) -gcov_version=1

else
	echo "No binaries provided, use -b=binary option"
fi
