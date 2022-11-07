#! /bin/bash

# function that takes date in format MM/YYYY as input
# echos expired if input date preceeds current date
# echos active if input date exceeds current date
# NB cards expire at end of month
check_date () {
c_year=$(date +'%Y')
c_month=$(date +'%m')

date_year=`echo $1 | cut -c 4-`
date_month=`echo $1 | cut -c 1-2`

if test "$date_year" -lt "$c_year"
then
	echo "expired"
elif test "$date_year" -gt "$c_year"
then
	echo "active"
else
	if test "$date_month" -le "$c_month"
	then
		echo "expired"
	else
		echo "active"
	fi
fi
}

# set numeric style to allow number formatting with comma separator
export LC_NUMERIC="en_US.utf8"

file='CC_Records.csv'
# store first row with column names separately
row1=`head -n 1 $file`

# store IFS to revert later
OLDIFS=$IFS
IFS=","

# read data into files
head -n 1 $file | while read c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11
do
	sed 1d $file | while read d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11
	do
		card_status=`check_date $d8`
		
		# creates output file	
		output=$d4.$card_status.txt
		
		# removes control chars to ensure correct formatting (specifically for the \r chars present)
		c11=`echo $c11 | tr -d [:cntrl:]`	
		d11=`echo $d11 | tr -d [:cntrl:]`
		
		# format into USD 
		limit=`printf "$%'d USD\n" "$d11"`
		
		# read data into output file
		echo -e "$c1: $d1 \n$c2: $d2 \n$c3: $d3 \n$c4: $d4 \n$c5: $d5 \n$c6: $d6 \n$c7: $d7 \n$c8: $d8 \n$c9: $d9 \n$c10: $d10 \n$c11: $limit" | tee -a $output
		
		# replace any special character in directory names with '_'
		d2=`echo $d2 | tr -d -c [:graph:]`
		d3=`echo $d3 | tr -d -c [:graph:]`
		
		# check for directories and create if necessary
		if [ ! -d $d2/ ]; then
			mkdir $d2
		fi
		if [ ! -d $d2/$d3/ ]; then
			mkdir $d2/$d3
		fi
		
		# move file into directory
		mv $output $d2/$d3		
		
	done
done
# reset IFS
IFS=$OLDIFS

