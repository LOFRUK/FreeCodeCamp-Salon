#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~"

echo -e "\nWelcome to my Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

if [[ -z $AVAILABLE_SERVICES ]] 
then
  echo "Sorry, we do not do this service at this time"
else
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
     echo "$SERVICE_ID) $NAME"
    done


    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "That is not a valid number."
      else
        SERV_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id ='$SERVICE_ID_SELECTED'")
        SERV_NAME=$($PSQL "SELECT name FROM services WHERE service_id ='$SERVICE_ID_SELECTED'")
        if [[ -z $SERV_AVAIL ]]
          then
            MAIN_MENU "I could not find this service, what would you like help with today?"
          else
          echo -e "What is your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          if [[ -z $CUSTOMER_NAME ]]
          then
            echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      
         fi
        echo -e "\nWhat time would you like your $SERV_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
          if [[ $INSERT_SERV_RESULT ]]
          then
            echo -e "\nI have put you down for a $SERV_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')." 
          fi
        fi
      fi
    fi
  fi  
}

MAIN_MENU