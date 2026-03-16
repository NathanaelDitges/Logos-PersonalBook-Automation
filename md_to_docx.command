#!/bin/bash

# Folder that contains the Markdown files you want to convert.
src="/Users/nathanditges/Documents/Docx for Logos"

# If no .md files are found, make the glob expand to nothing
# instead of staying as the literal string "*.md".
shopt -s nullglob

# Loop through every Markdown file in the source folder.
for file in "$src"/*.md; do
  # Convert each .md file to a .docx file with the same base name.
  # Example:
  #   notes.md  -> notes.docx
  pandoc "$file" -o "${file%.md}.docx"
done
