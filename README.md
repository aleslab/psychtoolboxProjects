ptbCorgi

PtbCorgi is a tool suite to facilitate stimulus presentation and project-level
management.

PtbCorgi offers several benefits for developing and analyzing experiments.
Reproducibility is a core consideration in the design. As a front-end to
Psychtoolbox ptbCorgi makes creating and running experimental paradigms simpler.
It’s design also lowers the Psychtoolbox learning curve making it simpler for
novice individuals to use the power of psychtoolbox to create experiments. This
is because ptbCorgi utilizes a modular design that separates core functions and
has a GUI for running experiments. As a project-level management and analysis
tool ptbCorgi helps organize datasets and running repeated analyses across
multiple participants.


Quick Start:

First Run: 

ptbCorgiSetup


Then run:
ptbCorgi 

From the GUI select "choose paradigm", in the "exampleParadigms" directory
Pick pdgm_orientation_2afc.m.  That will load an example orientation 
discrimination experiment.  You can play an example trial by selecting a
condition and choosing "test".      

Reproducibility

Reproducibility is a core motivation for ptbCorgi. The stimulus presentation
code self-archives the code used to display the stimulus alongside the
participant data. This enables recreation of experiments from a single
participants data.


Experiment Design & Display

ptbCorgi acts as a front-end GUI and set of convenience scripts for
psychtoolbox.


Modular Design

Commonly individuals utilize monolithic scripts for experiment code.  These
scripts can be daunting for new people to understand. Large scripts also
encourage copying large amounts of code for new experiments that may only be
minor tweaks on previous experiments. This creates the potential for more
bugs/errors to creep in and decreases reusability.  Instead of enouraging
monolithic experiment scripts ptbCorgi was taken a modular design separating out
functionality into separate files.


Key modules:

Experiment Paradigm:            (custom files) Defines that parameters for an
                                experimental session.  

Trial Display:                  (custom files) Renders the stimulus for a single trial.  

Experimental Session Handling:  (ptbCorgi.m)   Handles trial ordering and presentation and 
                                collection and saving of data.  

Psychtoolbox Initialization:    (openExperiment.m) Handles initialization of psychtoolbox.


Experiment Paradigm Definition

When most people think of an experiment they think about a collection of
conditions defined by different parameters. For example a set of sinusoidal
gratings at different orientations and different contrasts.  That’s exactly what
this file defines. An experimental paradigm is a definition of the parameters of
an experiment. It defines a collection of conditions parameters and experiment
options (e.g. 2AFC) various experiment wide settings (e.g. viewing distance). At
the simplest a user can create a new experiment by changing just the paradigm
definition.

Trial Display.

This is the other key part of an experiment.  It is the code that actually
renders the stimulus is kept separate from the paradigm definition.  For each
trial the session handling code will execute the trial display function with
options chosen from the experiment paradigm definition. This design makes it so
that you only have to write the trial rendering code once (say a Gabor in noise)
and the rendering code can be reutilized for multiple experiments.


Experimental Session Handling

The code that is the heart of the program handles running an experimental
session is separate from the rest of the code. It uses a GUI interface for
choosing options for a specific session, and handles different paradigms. The
goal is that normal users should never have to modify this code, and have all
the control they need to define an experiment from the experiment paradigm file.
The session handling code determines trial order, presents trials, collects
responses/data, saves the data. An important aspect of the session handling code
is that it self-archiving, which enables easy replicability.  What this means is
that alongside the data all the information needed to reproduce the experiment
is stored as well.  It stores all the custom matlab code that was executed in
running the experiment (except for PTB code and MATLAB core code). It also
stores all the output from the matlab window, information about the calibration
settings, the system hardware/software, various other pieces of information
about the session.


Psychtoolbox initialization

Initializing psychtoolbox is often confusing for new users. There are lot’s of
different options and things that can be done.  This code handles setting up the
display, audio interface (if needed), loading luminance and size calibration,
calculating various values that are useful (e.g. conversion factor from pixels
to visual angle). Standardizing the initialization helps to ensure experiments
are run using appropriate choices, and helps to facilitate usage of device
independent units ( visual angles, cm, seconds and NOT pixels and frames).
Importantly, ptbCorgi by default does not use the “classic” 0-255 color range,
but uses the modern normalized floating point number range 0.0 - 1.0.
