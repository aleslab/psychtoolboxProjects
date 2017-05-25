function [ computerName ] = ptbCorgiGetComputerName()
%ptbCorgiGetComputerName Returns the name for this computer
%[ computerName ] = ptbCorgiGetComputerName()
%   This is a quick wrapper function that enables setting a memorable name
%   for the current computer. If nothing is set it just returns the current
%   localHostName as determined from psychtoolbox.
%

if ispref('ptbCorgi','computerName');
    computerName = getpref('ptbCorgi','computerName');
else
    currentComputer = Screen('Computer');
    computerName = currentComputer.localHostName;
end


end

