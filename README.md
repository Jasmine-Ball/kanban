# kanban-compact

This uses a single column and technically isn't a kanban board, but can be used to store and filter basic tasks according to tags (new, in-progress etc) or other data via a Linux terminal / Termux with Bash.


1. Download the kanban.sh bash script
2. Add the 'execute' permission with `chmod +× kanban.sh` 
3. Run the kanban.sh script: `./kanban.sh`
4. Select options from the menu using your keyboard

Hidden functions:

1. Run the script with a single parameter to search the raw data file: `./kanban.sh water`
2. Run the script with `set` as the first parameter and the number of bytes to show for each result
3. Run the script and press `Enter` twice to quickly see recent tasks
