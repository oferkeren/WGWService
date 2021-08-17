#!/bin/bash


#At setup:   /home/ubuntu/admin_clean_room.sh  -setup
#For test   /home/ubuntu/admin_clean_room.sh  -removeroom

function removeroom {
      echo "$RUN"

      echo "start of removeroom function"
      cd /home/ubuntu/admin_clean_room
      node removerooms.js
      exit
}

removeroom
