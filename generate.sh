#!/bin/sh

get_all_folders() {
    ls $1
}

pure_log() {
    echo 1>&2 "$1"
}

pure_log_content() {
    echo 1>&2 "- [$1]($2)"
}

get_header() {
    num=$1
    v=$(printf "%-${num}s" "#")
    echo "${v// /#}"
}

increase() {
    echo "$1+1" | bc
}

get_depth() {
    # $(pure_log $1)
    echo "$1" | tr -cd '/' | wc -c
}

get_all_files() {
    depth=$2
    for f in $(ls $1); do
        if [[ -d $1"/"$f ]]; then
            new_folder=$1"/"$f
            if [[ $f != *"image"* ]]; then
                let "depth=$(get_depth $new_folder)+1"
                echo $(get_header $depth)" "$f >>README.md
                $(get_all_files $new_folder $depth)
            fi
        elif [[ $f != "README.md" ]] && [[ $f == *".md" || $f == *".adoc" || $f == *".ad" ]]; then
            path=$1"/"$f
            file_name=${f%.*}
            echo "- [$file_name]($path)" >>README.md
        fi
    done
}
echo "# Blogs List" >README.md
$(get_all_files . 1)
