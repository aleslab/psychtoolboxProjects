%% 1
assert(minAngleDiff(0,0)==0,'Failure')
%% 2
assert(minAngleDiff(20,0)==20,'Failure')
%% 3
assert(minAngleDiff(-20,0)==-20,'Failure')
%% 4
assert(minAngleDiff(180,0)==0,'Failure')
%% 5
assert(minAngleDiff(160,-20)==0,'Failure')
%% 6
assert(minAngleDiff(160,0)==-20,'Failure')
%% 7
assert(minAngleDiff(200,0)==20,'Failure')
%% 8
assert(minAngleDiff(80,-80)==-20,'Failure')
%% 9
assert(minAngleDiff(20,-180)==20,'Failure')
%% 10
assert(minAngleDiff(20,180)==20,'Failure')
%% 11
assert(minAngleDiff(20,-20)==40,'Failure')
%% 12
assert(minAngleDiff(-80,80)==20,'Failure')
%% 13
assert(minAngleDiff(200,-200)==40,'Failure')
%% 13 Check vector input

delta = minAngleDiff([80 -80],[30 30]);
assert(delta(1) == 50 && delta(2) == 70, 'Failure')

