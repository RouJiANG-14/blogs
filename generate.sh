#!/bin/sh

get_all_folders() {
    ls $1
}

log() {
    echo "- [$1]($2)" >> README.md
}


get_all_files() {
    for f in $(ls $1); do
        if [[ -d $1"/"$f ]] ; then
            if [[ $f != *"image"* ]]; then
                $(get_all_files $1"/"$f)
            fi
        elif [[ $f != "README.md" ]] && [[ $f == *".md" ]] ; then
            $(log ${f%.*} $1"/"$f)
        fi
    done
}

$(get_all_files .) 
