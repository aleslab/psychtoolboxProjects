viewingDistance = 57;

fixation = [0, 0, viewingDistance];

%1
object = [0, 10, 15];

expectedScreenX = 0; %expected position of the object for the left eye
expectedScreenY = 38;

[screen] = calculateHorizontalScreenLocation(fixation, object); 

%checking that expected is the same as what is calculated by the function.
assert(abs(screen(1)-expectedScreenX)<.1,'Failure');
assert(abs(screen(2)-expectedScreenY)<.1,'Failure');

%2
object = [0, 5, 30];

expectedScreenX = 0; %expected position of the object for the left eye
expectedScreenY = 9.5;

[screen] = calculateHorizontalScreenLocation(fixation, object); 

%checking that expected is the same as what is calculated by the function.
assert(abs(screen(1)-expectedScreenX)<.1,'Failure');
assert(abs(screen(2)-expectedScreenY)<.1,'Failure');
