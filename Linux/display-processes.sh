#!/bin/bash

#EXERCISE 3: Bash Script - User Processes
#Write a bash script using Vim editor that checks all the processes running for the current user (USER env var) and prints out the processes in console. Hint: use ps aux command and grep for the user.

#EXERCISE 4: Bash Script - User Processes Sorted
#Extend the previous script to ask for a user input for sorting the processes output either by memory or CPU consumption, and print the sorted list.

#EXERCISE 5: Bash Script - Number of User Processes Sorted
#Extend the previous script to ask additionally for user input about how many processes to print. Hint: use head program to limit the number of outputs. 

echo "Current user is $USER"
echo "Enter:"
echo "1- display a list of processes sorted by CPU consumption"
echo "2- display a list of processes sorted by Memory consumption"

read -p "Sort by CPU, or Memory consumption? " sort

read -p "How many processes to display? " count

if [[ ! "$count" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid number: $count"
    exit 1
fi

case "$sort" in
  1)
    ps -u "$USER" -o pid,%cpu,%mem,command --sort=-%cpu \
      | head -n $((count+1))
    ;;
  2)
    ps -u "$USER" -o pid,%cpu,%mem,command --sort=-%mem \
      | head -n $((count+1))
    ;;
  *)
    echo "Invalid option: $sort"
    exit 1
    ;;
esac
