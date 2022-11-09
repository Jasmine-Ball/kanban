#!/bin/bash

#Remove old backups and add new
rm backup-$(date +%y%m --date='-31 day')*  2> /dev/null
cp kanban.txt "backup-$(date +%y%m%d%H%M%S)"

#Set colors
HG="$(tput bold setaf 2)"
Z="$(tput sgr0)"

#Set the terminal to start at the top
tput -x clear
tput -x init

#Set the width of the results
results_width=$(sed -n /.*$id.*/p kanban_params.txt | cut -d ' ' -f 1)

#Process main memnu selection
process_user_selection () {

case $1 in

  a | A)
  add_entries_fun
  ;;
  
  f | F)
  filter_entries_fun
  ;;

  r | R)
  remove_entries_fun
  ;;

  u | U)
  update_entries_fun
  ;;

  e | E)
  echo "Exiting. Bye now"
  ;;

  *)
  recent_entries_fun "-"
  ;;  

esac

}

#Send data to file
process_user_input_fun () {
  echo $4 $3 $1 $2 >> kanban.txt
}

#Add entries
add_entries_fun () {
  read -p "$HG"Title"$Z: " -e title 
  read -p "$HG"Description"$Z: " -e description 
  read -p "$HG"Tags"$Z: " -e tags 
  title=${title//' '/-}
  description=${description//' '/-}
  tags='#'${tags//' '/#}
  id=$(date +%y%m%d%H%M%S)
  echo $id $tags $title $description >> kanban.txt
}

#Filter
filter_entries_fun () {
  read -p "$HG"Search"$Z: " -e search 
  selected_id=$(sed -n /.*$search.*/p kanban.txt | cut -d ' ' -f 1)
  recent_entries_fun $search
}

#Remove
remove_entries_fun () {
  read -p "$HG"ID"$Z: " -e id 
  selected_id=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 1)

  if [ ${#selected_id} == 12 ]
    then
    sed -i /${selected_id}/d kanban.txt
    echo -e ${selected_id} successfully removed
    else
    echo 'No unique match found. Please pass the search in as first parameter'
  fi

}

#Update
update_entries_fun () {
  read -p "$HG"ID"$Z: " -e id
  selected_id=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 1)

  if [ ${#selected_id} == 12 ]
    then
    title=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 3)
    description=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 4)
    tags=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 2 | cut -d '#' -f 2)
    read -p "$HG"ID"$Z: " -i $selected_id -e selected_id
    read -p "$HG"Title"$Z: " -i $title -e title
    read -p "$HG"Description"$Z: " -i $description -e description
    read -p "$HG"Tags"$Z: " -i $tags -e tags
    sed -i /${selected_id}/d kanban.txt
    title=${title//' '/-}
    description=${description//' '/-}
    tags='#'${tags//' '/#}
    process_user_input_fun $title $description $tags $selected_id
    else
    echo 'No unique match found. Please pass the search in as first parameter'
  fi

}

#Show entire line including ID and tags
verbose_entries_fun () {
echo "-------------------------------------------------"
line_total=$(sed -n '$=' kanban.txt)
for i in `seq $line_total -1 1`; 
do
  line_id=$(sed -n ${i}p kanban.txt | tr 'A-Z' 'a-z' | grep ${1,,} | cut -d ' ' -f 1)
  if [ ${#line_id} == 12 ]; then title=$(sed -n ${i}p kanban.txt | grep ${line_id}); echo $title | cut -b -${results_width}; fi
done
echo "-------------------------------------------------"
}

#Show entries
recent_entries_fun () {
echo "-------------------------------------------------"

line_total=$(sed -n '$=' kanban.txt)
line_count=1
for i in `seq $line_total -1 1`; 
do
if [ $1 ]
  then
  line_id=$(sed -n ${i}p kanban.txt | tr 'A-Z' 'a-z' | grep ${1,,} | cut -d ' ' -f 1)
  if [ ${#line_id} == 12 ]; then title=$(sed -n ${i}p kanban.txt | grep ${line_id} | cut -d ' ' -f 3); fi
  else 
  title=$(sed -n ${i}p kanban.txt | cut -d ' ' -f 3);
fi
  descr=$(sed -n ${i}p kanban.txt | cut -d ' ' -f 4-)
if [ $line_id ] && [ $line_count -le 20 ]
 then
 line_count=$((line_count +1))
 echo " $(tput bold setaf 2)${title//-/ } $(tput sgr0)${descr//-/ }" | cut -b -${results_width}
 elif [ $line_count -gt 20 ]
 then
 echo -e "-------------------------------------------------"
 exit 0
fi

done

}

#Show menu
show_menu_fun () {
  read -p "$HG"A"$Z"dd" $HG"F"$Z"ilter" $HG"R"$Z"emove" $HG"U"$Z"pdate" $HG"E"$Z"xit": " -e menu_input
  process_user_selection $menu_input
}

#Set prefered amount of data per entry
set_prefs_fun () {
 if [ $1 == "set" ]
   then
  echo $2 > kanban_params.txt
 fi
}

#Positional parameters
if [ $2 ] 
  then
  set_prefs_fun $1 $2
elif [ $1 ]
  then
  verbose_entries_fun $1
else
    show_menu_fun
fi