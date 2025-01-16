#!/bin/bash
# for OSX users:
# #!/bin/zsh
# author neunmalelf@gmail.com
# purpose: switching columns in a csv file
# usage  : download this file in your script folder and make it executable:
#          chmod +x whitep4nth3r_csv_changer.sh
#
#          then make a symlink to your home folder if your script folder isn't in your PATH
#
#          ln -s /path/to/your/script/folder/whitep4nth3r_csv_changer.sh ~/whitep4nth3r_csv_changer
#


# <SETTINGS>
# set some constants & variables

NL=$'\n'
CR=$'\r'
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_CYAN='\033[0;36m'
COLOR_PURPLE='\033[0;33m'

COLOR_LIGHTBLUE='\033[1;34m'

STYLE_RESET="${COLOR_RESET}"
STYLE_OK="${COLOR_GREEN}"
STYLE_ERROR="${COLOR_RED}"
STYLE_WARNING="${COLOR_RED}"
STYLE_INFO="${COLOR_BLUE}"
STYLE_SUCCESS="${COLOR_GREEN}"

STYLE_FILE1="${COLOR_YELLOW}"
STYLE_FILE2="${COLOR_CYAN}"
STYLE_DIRECTORY1="${COLOR_YELLOW}"
STYLE_DIRECTORY2="${COLOR_CYAN}"

MSG_EMPTY="      "
MSG_TRY="${COLOR_CYAN}TRY  ${COLOR_RESET}"
# STYLE_ERROR="${COLOR_RED}ERROR ${COLOR_RESET}"
# STYLE_WARNING="${COLOR_RED}WARNING ${COLOR_RESET}"
# STYLE_INFO="${COLOR_BLUE}INFO ${COLOR_RESET}"
# STYLE_SUCCESS="${COLOR_GREEN}OK ${COLOR_RESET}"

JOB_NAME="$(basename "$0")"
JOB_NAME="${JOB_NAME#./}"
# JOB_VERSION="0.1.20250115T154000"
CSVFILE_DEFAULT="words_to_replace.csv"
TEMP_FILE="_temp.csv"

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# * FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

function _show_usage() {
  echo "${NL}Usage: $0 [csvfile]"
  echo "       csvfile: the csv file to switch the columns in"
  echo "                default csv file: $CSVFILE_DEFAULT"
  echo ""
  echo "  switches the columns in a csv file"
  echo ""
  echo "  example:"
  echo ""
  echo "  $0 words_to_replace.csv"
  echo ""
  exit 1
}


function _printn() {
  local text=$1
  local style=$2
  if [ -z "$style" ]; then
    style="${STYLE_RESET}"
  fi
  echo -e -n "${style}${text}${STYLE_RESET}"
}


function _print() {
  local text=$1
  local style=$2
  if [ -z "$style" ]; then
    style="${STYLE_RESET}"
  fi

   echo -e "${style}${text}${STYLE_RESET}"
}

function _printok () {
  # local text=$1
  local text="${CR}"
  _print "${text}${STYLE_SUCCESS}OK "
}

function _printdone() {
  local text="${CR}"
  _print "${text}${STYLE_SUCCESS}DONE "
}

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# * MAIN
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


# read the name for the csv file from the command line or any help command
CSVFILE="$1"

if [[ "${CSVFILE,,}" == "help" || "${CSVFILE,,}" == "-help"  || "${CSVFILE,,}" == "-h" ]]; then
  _show_usage
  exit 0
fi
if [ -z "$CSVFILE" ]; then
  CSVFILE="$CSVFILE_DEFAULT"
fi

# </SETTINGS>

# * inform the user about the job

_print "=================================================="
_print "JOB_STARTED:  ${STYLE_INFO}${JOB_NAME} "
# echo "                        (ver.: ${JOB_VERSION})"
_print "=================================================="
_print ""


# * checking if the file exists
if [ ! -f "$CSVFILE" ]; then
  # echo ""
  _print "${STYLE_ERROR}"
  _print "ERROR: the file:  ${STYLE_FILE1}${CSVFILE}"
  _print "       does not exist"
  _print ""
  _print "${STYLE_WARNING}      => exiting JOB"
  _print ""
  exit 1
fi


# create a backup of the original file
_print "${MSG_EMPTY}making a backup of file: ${STYLE_FILE1}${CSVFILE}"
_printn "${MSG_TRY}                 as file: ${STYLE_FILE2}${CSVFILE}.bak"
cp -f "${CSVFILE}" "${CSVFILE}.bak"
_printdone
# Switch the columns and overwrite the original file
# word_a,word_b -> word_b,word_a
#
# old version using awk
#  awk -F, '{print $2 "," $1}' "$CSVFILE" > temp.csv && mv temp.csv "$CSVFILE"
# newvesion use only bash internal commands: external awk needed
_print ""
_printn "${MSG_TRY}switching columns A<->B in file: ${STYLE_FILE1}$CSVFILE"
while IFS=, read -r col1 col2; do
    echo "$col2,$col1"
done < "${CSVFILE}" > "${TEMP_FILE}" && mv "${TEMP_FILE}" "${CSVFILE}"
_printdone

# asking user if he wants to see the result
# _printn "${NL}Do you want to see the result? ${STYLE_OK}y${STYLE_RESET} = yes / ${STYLE_ERROR}[ENTER]${STYLE_RESET} or ${STYLE_ERROR}n${STYLE_RESET} = no : "
_printn "${NL}Do you want to see the changed file? ${STYLE_OK}y${STYLE_RESET} / ${STYLE_ERROR}n${STYLE_RESET} ${STYLE_ERROR}[ENTER]${STYLE_RESET} : "
read -r answer
if [ "${answer,,}" == "y" ]; then
  _print ""
  # echo "Result:"
  _print "${STYLE_INFO}----- ${STYLE_RESET}content of file: ${STYLE_FILE1}${CSVFILE}${STYLE_RESET} ${STYLE_INFO}-----"
  _print ""
  cat "$CSVFILE"
  _print ""
  _print "------------------------------------------------" "${STYLE_INFO}"
fi

_print ""
_print ".................................................."
_print "JOB_DONE: ${STYLE_INFO}${JOB_NAME}"
_print ".................................................."
_print ""
