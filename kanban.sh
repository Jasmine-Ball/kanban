#!/bin/bash

#Create and/or move backups
if [ ! -d kanban_backups ]
  then
    mkdir kanban_backups
fi

rm ./kanban_backups/backup-*  2> /dev/null
mv ./backup-* kanban_backups/ 2> /dev/null
cp kanban.txt "backup-$(date +%y%m%d%H%M%S)"

#Set item colors
P0=$(tput bold setaf 121)
P1=$(tput bold setaf 226)
P2=$(tput bold setaf 178)
P3=$(tput bold setaf 70)
P4=$(tput bold setaf 034)
ST=$(tput bold setaf 193)

#Set other colors
HG2=$(tput bold setaf 2)
G2=$(tput setaf 2)
HG70=$(tput bold setaf 70)
G70=$(tput setaf 70)
H=$(tput bold)
HO=$(tput bold setaf 1)
O=$(tput setaf 1)
Z=$(tput sgr0)



#Set the terminal to start at the top
tput -x clear
tput -x init

#Set the width of the results and max number per tag
if [ ! -f kanban_params.txt ]
  then
    echo 56 1 > kanban_params.txt
fi

results_width=$(sed -n /.*$id.*/p kanban_params.txt | cut -d ' ' -f 1)
max_results=$(sed -n /.*$id.*/p kanban_params.txt | cut -d ' ' -f 2)

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
  ordered_entries_fun 1 1
  ;;  

esac

}

#Send data to file
process_user_input_fun () {
  echo $4 $3 $1 $2 >> kanban.txt
}

#Add entries
add_entries_fun () {
  read -p "$HG2"Title"$Z: " -e title 
  read -p "$HG2"Description"$Z: " -e description 
  read -p "$HG2"Tags"$Z: " -e tags 
  title=${title//' '/-}
  description=${description//' '/-}
  if [ ${#tags} == 0 ]; then tags='#p4'; else tags='#'${tags//' '/#}; fi
  id=$(date +%y%m%d%H%M%S)
  echo $id $tags $title $description >> kanban.txt
}

#Filter
filter_entries_fun () {
  read -p "$HG2"Search"$Z: " -e search 
  selected_id=$(sed -n /.*$search.*/p kanban.txt | cut -d ' ' -f 1)
  ordered_entries_fun $search
}

#Remove
remove_entries_fun () {
  read -p "$HG2"ID"$Z: " -e id 
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
  read -p "$HG2"ID"$Z: " -e id
  selected_id=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 1)

  if [ ${#selected_id} == 12 ]
    then
      title=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 3)
      description=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 4)
      tags=$(sed -n /.*$id.*/p kanban.txt | cut -d ' ' -f 2 | cut -d ' ' -f 2)
      read -p "$HG2"ID"$Z: " -i $selected_id -e selected_id
      read -p "$HG2"Title"$Z: " -i $title -e title
      read -p "$HG2"Description"$Z: " -i $description -e description
      read -p "$HG2"Tags"$Z: " -i $tags -e tags
      sed -i /${selected_id}/d kanban.txt
      title=${title//' '/-}
      description=${description//' '/-}
      tags=${tags//' '/#}
      process_user_input_fun $title $description $tags $selected_id
    else
      echo 'No unique match found. Please pass the search in as first parameter'
  fi

}

#Show entire line including ID and tags
verbose_entries_fun () {
echo "----------------------------------------"
line_total=$(sed -n '$=' kanban.txt)
for i in `seq $line_total -1 1`; 
  do
    line_id=$(sed -n ${i}p kanban.txt | tr 'A-Z' 'a-z' | grep ${1,,} | cut -d ' ' -f 1)
    if [ ${#line_id} == 12 ]; then title=$(sed -n ${i}p kanban.txt | grep ${line_id}); echo $title | cut -b -${results_width}; fi
  done
echo "----------------------------------------"
}

#Order entries
ordered_entries_fun () {
  echo "----------------------------------------"
  if [ $2 ]
    then
      recent_entries_fun "#p0" $((4 * $max_results))
      [ $max_results -gt 2 ] && recent_entries_fun "#started" $((4 * $max_results))      
      recent_entries_fun "#p1" $((3 * $max_results))
      recent_entries_fun "#p2" $((3 * $max_results))
      recent_entries_fun "#p3" $((1 * $max_results))
    else
      recent_entries_fun $1 $((4 * $max_results))
  fi

  echo "----------------------------------------"
}

#Show entries
recent_entries_fun () {
line_total=$(sed -n '$=' kanban.txt)
line_count=1
for i in `seq $line_total -1 1`; 
  do
    if [ $line_count -le $2 ]
     then
       if [ $1 ]
         then
           line_id=$(sed -n ${i}p kanban.txt | tr 'A-Z' 'a-z' | grep ${1,,} | cut -d ' ' -f 1)
           if [ ${#line_id} == 12 ]; then title=$(sed -n ${i}p kanban.txt | grep ${line_id} | cut -d ' ' -f 3); fi
         else 
           title=$(sed -n ${i}p kanban.txt | cut -d ' ' -f 3);
       fi
         
         descr=$(sed -n ${i}p kanban.txt | cut -d ' ' -f 4-)
         task_status_p1=$(sed -n ${i}p kanban.txt | grep -c '#p1')
         task_status_p0=$(sed -n ${i}p kanban.txt | grep -c '#p0')
         task_status_p2=$(sed -n ${i}p kanban.txt | grep -c '#p2')
         task_status_started=$(sed -n ${i}p kanban.txt | grep -c '#started')
         task_status_p3=$(sed -n ${i}p kanban.txt | grep -c '#p3')
    
       if [ $line_id ] && [ $line_count -le $2 ]
         then
           line_count=$((line_count +1))
           color=$HG70
           if [ $task_status_p1 -gt 0 ]; then color=$P1; fi
           if [ $task_status_p0 -gt 0 ]; then color=$P0; fi
           if [ $task_status_p2 -gt 0 ]; then color=$P2; fi
           if [ $task_status_started -gt 0 ]; then color=$ST; fi
           if [ $task_status_p3 -gt 0 ]; then color=$P3; fi
           echo " ${color}${title//-/ } ${Z}${descr//-/ }" | cut -b -${results_width}
    
       fi
    fi
  done
  
}

#Show menu
show_menu_fun () {
  read -p "$HG2"A"$Z"dd" $HG2"F"$Z"ilter" $HG2"R"$Z"emove" $HG2"U"$Z"pdate" $HG2"E"$Z"xit": " -e menu_input
  process_user_selection $menu_input
}

#Set prefered amount of data per entry
set_prefs_fun () {
 if [ $1 == "setw" ]
   then
     echo $2 $max_results > kanban_params.txt
 elif [ $1 == "setr" ]
   then
     echo $results_width $2 > kanban_params.txt
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
