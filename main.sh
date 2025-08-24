#!/usr/bin/env bash

set -euo pipefail

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
	echo "Usage: $0 [-s WxH] [-o DIR]"
	echo "  -e mp4   Extension of videos to process (default: mp4)"
	echo "  -s WxH   Scale videos to resolution (default: 1920x1080)"
	echo "  -o DIR   Output directory (default: current directory)"
	echo "  -d       Run with default settings"
	echo "  -h       Show this help menu"
	exit 0
}

process_videos() {
	scale="$1"
	outdir="$2"
	extension="$3"

	for file in *."$extension"; do
		[[ "$file" == *-fhd.$extension ]] && continue

		base="${file%.mp4}"
		new_video="$outdir/${base}-fhd.$extension"
		tmp_video="${new_video}.part"

		log info "Converting $file to $new_video"
		if [[ ! -f "$new_video" ]]; then
			log debug "Running ffmpeg with scale=$scale"
			ffmpeg -i "$file" -vf "scale=$scale" -f "$extension" "$tmp_video" -y && mv "$tmp_video" "$new_video"
		fi
	done
}

main() {
	local scale="1920:1080"
	local outdir="."
	local extension="mp4"

	[[ $# -eq 0 ]] && print_help

	while getopts "s:o:e:dh" opt; do
		case $opt in
		s) scale="$OPTARG/x/:" ;;
		o) outdir="$OPTARG" ;;
		h)
			print_help
			;;
		e) extension="$OPTARG" ;;
		d) ;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		esac
	done
	shift $((OPTIND - 1))

	mkdir -p "$outdir"

	log info "Processing videos in $PWD"
	process_videos "$scale" "$outdir" "$extension"
}

main "$@"
