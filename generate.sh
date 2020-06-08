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

# depth=1
# append_readme() {
#     IFS='/' read -r -a array <<<"$2"
#     for current in "${array[@]}"; do
#         if [[ "${current}" != "." ]]; then
#             if [[ "${current}" != *".md" ]]; then
#                 let "depth=depth+1"
#                 #  $(pure_log $(get_header $depth)" "$current)
#                 echo $(get_header $depth)" "$current >>README.md
#             else
#                 # $(pure_log_content $1 $2)
#                 echo "- [$1]($2)" >>README.md
#                 let "depth=1"
#             fi
#         fi
#     done
# }

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
                # if [[ $1 == "." ]]; then
                #     let "depth=1"
                # fi
                # let "depth=depth+1"
                let "depth=$(get_depth $new_folder)+1"
                # $(pure_log $(get_depth $new_folder))
                echo $(get_header $depth)" "$f >>README.md
                $(get_all_files $new_folder $depth)
            fi
        elif [[ $f != "README.md" ]] && [[ $f == *".md" ]]; then
            path=$1"/"$f
            file_name=${f%.*}
            echo "- [$file_name]($path)" >>README.md
            #  $(append_readme  $1"/"$f)
            #  let "depth=1"
        fi
    done
}
echo "# Blogs List" >README.md
$(get_all_files . 1)
