# ptbCorgi
a wrapper that takes care of all the common psychtoolbox tasks.
This enables new paradigms to be easily implemented and tracked.


todo:

Cleanup the condition inspector. Make it draw in the same place. Or something
that makes it work a little more intuitively. 
Add a check for if ptbCorgi changed from last run and warn user.  
Add a convenience function for creating a group of conditions.  
Add some hashing functions to detect changes. 


Version History
0.33.0
Added new checks for which system calibration was created on. 
Added new and changed messages to users regarding calibration
Various bug fixes

0.32.2
Added checks to ensure audio is enabled when implicitly needed by conditions.
Ensured calls to PsychPortAudio() only happen after InitializePsychPortAudio has been run.
Added more informative checks and error messages when attempting to load a 
paradigm that conflicts with others on the path.

0.32.1
Various changes to improve compatibility with windows. 

0.32.0
Renamed to ptbCorgi
Started project management framework for data analysis: 
   added function ptbCorgiAnalyzeEachParticipant() that will execute arbitrary 
   analayses on all participants in an experiment
Added convience function build2AfcMatrix() that returns a simple matrix 
Added new buildMatrixFromField to extract any fieldname from datasets and return a matrix
Made automatic setting up of the matlab path more robust
Enables warnings for matlab legacy random number generators. 
Change randomization structure to be more user friendly. Now specified 
   using single trialRandomization structure. Old structure format still 
   works but new way is tidier, see help makeTrialList for details
Added new randomization blocking options
ptbCorgiDataBrowser now recursively loads files in subdirectories as well.
ptbCorgiDataBrowser can now generate code for loading data that can be copy/pasted into scripts
Updated overloadOpenPtbCorgiData to handle cell arrays of filenames.
Added Condition groups to ptbCorgi gui.
Add more information to calibration routines to avoid filename ambiguities
Calibration files now show a computer name.
Calibration information now is saved in a single file. 
Simple response trial type has upgraded keypress handling (e.g. escape aborts)
Simple response upgraded to allow defintion of the "correct" key press for each condition. 
expInfo structure documented (mostly)
Updated keyboard initialization to get keypresses from all devices when using KbCheck()
Structured code to enable easy testing/debugging of trial files. 
Added new ptbCorgiSetup() that unifies setup and calibration
Added support for BitsSharp mono++ mode and triggering. 
Added createConditionsFromParamList to simplify creation of groups of condInfo



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