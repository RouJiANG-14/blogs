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
    v=$(printf "%-${num}s" "=")
    echo -e "\n${v// /=}"
}

increase() {
    echo "$1+1" | bc
}

get_depth() {
#     $(pure_log $1)
    echo "$1" | tr -cd '/' | wc -c
}

get_all_files() {
    depth=$2
    for f in $(ls $1); do
        if [[ -d $1"/"$f ]]; then
            new_folder=$1"/"$f
            if [[ $f != *"image"* ]]; then
                let "depth=$(get_depth $new_folder)+1"
                echo -e $(get_header $depth)" "$f"\r\n" >>README.adoc
                $(get_all_files $new_folder $depth)
            fi
        elif [[ $f != "README.adoc" ]] && [[ $f == *".md" || $f == *".adoc" || $f == *".ad" ]]; then
            path=$1"/"${f%.*}
            path=${path/./""}
            file_name=${f%.*}
            echo  -e ". link:$path[$file_name]\n" >>README.adoc
        fi
    done

}

echo -e "= Blog List link:https://github.com/xiaoquisme/blogs[github]\r\n" >README.adoc
$(get_all_files . 1)
