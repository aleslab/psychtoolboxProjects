function [ mfiles ] = findLocalExecutedFiles( directory )
%findLocalExecutedFiles  Checks which local functions have been run
%   This function is used to determine which functions/files have been run
%   recently. Uses matlab "inmem" to get a list and parses that list for
%   functions in the input directory or subfolder.

[mFilesInMem] = inmem('-completenames');

idx = 1;
for iFile = 1:length(mFilesInMem)

    if strncmp(directory,mFilesInMem(iFile),length(directory))
        mfiles{idx,1} = mFilesInMem{iFile};
        idx = idx + 1;
    end
end

end

