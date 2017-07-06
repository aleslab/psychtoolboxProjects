function ptbCorgiSetPlotOptions( figHandle )
%ptbCorgiSetPlotOptions Sets various matlab options for nicer plots. 
%ptbCorgiSetPlotOptions( [figHandle] )
%


%If no handle given 
if nargin== 0;
    figHandle = groot;
elseif ishandle(figHandle) && strcmp(get(figHandle,'type'),'figure')
    %If given a figure handle
    box(findobj(gcf,'type','axes'),'off')
else
    figHandle
    warning('Input incorrect, Not setting graphics options')
end
    
%Change matlab default plotting options for plots more easily used for
%presentations/figures.
lineWidth = 3;
%First make lines larger
set(figHandle,'DefaultLineLineWidth',lineWidth)
set(figHandle,'DefaultErrorBarLineWidth',lineWidth)
set(figHandle,'DefaultAxesLineWidth', lineWidth)

set(figHandle,'DefaultAxesBox', 'off')

%I like white backgrounds
set(figHandle,'DefaultFigureColor','w')

%Make fonts BIGGER
set(figHandle,'DefaultAxesFontSize',24)
set(figHandle,'DefaultTextFontSize',24)

%This is a setting that makes ALL plots come black, and 
%myCol is a matrix that sets up a list of RGB colors that will be used by
%matlab for making figures
%myCol = [0 0 0; 0 0 0];
%Now override the default matlab color list
%set(figHandle,'DefaultAxesColorOrder',myCol)

%Instead of changing color, make lines alternate between solid ('-') and
%dotted (':')
%set(figHandle,'DefaultAxesLineStyleOrder',{'-',':'})