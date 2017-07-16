function [ condInfo ] = createConditionsFromParamList( conditionTemplate, method,varargin )
%createConditionsFromParamList Creates 
%   [ condInfo ] = createConditionsFromParamList( conditionTemplate, method, [ 'key',value ...] )
%
%   
%   Inputs:
%   conditionTemplate - A structure with all the common fields set
%
%   method - Either: 'pairwise' or 'crossed'
%            'pairwise': Take values as paired (or n-tupled) lists from the arguments 
%            'crossed':  Generate all possible combinations of the
%                        arguments (i.e. a "fully crossed" design)
%          
%   The rest of the arguments are specified as key/value pairs. The key is
%   a string corresponding to the field to set. The value contains the list
%   of settings to be used for each condition. For numeric values a simple
%   vector works. For strings use a cell array of strings. For anything
%   else use a cell array. Use as many key/value pairs as needed.
%
%   Output: 
%   condInfo - A structure that has the fields from condTemplate all
%   identical and the fields from the key/value pairs set as requested.
%
%   Finally, the function also sets the condInfo.label field to a string
%   that specifies the levels for the dynamic parameters. 
%
%   Examples:
%   
%   To create 3 conditions with 2 static parameters and 2 variable parameter p
%   pairs: [4, 'X'] [5, 'Y'] [6 'Z'] 
%
%   condTemplate.staticParamA = 1;
%   condTemplate.staticParamB = 2;
%   
%   condInfo = createConditionsFromParamList(condTemplate,...
%         'pairwise','variableParamA',[4 5 6],'variableParamB',{'X' 'Y' 'Z'})
% 
%
%    Creating a 3x3 fully crossed set of parameters will 
%    generate 9 conditions:
%
%   condTemplate.staticParamA = 1;
%   condTemplate.staticParamB = 2;
%
%   condInfo = createConditionsFromParamList(condTemplate,...
%         'crossed','factor1',[4 5 6],'factor2',{'X' 'Y' 'Z'})
%
%   The label field contains a string for labeling each condition with the
%   levels. A quick way to print out all the labels is:
%    
%     {condInfo.label}'
% 
%     Which prints for the 3x3 set:
%     'factor1:4, factor2:X'
%     'factor1:5, factor2:X'
%     'factor1:6, factor2:X'
%     'factor1:4, factor2:Y'
%     'factor1:5, factor2:Y'
%     'factor1:6, factor2:Y'
%     'factor1:4, factor2:Z'
%     'factor1:5, factor2:Z'
%     'factor1:6, factor2:Z'
%
%

if ~isstruct( conditionTemplate ) || numel(conditionTemplate)>1
    error('ptbCorgi:createConditions:inputError',...
        'Input variable conditionTemplate must be a length 1 structure');
end

%parse input
for iKeyVal = 1:2:length(varargin),
    idx = (iKeyVal-1)/2+1;
    fieldnames{idx} = varargin{iKeyVal};  %Get the fieldnames
    values{idx}      = varargin{iKeyVal+1}; %Get the params to use
    numValues(idx)      = length(values{idx});
    valueIdx{idx}       = 1:length(values{idx});
end

nKeyVal = length(fieldnames); %The number of key value pairs we have. 

switch lower(method)
    
    case 'pairwise'
        %For pairwise we just use the list 
        %Check if all inputs
        if length(unique(numValues))>1
            error('ptbCorgi:createCondition:inputError',...
                'For pairwise combination all parameter lists must be the same length');
        end
        
        %For pairwise we just loop through the value list and make set the
        %values. Since everything is the same length can ust grab the first
        %element of numValues
        condInfo(1:numValues(1)) = conditionTemplate;
        
        for iVal = 1:numValues(1)
            label = '';
            for iField = 1:length(fieldnames)               
                %Handle cell aray lists. If it is a cell array list
                %derefence the cell before putting into condInfo.
                thisVal = values{iField}(iVal);
                if iscell(thisVal)
                    thisVal = cell2mat(thisVal);
                end
                
                condInfo(iVal).(fieldnames{iField}) = thisVal;
                
                if ischar(thisVal)
                    labelVal = thisVal;
                elseif isnumeric(thisVal)
                    labelVal = num2str(sum(thisVal(:)),3);
                end
                
                label = [label (fieldnames{iField}) ':' labelVal  ', '];
                
            end
            
            condInfo(iVal).label = label(1:end-2); %easy way to trim trailing ', '
        end
        
            
        
    case { 'crossed','allcombination','fullycrossed','allcombo'}
        
        %For crossed the total number of conditions is the product of the
        %length of all the value lists given.
        condTotal = prod(numValues);
        condInfo(1:condTotal) = conditionTemplate;
        
        %This is a really tricky way of creating the crossed list of conditions
        %things. First using cell arrays to pass arbitrary sized arguments
        %lists to ndgrid, and return arbitrary number of outputs.
        %Ndgrid handles making matrices that contain all possible
        %combinations. We are going to generate all combinations of
        %"indices" into the lists passed in. That way we can handle
        %multiple input types given as cell arrays. To get this into the
        %individual elements needed for each condition  we use implicit
        %element indexing.
        %A simple example of ndgrid that generates all pairwise
        %is below:
        %[a b] = ndgrid([1 2], [4 5 6])
        %[a(:) b(:)]
        allCondValues = cell(1,nKeyVal);
        [allCondValues{:}] = ndgrid(valueIdx{:});

       
       for iCond = 1:condTotal,
           
           label = '';
           for iKeyVal = 1:nKeyVal
               %This is a dense loop.  The ndgrid above generates are
               %matrices of indices into are list. 
               
               thisValIdx = allCondValues{iKeyVal}(iCond);
               
               %Handle cell aray lists. If it is a cell array list
               %derefence the cell before putting into condInfo.
               thisVal = values{iKeyVal}(thisValIdx);
               if iscell(thisVal)
                   thisVal = cell2mat(thisVal);
               end
                
               condInfo(iCond).(fieldnames{iKeyVal}) = thisVal;
               
               if ischar(thisVal)
                   labelVal = thisVal;
               elseif isnumeric(thisVal)
                   labelVal = num2str(sum(thisVal(:)),3);
               end
               
               label = [label (fieldnames{iKeyVal}) ':' labelVal  ', '];
               
               end
           
           condInfo(iCond).label = label(1:end-2); %easy way to trim trailing ', '
       end
       
   
    otherwise
        error('ptbCorgi:createCondition:inputError',...
            'Unrecognized method: %s',method);

end

