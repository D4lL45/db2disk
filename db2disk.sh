#!/bin/bash

###########################################################################
#                                                                         #
#                                db2disk.sh                               #
#                                                                         #
#                                                                         #
#  Author:      D4lL45                                                    #
#                                                                         #
#  Version:     1.0.0                                                     #
#  Date:        14.04.2022                                                #
#                                                                         #
#  Description:                                                           #
#                                                                         #
#  Usage:                                                                 #
#                                                                         #
#  Parameter:                                                             #
#                                                                         #
###########################################################################


# get arguments from command line:
BLACKLIST=false
SCRAPE=false
DOWNLOAD=false
RECURSIVE=false
DUMP_FOLDER="sql_dumps"     # directory to save the downloaded sql dumps
                            # will be located in $SAVE_DIR
while [[ $# -gt 0 ]]; do
	case "$1" in
		--scrape)
			SCRAPE=true; shift ;;
		--download)
			DOWNLOAD=true; shift ;;
		-R)
			RECURSIVE=true; shift ;;
		-l)
			LIST=$2; shift 2 ;;
		--dir)
			SCRAPE_DIR=$2; shift 2 ;;
		--file)
			SCRAPE_FILE=$2; shift 2 ;;
		-f)
			RESULT_FILE=$2; shift 2 ;;
		-c)
			RESULT_DIR=$2; shift 2 ;;
		--ip)
			IP=$2; shift 2 ;;
		--user)
			USER=$2; shift 2 ;;
		--pw)
			PASSWORD=$2; shift 2 ;;
		--db)
			DATABASE=$2; shift 2 ;;
		--save)
			SAVE_DIR=$2; shift 2 ;;
		--use-blacklist)
			BLACKLIST=true; shift ;;
		*)
			echo -e "\nError: something is wrong with your arguments!\n"
			exit
			break ;;
	esac
done

# scrape data from given table files only:
if [[ $SCRAPE == true && $DOWNLOAD == false ]]; then
	# check for the other arguments:
	[ ! -f "$LIST" ] && echo -e "\nError: wordlist doesn't exist!\n" && exit
	[[ -v "$SCRAPE_DIR" && -v "$SCRAPE_FILE" ]] && echo -e "\nError: no file or directory selected, to scrape data from!\n" && exit
	[[ ! -v "$SCRAPE_DIR" && ! -d "$SCRAPE_DIR" && -v "$SCRAPE_FILE" ]] && echo -e "\nError: directory to scrape data from doesn't exist!\n" && exit
	[[ ! -v "$SCRAPE_FILE" && ! -f "$SCRAPE_FILE" && -v "$SCRAPE_DIR" ]] && echo -e "\nError: file to scrape data from doesn't exist!\n" && exit
	if [ ! -v $RESULT_DIR ]; then
		[ ! -d "$RESULT_DIR" ] && echo -e "\nError: directory to copy files with a match to, doesn't exist!\n" && exit
	fi
	if [ ! -v $RESULT_FILE ]; then
		[ ! -d "$(dirname $RESULT_FILE)" ] && echo -e "\nError: directory of the result file path not found!\n" && exit
	fi
	# executing script with arguments:
	# using scrape file:
	if [ ! -v $SCRAPE_FILE ]; then
		sh ./data_scraper.sh -l $LIST -s $SCRAPE_FILE
	# using scrape directory:
	elif [ ! -v $SCRAPE_DIR ]; then
		if [ ! -v $RESULT_DIR ]; then
			if [ $RECURSIVE ]; then
				sh ./data_scraper.sh -l $LIST -c $RESULT_DIR -R -d $SCRAPE_DIR
			else
				sh ./data_scraper.sh -l $LIST -c $RESULT_DIR -d $SCRAPE_DIR
			fi
		elif [ ! -v $RESULT_FILE ]; then
			if [ $RECURSIVE ]; then
				sh ./data_scraper.sh -l $LIST -f $RESULT_FILE -R -d $SCRAPE_DIR
			else
				sh ./data_scraper.sh -l $LIST -f $RESULT_FILE -d $SCRAPE_DIR
			fi
		else
			if [ $RECURSIVE ]; then
				sh ./data_scraper.sh -l $LIST -R -d $SCRAPE_DIR
			else
				sh ./data_scraper.sh -l $LIST -d $SCRAPE_DIR
			fi
		fi
	else
		echo -e "\nError: ooops, something went wrong, sorry!\n"
		exit
	fi
	#sh ./data_scraper.sh
fi

# download data from database:
if [[ $DOWNLOAD == true ]]; then
	echo "currently not implemented!"
fi
