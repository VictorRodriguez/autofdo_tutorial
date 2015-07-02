#!/bin/bash

INSTALLATION_PATH=${1:-"/tmp"}

which create_gcov > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "AutoFDO is installed"
	echo $(dirname "$(which create_gcov)")
else
	if [ ! -f $INSTALLATION_PATH/autofdo/create_gcov ]; then
		echo "Installing autofdo"
		cd $INSTALLATION_PATH
		git clone https://github.com/google/autofdo
		cd autofdo
		echo "$(pwd)"
		./configure
		aclocal
		automake --add-missing
		make
	fi
	echo "AutoFDO is installed"
	echo "$INSTALLATION_PATH/autofdo"
fi

