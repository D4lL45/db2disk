#!/bin/bash

###########################################################################
#                                                                         #
#                             data_scraper.sh                             #
#                                                                         #
#                                                                         #
#  Author:      D4lL45                                                    #
#                                                                         #
#  Version:     1.0.2                                                     #
#  Date:        13.04.2022                                                #
#                                                                         #
#  Description: This script allows you to extract data from sql table     #
#               results as text file downloaded with db_download.sh. By   #
#               using a wordlist it searches the table column names for   #
#               table key names such as password, passwd, user, mail and  #
#               more. You can also add regular expressions to the         #
#               wordlist file to optimize your search results.            #
#               If there is a match between a wordlist entry and a table  #
#               column name, the script will copy the whole table to a    #
#               textfile and appends all other matches to it.             #
#                                                                         #
#  Usage:       data_scraper.sh -l [wordlist] -d [dir]                    #
#               data_scraper.sh -l [wordlist] -s [file]                   #
#               data_scraper.sh -l [wordlist] -R -d [dir]                 #
#               data_scraper.sh -l [wordlist] -c [path] -R -d [dir]       #
#               data_scraper.sh -l [wordlist] -f [file] -R -d [dir]       #
#                                                                         #
#  Parameter:   -l [wordlist]   path to a wordlist                        #
#               -c [path]       directory to copy the files               #
#               -f [file]       copy data to a single file                #
#               -R              recursive, looking for subfolders         #
#               -d [dir]        directory to scrape data                  #
#               -s [file]       file to scrape data from                  #
#                                                                         #
###########################################################################


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++                                                                     ++
# ++                        FUNCTION checkTable                          ++
# ++                                                                     ++
# ++ This function scans a table txt file for regular expressions.       ++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

checkTable() {
	echo -ne "Checking table $(basename $source) of $(basename $(dirname $source)) for regular expressions ... "
	hit=0
	i=0
	while read line; do
		if [ $i = 0 ]; then
			i=$((i+1))
			continue
		fi
		# exit loop while passing the second line of the file:
		if [ $i = 2 ]; then
			if [ "$hit" -eq 0 ]; then
				echo -ne "None"
				echo ""
			fi
			break
		fi
		# check if line contains one of the strings from wordlist:
		while read str; do
			if [[ "$line" =~ .*"$str".* ]]; then
				echo -ne "${RED}Hit: $str${NC}"
				echo ""
				hit=1
				if [ -n "$cp" ]; then
					cp $source $cp/$(basename $(dirname $source))-$(basename $source)
				fi
				if [ -n "$f" ]; then
					echo "Table $(basename $source) from database $(basename $(dirname $source)):" >> $f
					cat "$source" | tee -a $f >/dev/null 2>&1
					echo "" >> $f
				fi
				break
			fi
		done < $wordlist
		i=$((i+1))
	done < $source
}


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++                                                                     ++
# ++                            MAIN SCRIPT                              ++
# ++                                                                     ++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# init constants, argument data and flags:
RED='\033[0;31m'
NC='\033[0m' # No Color
wordlist=""
cp=""
f=""
rec=0
path=""
dir=""
source=""

echo ""

# check if there are enough arguments (at least 4 required and max 7):
if [[ "$#" -lt 4 || "$#" -gt 7 ]]; then
	echo ""
	echo "Check your arguments! More than 3 and less than 8 required!"
	exit 1
fi

# extract arguments from command line:
while getopts ":l:c:f:Rd:s:" option; do
	case $option in
		l) # use wordlist
		   if [ -f "$OPTARG" ]; then
			wordlist=$OPTARG
		   else
			echo "Error: Wordlist not found!"
			echo ""
			exit 1
		   fi;;
		c) # copy all files with a hit
		   if [ -d "$OPTARG" ]; then
			cp=$OPTARG
		   else
			echo "Error: Path to copy files not found!"
			echo ""
			exit 1
		   fi;;
		f) # copy data to one file
		   touch "$OPTARG"
		   if [ -f "$OPTARG" ]; then
			f=$OPTARG
		   else
			echo "Error: File to copy data to not found!"
			echo ""
			exit 1
		   fi;;
		R) # Recursive mode
		   rec=1;;
		d) # directory search
		   if [ -d "$OPTARG" ]; then
			dir=$OPTARG
		   else
			echo "Error: Search directory not found!"
			echo ""
			exit 1
		   fi;;
		s) # file search
		   if [ -f "$OPTARG" ]; then
			source=$OPTARG
		   else
			echo "Error: Search file not found!"
			echo ""
			exit 1
		   fi;;
		\?) # invalid option
		   echo "Error: Invalid option!"
		   echo ""
		   exit 1
	esac
done

# search in one file only:
if [ -n "$source" ]; then
	checkTable
# search in a directory:
elif [ -n "$dir" ]; then
	if [ $rec -eq 1 ]; then
		files=$(find "$dir" -name "*.txt" -print)
		for file in $files; do
			source=$file
			checkTable
		done
	else
		for file in "$dir"/*.txt; do
			source=$file
			checkTable
		done
	fi
else
	echo "Error: No source file or directory found!"
	echo ""
fi
