#! /bin/bash
#
# This is the file which is used for synching the directories
#

print_help() {
    cat <<EOF
This is the help file for the script.

Usage:
    -b|--backup
        Update the repository, or backup.
    -s|--sync
        Update the local files using the repository copies.
    -p|--pretend
        Do not actually sync, just check if there are any changes.
    -v|--verbose
        A lot of output which is not needed always.
    -h|--help
        Print this text.
EOF
}

update () {
    file=${DIR_TO}$@
    base_file=${DIR_FROM}$file

    if [ -f "$base_file" ]
    then
        if ${SYNC}; then
            tmp=${base_file}
            base_file=${file}
            file=${tmp}
        fi
        if diff "$base_file" "$file" > /dev/null; then
            # File did not change
            if ${VERBOSE}; then
                echo -e "${col_skip}Skipping${col_end} $file"
            fi
            return
        else
            if  [[ `stat -c %Y $base_file` -lt `stat -c %Y $file` ]]; then
                echo -e "${col_outdate}Skipping${col_end} $file"
                return
            fi
            # Normal files are just copied
            if ${SYNC}; then
                echo -e "${col_update}Synchronising${col_end} $base_file" >& 2
                if ! ${PRETEND}; then
                    cp -vira "$base_file" "$file"
                fi
            else
                echo -e "${col_update}Updating${col_end} $file" >& 2
                if ! ${PRETEND}; then
                    cp -R "$base_file" "$file"
                fi
            fi
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

    echo -e "${col_unknown}Skipping${col_end} $file"
}


update_dir ()
{
    for file in $@*; do
        case $file in
            update.sh|README|.gitignore|*.list)
                continue
                ;;
            *)
                update ${file}
                ;;
        esac
    done
}

main() {
    # Set the settings
    export PRETEND=false
    export VERBOSE=false
    export SYNC=false
    export DIR_TO=
    export DIR_FROM=~/.

    export col_skip="\033[1;33m"
    export col_unknown="\033[1;37m"
    export col_update="\033[1;34m"
    export col_outdate="\033[1;31m"
    export col_end="\033[0;37m"

    echo -e "\
${col_end}\
============================================================================
Colour codings:
${col_update}Updating: Local ver. is older
${col_skip}Skipping: Local ver. is the same
${col_outdate}Skipping: Local ver. is newer
${col_unknown}Skipping: Unknown file type or there is no local copy pressent
${col_end}\
============================================================================\
"
    # First pass of the variables
    for var in $@; do
        case $var in
            -p|--pretend)
                export PRETEND=true
                echo -e "\
Running in PRETEND mode (no actual changes will be done)
============================================================================\
"
                ;;
            -v|--verbose)
                export VERBOSE=true
                ;;
            -b|--backup|-s|--sync)
                # do nothing
                ;;
            -h|--help|*)
                print_help 
                return 0
                ;;
        esac
    done

    for var in $@; do
        case $var in
            -b|--backup)
                export SYNC=false
                update_dir
                return 0
                ;;
            -s|--sync)
                export SYNC=true
                update_dir
                return 0
                ;;
        esac
    done
}

main $@
