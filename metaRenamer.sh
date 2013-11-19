#!/bin/bash
# metaRenamer v0.1
# ----------------
# Author: Luca Zorzi @LucaTNT
# License: BSD
#
# This script uses SublerCLI to rename TV Shows according to the metadata embedded into the file
# The intended use is to rename files that have been processed by iFlicks, which is quite good at
# interpreting the wacky naming schemes used by uploaders for their files



# Define some functions

# Usage, called when used does not specify an input file
function usage
{
	echo 'USAGE: metaRenamer [-t] [-p pattern] sourceFile';
	echo '-----------------------------------------------';
	echo '-t             enables test mode: it only shows how metaRenamer would rename your files without actually renaming them';
	echo '-p pattern     sets the the pattern used to rename your files';
	echo '               Your pattern is defined replacing your placeholders with the actual data';
	echo '               Available placeholders are:';
	echo '               %TITLE     The title of the movie/episode';
	echo '               %YEAR      The release year';
	echo '               %SHOW      The show title (TV Shows only)';
	echo '               %SEASON    The season number';
	echo '               %SEASON0   The season number with leading zero';
	echo '               %EPISODE   The episode number';
	echo '               %EPISODE0  The episode number with leading zero';
	exit 1;
}

# Function that deals with TV shows
function process_tvshow
{	
	# The default naming scheme
	NEW_NAME="$SHOW $SEASON""x$EPISODE0 $TITLE.$EXTENSION";

	# Parse the user's pattern (if any), otherwise keep the default one
	parse_pattern

	rename "$SOURCE" "$SOURCE_PATH/$NEW_NAME";

	echo -e "TV show renamed to \033[33;40;5m\033[1m$NEW_NAME\033[0m";
}

# Function that deals with movies
function process_movie
{
	# The default naming scheme
	NEW_NAME="$TITLE.$EXTENSION";

	# Parse the user's pattern (if any), otherwise keep the default one
	parse_pattern

	rename "$SOURCE" "$SOURCE_PATH/$NEW_NAME";

	echo -e "Movie renamed to \033[33;40;5m\033[1m$NEW_NAME\033[0m";
}

# Function that parses the user provided pattern
function parse_pattern
{
	if [[ $PATTERN != '' ]]
	then
		echo $SOURCE
		NEW_NAME=$PATTERN;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%TITLE/"$TITLE"/g`;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%YEAR/"$YEAR"/g`;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%SHOW/"$SHOW"/g`;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%SEASON0/"$SEASON0"/g`;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%SEASON/"$SEASON"/g`;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%EPISODE0/"$EPISODE0"/g`;
		NEW_NAME=`echo "$NEW_NAME" | sed s/%EPISODE/"$EPISODE"/g`;
		NEW_NAME="$NEW_NAME.$EXTENSION";
	fi
}

# Function that actually performs renaming
function rename
{
	if [[ $TEST_RUN == 0 ]]
	then
		mv "$1" "$2";
	fi
	return;
}

# Function that works with the file, checks if it is valid, and so on
function process_file
{
	# Define some useful variables
	SOURCE=$1;
	SOURCE_PATH=`dirname "$SOURCE"`;
	SUBLER_OUTPUT=`/usr/bin/SublerCLI -source "$SOURCE" -listmetadata &2> /dev/null`;
	FILENAME=$(basename "$SOURCE")
	EXTENSION="${FILENAME##*.}"

	# Check if file is valid
	if [[ "`echo $SUBLER_OUTPUT | grep 'be opened'`" != "`echo -n`" && $# -gt 1 ]]
	then
		echo "Error: the file does not appear to be a valid mp4/m4v";
		
		# If the second parameter is set we are working with a single file, and so we can
		# set the exit code to 1 when an error occours. We avoid doing that while processing
		# multiple files at once since it would stop the script.
		if [ $# -gt 1 ]
		then
			exit 1;
		fi
	fi

	# If the file is valid, get some values including the media kind,
	# which tells us if we're dealing with a movie or a TV show
	TITLE=`echo "$SUBLER_OUTPUT" | grep Name | cut -c7-`;
	YEAR=`echo "$SUBLER_OUTPUT" | grep Date | cut -c15-18`;
	MEDIA_KIND=`echo "$SUBLER_OUTPUT" | grep Media\ Kind | cut -c13-`;
	SHOW=`echo "$SUBLER_OUTPUT" | grep "TV Show" | cut -c10-`;
	SEASON=`echo "$SUBLER_OUTPUT" | grep "TV Season" | cut -c12-`;
	EPISODE=`echo "$SUBLER_OUTPUT" | grep "TV Episode \#" | cut -c15-`;

	# Add a leading zero for single-digit episodes
	if [ ${#EPISODE} -lt 2 ]
	then
		EPISODE0="0$EPISODE";
	else
		EPISODE0=$EPISODE;
	fi

	# Add a leading zero for single-digit seasons
	if [ ${#SEASON} -lt 2 ]
	then
		SEASON0="0$SEASON";
	else
		SEASON0=$SEASON;
	fi

	case $MEDIA_KIND in
		9 ) process_movie;
			;;
		10 ) process_tvshow;
			;;
	esac
}

# Check if SublerCLI is available
command -v SublerCLI >/dev/null 2>&1
if [ $? -eq 1 ]
then
	echo "Error: You do not appear to have SublerCLI installed.";
	echo "metaRenamer can try to grab the latest copy of SublerCLI for you, and install it";
	read -p "Do you want metaRenamer do download and install SublerCLI? [y/n] " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo;
		echo "Starting download...";
		URL=`curl -s http://lucazorzi.net/stuff/SublerCLI-URL.txt`;
		curl -# -o /tmp/sublercli.zip $URL;
		echo "Download completed";
		echo -n "Extracting... "
		unzip -qq /tmp/sublercli.zip SublerCLI -d /tmp/
		echo "Done"
		echo "SublerCLI has to be moved to a system directory, so you'll need to provide your password. It won't be stored."
		sudo mv /tmp/SublerCLI /usr/bin
		command -v SublerCLI >/dev/null 2>&1
		if [ $? -eq 1 ]
		then
			echo "Something went wrong while trying to download or install SublerCLI.";
			echo "Please go to http://code.google.com/p/subler/ and download the latest version of SublerCLI."
			echo "Extract the zip file and move SublerCLI to /usr/bin or any other directory in your PATH."
			exit 1;
		else
			echo "Installation successful"
		fi
		rm /tmp/SublerCLI /tmp/sublercli.zip 2> /dev/null
	else
		exit 1;
	fi
fi

# Process options
TEST_RUN=0; # set to 1 to disable renaming, using the -t option
PATTERN=""; # Used to set the renaming pattern

while getopts "tp:" flag
do
	case "$flag" in
		t) TEST_RUN=1;;
		p) PATTERN=$OPTARG;;
		*) usage; exit 1;;
	esac
done
shift $((OPTIND-1))


# Check if user has supplied an input file
if [ $# -lt 1 ]
then
	usage;
fi


# Check if file exists and that it is not a directory
if [[ ! -f "$1" && ! -d "$1" ]]
then
	echo "Error: can't find file $1";
	exit 1;
fi

# If it is a folder, we should process its contents, otherwise just pass the file to process_file()
if [[ -d "$1" ]]
then
	echo "Processing folder $1";
	files_found=0;
	shopt -s nullglob
	for file in "$1"/*;
	do
		if [[ ! -d "$file" ]] 
		then
			process_file "$file"
			((files_found++));
		fi
	done
	
	if [ $files_found -lt 1 ]
	then
		echo "Error: no files found in this directory";
		exit 1;
	fi
else
	process_file "$1" 1
fi


