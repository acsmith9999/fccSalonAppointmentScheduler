#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  # case $SERVICE_ID_SELECTED in
  #   1|2|3|4|5) BOOKING_MENU ;;
  #   *) MAIN_MENU "I could not find that service. What would you like today?" ;; 
  # esac
  #get service type
  SERVICE_TYPE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
   
  if [[ -z $SERVICE_TYPE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
     #get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      #get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      #insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    #get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #format results
    SERVICE_TYPE_FORMATTED=$(echo $SERVICE_TYPE | sed -E 's/^ *| *$//g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
    #get appointment time
    echo -e "\nWhat time would you like your $SERVICE_TYPE_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME
    #insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    #success
    echo -e "\nI have put you down for a $SERVICE_TYPE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU