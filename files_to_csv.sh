#! /bin/bash

# create output file
touch data_out.csv

# function to read data from file into csv out
read_file () {
	
entry='' # variable to hold next csv line

while read line
do
	# read each entry into the output var 
	line=`echo "$line" | cut -d ":" -f2`  # split line to the chars after the ':'
	line=${line:1} # remove the first char of the line (which is the space after the ':'
	if test ${line::1} == '$'; then
		line=`echo $line | tr -d -c [:digit:]` # if line starts with dollar sign, delete all non number chars (for un-formatting credit limit)
	fi	       
	entry+=`echo "$line"`
	entry+=','
done < $1

# remove last comma
entry=${entry::-1}

echo $entry

# append line onto output file
echo $entry >> data_out.csv
}

# function to read column names into csv out
read_columns () {
#echo "reading column names"
col_names=''
while read line
do
	line=`echo "$line" | cut -d ":" -f1`
	col_names+=`echo "$line"`
	col_names+=','
done < $1

col_names=${col_names::-1}

echo $col_names > data_out.csv
}

###

# read all files into arrays 
readarray -d '' exp_files < <(find -name "*.expired.txt")
readarray -d '' act_files < <(find -name "*.active.txt")

# bool to note first file read
first='true'

for file in $act_files
do
	if test $first == 'true'; then
		first='false'
		read_columns $file
	fi
	read_file $file
done

for file in $exp_files
do
	read_file $file
done

