#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "select * from services")

LOOP() {
  echo "$SERVICES" | while read id foo service; do
    echo "$id) $service"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
  echo $SERVICE_NAME
  if [[ -z $SERVICE_NAME ]]; then
    LOOP
  else
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE';")
    echo $CUSTOMER_NAME
    if [[ -z $CUSTOMER_NAME ]]; then
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      RESULT=$($PSQL "insert into customers values(default, '$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ //g')
    NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ //g')
    echo "What time would you like your $SERVICE_NAME_FORMATTED, $NAME_FORMATTED?."
    read SERVICE_TIME
    C_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    PUSH=$($PSQL "insert into appointments values(default,  $C_ID, $SERVICE_ID_SELECTED,  '$SERVICE_TIME')")
    if [[ -z $PUSH ]]; then
      echo "some error, cant insert to appointments"
    else
      echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $NAME_FORMATTED."
      exit
    fi
  fi
}

LOOP
