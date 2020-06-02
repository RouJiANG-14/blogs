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

depth=1
append_readme() {
    IFS='/' read -r -a array <<<"$2"
    for current in "${array[@]}"; do
        if [[ "${current}" != "." ]]; then
            if [[ "${current}" != *".md" ]]; then
                let "depth=depth+1"
                #  $(pure_log $(get_header $depth)" "$current)
                echo $(get_header $depth)" "$current >>README.md
            else
                # $(pure_log_content $1 $2)
                echo "- [$1]($2)" >>README.md
                let "depth=1"
            fi
        fi
    done
}

get_all_files() {
    for f in $(ls $1); do
        if [[ -d $1"/"$f ]]; then
            if [[ $f != *"image"* ]]; then
                $(get_all_files $1"/"$f)
            fi
        elif [[ $f != "README.md" ]] && [[ $f == *".md" ]]; then
            $(append_readme ${f%.*} $1"/"$f)
        fi
    done
}
echo "# Blogs List" >README.md
$(get_all_files .)
