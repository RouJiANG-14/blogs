#!/bin/bash

get_list() {
  ls
}

get_file_list() {
  ls | egrep '\.\w*$'
}

get_folder_list() {
  list=$(get_list);
  printf "$list"

#  for l in $list; do
#    echo "$l"
#    #    if [[ $l =~ \.\w*$ ]]; then
#    #      continue
#    #    else
#    #      echo "$l"
#    #    fi
#  done
}

$(get_folder_list)
