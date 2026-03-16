use AppleScript version "2.4"
use scripting additions

-- This handler tries to locate the Pandoc executable.
-- It checks a few common install locations first,
-- then falls back to just calling "pandoc" from the shell PATH.
on findPandoc()
	-- Common Pandoc install paths on macOS:
	-- Apple Silicon Homebrew, Intel Homebrew, and a generic system path.
	set candidates to {"/opt/homebrew/bin/pandoc", "/usr/local/bin/pandoc", "/usr/bin/pandoc"}
	
	-- Loop through each possible path and test whether it exists
	-- and is executable.
	repeat with p in candidates
		try
			do shell script "test -x " & quoted form of (contents of p)
			return contents of p -- Return the first working Pandoc path found.
		end try
	end repeat
	
	-- If none of the hardcoded paths work, rely on the shell's PATH.
	return "pandoc"
end findPandoc

-- Store the detected Pandoc command/path for later use.
set pandocPath to findPandoc()

-- Ask Finder for the currently selected items.
tell application "Finder"
	set sel to selection as alias list
end tell

-- If nothing is selected, stop and show the user a message.
if (count of sel) is 0 then
	display dialog "Select one or more .md files in Finder first." buttons {"OK"} default button 1
	return
end if

-- Create an empty list that will hold the POSIX paths
-- of all selected Markdown files.
set mdPosixPaths to {}

-- Loop through every selected Finder item.
repeat with a in sel
	-- Convert the Finder alias into a standard POSIX path string.
	set p to POSIX path of a
	
	-- Only keep files whose names end in ".md".
	if p ends with ".md" then
		set end of mdPosixPaths to p
	end if
end repeat

-- If the user selected files, but none of them were Markdown files,
-- stop and notify them.
if (count of mdPosixPaths) is 0 then
	display dialog "No .md files found in your selection." buttons {"OK"} default button 1
	return
end if

-- Ask the user where to save the merged DOCX file.
-- A default output name is suggested.
set outFile to choose file name with prompt "Save merged DOCX as:" default name "merged_output.docx"

-- Convert the chosen output file location into a POSIX path
-- so it can be used in a shell command.
set outPath to POSIX path of outFile

-- Start building the Pandoc shell command.
-- The -s flag tells Pandoc to create a standalone document.
set cmd to quoted form of pandocPath & " -s"

-- Add each Markdown file path to the command.
-- quoted form protects paths with spaces or special characters.
repeat with p in mdPosixPaths
	set cmd to cmd & " " & quoted form of (contents of p)
end repeat

-- Add the output file option and destination path.
set cmd to cmd & " -o " & quoted form of outPath

-- Run the Pandoc command.
try
	do shell script cmd
	
	-- If successful, show the user where the DOCX was created.
	display dialog "Merged DOCX created:" & return & outPath buttons {"OK"} default button 1
on error errMsg
	-- If Pandoc fails, show the returned error message.
	display dialog "Pandoc failed:" & return & errMsg buttons {"OK"} default button 1
end try
