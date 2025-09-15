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

print_help() {
	cat <<EOF
Usage: ${0##*/} [-a ACTION] [-o DIR] [-e EXT] [-g]

Options:
  -a ACTION   What to do with original files:
                NOTHING - keep originals (default)
                DELETE  - remove originals after conversion
                ARCHIVE - tar.gz originals then delete them
  -o DIR      Output directory (default: current directory)
  -e EXT      Target extension (default: png). Case-insensitive.
  -g          Launch a simple GUI (yad) to set the above options.

Examples:
  ${0##*/} -a delete -o converted -e jpg
  ${0##*/} -g          # opens the GUI
EOF
}

gui_prompt() {
	if ! command -v yad >/dev/null 2>&1; then
		log error "yad not found - install it or run the script without -g"
		exit 1
	fi

	local result
	result=$(yad --form \
		--title="Image Converter" \
		--field="Action:CB" "NOTHING!DELETE!ARCHIVE" \
		--field="Output folder:DIR" "$(pwd)" \
		--field="Extension:CB" "png!jpg!jpeg!webp!tiff" \
		--button=gtk-ok:0 --button=gtk-cancel:1)

	[[ $? -ne 0 ]] && exit 0 # user cancelled

	IFS="|" read -r gui_action gui_out_dir gui_ext <<<"$result"
	action=$(uppercase "$gui_action")
	output_folder="$gui_out_dir"
	out_extension=$(echo "$gui_ext" | tr '[:upper:]' '[:lower:]')
}

main() {
	[[ $# -eq 0 ]] && {
		print_help
		exit 0
	}

	local action="NOTHING"
	local output_folder="."
	local out_extension="png"
	local src_extension="HEIC"
	local use_gui=0

	while getopts "a:o:e:g" opt; do
		case $opt in
		a) action=$(uppercase "$OPTARG") ;;
		o) output_folder="$OPTARG" ;;
		e) out_extension=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]') ;;
		g) use_gui=1 ;;
		*)
			print_help
			exit 1
			;;
		esac
	done
	shift $((OPTIND - 1))

	if ((use_gui)); then
		gui_prompt
	fi

	case $action in
	NOTHING | DELETE | ARCHIVE) ;;
	*)
		log error "Invalid action: $action"
		print_help
		exit 1
		;;
	esac

	if [[ ! -d "$output_folder" ]]; then
		log info "Creating output folder: $output_folder"
		mkdir -p "$output_folder" || {
			log error "Failed to create $output_folder"
			exit 1
		}
	fi

	# build a case-insensitive glob for source files
	shopt -s nullglob nocaseglob
	local files=(*."$src_extension")
	shopt -u nocaseglob

	if ((${#files[@]} == 0)); then
		log warn "No *.$src_extension files found in $(pwd)"
		exit 0
	fi

	# if archiving, prepare a temporary list
	local archive_path="${output_folder}/archived_originals_$(date +%Y%m%d_%H%M%S).tar.gz"
	local to_archive=()

	for file in "${files[@]}"; do
		# build target filename by removing extension and appending target extension
		local base="${file%.*}"
		local target="${output_folder}/${base}.${out_extension}"

		# TODO: this should be moved to a separate function and this specific check should be at the start
		if command -v convert >/dev/null 2>&1; then
			log info "Converting $file → $target"
			convert "$file" "$target" && log debug "Success"
		else
			log error "ImageMagick not installed - cannot convert $file"
			continue
		fi

		case $action in
		DELETE) rm -f "$file" && log debug "Deleted $file" ;;
		ARCHIVE) to_archive+=("$file") ;;
		NOTHING) ;; # keep original
		esac
	done

	# if archiving, create tar.gz and then delete originals
	if [[ $action == "ARCHIVE" && ${#to_archive[@]} -gt 0 ]]; then
		log info "Archiving ${#to_archive[@]} original files to $archive_path"
		tar -czf "$archive_path" "${to_archive[@]}" &&
			rm -f "${to_archive[@]}" &&
			log debug "Archived and removed originals"
	fi

	log info "Done."
}

# run the script if it was called directly
[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
