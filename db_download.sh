#!/bin/bash

###########################################################################
#                                                                         #
#                             db_downloader.sh                            #
#                                                                         #
#                                                                         #
#  Author:      D4lL45                                                    #
#                                                                         #
#  Version:     1.0.1                                                     #
#  Date:        13.04.2022                                                #
#                                                                         #
#  Description: Downloading all tables from a given database locateed on  #
#               an sql server. You can download just the tables or also   #
#               the sql dump of a database or a single table.             #
#               IMPORTANT: YOU HAVE TO CHANGE SOME VARIABLES BELOW,       #
#               BEFORE YOU EXECUTING THE SCRIPT!                          #
#                                                                         #
#  Usage:       db_downloader.sh [db]                                     #
#               db_downloader.sh -t | -d [db]                             #
#               db_downloader.sh -s -t | -d [db]                          #
#                                                                         #
#  Parameter:   -t [db]    download only tables of the database db        #
#               -d [db]    download only sql dump of the database db      #
#               -s -t [db] download a single table of the database db     #
#               -s -d [db] download the sql dump file of a single table   #
#                          of the database db                             #
#               [db]       downloading tables and sql dump of the         #
#                          database db                                    #
#                                                                         #
###########################################################################


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# change variables before usage:
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ip=""                       # database host ip
user=""                     # username for login
pass=""                     # user password

base_folder=""              # root directory to save all data
dump_folder="sql_dumps"     # directory to save the downloaded sql dumps
                            # will be located in $base_folder
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

db_name=""
f_table=0
f_dump=0
f_single=0
tbl_name=""

if [ "$#" -eq 1 ]; then
	f_table=1
	f_dump=1
	db_name=$1
elif [ "$#" -eq 2 ]; then
	if [ $1 = "-t" ]; then
		f_table=1
	elif [ $1 = "-d" ]; then
		f_dump=1
	else
		echo "\nWrong parameter!"
		exit 1
	fi
	db_name=$2
elif [ "$#" -eq 3 ]; then
	if [ $1 = "-s" ]; then
		f_single=1
	else
		echo "\nWrong parameter!"
		exit 1
	fi
	if [ $2 = "-t" ]; then
		f_tables=1
	elif [ $2 = "-d" ]; then
		f_dump=1
	else
		echo "\nWrong parameter!"
		exit 1
	fi
	db_name=$3
else
	echo "\nCheck your arguments!"
	exit 1
fi

save_txts=$base_folder/$db_name

echo "\nGrabbing stuff from database $db_name" 

# preparing folder & downloading table overview of the db:
echo -ne "\n\nCreating new folder $db_name ... "
mkdir $save_txts
echo -ne "done"
echo -ne "\nDownloading database tables ... "
torsocks mysql -h"$ip" -u"$user" -p"$pass" -t -e"show tables from $db_name;" > $save_txts/$db_name-tables.txt
echo -ne "done"

# getting tmp file of all tables with all names ready to download them one by one:
torsocks mysql -h"$ip" -u"$user" -p"$pass" -e"show tables from $db_name;" > $save_txts/$db_name-tmp.txt
sed -i '1d' $save_txts/$db_name-tmp.txt

if [ "$f_dump" -eq 1 ]; then
	if [ "$f_single" -eq 1 ]; then
		echo "\nSelect a table to download its sql dump file:"
		while read line; do
			echo "   $line"
		done < $save_txts/$db_name-tmp.txt
		echo ""
		read -p "table: " tbl
		tbl_name=$tbl
		echo -ne "\nDownloading SQL dump of the table ... "
		torsocks mysqldump --single-transaction -h"$ip" -u"$user" -p"$pass" $db_name $tbl_name > $base_folder/$dump_folder/$db_name-$tbl_name.sql
		echo -ne "done"
	else
		# downloading sql dump of the database:
		echo -ne "\nDownloading SQL dump of the database ... "
		torsocks mysqldump --single-transaction -h"$ip" -u"$user" -p"$pass" $db_name > $base_folder/$dump_folder/$db_name.sql
		echo -ne "done"
	fi
fi

if [ "$f_table" -eq 1 ]; then
	if [ "f_single" -eq 1 ]; then
		echo "\nSelect a table to download its sql dump file:"
		while read line; do
			echo "   $line"
		done < $save_txts/$db_name-tmp.txt
		echo ""
		read -p "table: " tbl
		tbl_name=$tbl
		echo -ne "\nDownloading data of single table ... "
		torsocks mysql -h"$ip" -u"$user" -p"$pass" -t -e"select * from $db_name.$tbl_name;" > $save_txts/$db_name-$tbl_name.txt
		echo -ne "done"
	else
		# reading table tmp file line by line and downloading each table:
		echo -ne "\nStart downloading table data ...\n"
		while read line; do
			echo -ne "\nDownloading table $line ... "
			torsocks mysql -h"$ip" -u"$user" -p"$pass" -t -e"select * from $db_name.$line;" > $save_txts/$line.txt
			echo -ne "done"
			sleep 1.5
		done < $save_txts/$db_name-tmp.txt
	fi
fi

# removing tmp table list
rm $save_txts/$db_name-tmp.txt
echo -ne "\n\nAll done!\n"
