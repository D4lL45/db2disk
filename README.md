# db2disk
Gained access to a database? Good, now you can easily download and extract tables containing sensitive data such as passwords, usernames or mail addresses.

# Scripts
## db_downloader
Use this script at first to download a copy of all neccessary tables and / or SQL dumps.<br>
You have to make the file executable before usage!<br>
## data_scraper
After a successful download session, you have got a lot of tables in clear text.<br>
This script allows you to search for regular expressions in table column names and copies the matching tables to a text file.<br>
If there are more than one match, data_scraper will append the result text file with tables.<br>
You habe to make the file executable before usage!<br>
<br>
You can use the wordlist.txt for most common sensitive data or feel free to edit the list.

# Disclaimer
Feel free to do whatever you want with this piece of software. Keep in mind, that gaining access to a database and stealing information is illegal!<br><b>D4lL45 is not responsible for any damage, data breaches or cybercrime caused by this software!</b>
