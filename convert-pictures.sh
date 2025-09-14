#!/usr/bin/env bash

# TODO: add an option to:
# - change extension and/or make it case insensitive
# - CLI for selecting types
# - what to do with old images: delete them or add them to a batch list and then compress them into a tar.gz archive
# - optional GUI with yad 
# for file in *.HEIC; do
	# convert "$file" "${file%.*}.png"
# done


green="\033[32m"
reset="\033[0m"
red="\033[31m"
yellow="\033[33m"
blue="\033[34m"

# Usage: <string>
uppercase() {
	echo "${1^^}"
}

# Usage: <level> <string>
log() {
	[[ -z "$1" ]] && return
	level=$1
	message=$2

	case $level in
	debug)
		level=$(uppercase "$level")
		printf "${blue}[%s]${reset} %s\n" "$level" "$message" >&2
		;;
	info)
		level=$(uppercase "$level")
		printf "${green}[%s]${reset} %s\n" "$level" "$message" >&2
		;;
	warn)
		level=$(uppercase "$level")
		printf "${yellow}[%s]${reset} %s\n" "$level" "$message" >&2
		;;
	error)
		level=$(uppercase "$level")
		printf "${red}[%s]${reset} %s\n" "$level" "$message" >&2
		;;
	\?) exit 1 ;;
	esac
}

print_help() {
	
}

main() {
	[[ $# -eq 0 ]] && print_help
	local action="nothing"
	local output_folder="."
	local out_extension="png"
	local use_gui=0

	# a: action (what to do with old images):
	#   - NOTHING
	#   - ARCHIVE old images and delete old non-compressed images
	#   - DELETE old images, keeping the new images
	# o: output folder (default: .)
	# e: new extension (make it valid)
	# g: use yad for GUI
	while getopts "a:o:e:g" opt; do
		case $opt in
		a) a=${uppercase "$OPTARG"} ;;
		o)
			output_directory="$OPTARG"
			if [ -d "$OPTARG" ]; then
				log info "Making new folder at $OPTARG"
				mkdir -p "$OPTARG"
			fi
			;;
		e) out_extension="$OPTARG" ;;
		g) log warn "TODO" ;;
}
