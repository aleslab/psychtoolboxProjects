# psychMaster
a wrapper that takes care of all the common psychtoolbox tasks.
This enables new paradigms to be easily implemented and tracked.


todo:
Add more information to calibration routines to avoid filename ambiguities
Cleanup the condition inspector. Make it draw in the same place. Or something
that makes it work a little more intuitively. 
Issue #7 Create an automatic format to create paradigms
Add a check for if psychmaster changed from last run and warn user.  
Add a convenience function for creating a group of conditions.  

Version History
0.31.0
Switched to semantic version numbering
Added ability to randomize arbitrary fields in the condition structure
Added new way to specify 2afc experiment allowing the change of randomized fields
Fixed crackle from audio feedback.
Made it possible to play audio feedback at the same time as displaying written feedback
Fixed bug that kept cursor hidden during testing on 2nd monitors.
Fixed bug that broke feedback in stereo mode. 
Added '*' to condition label to indicate changed by user in GUI

0.3: 
Added code to save git commit SHA when code is exported from git.
Added code to extract and code archived in datafiles
Added ptbCorgiDataBrowser to support project level management.
Added new fixation drawing code for ability to set fixation using paradigm files
Added new session tag box to GUI
Added new "block randomization" option for trial sequences
Several bug fixes. 

0.2:
Added Gui with several features:
Input participant id
Load paradigm
Inspect what is in the conditions. 
Test run single trials.

Added Self documentation features, mfile experiment code is saved along experiment data. 

Added saving of all matlab output with data. 

Added calibration utilities for spatial and luminance calibration.
Luminance calibration utilizes the CRS ColorCalII. Added code that interfaces
with the ColorCalII using the serial interface.
Added 2AFC support
Added generic display of trials in random order.
Added ability to display arbitrary feedback messages between trials
Added response monitoring with either GetChar or high performance KbQueues 

0.1: 
Initial code