gif2mp4() {
        if [[ "$1" == "--help" ]]; then
                echo "Usage: gif2mp4 <path_to_gif> <resolution :: optional [720p]>"
                echo "Example (720p): gif2mp4 test.gif 720"
                return
        fi
        local resolution
        if [[ -z "$2" ]]; then
                resolution=720
        else
                resolution=$2
        fi
        orig_path=$1
        path_stripped="${orig_path%.*}"

        ffmpeg -y -i "$orig_path" -c:v libvpx-vp9 -b:v 0 -crf 18 -vf "scale=-1:$2,fps=30" -pix_fmt yuv420p "$path_stripped.mp4" || return
}