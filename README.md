# Markdown / Gutenberg to DOCX Scripts for Logos

These scripts are small personal utilities I use to download, clean up, and convert Project Gutenberg books or other webpages into `.docx` files for import into **Logos Bible Software** as personal books.

## What these scripts do

Depending on the script, they can:

- download HTML pages or books from Project Gutenberg
- open and review the downloaded content
- convert `.html` or `.md` files into `.docx`
- optionally convert content into Markdown first
- prepare files in a format that works well for Logos import

## Main use case

My normal workflow is:

1. download a Project Gutenberg book or webpage
2. inspect the HTML if needed
3. convert it to Markdown or DOCX with Pandoc
4. import the finished `.docx` file into Logos Bible Software

## Notes

- These scripts are built around my personal folder structure and workflow
- Some paths will need to be changed before they work on another machine
- They assume tools like `pandoc`, `wget`, and macOS automation tools are available
- Some scripts are written in AppleScript for macOS-specific automation

## Requirements

Operating System
- macOS

Terminal 
- Pandoc  --- brew install pandoc
- Wget    --- brew install wget

Software
- Obsidian Software                      --- https://obsidian.md/download
- Brave Browser                          --- https://brave.com/download  (for the review step in one script)
- Logos Bible Software for final import  --- https://www.logos.com/install

## Purpose

The goal of these scripts is not to create polished publishing files, but to quickly generate readable and importable DOCX documents for use inside Logos.
