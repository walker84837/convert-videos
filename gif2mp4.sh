#!/usr/bin/env bash

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
	local level=$1
	local message=$2

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
	*) return 1 ;;
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
	[[ -z "$res" ]] && error "Resolution cannot be empty. Try 720 or 1920x1080."
	if ((advanced)); then
		if ! [[ $res =~ ^[0-9]+x(-?[0-9]+)$ ]]; then
			error "Invalid resolution '$res'. Must be WxH (e.g., 1920x1080 or 720x-1)."
		fi
	else
		if ! [[ $res =~ ^[1-9][0-9]*$ ]] && ! [[ $res =~ ^[1-9][0-9]*x[1-9][0-9]*$ ]]; then
			error "Invalid resolution '$res'. Must be a number (e.g., 720) or WxH with positive integers (e.g., 1920x1080). Use -a for advanced syntax."
		fi
	fi
}

# Usage: <file>
validate_input_file() {
	local file=$1
	[[ -z "$file" ]] && error "Input file cannot be empty. Provide a GIF path."
	if ! [ -f "$file" ]; then
		error "Input file '$file' does not exist or is not readable. Check the path."
	fi
	if ! [[ $file =~ \.gif$ ]]; then
		error "Input file '$file' is not a GIF. Provide a .gif file."
	fi
}

gif2mp4() {
	local resolution
	if [[ -z "$2" ]]; then
		resolution=720
	else
		resolution=$2
	fi
	validate_resolution "$resolution"
	validate_input_file "$1"
	orig_path=$1
	path_stripped="${orig_path%.*}"

	log info "Converting $orig_path to ${path_stripped}.mp4 with resolution $resolution"
	ffmpeg -y -i "$orig_path" -c:v libvpx-vp9 -b:v 0 -crf 18 -vf "scale=-1:$resolution,fps=30" -pix_fmt yuv420p "${path_stripped}.mp4" || error "FFmpeg conversion failed."
	log info "Conversion complete."
}

print_help() {
	echo "Usage: $0 [-a] <path_to_gif> [resolution]"
	echo "  -a    Allow advanced FFmpeg resolution syntax (e.g., 720x-1)"
	echo "  <path_to_gif>  Path to input GIF file"
	echo "  [resolution]   Resolution (default: 720). E.g., 720 or 1920x1080"
	echo ""
	echo "Examples:"
	echo "  $0 test.gif"
	echo "  $0 test.gif 1080"
	echo "  $0 -a test.gif 720x-1"
	exit 0
}

main() {
	local advanced=0

	while getopts "ah" opt; do
		case $opt in
		a) advanced=1 ;;
		h) print_help ;;
		*) print_help ;;
		esac
	done
	shift $((OPTIND - 1))

	[[ $# -eq 0 ]] && print_help

	gif2mp4 "$@"
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
