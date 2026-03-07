#!/bin/bash

src="/Users/nathanditges/Documents/Docx for Logos"

shopt -s nullglob
for file in "$src"/*.md; do
  pandoc "$file" -o "${file%.md}.docx"
done