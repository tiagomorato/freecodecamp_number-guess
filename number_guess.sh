#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# set random number
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo -e "Enter your username:"
read USERNAME

# check if username is in the database
USERNAME_IN_DATABASE=$($PSQL "SELECT username FROM user_info WHERE username = '$USERNAME' ")

if [[ $USERNAME_IN_DATABASE = $USERNAME ]]
then
  # get games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username = '$USERNAME' ")
  if [[ -z $GAMES_PLAYED ]]
  then GAMES_PLAYED=0
  fi
  # get best game
  BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE username = '$USERNAME' ")
  # user was found
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # insert new user
  INSERT_NEW_USER=$($PSQL "INSERT INTO user_info(username) VALUES('$USERNAME') ")
  # user not found
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
fi

echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS

NUMBER_OF_GUESSES=1

while [ ! $USER_GUESS = $RANDOM_NUMBER ]
  do
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1)) 

  # if guess not int
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
    read USER_GUESS 
  else 
    if [[ $USER_GUESS > $RANDOM_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
      read USER_GUESS
    else  
      # if guess num < random num
      if [[ $USER_GUESS < $RANDOM_NUMBER ]]
      then
        echo -e "It's higher than that, guess again:"
        read USER_GUESS
      fi
    fi  
  fi      
done

# if user guess = random num
if [[ $USER_GUESS = $RANDOM_NUMBER ]]
then 
  echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"      
fi

# if best game is empty
if [[ -z $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE user_info SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME' ")
fi

# if num guesses < best game
if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
then
  # set best game to $NUMBER_OF_GUESSES
  UPDATE_BEST_GAME=$($PSQL "UPDATE user_info SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME' ")
fi

# set games played + 1
GAMES_PLAYED_PLUS_ONE=$(($GAMES_PLAYED + 1))
GAMES_PLAYED_PLUS_ONE=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED_PLUS_ONE WHERE username = '$USERNAME' ")