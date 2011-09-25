#!/bin/sh

# For every file and dir in ., this scripts checks if a file with .<name>
# exists in ~ and copies it into the current directory

update ()
{
	file="$@"
	base_file=~/.$file

	# Fallack: no leading dot
	if [ ! -e "$base_file" ]
	then
		base_file=~/$file
	fi

	if [ -f "$base_file" ]
	then
		if diff "$base_file" "$file" > /dev/null
		then
			# File did not change
			#echo "Skipped $file"
			return
		else
			# Normal files are just copied
			echo "Updating $file" >& 2
			cp -R "$base_file" "$file"
			return
		fi
	fi

	if [ -d "$base_file" ]
	then
		# Dirs are handled recursively
		#echo "Recursively updating $file..."
		update_dir $file/
		return
	fi

	echo "Skipping $file (unknown type)"
}

update_dir ()
{
	for file in ${@}*
	do
		case $file in
			update.sh)
			continue
		;;
			symlink.sh)
			continue
		;;
		esac

		update "$file"
	done
}

update_dir
