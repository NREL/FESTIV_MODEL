function inputFiles = List_Of_Input_Files()
% Produce a list of all input files in the Input Directory. Essentially,
% this file stores the path of  all excel files not in the main 'Input' 
% directory and not in a 'TIMESERIES' directory in 'inputFiles'.

% Gather list of all files
[~,r2]=system('dir /S /B *.xlsx *.xls');
files=regexp(r2,'\n','split')';
clear r2

% Find files not in a 'TIMESERIES' directory
inputFileIndicies1=zeros(size(files,1),1);
for i=1:size(inputFileIndicies1,1)
    check=strfind(files{i,1},'TIMESERIES');
    if isempty(check)
        inputFileIndicies1(i,1)=1;
    end
end

% Make sure files are in the 'Input' directory
inputFileIndicies2=zeros(size(files,1),1);
for i=1:size(inputFileIndicies2,1)
    check=strfind(files{i,1},'Input');
    if ~isempty(check)
        inputFileIndicies2(i,1)=1;
    end
end

% Ignore Files directly in the 'Input' directory
inputFileIndicies3=ones(size(files,1),1);
for i=1:size(inputFileIndicies3,1)
    temp=fileparts(files{i,1});
    try
        if strcmp(temp(end-4:end),'Input')
            inputFileIndicies3(i,1)=0;
        end
    catch
        inputFileIndicies3(i,1)=0;
    end
end

% Final indicies of all input files
inputFileIndicies=inputFileIndicies1.*inputFileIndicies2.*inputFileIndicies3;

% Collect the input files and store them in 'inputFiles'
inputFiles=files(logical(inputFileIndicies),1);

end % end function