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
SOURCE_PATH=`dirname $SOURCE`
/usr/bin/SublerCLI -source "$SOURCE" -listmetadata > /tmp/metaRenamer.tmp

TITLE=`cat /tmp/metaRenamer.tmp | grep Name | cut -c7-`;
SHOW=`cat /tmp/metaRenamer.tmp| grep "TV Show" | cut -c10-`;
SEASON=`cat /tmp/metaRenamer.tmp| grep "TV Season" | cut -c12-`;
EPISODE=`cat /tmp/metaRenamer.tmp| grep "TV Episode \#" | cut -c15-`;
YEAR=`cat /tmp/metaRenamer.tmp| grep Date | cut -c15-18`;

if [ ${#EPISODE} -lt 2 ]
then
	EPISODE="0$EPISODE"
fi 


NEW_NAME="$SHOW $SEASON""x$EPISODE $TITLE.m4v"
mv $SOURCE "$SOURCE_PATH/$NEW_NAME"

echo "File renamed to $NEW_NAME"




rm /tmp/metaRenamer.tmp