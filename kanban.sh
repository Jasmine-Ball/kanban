#!/bin/bash


HG="$(tput bold setaf 2)"
Z="$(tput sgr0)"

tput -x clear
tput -x init

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
  recent_entries_fun
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
  read -p "$HG"Search"$Z: " -e id 
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
  read -p "$HG"Search"$Z: " -e id
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

#Show entries
recent_entries_fun () {
echo "-------------------------------------------------"

for i in {1..20}; 
do
if [ $1 ]
  then
  title=$(sed -n ${i}p kanban.txt | grep ${1} | cut -d ' ' -f 3)
  else 
  title=$(sed -n ${i}p kanban.txt | cut -d ' ' -f 3);
fi
  descr=$(sed -n ${i}p kanban.txt | cut -d ' ' -f 4-)
if [ $title ]; then echo " $(tput bold setaf 2)${title//-/ } $(tput sgr0)${descr//-/ }" | cut -b -65; fi
done
echo -e "-------------------------------------------------"
}

#Show menu
show_menu_fun () {
read -p "$HG"A"$Z"dd" $HG"F"$Z"ilter" $HG"R"$Z"emove" $HG"U"$Z"pdate" $HG"E"$Z"xit": " -e menu_input
process_user_selection $menu_input
}

#If raw search term passed in show full row
if [ $1 ] 
  then
    cat ./kanban.txt | grep $1
  else
    show_menu_fun
fi