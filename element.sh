#!/bin/bash

PSQL="psql -U freecodecamp -d periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  exit 0
fi

# if argument is provided
# check if argument is atomic number, symbol or name
if [[ "$1" =~ ^[0-9]+$ ]]
then
  # Input is atomic number
  CONDITION="atomic_number = $1"
elif [[ "$1" =~ ^[A-Za-z]{1,2}$ ]]
then
  # Input is symbol
  CONDITION="symbol = '$1'"
else
  # Input is element name
  CONDITION="name = '$1'"
fi

# query to get atomic number, symbol, name, atomic mass, type, melting point and boiling point from the database
QUERY="SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) RIGHT JOIN types USING(type_id) WHERE $CONDITION"

# get the values and store then in the result variable
RESULT=$($PSQL "$QUERY")

# Check if the queried element exists in the database
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
else
  while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MPT BPT
  do 
    echo "The element with atomic number $ATOMIC_NUMBER is "$NAME" ("$SYMBOL"). It's a "$TYPE", with a mass of $ATOMIC_MASS amu. "$NAME" has a melting point of $MPT celsius and a boiling point of $BPT celsius."
  done <<< "$RESULT"
fi

