#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MySalon Appointment Scheduler ~~~~~\n"

DISPLAY_SERVICE() {
  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services order by service_id")
  # display services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nWhich service would you like to book?"
  read SERVICE_ID_SELECTED

  # if not number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to service menu
      echo -e "\nPlease choose a service number."
      DISPLAY_SERVICE
    else 
      SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

      # get service name
      # if not in list
      if [[ -z $SERVICE_NAME_SELECTED ]]
       then
        # send to service menu
        echo -e "\nPlease choose a service on the list."
        DISPLAY_SERVICE

      else
        # ask for phone number
        echo -e "\nPlease provide your phone number:"
        read CUSTOMER_PHONE
        # get customer id from records
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

        # if phone not in records
        if [[ -z $CUSTOMER_ID ]]
          then
            # ask for name
            echo -e "\nA new customer! Thank you for visiting. Please provide your name:"
            read CUSTOMER_NAME
            # add to customers
            CUSTOMER_ADDED_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            if [[ $CUSTOMER_ADDED_RESULT == "INSERT 0 1" ]]
              then echo -e "\nYou're now a member, $CUSTOMER_NAME!"
            fi
        fi
        # get customer id
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")

        #ask for time
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g') service, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
        read SERVICE_TIME
        SERVICE_ADDED_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        if [[ $SERVICE_ADDED_RESULT == "INSERT 0 1" ]]
          then echo -e "\nI have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
        fi
      fi
  fi
}

SERVICE_MENU() {
  if [[ $1 ]]
    then echo -e "\n$1"
  fi

  DISPLAY_SERVICE  

  # prompt for service wanted
  
}

SERVICE_MENU "Welcome to MySalon, here are the services we have available:"