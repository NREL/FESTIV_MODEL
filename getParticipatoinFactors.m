function [GENBUSTABLE]=getParticipatoinFactors(path)
    %% Create the participation factor matrix for the Excel input sheet 'GENBUS' tab
    inputfilepath=path;
    useHDF5=evalin('caller','useHDF5');
    fileName=evalin('caller','fileName');

    %% Read in GENBUS tab and seperate bus from generator
    if useHDF5==0
        [partfactors,genbus]=xlsread(inputfilepath,'GENBUS','A2:B10000');
    else
        x=h5read(fileName,'/Main Input File/GENBUS');
        y=fields(x);
        partfactors=x.(y{2});
        genbus=x.(y{1});
    end
    listofbuses=cell(size(genbus,1),1);
    listofgens =cell(size(genbus,1),1);
    for i=1:size(genbus,1)
        [d,e]=strtok(genbus{i,1},'.');
        listofbuses(i,1)={d};
        listofgens(i,1)={e(1,2:end)};
    end
    seperatedgenbus=[listofbuses,listofgens];

    %% Set up the participation factor matrix
    uniquegenids=unique(seperatedgenbus(:,2));
    uniquebusids=unique(seperatedgenbus(:,1));

    GENBUSTABLE.name='PARTICIPATION_FACTORS';
    GENBUSTABLE.form='full';
    GENBUSTABLE.type='parameter';
    GENBUSTABLE.uels={uniquebusids',uniquegenids'};
    GENBUSTABLE.val=zeros(size(uniquebusids,1),size(uniquegenids,1));

    %% Fill in participation factors
    % if no participation factors are given in the second column of input file
    if isempty(partfactors)
        % participation factor = 1 at every bus with a generator attached
        for i=1:size(genbus,1)
            for j=1:size(uniquegenids,1)
                if strcmp(seperatedgenbus(i,2),uniquegenids(j,1))
                    for m=1:size(uniquebusids,1)
                        if strcmp(seperatedgenbus(i,1),uniquebusids(m,1))
                            GENBUSTABLE.val(m,j)=1;
                        end
                    end
                end
            end
        end

        % check if a generator is connected to a multiple bus and divide the
        % participation factor evenly amongst them if applicable
        for i=1:size(GENBUSTABLE.val,2)
           if sum(GENBUSTABLE.val(:,i)) > 1
               temp=sum(GENBUSTABLE.val(:,i));
               for j=1:size(uniquebusids,1)
                   if GENBUSTABLE.val(j,i) > 0
                       GENBUSTABLE.val(j,i) = 1/temp;
                   end
               end
           end
        end

    % if participation factors are already specified in the input sheet
    % (i.e. column B on GENBUS input sheet)
    else
        for i=1:size(genbus,1)
            for j=1:size(uniquegenids,1)
                if strcmp(seperatedgenbus(i,2),uniquegenids(j,1))
                    for m=1:size(uniquebusids,1)
                        if strcmp(seperatedgenbus(i,1),uniquebusids(m,1))
                            GENBUSTABLE.val(m,j)=partfactors(i,1);
                        end
                    end
                end
            end
        end
    end

end % end function
