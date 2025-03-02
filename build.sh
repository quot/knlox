#!/bin/zsh

BLUE='\033[0;34m'
NOCOLOR='\033[0m'

run_requirements=("kotlinc-native" "make")

path+=$(pwd)/resources/dart-sdk/bin
dart --disable-analytics

typeset -A build_opts
build_opts=(
  [build]=true
  [run]=true
  [clean]=false
  [build_dir]="build/knlox"
  [bin_name]="bin"
)

# Parse command arguements
while (( "$#" )); do
  case "$1" in
    --clean)
      build_opts[clean]=true
      shift
      ;;
    --nobuild)
      build_opts[build]=false
      shift
      ;;
    # -p|--profiles)
    #   if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
    #     build_opts[profiles]=$2
    #     shift 2
    #   else
    #     echo "Error: Argument for $1 is missing" >&2
    #     exit 1
    #   fi
    #   ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# Check for script prereqs
for prereq in "${run_requirements[@]}"; do
  if ! command -v ${prereq} 2>&1 >/dev/null; then
      echo "[${prereq}] missing!"
      echo "[${run_requirements}] required to run."
      exit 1
  fi
done


if [[ $build_opts[clean] == true ]]; then
  echo "${BLUE}Cleaning project...${NOCOLOR}"
  rm -rf ./build
  (cd ./craftinginterpreters; make clean && rm ./jlox)
fi

# Build knlox
if [[ $build_opts[build] == true ]]; then
  echo "${BLUE}Building KNLox...${NOCOLOR}"
  mkdir -p ./${build_opts[build_dir]}
  kotlinc-native main.kt -o ${build_opts[build_dir]}/${build_opts[bin_name]}
elif ! [[ -e ./${build_opts[build_dir]}/${build_opts[bin_name]}.kexe ]]; then
  echo "Build skipped and ./${build_opts[build_dir]}/${build_opts[bin_name]}.kexe does not exist!"
  exit 1
fi

# Build refernce repo
if [[ $build_opts[build] == true ]] && ! [[ -e ./craftinginterpreters/jlox ]]; then
  echo "${BLUE}Building reference Lox project...${NOCOLOR}"
  (cd ./craftinginterpreters && make get && make)
fi

if [[ $build_opts[run] == true ]]; then
  echo "${BLUE}Running KNLox...${NOCOLOR}"
  ./${build_opts[build_dir]}/${build_opts[bin_name]}.kexe
  echo "${BLUE}Running JLox...${NOCOLOR}"
  (cd ./craftinginterpreters && make test_jlox)
fi
