#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
##################################################
# To erase data that has been inserted before hand to the tables mentioned. This way the table where the data is inserted will contain only the data in the games.csv file (no duplicates etc.)
echo $($PSQL "TRUNCATE table games, teams")
# Alter the table so that the sequence of the team_id starts runnign from 1.
$PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1"
$PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1"
# Enters the csv file and reads the columns mentioned after "read" which it will interpret as differentiated with a comma. It starts a pipe, While loop with a do acction.
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # To not insert the name of the column in the csv file, when reading through the 'winner'. 
  if [[ $winner != "winner" ]]
  then
  # Get the team_id from the teams table, so that it is possible to add to each team name an unique id number.
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
    # if a TEAM_ID is not found, it means that there has not been inserted a team with the same name (since if there would, it would have a unique team_id).
    if [[ -z $TEAM_ID ]]
    then
      # Insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$winner')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
      echo Inserted into teams from winners, $winner
      fi
    # Get new team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")  
    fi
  fi
  # To not insert the name of the column in the csv file, when reading through the 'opponent'. 
  if [[ $opponent != "opponent" ]]
  then
  # Get the team_id from the teams table, so that it is possible to add to each team name an unique id number.
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")
    # if a TEAM_ID is not found, it means that there has not been inserted a team with the same name (since if there would, it would have a unique team_id).
    if [[ -z $TEAM_ID ]]
    then
      # Insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$opponent')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
      echo Inserted into teams from opponents, $opponent
      fi
    # Get new team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")  
    fi
  fi
done  
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != "year" ]]
  then
	  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
	  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
	  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,winner_id,opponent_id,winner_goals,opponent_goals,round) VALUES ($YEAR,$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS,'$ROUND')")
	fi
done