function sequence = generateMarkovSequence(n,transMatrix)
%generateMarkovSequence Generates a markov chain using a transition matrix
%sequence = generateMarkovSequence(n,transMatrix)
%
%Generates a random markov chain governed by probabilityis in transMatrix
%
%The initial state is chosen randomly according to the limiting
%distribution of the markov chain.
%
%Inputs:
% 
% n - Number of states to generate
% tansMatrix - Matrix governing the transition probabilities for changing
% state.  Each row is for the current state, with each column the
% probability for the next state.
% E.g. the matrix:
% [.8 .2
%   1 0 ]
% means State 1 has 80% chance of staying in state 1, 20% of changing to
% state 2, State 2 has 100% chance of going to state 1.
%
% Output:
% sequence - sequence of states gnerated by the chain
% Example:
% For having 1 goes to 2, 2 goes to 3, 3 has 80% chance of 1, and 20% of 2
% t=[0 1 0;0 0 1; .8 .2 0] 
% seq=generateMarkovSequence(10,t);
% disp(seq)
%Generates e.g.: 
% 2     3     1     2     3     1     2     3     1     2
%


sequence = zeros(n,1);

%First calculate the approx limiting probability of being in each state
limitingProb = mean(transMatrix^50);
%Now generate a random state from the limiting probability.
cumProb  = cumsum( [0 limitingProb]);
initState = find(cumProb<rand(),1,'last');


%Now transform transition matrix into cumulative probability matrix for
%ease of generating sequence.

%First add a 0 for starting cumulative probability
cumTransMatrix = [zeros(size(transMatrix(:,1))) transMatrix];

%Now sum to create cumulative distribution
cumProb  = cumsum( cumTransMatrix')';

%Check for error in transition matrix
if any(cumProb(:)>1)
    error('transition matrix probability misspecified, transitions sum to greater than 100%');
end

%Cut off last column of all 1's
cumProb = cumProb(:,1:end-1);

state = initState;
    
for iSeq = 1:n,
    
    %Set the current state;
    sequence(iSeq) = state;
    
    %Now find the next state
    %draw a random number from 0-1,
    %find which column it falls into that's the new state.
    
    
    newState = find(cumProb(state,:)<rand(),1,'last');
    
    state = newState;
    
end