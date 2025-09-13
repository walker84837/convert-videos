#!/usr/bin/env bash

# TODO: add an option to:
# - change extension and/or make it case insensitive
# - CLI for selecting types
# - what to do with old images: delete them or add them to a batch list and then compress them into a tar.gz archive
# - optional GUI with yad 
for file in *.HEIC; do
	convert "$file" "${file%.*}.png"
done
