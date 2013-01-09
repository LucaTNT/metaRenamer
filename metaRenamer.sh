#!/bin/bash
# metaRenamer v0.1
# ----------------
# Author: Luca Zorzi @LucaTNT
#
# This script uses SublerCLI to rename TV Shows according to the metadata embedded into the file
# The intended use is to rename files that have been processed by iFlicks, which is quite good at
# interpreting the wacky naming schemes used by uploaders for their files



# Define some functions

# Usage, called when used does not specify an input file
function usage
{
	echo 'USAGE: metaRenamer [sourceFile]'
	echo '-----------------------------------'
	echo 'You did not provide the source file'
	exit 1;
}

# Function that deals with TV shows
function process_tvshow
{
	SHOW=`echo "$SUBLER_OUTPUT" | grep "TV Show" | cut -c10-`;
	SEASON=`echo "$SUBLER_OUTPUT" | grep "TV Season" | cut -c12-`;
	EPISODE=`echo "$SUBLER_OUTPUT" | grep "TV Episode \#" | cut -c15-`;
	
	# Add a leading zero for single-digit episodes
	if [ ${#EPISODE} -lt 2 ]
	then
		EPISODE="0$EPISODE";
	fi 


	NEW_NAME="$SHOW $SEASON""x$EPISODE $TITLE.m4v";
	rename $SOURCE "$SOURCE_PATH/$NEW_NAME";

	echo -e "TV show renamed to \033[33;40;5m\033[1m$NEW_NAME\033[0m";
}

# Function that deals with movies
function process_movie
{
	NEW_NAME="$TITLE.m4v";
	rename $SOURCE "$SOURCE_PATH/$NEW_NAME";

	echo -e "Movie renamed to \033[33;40;5m\033[1m$NEW_NAME\033[0m";
}

# Function that actually performs renaming
function rename
{
	#mv "$1" "$2";
	return;
}


# Check if user has supplied an input file
if [ $# -lt 1 ]
then
	usage;
fi

# Check if file exists
if [ ! -f "$1" ]
then
	echo "Error: can't find file $1";
	exit 1;
fi

# Define some useful variables
SOURCE=$1;
SOURCE_PATH=`dirname "$SOURCE"`;
SUBLER_OUTPUT=`/usr/bin/SublerCLI -source "$SOURCE" -listmetadata &2> /dev/null`;

# Check if file is valid
if [ "`echo $SUBLER_OUTPUT | grep 'be opened'`" != "`echo -n`" ]
then
	echo "Error: the file does not appear to be a valid mp4/m4v";
	exit 1;
fi

# If the file is valid, get some values that are (usually) present in both movies
# and TV shows, including the media kind, which tells us if we're dealing with a movie
# or a TV show
TITLE=`echo "$SUBLER_OUTPUT" | grep Name | cut -c7-`;
YEAR=`echo "$SUBLER_OUTPUT" | grep Date | cut -c15-18`;
MEDIA_KIND=`echo "$SUBLER_OUTPUT" | grep Media\ Kind | cut -c13-`;

case $MEDIA_KIND in
	9 ) process_movie;
		;;
	10 ) process_tvshow;
		;;
esac
