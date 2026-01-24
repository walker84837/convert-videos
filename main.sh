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

# Usage: <message>
error() {
	log error "$1"
	exit 1
}

# Usage: <resolution>
validate_resolution() {
	local res=$1
	[[ -z "$res" ]] && error "Resolution cannot be empty. Try 1920x1080."
	if ((advanced)); then
		if ! [[ $res =~ ^[0-9]+x(-?[0-9]+)$ ]]; then
			error "Invalid resolution '$res'. Must be WxH (e.g., 1920x1080 or 720x-1)."
		fi
	else
		if ! [[ $res =~ ^[1-9][0-9]*x[1-9][0-9]*$ ]]; then
			error "Invalid resolution '$res'. Must be WxH with positive integers (e.g., 1920x1080). Use -a for advanced syntax."
		fi
	fi
}

# Usage: <dir>
validate_output_dir() {
	local dir=$1
	[[ -z "$dir" ]] && error "Output directory cannot be empty. Try '.' or a valid path."
	if ! [ -d "$dir" ] && ! mkdir -p "$dir" 2>/dev/null; then
		error "Cannot create output directory '$dir'. Check permissions or try a different path."
	fi
}

print_help() {
	echo "Usage: $0 [-s WxH] [-o DIR]"
	echo "  -e mp4   Extension of videos to process (default: mp4)"
	echo "  -s WxH   Scale videos to resolution (default: 1920x1080)"
	echo "  -o DIR   Output directory (default: current directory)"
	echo "  -a       Allow advanced FFmpeg resolution syntax (e.g., 720x-1)"
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

dependency_check() {
	local program=$1
	if ! command -v "$program" >/dev/null 2>&1; then
		log error "$program is not installed. Install it with your package manager."
		exit 1
	fi
}

main() {
	local scale="1920:1080"
	local outdir="."
	local extension="mp4"
	local use_gui=0
	local advanced=0

	[[ $# -eq 0 ]] && print_help

	while getopts "s:o:e:dgha" opt; do
		case $opt in
		s)
			validate_resolution "$OPTARG"
			scale="${OPTARG/x/:}"
			;;
		o) outdir="$OPTARG" ;;
		h)
			print_help
			;;
		e) extension="$OPTARG" ;;
		d) ;;
		g) use_gui=1 ;;
		a) advanced=1 ;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		esac
	done
	shift $((OPTIND - 1))

	if [[ $use_gui -eq 1 ]]; then
		dependency_check "yad"

		local values
		if ! values=$(yad --form --title="FFmpeg Batch Converter" \
			--field="Scale (WxH):" "1920x1080" \
			--field="Output Directory:DIR" "$PWD" \
			--field="Extension:" "mp4"); then
			exit 1 # user canceled
		fi

		IFS="|" read -r scale outdir extension <<<"$values"
		validate_resolution "$scale"
		scale="${scale/x/:}"
	fi

	validate_output_dir "$outdir"

	mkdir -p "$outdir"

	log info "Processing videos in $PWD"
	process_videos "$scale" "$outdir" "$extension"
}

main "$@"
