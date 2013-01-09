# metaRenamer

## What is metaRenamer?
This script uses SublerCLI to rename video files according to their metadata.
As of now, it only supports a fixed naming scheme, but this will be improved ASAP.
The intended use is to rename files that have been processed by iFlicks, which is quite good at interpreting the wacky naming schemes used by uploaders for their files.

## Usage
metaRenamer.sh [file]
It currentlysupports only one file at a time, and it will rename TV shows with this scheme:		
*Show* *Season*x*Episode* *Title*, for example: Fringe 1x01 Pilot		
and Movies with this one:		
*Title*

**Warning**: it will rename the file you files in place, and there's no undo. As a workaround, you'll still know the original file name from your shell history.

## License
BSD

## Author
Luca Zorzi @LucaTNT

