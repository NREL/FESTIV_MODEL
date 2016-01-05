function [BRANCHBUSTABLE]=getBRANCHBUS(path)
    %% Create the BRANCHBUS variable for GAMS
    inputfilepath=path;
    useHDF5=evalin('caller','useHDF5');
    fileName=evalin('caller','fileName');

    %% Read in BRANCHDATA tab and seperate buses
    if useHDF5==0
        [~,BRANCH_DATA]=xlsread(inputfilepath,'BRANCHDATA','A2:B10000');
    else
        x=h5read(fileName,'/Main Input File/BRANCHDATA');
        BRANCH_DATA=[x.NAME1 x.BRANCHBUS];
    end

    listofbuses=cell(size(BRANCH_DATA,1),1);
    listoffrombuses=cell(size(BRANCH_DATA,1),1);
    listoftobuses=cell(size(BRANCH_DATA,1),1);
    SEPERATED_BRANCH_DATA=cell(size(BRANCH_DATA,1),3);

    for i=1:size(BRANCH_DATA,1)
        [~,rem]=strtok(BRANCH_DATA{i,2},'.');
        listofbuses(i,1)={rem(1,2:end)};
    end
    for i=1:size(BRANCH_DATA,1)
        [tok,rem]=strtok(listofbuses{i,1},'.');
        listoffrombuses(i,1)={tok};
        listoftobuses(i,1)={rem(1,2:end)};
    end
    SEPERATED_BRANCH_DATA(:,1)=BRANCH_DATA(:,1);
    SEPERATED_BRANCH_DATA(:,2)=listoffrombuses(:,1);
    SEPERATED_BRANCH_DATA(:,3)=listoftobuses(:,1);

    %% Set up the BRANCHBUS variable
    uniquefromids=unique(SEPERATED_BRANCH_DATA(:,2));
    uniquetoids=unique(SEPERATED_BRANCH_DATA(:,3));

    BRANCHBUSTABLE.name='BRANCHBUS';
    BRANCHBUSTABLE.form='full';
    BRANCHBUSTABLE.type='set';
    BRANCHBUSTABLE.uels={BRANCH_DATA(:,1)',uniquefromids',uniquetoids'};
    BRANCHBUSTABLE.val=zeros(size(BRANCH_DATA,1),size(uniquefromids,1),size(uniquetoids,1));

    %% Fill in branch locations
    for a=1:size(BRANCH_DATA,1)
        for b=1:size(uniquefromids,1)
            if strcmp(uniquefromids(b,1),SEPERATED_BRANCH_DATA(a,2))
                for c=1:size(uniquetoids,1)
                    if strcmp(uniquetoids(c,1),SEPERATED_BRANCH_DATA(a,3))
                        BRANCHBUSTABLE.val(a,b,c)=1;
                    end
                end
            end
        end
    end

end % end function
