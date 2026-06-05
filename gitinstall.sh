#!/bin/bash

echo "Script to install git"
echo "Installation started"
if [ "$(uname)" == "Linux" ];
then
	echo "This is linux box, installing git"
	sudo apt install git -y
elif [ "$(uname)" == "Darwin" ];
then
	echo -e "This is not linux box\nThis is MacOS"
	brew install git
else
	echo "Not installing"
fi
