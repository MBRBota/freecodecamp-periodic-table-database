#!/bin/bash
PSQL="psql -U freecodecamp -d periodic_table -t -A -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    QUERY=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
    QUERY_CONDITION="atomic_number"
  else
    QUERY=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
    QUERY_CONDITION="symbol"
    if [[ -z $QUERY ]]
    then
      QUERY=$($PSQL "SELECT name FROM elements WHERE name = '$1'")
      QUERY_CONDITION="name"
    fi
  fi
  
  if [[ -z $QUERY ]]
  then
    echo "I could not find that element in the database."
  else
    QUERY_FULL=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE $QUERY_CONDITION = '$QUERY'")
    IFS='|' read -a QUERY_ARRAY <<< $QUERY_FULL
    ATOMIC_NUMBER=${QUERY_ARRAY[0]}
    SYMBOL=${QUERY_ARRAY[1]}
    NAME=${QUERY_ARRAY[2]}
    MASS=${QUERY_ARRAY[3]}
    MELT=${QUERY_ARRAY[4]}
    BOIL=${QUERY_ARRAY[5]}
    TYPE=${QUERY_ARRAY[6]}

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  fi
fi
