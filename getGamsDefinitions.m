function definitions=getGamsDefinitions(startofsection,endofsection,path)

%{
    This function reads in definitions for GAMS
%}

% Read in set definitions
    fid = fopen(path,'r+');
    tline = fgetl(fid);
    i=1;
    while ~isnumeric(tline)
        if ~isempty(regexp(tline,startofsection,'match'))
            endfound=0;
            definitions.(sprintf('definition_%d',i)).constraint={};
            while endfound==0
                tline = fgetl(fid);
                if ~isempty(regexp(tline,endofsection,'match'))
                    endfound=1;
                    i=i+1;
                else
                    definitions.(sprintf('definition_%d',i)).constraint=[definitions.(sprintf('definition_%d',i)).constraint;tline];
                end
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end