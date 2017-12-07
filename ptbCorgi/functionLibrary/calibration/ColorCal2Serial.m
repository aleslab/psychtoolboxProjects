function varargout = ColorCal2Serial(command, varargin)
% varargout = ColorCal2Serial(command, [varargin])
%
% Description:
% Interface function to communicate with the ColorCal2 using the serial interface
% uses same format as ColorCal2.m
%
% Required Input:
% command (string) - Command to send to the ColorCal2 device.  Commands are
%                    case insensitive.
%
% Optional Input:
% varargin - Argument(s) required for a subset of the ColorCal2
%            commands.  Varies depending on the command.
%
% Optional Output:
% varargout - Value(s) returned for a subset of the ColorCal2 commands.
%
% Command List:
% 'DeviceInfo' - Retrieves the following device information in a struct: firmware
%      version number, 8 digit serial number, and firmware build number.
%      The struct's fields are romVersion, serialNumber, buildNumber.
%
%      Example:
%      devInfo = ColorCal2('DeviceInfo');
% 'MeasureXYZ' - Measures the tri-stimulus value of the current light.
%      Returns a struct with x, y, and z in floating point format.  These
%      values should be corrected by multiplying them against the calibration
%      matrix typically stored in the 1st calibration matrix in the device.
%
%      Example: Retrieve the xyz values and correct them with the 1st
%               calibration matrix.
%      cMatrix = ColorCal2Serial('ReadColorMatrix');
%      s = ColorCal2Serial('MeasureXYZ');
%      correctedValues = cMatrix(1:3,:) * [s.x s.y s.z]';
% 'ReadColorMatrix' or 'ReadColourMatrix' - Retrieves all 3 color
%      calibration matrices from the device and returns them as a 9x3 matrix.
%      Each set of 3 rows represents a single calibration matrix.  All
%      values will be in floating point format.
% 'ZeroCalibration' - Removes small zero errors in the electronic system of
%      the ColorCal2 device.  It reads the current light level and stores
%      the readings in a zero correction array.  All subsequent light
%      readings have this value subtracted from them before being returned.
%      This command is intended to be issued when the ColorCal2 is in the
%      dark.  Returns 1 if the command succeeds, 0 if it fails.  This
%      command must be run after every power cycle of the device.
%
% 
% The following are currently unsupported commands for the serial interface. 
% 'LEDOn' - Turns the LED on.
% 'LEDOff' - Turns the LED off.
% 'GetRawData' - Returns the raw data for all three light channels, the
%      contents of the zero correction array for all three channels, and
%      the current reading of the trigger ADC.  Returns a single struct
%      containing the following fields: Xdata, Xzero, Ydata, Yzero, Zzero,
%      Trigger.  All values are unformatted.
% 'SetLEDFunction' - Controls whether the LED is illuminated when the
%      trigger signal is generated.  This state is stored in non-volatile
%      memory and will survive a power cycle.  Takes 1 additional argument:
%      0 or 1.  0 = LED not active when triggered, 1 = LED active when
%      triggered.
% 'SetTriggerThreshold' - Sets the threshold which must be exceeded by the
%      first derivative of the trigger ADC before a trigger pulse is
%      generated.  It is stored in non-volatile memory and will survive a
%      power cycle.  Takes 1 additional argument which is the trigger
%      threshold value.
% 'StartBootloader' - Causes the ColorCal2 to start its internal bootloader
%      in preparation for a firmware upgrade.


% History:
%31.01.2016: Justin Ales modified ColorCal2.m to use serial interface instead of USB. 
persistent CC2_serialHandle;

varargout = {};

if nargin == 0
	error('Usage: varargout = ColorCal2(command, [varargin])');
end

if ~ischar(command)
	error('command must be a string.');
end

if ismac
    port = '/dev/cu.usbmodem0001';
elseif isunix 
    port = '/dev/ttyACM0';
elseif ispc %Untested
    error('Sorry PC mode is untested, you need to check the code and set the port yourself')
    %port = 3;
end


% Connect to the ColorCal2 if we haven't already.
if isempty(CC2_serialHandle)
    
    %check if we've already got the port open and forgot.
    allSerial = instrfindall('port',port);
    
    
    if ~isempty(allSerial) && any( strcmp(allSerial(:).Status,'open') ) %Are any interfaces open
        
        openIndex = find( strcmp(allSerial(:).Status,'open') );
        disp('Lost connection identity, re-establishing connection');
        CC2_serialHandle = allSerial(openIndex);
        
    else
        
        % Use the 'serial' function to assign a handle to the port ColorCAL II is
        % connected to. This handle (CC2_serialHandle in the current example) will then be used
        % to communicate with the chosen port).
        CC2_serialHandle = serial(port);
        
        % Open the ColorCAL II port so that it is open to be communicated with.
        % Communication with the ColorCAL II occurs as though it were a text file.
        % Therefore to open it, use fopen.
        
        try
            fopen(CC2_serialHandle);
        catch
            error('Error opening serial port. Try: fclose(instrfindall(''Type'', ''serial'')) ')
            
        end
    end
    
   %make sure serial connection is still open and valid
elseif ~strcmp(CC2_serialHandle.Status,'open')
 
    
    try
        fclose(CC2_serialHandle);
        delete(CC2_serialHandle);
    catch
    end
    CC2_serialHandle = [];
    error('Error: Serial connection was previously improperly disconnected. Resetting connection')
end

    

set(CC2_serialHandle,'Timeout',2); %Set a timeout of 2 seconds.
%probably ready to go lets flush the read buffer if there was any junk left

if CC2_serialHandle.BytesAvailable >0
    fread(CC2_serialHandle,CC2_serialHandle.BytesAvailable);
end

switch lower(command)
	case {'close', 'cls'}
		fclose(CC2_serialHandle);
        delete(CC2_serialHandle);
		disp('- ColorCal2 closed');
		CC2_serialHandle = [];
		
	case {'ledon', 'lon'}
        fprintf(CC2_serialHandle, ['LON' 13]);
        
        if CC2_serialHandle.BytesAvailable >0
            fread(CC2_serialHandle,CC2_serialHandle.BytesAvailable);
        end
        
	case {'ledoff', 'lof'}
		error('LEDOFF command not supported');
		
	case {'measurexyz', 'mes'}
              
        % whichColumn is to indicate the column the current value is to be written
        whichColumn = 1;
        % Commands are passed to the ColorCAL II as though they were being
        % written to a text file, using fprintf. The command MES will read
        % current light levels and and return the tri-stimulus value (to 2
        % decimal places), adjusted by the zero-level calibration values above.
        % Note the '13' represents the terminator character. 13 represents a
        % carriage return and should be included at the end of every command to
        % indicate when a command is finished.
        fprintf(CC2_serialHandle, ['MES' 13]);
        
        % This command returns a blank character at the start of each line by
        % default that can confuse efforts to read the values. Therefore use
        % fscanf once to remove this character.
        fscanf(CC2_serialHandle);
        
        % To read the returned data, use fscanf, as though reading from a text
        % file.
        dataLine = fscanf(CC2_serialHandle);
        
        % The returned dataLine will be returned as a string of characters in
        % the form of 'OK00,242.85,248.11, 89.05'. In case of additional blank
        % characters before or after the relevant information, loop through
        % each character until a O is found to be sure of the start position of
        % the data.
        for k = 1:length(dataLine)
            
            % Once an O has been found, assign the start position of the
            % numbers to 5 characters beyond this (i.e. skipping th 'OKOO,')
            if dataLine(k) == 'O'
                myStart = k+5;
                
                % A comma (,) indicates the start of a value. Therefore if this
                % is found, the value is the number formed of the next 6
                % characters
            elseif dataLine(k) == ','
                myEnd = k+6;
                
                % Using k to indicate the row position and whichColumn to
                % indicate the column position, convert the 5 characters to a
                % number and assign it to the relevant position.
                a(whichColumn) = str2double(dataLine(myStart:myEnd));
                
                % reset myStart to k+7 (the first value of the next number)
                myStart = k+7;
                
                % Add 1 to the whichColumn value so that the next value will be
                % saved to the correct location.
                whichColumn = whichColumn + 1;
                
            end
        end
        

		s.x = a(1);
		s.y = a(2);
		s.z = a(3);
		
		varargout(1) = {s};
		
	case {'zerocalibration', 'uzc'}
        % Calibrate zero-level, by which to adjust subsequent measurements by.
        % ColorCAL II should be covered during this period so that no light can be
        % detected.
        
        fprintf(CC2_serialHandle, ['UZC' 13]);
    
        % This command returns a blank character at the start of each line by
        % default that can confuse efforts to read the values. Therefore use
        % fscanf once to remove this character.
        fscanf(CC2_serialHandle);
    
        % To read the returned data, use fscanf, as though reading from a text
        % file.
        dataLine = fscanf(CC2_serialHandle);
    
        % The expected returned messag if successful is 'OKOO' or if an error,
        % 'ER11'. In case of any additional blank characters either side of
        % these messages, search through each character until either an O or an
        % E is found so that the start of the relevant message can be
        % determined.
        for k = 1:length(dataLine)
        
            % Once either an O or an E is found, the start of the relevant
            % information is the current character positiong while the end is 3
            % characters further (as each possible message is 4 characters in
            % total).
            if dataLine(k) == 'O' || dataLine(k) == 'E'
                myStart = k;
                myEnd = k+3;
            end
        end
    
        % the returned message is the characters between the start and end
        % positions.
        outString = dataLine(myStart:myEnd);
        
		% Parse the output string.
		switch outString(1:4)
			case 'OK00'
				varargout(1) = {true};
			case 'ER11'
				varargout(1) = {false};
			otherwise
				error('Failed to parse output string from the ColorCal2');
        end

        
% 	case {'getrawdata', 'grd'}
% 		bmRequestType = hex2dec('C0');
% 		wValue = 4;
% 		wLength = 28;
% 		wIndex = 0;
% 		outData = PsychHID('USBControlTransfer', usbHandle, bmRequestType, bRequest, wValue, wIndex, wLength);
% 		
% 		% Each 4 bytes represents one value, so we must concatenate each
% 		% group of 4 bytes to get number we want.  On big endian systems we
% 		% must swap the byte order because the USB bus works in little
% 		% endian mode.
% 		extractedData = [];
% 		for i = 1:4:28
% 			% Read 4 bytes of data and convert it into an uint32 value.
% 			y = typecast(outData(i:i+3), 'uint32');
% 			
% 			% Swap the byte order if on a big endian machine.
% 			if useBigEndian
% 				y = swapbytes(y);
% 			end
% 			
% 			extractedData(end+1) = double(y); %#ok<NASGU>
% 		end
% 		
% 		% Create a struct to hold the results.
% 		d.Xdata = extractedData(1);
% 		d.Xzero = extractedData(2);
% 		d.Ydata = extractedData(3);
% 		d.Yzero = extractedData(4);
% 		d.Zdata = extractedData(5);
% 		d.Zzero = extractedData(6);
% 		d.Trigger = extractedData(7);
% 		
% 		varargout(1) = {d};
% 		
    case {'readcolormatrix', 'readcolourmatrix', 'rcm'}
        
        % Cycle through the 3 rows of the 3 correction matrices.
        for j = 1:9
            
            % whichColumn is to indicate the column the current value is to be
            % written to.
            whichColumn = 1;
            
            % Commands are passed to the ColorCAL II as though they were being
            % written to a text file, using fprintf. The commands 'r01', 'r02'
            % and 'r03' will return the 1st, 2nd and 3rd rows of the correction
            % matrix respectively. Note the '13' represents the terminator
            % character. 13 represents a carriage return and should be included
            % at the end of every command to indicate when a command is
            % finished.
            fprintf(CC2_serialHandle,['r0' num2str(j) 13]);
            
            % This command returns a blank character at the start of each line
            % by default that can confuse efforts to read the values. Therefore
            % use fscanf once to remove this character.
            fscanf(CC2_serialHandle);
            
            % To read the returned data, use fscanf, as though reading from a
            % text file.
            dataLine = fscanf(CC2_serialHandle);
            
            % The returned dataLine will be returned as a string of characters
            % in the form of 'OK00, 8053,52040,50642'. Therefore loop through
            % each character until a O is found to be sure of the start
            % position of the data.
            for k = 1:length(dataLine)
                
                % Once an O has been found, assign the start position of the
                % numbers to 5 characters beyond this (i.e. skipping the
                % 'OKOO,').
                if dataLine(k) == 'O'
                    myStart = k+5;
                    
                    % A comma (,) indicates the start of a value. Therefore if
                    % this is found, the value is the number formed of the next
                    % 5 characters.
                elseif dataLine(k) == ','
                    myEnd = k+5;
                    
                    % Using j to indicate the row position and whichColumn to
                    % indicate the column position, convert the 5 characters to
                    % a number and assign it to the relevant position.
                    myCorrectionMatrix(j, whichColumn) = str2num(dataLine(myStart:myEnd));
                    
                    % reset myStart to k+6 (the first value of the next number)
                    myStart = k+6;
                    
                    % Add 1 to the whichColumn value so that the next value
                    % will be saved to the correct location.
                    whichColumn = whichColumn + 1;
                    
                end
            end
        end
        



		% Convert the matrix values from Minolta format to floating point.
		varargout(1) = {Minolta2Float(myCorrectionMatrix)};
		
	case {'deviceinfo', 'idr'}
       
        fprintf(CC2_serialHandle,['IDR'  13]);

        fscanf(CC2_serialHandle);
            
        % To read the returned data, use fscanf, as though reading from a
        % text file.
        response = fscanf(CC2_serialHandle);
         

     	% Parse the device info string.
		x = sscanf(response(2:end), 'OK00,1,%d,100.10,%d,%d');
		
		% Set the output: rom version, serial number, and build number.
		dInfo.romVersion = x(1);
		dInfo.serialNumber = x(2);
		dInfo.buildNumber = x(3);
		varargout(1) = {dInfo};
		
        
		
% 	case {'reseteeprom', 'rse'}
% 		bmRequestType = hex2dec('40');
% 		wValue = 7;
% 		wLength = 0;
% 		wIndex = 0;
% 		
% 		% Send the reset command.
% 		PsychHID('USBControlTransfer', usbHandle, bmRequestType, bRequest, wValue, wIndex, wLength);
% 		
% 	case {'startbootloader', 'sbl'}

% 	case {'settriggerthreshold', 'stt'}
% 		bmRequestType = hex2dec('40');
% 		wValue = 8;
% 		wLength = 0;
% 		
% 		% Make sure a trigger value was passed.
% 		if nargin ~= 2
% 			error('Usage: ColorCal2(''SetTriggerThreshold'', triggerValue)');
% 		end
% 		
% 		% Make sure the trigger value is scalar.
% 		wIndex = varargin{1};
% 		if ~isscalar(wIndex)
% 			error('triggerValue must be scalar.');
% 		end
% 		
% 		% Send the set trigger threshold command.
% 		PsychHID('USBControlTransfer', usbHandle, bmRequestType, bRequest, wValue, wIndex, wLength);
% 		
% 	case {'setledfunction', 'slf'}
% 		bmRequestType = hex2dec('40');
% 		wValue = 9;
% 		wLength = 0;
% 		
% 		% Make sure a LED function value was passed.
% 		if nargin ~= 2
% 			error('Usage: ColorCal2(''SetLEDFunction'', ledFunctionValue)');
% 		end
% 		
% 		% Make sure that the function value is 0 or 1.
% 		wIndex = varargin{1};
% 		if ~isscalar(wIndex)
% 			error('ledFunctionValue must be a scalar.');
% 		end
% 		if ~any(wIndex == [0 1])
% 			error('ledFunctionValue must be 0 or 1.');
% 		end
% 		
% 		% Send the new LED function value.
% 		PsychHID('USBControlTransfer', usbHandle, bmRequestType, bRequest, wValue, wIndex, wLength);

		
	otherwise
		error('Invalid command: %s', command);
end
