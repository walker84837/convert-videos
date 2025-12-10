# Video and Image Conversion Scripts

This repository contains a collection of Bash scripts for converting videos and images.

## Scripts

### `main.sh` (Video Converter)

A Bash script that uses `ffmpeg` to process and scale videos. It can also be run with a graphical user interface (GUI) using `yad`.

#### Features

- Scales videos to a specified resolution.
- Supports different output directories and video extensions.
- Includes a GUI for easier interaction.

#### Dependencies

- `ffmpeg`
- `yad` (optional, for GUI mode)

#### Usage

```bash
./main.sh [-s WxH] [-o DIR] [-e EXT] [-d] [-g]
```
- `-s WxH`: Scale videos to a specified resolution (e.g., `1920x1080`). Default is `1920:1080`.
- `-o DIR`: Specify the output directory. Default is the current directory.
- `-e mp4`: Extension of videos to process (e.g., `mp4`, `mov`). Default is `mp4`.
- `-d`: Run with default settings.
- `-g`: Launch a simple GUI using `yad` to set options.
- `-h`: Show help menu.

#### Examples

```bash
./main.sh -s 1280x720 -o converted_videos -e mov
./main.sh -g
```

### `convert-pictures.sh` (Image Converter)

A Bash script that uses ImageMagick's `convert` command to convert image files. It handles original files based on the chosen action and supports a GUI with `yad`.

#### Features

- Converts image files to a target extension (e.g., PNG, JPG).
- Actions for original files: `NOTHING` (keep), `DELETE` (remove), `ARCHIVE` (tar.gz then delete).
- Includes a GUI for easier interaction.

#### Dependencies

- `ImageMagick` (`convert` command)
- `yad` (optional, for GUI mode)
- `tar` and `gzip` (for ARCHIVE action)

#### Usage

```bash
./convert-pictures.sh [-a ACTION] [-o DIR] [-e EXT] [-g]
```

- `-a ACTION`: What to do with original files:
    - `NOTHING`: Keep originals (default).
    - `DELETE`: Remove originals after conversion.
    - `ARCHIVE`: `tar.gz` originals then delete them.
- `-o DIR`: Output directory (default: current directory).
- `-e EXT`: Target extension (default: `png`). Case-insensitive.
- `-g`: Launch a simple GUI (`yad`) to set the above options.

#### Examples

```bash
./convert-pictures.sh -a delete -o converted_images -e jpg
./convert-pictures.sh -g
```

### `gif2mp4.sh` (GIF to MP4 Converter)

A simple Bash function that converts a GIF file to an MP4 video using `ffmpeg`. This script defines a function `gif2mp4` which can be sourced into your shell or executed directly.

#### Dependencies

- `ffmpeg`

#### Usage

Source the script first (e.g., in your `.bashrc` or directly):

```bash
source gif2mp4.sh
```

Then use the `gif2mp4` function:

```bash
gif2mp4 <path_to_gif> [resolution]
```

- `<path_to_gif>`: The path to the GIF file to convert.
- `[resolution]`: Optional. The target height for the MP4 video (e.g., `720` for 720p). Default is `720`.

#### Examples

```bash
gif2mp4 my_animation.gif
gif2mp4 another_gif.gif 1080
gif2mp4 --help # Shows usage information
```

## License

This project is licensed under the [0BSD License](LICENSE).
