function [ fileList ] = rdir( dirname, subdirLimit )
%rdir recursive directory listing
%[ fileList ] = rdir( dirname, [subdirLimit] )
%
% A drop in replacement for dir() that recurses
% D = dir('directory_name') returns the results in an M-by-1
%     structure with the fields: 
%         name    -- Filename
%         date    -- Modification date
%         bytes   -- Number of bytes allocated to the file
%         isdir   -- 1 if name is a directory and 0 if not
%         datenum -- Modification date as a MATLAB serial date number.
%                    This value is locale-dependent.

%Set a default sub directory recursion limit
if nargin <=1 || isempty(subdirLimit)
    subdirLimit = 20; 
end

%If no directory input default to running in current directory.
if nargin<1 || isempty(dirname)
    dirname = pwd;
end
   
%Because the code is structured to pre-decrement the level we need to add 1
%for the level to make sense for the user. i.e. 1 = just this directory and 2 . 
subdirLimit = subdirLimit+1;

%First we need to find out if the string contains a filterspec. 
[pathstr,name,ext] = fileparts(dirname);
filterspec = '*';

fileList = []; %Default to empty array if nothing found. 
%If a directory is passed in just go. 
if isdir( dirname )
    fileList = getFileList( dirname,subdirLimit,filterspec);
%Not a directory assume the last bit includes a filterspec. 
elseif isdir( fullfile(pathstr) )
    
    filterspec = [name ext];
    dirname = pathstr;
    fileList = getFileList(dirname,subdirLimit,filterspec);
else
    %error('Error finding directory %s',dirname);    
    fileList = getFileList( dirname,subdirLimit,filterspec);
end

%fileList = getFileList(dirname,subdirLimit,filterspec);



    function fileList = getFileList( dirname,level,filterspec)
            
        %Decrement the level counter
        level = level -1;
        fileList = [];

        %If we've reached the level limit return.
        if level < 0             
            warning('ptbCorgi:rdir:recursionLimit','Reached subdirectory recursion limit, skipping %s',dirname);
            return;
        end
        
        
        allFileList = dir( dirname );
                
        thisFileList = dir( fullfile(dirname,filterspec));
                        
        validIdx = ~((strcmp({thisFileList(:).name},'.') |  strcmp({thisFileList(:).name},'..')));
        
        thisFileList = thisFileList(validIdx);
        
        %Make the file list full pathnames.
        %These are two dense lines.  dir just returns the filename of the
        %found files. We want to include the full path so we know what
        %subirectories these files are in. So we're going to prepend the
        %current dirname to the filename.  But we've got a structure with
        %severl elements.  So to do this. First we are going to concatenate
        %a single directory onto multiple strings by passing a cell array
        %into fullfile().  Next we use deal() to assign each cell value
        %back into the structure. The order and placement of {} is critical
        %for this to work.
        if ~isempty(thisFileList)
            fullFileNames = fullfile(dirname,{thisFileList.name});
            [thisFileList.name] = deal(fullFileNames{:});
        end
        
        
        for iFile = 1 : length(allFileList)
            thisRecurseList = [];
%allFileList(iFile).name
            %Skip '.' and '..'
            if strcmp(allFileList(iFile).name,'.') || strcmp(allFileList(iFile).name,'..')
                
                continue;
            end
            
            %If it's a directory recurse. 
            if allFileList(iFile).isdir
               
               thisRecurseList = getFileList( fullfile(dirname,allFileList(iFile).name), level,filterspec);                     
                
            end
            
     
            %If we haven't got any files skip because we don't have
            %anything to add
            if ~isempty(thisRecurseList)
           
                %If the previous list was empty let's initialize it.  
                if isempty(thisFileList)
                    thisFileList = thisRecurseList;
                else %Otherwise let's add the found files to the list
                    thisFileList = cat(1,thisFileList,thisRecurseList);
                end
            end
            
        end
        
 
        fileList = thisFileList;

    end

end

