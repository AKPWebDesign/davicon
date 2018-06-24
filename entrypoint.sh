#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CLEAR='\033[0m'

HELP=0
SIZES="16,32,48,57,64,70,72,114,120,144,150,152,256,310,512"
FAVICONSIZES="16,32,64,128,256"

OPTIONS=s:f:hv
LONGOPTIONS=sizes:,favicon-sizes:,help,verbose

# -temporarily store output to be able to check for errors
# -e.g. use “--options” parameter by name to activate quoting/enhanced mode
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
  # e.g. $? == 1
  #  then getopt has complained about wrong arguments to stdout
  exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
  case "$1" in
    -h|--help)
      HELP=1
      shift
      break
      ;;
    -s|--sizes)
      SIZES="$2"
      shift 2
      ;;
    -f|--favicon-sizes)
      SIZES="$2"
      shift 2
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Programming error"
      exit 3
      ;;
  esac
done

if [ "$HELP" -eq "1" ]; then
  echo -e "${GREEN}Davicon!${CLEAR}"
  echo "Usage: docker run --rm -it -v \$(pwd):/app/icons akpwebdesign/davicon [options] <image>"
  echo "Options:"
  echo "  --sizes, -s: Set the output size list. Default: \"16,32,48,57,64,70,72,114,120,144,150,152,256,310,512\""
  echo "  --favicon-sizes, -f: Set the favicon output size list. Default: \"16,32,64,128,256\""
  echo "  --help, -h: Shows this text."
  exit 0;
fi

if [ ! -d "/app/icons" ]; then
  echo -e "${RED}Icons directory doesn't exist! Did you remember to link your icons directory to the container?${CLEAR}"
  echo -e "${RED}Usage: docker run --rm -it -v \$(pwd):/app/icons akpwebdesign/davicon [options]${CLEAR}"
  exit 1
fi

if [[ $# -ne 1 ]]; then
    echo -e "${RED}davicon: A single input file is required.${CLEAR}"
    exit 1
fi

convert_svg() {
  inkscape -z -e "$3/favicon-$1.png" -w $1 -h $1 /app/icons/$2 > /dev/null 2>&1
}

convert_non_svg() {
  convert -resize $1x$1 /app/icons/$2 "$3/favicon-$1.png"
}

if [[ "$1" == *svg ]]
then
  for size in $(echo $SIZES | sed "s/,/ /g")
  do
    echo "Creating favicon-$size.png..."
    convert_svg $size $1 /app/icons
  done

  mkdir /app/temp
  FILES=""

  echo "Creating favicon.ico"
  for size in $(echo $FAVICONSIZES | sed "s/,/ /g")
  do
    convert_svg $size $1 /app/temp
    FILES="/app/temp/favicon-$size.png $FILES"
  done
else
  for size in $(echo $SIZES | sed "s/,/ /g")
  do
    echo "Creating favicon-$size.png..."
    convert_non_svg $size $1 /app/icons
  done

  mkdir /app/temp
  FILES=""

  echo "Creating favicon.ico"
  for size in $(echo $FAVICONSIZES | sed "s/,/ /g")
  do
    convert_non_svg $size $1 /app/temp
    FILES="/app/temp/favicon-$size.png $FILES"
  done
fi



convert $FILES -colors 256 -background transparent /app/icons/favicon.ico > /dev/null

echo -e "${GREEN}All done!${CLEAR}"
