use AppleScript version "2.4"
use scripting additions

-- Try common pandoc locations; fall back to PATH
on findPandoc()
	set candidates to {"/opt/homebrew/bin/pandoc", "/usr/local/bin/pandoc", "/usr/bin/pandoc"}
	repeat with p in candidates
		try
			do shell script "test -x " & quoted form of (contents of p)
			return contents of p
		end try
	end repeat
	-- Last resort: rely on PATH
	return "pandoc"
end findPandoc

set pandocPath to findPandoc()

tell application "Finder"
	set sel to selection as alias list
end tell

if (count of sel) is 0 then
	display dialog "Select one or more .md files in Finder first." buttons {"OK"} default button 1
	return
end if

-- Filter to .md files and build a list of POSIX paths (quoted)
set mdPosixPaths to {}
repeat with a in sel
	set p to POSIX path of a
	if p ends with ".md" then
		set end of mdPosixPaths to p
	end if
end repeat

if (count of mdPosixPaths) is 0 then
	display dialog "No .md files found in your selection." buttons {"OK"} default button 1
	return
end if

-- Ask where to save output
set outFile to choose file name with prompt "Save merged DOCX as:" default name "merged_output.docx"

set outPath to POSIX path of outFile

-- Build pandoc command
set cmd to quoted form of pandocPath & " -s"
repeat with p in mdPosixPaths
	set cmd to cmd & " " & quoted form of (contents of p)
end repeat
set cmd to cmd & " -o " & quoted form of outPath

-- Run it
try
	do shell script cmd
	display dialog "Merged DOCX created:" & return & outPath buttons {"OK"} default button 1
on error errMsg
	display dialog "Pandoc failed:" & return & errMsg buttons {"OK"} default button 1
end try
