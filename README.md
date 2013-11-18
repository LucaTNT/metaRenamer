# metaRenamer

## What is metaRenamer?
This script uses SublerCLI to rename video files according to their metadata.
As of now, it only supports a fixed naming scheme, but this will be improved ASAP.
The intended use is to rename files that have been processed by iFlicks, which is quite good at interpreting the wacky naming schemes used by uploaders for their files.

## Usage
metaRenamer.sh [-t] [-p pattern] file/folder

It supports renaming of either one file at a time or of entire directories (not yet with recursion).

If you specify the -t option, metaRenamer will not actually rename your files, it will only show how it *would* rename them.

The default pattern for file names is		
*Show* *Season*x*Episode* *Title*, for example: Fringe 1x01 Pilot		
for TV shows, and	
*Title*		
for movies.

You can also customize the pattern used to rename your files. To do so, just add the -p option followed by your pattern.
metaRenamer will replace these placeholders with their actual value:

| Placeholder | Value                                  |
| ----------- | -------------------------------------- |
| *%TITLE*    | The title of the movie/episode         |
| *%YEAR*     | The release year                       |
| *%SHOW*     | The show title (TV Shows only)         |
| *%SEASON*   | The season number                      |
| *%SEASON0*  | The season number with a leading zero  |
| *%EPISODE*  | The episode number                     |
| *%EPISODE0* | The episode number with a leading zero |


**Warning**: metaRenamer will rename the file you files in place, and there's no undo. You may want to add the -t option if you're not sure of the result of the renaming. 

## License
BSD

## Author
Luca Zorzi @LucaTNT

