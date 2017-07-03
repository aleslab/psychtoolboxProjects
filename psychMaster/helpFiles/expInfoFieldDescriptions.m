function [ output_args ] = expInfoFieldDescriptions( input_args )
%expInfoFieldDescriptions - Documention of fields of expInfo
%expInfo contains settings experiment wide settings. These setting can
%be used by the experimental paradigm for setting things like a fixation
%cross. The structure also contains crucial information the trial function
%needs for rendering the stimulus (e.g. expInfo.curWindow is the window
%handle)
%
%
%Important fields for paradigm setup:
%
%expInfo.paradigmName - [string] A short name that identifies this paradigm
%expInfo.trialRandomization - [structure] Sets options for how trials are
%                             ordered. Default is in random order. For
%                             documentation of other options see: help
%                             makeTrialList
%expInfo.viewingDistance - [scalar] Viewing distance in centimeters;
%expInfo.fixationInfo - [structure] Defines fixation options. See: help drawFixation
%expInfo.instructions - [string] text to be displayed before the experiment
%                        starts. Separate lines with \n
%
%expInfo.conditionGroupingField - [string] Field to use to group conditions;
%expInfo.pauseInfo - [string] Text to be displayed when experiment is paused
%expInfo.stereoMode - [scaler,0] Psychtoolbox stereo mode to use
%expInfo.useFullScreen - [boolean] Use to force full screen on single ssmonitor setup
%
%expInfo.enablePowermate - [boolean] If true opens powermate
%expInfo.powermateId - [scalar] Handle for powermate, See PsychPowerMate()
%
%Fields for trial rendering ( most created by openExperiment() )
%       
%expInfo.curWindow    - [scalar] Handle to the current window
%expInfo.monitorWidth - [scalar] Monitor width in cm. If not calibrated by
%                       physical measurment, value is from
%                       Screen('DisplaySize')
%expInfo.windowSizePixels - [vector] Window size in pixels
%expInfo.screenNum    - [scalar] Number of the screen being used.
%expInfo.ifi          - [scalar] Interframe interval in seconds
%expInfo.monRefresh   - [scalar] Refresh rate in Hz. 
%expInfo.center - [1x2] Pixel coord of the window center
%
%expInfo.pixPerCm - [scalar] Pixels per cm 
%
%Note: pixels to degrees is not actually a linear transform. However, for
%most experiments/displays the linear approximation results in only ~5%
%error. Which is usually sufficient. Most cases use pixPerDeg which is
%calculated using the half-width of the monitor.
%pixPerDegAtCenter/pixPerDegAtEdge calculate the local derivative to find
%the correct factor at these points. Mainly used for detecting if the
%viewing geometry results in large inaccuracies for the linear
%approximation. See comments openExperiment.m for details on how these are
%calculated.
%
%expInfo.pixPerDeg - [scalar] Approximate pixels per degree
%
%expInfo.pixPerDegAtCenter - [scalar] Local pixels per degree at monitor center
%expInfo.pixPerDegAtEdge   - [scalar] Local pixels per degree at monitor edge
%expInfo.ppd - [obsolete] same as pixPerDeg
%
%
%expInfo.modeInfo - [struct] Videomode from Screen('Resolution')
%expInfo.windowInfo -  [struct] See Screen('GetWindowInfo?') for details
%expInfo.finalWindowInfo - [struct] Same as windowInfo but after experiment is
%                   finished useful for field 'MissedDeadlines' which
%                   contains a count of missed frames
%
%expInfo.enableAudio - [boolean] If true initializes PsychPortAudio
%expInfo.audioInfo   - [struct] Contains info for audio DOCUMENTATION NEEDED
%
%expInfo.inputDeviceNumber - [scalar] Device number see
%                             GetKeyboardIndices(), KbCheck(),
%                             KbEventGet(), KbQueueCheck() for more details
%                             on how device numbers are used. 
%expInfo.useKbQueue - [boolean] !Not Complete! because kbqueue's cannot be mixed
%                       this flag is used to choose between KbQueue and
%                       KbCheck
%
%expInfo.currentTrial - [struct] Contains info about current trial. Useful
%                       for aborted sessions. 
%
%
%Questionable fieldnames marked for change:
%
%Fields to change name to make more clear:
%expInfo.bckgnd       - [] Color to use for background. 
%expInfo.screenRect   - [vector] Rectangle defining the current window location      
%
%Remove these:
%expInfo.frameDur - frame duration in ms;
%
%



help('expInfoFieldDescriptions')         


end

