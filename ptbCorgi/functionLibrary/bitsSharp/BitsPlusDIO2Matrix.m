function encodedDIOdata = BitsPlusDIO2Matrix(mask, data, command, goggle, DAC)
% encodedDIOdata = BitsPlusDIO2Matrix(mask, data, command [,goggle ,DAC]);
%
% Generates a Matlab matrix containing the magic code and data
% required to set the DIO port of CRS Bits++ box in Bits++ mode.
%
% 'mask', 'data', and 'command' have the same meaning as in the function
% 'bitsEncodeDIO.m'.
%
% Both mask and data 11 usable bits, the first 10 (2^0 - 2^9) correspond to
% the the 10 DOUT pins on the DB25 connecter, bit 11 (2^10) corresponds to
% the trigger out BNC on the Bits#.
%
% This is a helper function, called by bitsEncodeDIO and
% BitsPlusDIO2Texture, as well as from BitsPlusPlus when used with the
% imaging pipeline. It takes parameters for controlling Bits++ DIO and
% generates the data matrix for the corresponding T-Lock control code. This
% matrix is then used by the respective calling routines to convert it into
% a texture, a framebuffer image, or whatever is appropriate.
%
% This is just to unify the actual T-Lock encoding process in one file, so
% we don't have to edit or fix multiple files if something changes...
%
% If the optional google and DAC parameters are used (for Bits#) both must
% be set.
%
%   DAC:
% The analogue output levels are set to be between -5 and +5 Volts for each
% of the two ports. E.g. dac = [3 -4]; for 3 Volts on port 1 and -4 Volts
% on port 2.
%
%   goggle:
% controls the output on pin 3 and 5 on the TRIAD 01 circular goggle
% connector on the rear panel of the Bits#. E.g. goggle = [1 0]; for pin 3
% high and pin 5 low. The five pins on the connector are numbered
% increasing in counter-clock wise direction starting from the notch. For
% use with FE goggle the following applies:
%   pin 3   pin5    Left eye    Right eye
%   0       0       Open        Closed
%   0       1       Closed      Closed
%   1       0       Closed      Open
%   1       1       Open        Open

% History:
% 12/10/2007 Written, derived from BitsPlusDIO2Texture. (MK)
% 06/02/2008 Fix handling of LSB of 'mask': bitand(mask,255) was missing,
%            which would cause wrong result if mask > 255. (MK)
% 04.04.2014 Added goggle, DAC and BNC port control for Bits#. (JT)
% 29.06.2017 Changed back to bitwise operations because bin2dec() and
%            dec2bin() are too slow. (JMA)

if nargin < 3
    error('Usage: encodedDIOdata = BitsPlusDIO2Matrix(mask, data, command)');
end


if nargin < 4,
    goggle = [];
    DAC = [];
end


% add goggle and DAC only if given as input parameter
if ~isempty(goggle) && ~isempty(DAC),
    
    % Prepare the data array - with space for goggle and DAC
    encodedDIOdata = uint8(zeros(1, 508+6, 3));
    
    % goggle
    goggle = bitand(goggle,1); %Mask any value higher than the first bit.
    goggle2 = bitor(bitshift(goggle(2),1),goggle(1)); %Combine goggle(1) and goggle(2) into single integer.
    goggle2 = bitshift(goggle2,5) %Shift the bit pattern to the right place in the uint8;
    encodedDIOdata(1,10,3) = uint8(goggle2);              % goggle
    encodedDIOdata(1,10,2) = uint8(0);                    % always zero
    encodedDIOdata(1,10,1) = uint8(1);                    % address
    
    encodedDIOdata(1,11,:) = uint8([0 0 0]);              % empty
    
    % DAC
    dac2 = round(((DAC+5)/10)*(2^16-1)); % convert to 0 - 65535 (2^16) range
    dacMS = floor(dac2/256);
    dacLS = rem(dac2,256);
    
    % DAC port 1
    encodedDIOdata(1,12,3) = uint8(dacLS(1));             % LSB
    encodedDIOdata(1,12,2) = uint8(dacMS(1));             % MSB
    encodedDIOdata(1,12,1) = uint8(2);                    % address
    
    encodedDIOdata(1,13,:) = uint8([0 0 0]);              % empty
    
    % DAC port 2
    encodedDIOdata(1,14,3) = uint8(dacLS(2));             % LSB
    encodedDIOdata(1,14,2) = uint8(dacMS(2));             % MSB
    encodedDIOdata(1,14,1) = uint8(3);                    % address
    
    encodedDIOdata(1,15,:) = uint8([0 0 0]);              % empty
    
    % shift the rest of the matrix of goggle and DAC is used
    shift=6;
else
    % Prepare the data array - wothout goggle and DAC
    encodedDIOdata = uint8(zeros(1, 508, 3));
    
    % dont shift if goggle and ADC is not used
    shift = 0;
end


% Putting the unlock code for DVI Data Packet
encodedDIOdata(1,1:8,1:3) =  ...
    uint8([69  40  19  119 52  233 41  183;  ...
    33  230 190 84  12  108 201 124;  ...
    56  208 102 207 192 172 80  221])';

% Length of a packet - it could be changed
encodedDIOdata(1,9,3) = uint8(249);	% length of data packet = number + 1

% Command - data packet
encodedDIOdata(1,10+shift,3) = uint8(2);          % this is a command from the digital output group
encodedDIOdata(1,10+shift,2) = uint8(command);    % command code
encodedDIOdata(1,10+shift,1) = uint8(6);          % address

% -- updated for Bits# --
% mask
[blueByte, greenByte] = splitDataToChannels(mask); %Split 11bit data into 2 bytes
encodedDIOdata(1,12+shift,3) = blueByte; % LSB DIO Mask data
encodedDIOdata(1,12+shift,2) = greenByte;% MSB DIO Mask data
encodedDIOdata(1,12+shift,1) = uint8(7); % address

% data:
[blueByte, greenByte] = splitDataToChannels(data); %Split 11bit data into 2 bytes
encodedDIOdata(1,(14:2:508)+shift,3) = blueByte;      % LSB DIO
encodedDIOdata(1,(14:2:508)+shift,2) = greenByte;     % MSB DIO
encodedDIOdata(1,(14:2:508)+shift,1) = uint8(8:255);  % addresses


end

function [blueByte, greenByte] = splitDataToChannels(data)
%This function handles splitting data into the green and blue channels.
%
%
%From the Bits Sharp documentation Version R08, Page 108:
%The 11 pins are represented by two binary strings. The 10 pins are
%represented in the first 10 positions and the ?Trigger Out? pin is
%represented at position 16. Therefore the first 8 pins of the I/O trigger
%port are represented in the blue channel (e.g. ?11111111?), while the last
%two of the I/O trigger port pins and the
%?Trigger Out? port pin are represented in the green channel (e.g.
%?10000011?). It does not matter what values are entered to positions
%11-15, they are ignored. If a pin is set to 1, its status (high or low)
%will be overwritten by whatever the trigger data specifies for that pin.

%Blue byte is straightforward, just use first 8 bits of data.
blueByteBitMask  = 2^8-1; %First 8 bytes of input data
blueByte = uint8( bitand(data,blueByteBitMask));

%Green byte is trickier: bits 9,10 go to bits 1 and 2, the trigger from bit 11 goes
%to green byte bit 8.
dioBitMask = bitshift(2^2-1,8); %Mask bits 9,10;
triggerBitMask = 2^10; %Mask bit 11;
dioByte = bitshift(bitand(data,dioBitMask),-8);%Take the dio bits and shift them to the LSB
triggerByte = bitshift(bitand(data,triggerBitMask),-3);%Take the trigger bit and shift it from bit 11 to bit 8;

greenByte = uint8(bitor(dioByte,triggerByte)); %Combine the dio and trigger into the green byte.
end
