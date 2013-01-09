#!/bin/bash
# This script uses SublerCLI to rename TV Shows according to the metadata embedded into the file
# The intended use is to rename files that have been processed by iFlicks, which is quite good at
# interpreting the wacky naming schemes used by uploaders for their files

if [ $# -lt 1 ]
then
	echo 'USAGE: metaRenamer [sourceFile]'
	echo '-----------------------------------'
	echo 'You did not provide the source file'
	break;
fi

if [ ! -f "$1" ]
then
	echo "Error: can't find file $1"
	break;
fi


SOURCE=$1
SOURCE_PATH=`dirname "$SOURCE"`
SUBLER_OUTPUT=`/usr/bin/SublerCLI -source "$SOURCE" -listmetadata`

TITLE=`echo "$SUBLER_OUTPUT" | grep Name | cut -c7-`;
SHOW=`echo "$SUBLER_OUTPUT" | grep "TV Show" | cut -c10-`;
SEASON=`echo "$SUBLER_OUTPUT" | grep "TV Season" | cut -c12-`;
EPISODE=`echo "$SUBLER_OUTPUT" | grep "TV Episode \#" | cut -c15-`;
YEAR=`echo "$SUBLER_OUTPUT" | grep Date | cut -c15-18`;

if [ ${#EPISODE} -lt 2 ]
then
	EPISODE="0$EPISODE"
fi 


NEW_NAME="$SHOW $SEASON""x$EPISODE $TITLE.m4v"
mv $SOURCE "$SOURCE_PATH/$NEW_NAME"

echo "File renamed to $NEW_NAME"
