% Read in formulation mods and create GAMS files without GUI
gamsfields={'Header';'User_Defined_1';'Declare_Sets';'User_Defined_2';'Declare_Parameters';'User_Defined_3';'Load_Inputs';'User_Defined_4';'Define_Sets';'User_Defined_5';'Define_Parameters';'User_Defined_6';'Declare_Variables';'User_Defined_7';'Define_Variables';'User_Defined_8';'Declare_Equations';'User_Defined_9';'Define_Equations';'User_Defined_10';'Define_Model';'User_Defined_11';'Solver_Options';'User_Defined_12';'Solve_Statement';'User_Defined_13';'Post_Processing';'User_Defined_14';'Footer'};
for model=1:3
    % set up model data
    if model==1
        tmppath='gamsDAC.txt';
        GAMS_FILE_NAME='DASCUC.gms';
    elseif model==2
        tmppath='gamsRTC.txt';
        GAMS_FILE_NAME='RTSCUC.gms';
    else
        tmppath='gamsRTD.txt';
        GAMS_FILE_NAME='RTSCED.gms';
    end
    % Read txt file definitions
    for f=1:size(gamsfields,1)
        tmp=split(char(inifile(tmppath,'read',{'','',gamsfields{f},''})),',');
        if size(tmp{1},1) > 0
            gamsFilesPaths.(sprintf('%s',gamsfields{f})) = tmp;
        else
            gamsFilesPaths.(sprintf('%s',gamsfields{f})) = {};
        end
    end
    % Create gams files
    tmp=fields(gamsFilesPaths);
    for i=1:size(fields(gamsFilesPaths),1)
        num_files=size(gamsFilesPaths.(sprintf('%s',tmp{i})),1);
        if num_files > 0
            for j=1:num_files
                idx=strfind(gamsFilesPaths.(sprintf('%s',tmp{i})){j},'\');
                gamsFilesPaths.(sprintf('%s',tmp{i})){j}(idx)=filesep;
            end
        end
    end
    if ~isempty(gamsFilesPaths)
        GAMSsectionNames=fieldnames(gamsFilesPaths);
        clear data_to_write
        for i=1:size(GAMSsectionNames,1)
            temp_name=eval('(sprintf(''gamsFilesPaths.%s'',GAMSsectionNames{i}))');
            temp_size=size(eval(temp_name),1);
            user_count=1;
            for j=1:temp_size
                temp_dir=cell2mat(eval([temp_name,sprintf('(%d,:)',j)]));temp_dir2=pwd;
                if strcmp(temp_dir(1:3),temp_dir2(1:3))
                    temp_data=getGamsDefinitions('=start','=end',cell2mat(eval([temp_name,sprintf('(%d,:)',j)])));
                else
                    temp_data=getGamsDefinitions('=start','=end',cell2mat(strcat(pwd,filesep,eval([temp_name,sprintf('(%d,:)',j)]))));
                end
                for k=1:size(fieldnames(temp_data),1)
                    data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',user_count))=temp_data.(sprintf('definition_%d',k)).constraint;
                    user_count=user_count+1;
                end
            end
        end
        writableGAMSsectionNames=fieldnames(data_to_write);
        firstWrite=1;
        for i=1:size(GAMSsectionNames,1)
           if ~isempty(find(strcmp(sprintf('section_%d',i),writableGAMSsectionNames),1))
               if firstWrite==1
                   openOption='w+';
               else
                   openOption='a+';
               end
               if i == 1 % Write header
                   writeGamsDefinitions(GAMS_FILE_NAME,openOption,sprintf('*     %s     *',GAMSsectionNames{i}),data_to_write.(sprintf('section_%d',i)));
                   firstWrite=0;
               elseif i == 3 || i == 9 || i == 11
                   for j=1:size(fieldnames(eval(sprintf('data_to_write.section_%d',i))),1)
                       if ~isempty(data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)))
                            data_to_write_tmp=data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j));
                            fid=fopen(GAMS_FILE_NAME,openOption);
                            for k=1:size(data_to_write_tmp,1)
                                fprintf(fid,'%s',[data_to_write_tmp{k,1}]);
                                fprintf(fid,'\r\n');
                            end
                            fprintf(fid,'\r\n');
                            fclose(fid);
                        %writeGamsLists(GAMS_FILE_NAME,openOption,sprintf('*     Load %ss     *',data_type),data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)));
                       end
                   end
               elseif i == 5 || i == 7 || i == 13 || i == 15 || i == 17 || i == 19 || i == 21 || i == 23
                   writeGamsDefinitions(GAMS_FILE_NAME,openOption,sprintf('*     %s     *',GAMSsectionNames{i}),data_to_write.(sprintf('section_%d',i)));
               %{
                elseif i == 9 || i == 11
                   if i == 9
                        max_size=size(fieldnames(data_to_write.section_9),1);
                   else
                        max_size=size(fieldnames(data_to_write.section_11),1);
                   end
                   for j=1:max_size
                       if j==1 && i == 9
                           data_type='VARIABLE';use_final_semicolon=1;
                       elseif j==2 && i == 9
                           data_type = 'POSITIVE VARIABLE';use_final_semicolon=1;
                       elseif i == 9
                           data_type = ' ';use_final_semicolon=0;
                       elseif j == 1 && i == 11
                           data_type = 'EQUATION';use_final_semicolon=0;
                       elseif j == max_size && i == 11
                           data_type = ' ';use_final_semicolon = 1;
                       else
                           data_type = ' ';use_final_semicolon = 0;
                       end
                       data_to_write_tmp=data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j));
                       fid=fopen(GAMS_FILE_NAME,openOption);
                       for k=1:size(data_to_write_tmp,1)
                           fprintf(fid,'%s',[data_to_write_tmp{k,1}]);
                           fprintf(fid,'\r\n');
                       end
                       fprintf(fid,'\r\n');
                       fclose(fid);
                    end
                   %}
               else
                   writeGamsDefinitions(GAMS_FILE_NAME,openOption,sprintf('*     %s     *',GAMSsectionNames{i}),data_to_write.(sprintf('section_%d',i)));
               end
           end
        end
    else
        if model==1    
            disp('DASCUC GAMS description is empty!');
        elseif model==2
            disp('RTSCUC GAMS description is empty!');
        else
            disp('RTSCED GAMS description is empty!');
        end
    end
end