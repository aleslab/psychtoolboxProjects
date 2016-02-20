# psychMaster
a wrapper that takes care of all the common psychtoolbox tasks.
This enables new paradigms to be easily implemented and tracked.


todo:
Cleanup the condition inspector. Make it draw in the same place. Or something
that makes it work a little more intuitively. 

Version History

 
0.2:
Added saving of mfile content with experiment data. 
Added saving of all matlab output with data. 
Added Gui 

Added calibration utilities for spatial and luminance calibration.
Luminance calibration utilizes the CRS ColorCalII. Added code that interfaces
with the ColorCalII using the serial interface.
Added 2AFC support
Added generic display of trials in random order.
Added ability to display arbitrary feedback messages between trials
Added response monitoring with either GetChar or high performance KbQueues 

0.1: 
Initial code