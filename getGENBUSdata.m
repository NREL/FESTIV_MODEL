    %% Create the participation factor matrix for the Excel input sheet 'GENBUS' tab

    %% Read in GENBUS tab and seperate bus from generator
    if useHDF5==0
        [partfactors,genbus_string]=xlsread(inputPath,'GENBUS','A2:B10000');
    else
        x=h5read(fileName,'/Main Input File/GENBUS');
        y=fields(x);
        partfactors=x.(y{2});
        genbus_string=x.(y{1});
    end
    listofbuses=cell(size(genbus_string,1),1);
    listofgens =cell(size(genbus_string,1),1);
    for k=1:size(genbus_string,1)
        [d,e]=strtok(genbus_string{k,1},'.');
        listofbuses(k,1)={d};
        listofgens(k,1)={e(1,2:end)};
    end
    seperatedgenbus=[listofbuses,listofgens];

    %% Set up the participation factor matrix
    uniquegenids=unique(seperatedgenbus(:,2));
    uniquebusids=unique(seperatedgenbus(:,1));

    GENBUS_STRING={uniquebusids',uniquegenids'};
    GENBUS_VAL=zeros(size(uniquebusids,1),size(uniquegenids,1));
    INJECTION_FACTOR_VAL=zeros(size(uniquebusids,1),size(uniquegenids,1));
    GENBUS_CALCS_VAL = zeros(size(seperatedgenbus,1),3);
    %% Fill in participation factors
    % if no participation factors are given in the second column of input file
    if isempty(partfactors)
        % participation factor = 1 at every bus with a generator attached
        for k=1:size(genbus_string,1)
            for j=1:size(uniquegenids,1)
                if strcmp(seperatedgenbus(k,2),uniquegenids(j,1))
                    for m=1:size(uniquebusids,1)
                        if strcmp(seperatedgenbus(k,1),uniquebusids(m,1))
                            INJECTION_FACTOR_VAL(m,j)=1;
                        end
                    end
                end
            end
        end

        % check if a generator is connected to a multiple bus and divide the
        % participation factor evenly amongst them if applicable
        for k=1:size(INJECTION_FACTOR_VAL,2)
           if sum(INJECTION_FACTOR_VAL(:,k)) > 1
               temp=sum(INJECTION_FACTOR_VAL(:,k));
               for j=1:size(uniquebusids,1)
                   if INJECTION_FACTOR_VAL(j,k) > 0
                       INJECTION_FACTOR_VAL(j,k) = 1/temp;
                   end
               end
           end
        end

    % if participation factors are already specified in the input sheet
    % (i.e. column B on GENBUS input sheet)
    else
        for k=1:size(genbus_string,1)
            for j=1:size(uniquegenids,1)
                if strcmp(seperatedgenbus(k,2),uniquegenids(j,1))
                    for m=1:size(uniquebusids,1)
                        if strcmp(seperatedgenbus(k,1),uniquebusids(m,1))
                            INJECTION_FACTOR_VAL(m,j)=partfactors(k,1);
                        end
                    end
                end
            end
        end
    end
    
    GENBUS_VAL = double(INJECTION_FACTOR_VAL>0);
    %for k=1:size(genbusstrings,1)
     %   tmp = strsplit(genbusstrings{k},'.');
      %  GENBUS_BUS_STRING{k} = tmp{1};
       % GENBUS_GEN_STRING{k} = tmp{2};
    %end;
    for k=1:size(genbus_string,1)
        i=1;
        while i<=ngen
            if strcmp(GEN_VAL(i,1),seperatedgenbus(k,2))
                GENBUS_CALCS_VAL(k,1) = i;
                GENBUS_CALCS_VAL(k,3) = partfactors(k,1);
                i=ngen;
            end;
            i=i+1;
        end;
        n=1;
        while n<=nbus
            if strcmp(BUS.uels(1,n),seperatedgenbus(k,1))
                GENBUS_CALCS_VAL(k,2) = n;
                n=nbus;
            end;
            n=n+1;
        end;
    end;


