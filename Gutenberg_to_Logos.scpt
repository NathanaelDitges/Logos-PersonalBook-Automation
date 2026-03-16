use AppleScript version "2.4" -- Requires Yosemite (10.10) or later
use scripting additions

-- Toggle whether a Markdown copy should also be created.
-- 1 = yes, also convert to Markdown
-- 0 = no, only create the DOCX
set toMD to 0 -- Just use obsidian clipper idiot.. :) (1 is convert to MD; 0 not)

-- Ask for the first Gutenberg URL document number to process.
set startNumber to text returned of (display dialog "Number of First Document:" default answer 17489) --7

-- Ask for the last Gutenberg URL document number to process.
-- The script will loop from startNumber to endNumber.
set endNumber to text returned of (display dialog "Number of Final Document:" default answer 17489) --8

-- Loop through every document number in the chosen range.
repeat with i from startNumber to endNumber
	
	-- Build the default Project Gutenberg HTML URL for this document number.
	set websiteURL to "https://www.gutenberg.org/files/" & i & "/" & i & "-h/" & i & "-h.htm"
	
	-- Build the expected local file path where wget will save the HTML file.
	set savePath to "/Users/nathanditges/Downloads/WgetDownloads/www.gutenberg.org/files/" & i & "/" & i & "-h/" & i & "-h.htm"
	
	-- Let the user confirm or replace the URL before downloading.
	set websiteURL to text returned of (display dialog "Enter the website URL:" default answer websiteURL)
	
	-- Open Terminal and run wget to download the page and its required assets.
	-- Flags used:
	-- --recursive        = follow links needed for download
	-- --no-clobber       = don't overwrite existing files
	-- --convert-links    = rewrite links for local browsing
	-- --page-requisites  = download images/CSS/etc. needed by the page
	-- --no-parent        = don't climb to parent directories
	tell application "Terminal"
		activate
		do script "cd ~/Downloads/WgetDownloads && wget --recursive --no-clobber --convert-links --page-requisites --no-parent " & quoted form of websiteURL in window 1
	end tell
	
	-- Wait until the Terminal command finishes.
	my checkTerminalStatus()
	
	-- Notify the user that the website download step has finished.
	display dialog "Website downloaded successfully!" buttons {"OK"} default button "OK"
	
	-- Store the downloaded HTML file path as the source file for Pandoc.
	set sourceHTMLFile to savePath
	
	-- Convert the source file reference into a POSIX path string.
	-- Note: this variable is set, but not actually used later in the script.
	set sourceFolderPath to POSIX path of (sourceHTMLFile as text)
	
	-- Open the downloaded HTML file in Brave so the user can inspect it first.
	tell application "Brave Browser" to open (savePath)
	
	-- Pause until the user has finished reviewing the file.
	-- The message mentions Preview, but the script is actually opening Brave Browser.
	display dialog "Please close Preview after reviewing the HTML file. Once closed, click OK to start conversion." buttons {"OK"} default button "OK"
	
	-- Ask the user what to name the converted DOCX file.
	set targetFileName to text returned of (display dialog "Enter the name for the converted DOCX file:" default answer "Converted Document" buttons {"OK"} default button "OK")
	
	-- Build the full output path for the DOCX file.
	set targetDOCXFile to "/Users/nathanditges/Downloads/WgetDownloads/www.gutenberg.org/Converted/" & targetFileName & ".docx" -- change to ".md"
	
	-- Run Pandoc to convert the downloaded HTML file into DOCX.
	tell application "Terminal"
		activate
		do script "pandoc " & quoted form of POSIX path of sourceHTMLFile & " -o " & quoted form of POSIX path of targetDOCXFile in window 1 -- remove "-t markdown" for docx
	end tell
	
	-- Wait until Pandoc finishes.
	my checkTerminalStatus()
	
	-- Optionally also create a Markdown version of the same document.
	if toMD is 1 then
		-- Build the output path for the Markdown file.
		set targetMDFile to "/Users/nathanditges/Downloads/WgetDownloads/www.gutenberg.org/Converted/" & targetFileName & ".md"
		
		-- Small delay before launching the next Terminal command.
		delay 2
		
		-- Run Pandoc again, this time exporting to MultiMarkdown-style Markdown.
		tell application "Terminal"
			activate
			do script "pandoc -s " & quoted form of POSIX path of sourceHTMLFile & " -t markdown_mmd -o " & quoted form of POSIX path of targetMDFile in window 1 -- -f docx -t markdown
		end tell
		
		-- Wait until the Markdown conversion finishes.
		my checkTerminalStatus()
	end if
	
	-- Notify the user that this document number finished converting.
	display dialog "HTML to DOCX -" & i & " conversion complete!" buttons {"OK"} default button "OK"
	
end repeat


-- This handler waits for Terminal window 1 to stop being busy.
-- It polls once per second until the command finishes.
on checkTerminalStatus()
	
	set isBusy to true
	
	repeat until isBusy is false
		tell application "Terminal"
			tell window 1
				set isBusy to busy as boolean --> Test if busy
			end tell
		end tell
		delay 1 --> Check every second
	end repeat
	
	-- Bring this script back to the front once Terminal is done.
	tell me to activate
	
	-- Close Terminal when the current command is finished.
	quit application "Terminal"
	
end checkTerminalStatus
