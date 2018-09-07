% Build GAMS files from the pieces in the GAMS_Model_Files folder
%
% Extracted from FESTIV_GUI so still called when fopt.use_gui = false
function create_gams_rules()
    for model=1:3
        if model==1
            gamsFilesPaths=evalin('base','gamsFilesPaths_DAC');GAMS_FILE_NAME='DASCUC.gms';
            inputfilenames={'\r\n$GDXIN DASCUCINPUT1\r\n\r\n';'\r\n$GDXIN DASCUCINPUT2\r\n\r\n'};
        elseif model==2
            gamsFilesPaths=evalin('base','gamsFilesPaths_RTC');GAMS_FILE_NAME='RTSCUC.gms';
            inputfilenames={'\r\n$GDXIN RTSCUCINPUT1\r\n\r\n';'\r\n$GDXIN RTSCUCINPUT2\r\n\r\n'};
        else
            gamsFilesPaths=evalin('base','gamsFilesPaths_RTD');GAMS_FILE_NAME='RTSCED.gms';
            inputfilenames={'\r\n$GDXIN RTSCEDINPUT1\r\n\r\n';'\r\n$GDXIN RTSCEDINPUT2\r\n\r\n'};
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
                   elseif i == 3 % Load input data
                       fid=fopen(GAMS_FILE_NAME,'a+');
                       fprintf(fid,inputfilenames{1});
                       fclose(fid);
                       for j=1:3:size(fieldnames(data_to_write.section_3),1)
                           if j==1
                               data_type='SCALAR';
                           elseif j==4
                               data_type='SET';
                           elseif j==7
                               data_type='PARAMETER';
                           else
                               data_type='TABLE';
                           end
                           if ~isempty(data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)))
                                writeGamsLists(GAMS_FILE_NAME,openOption,sprintf('*     Load %ss     *',data_type),data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)),data_type,1,0,1);
                           end
                       end
                       fid=fopen(GAMS_FILE_NAME,'a+');
                       fprintf(fid,inputfilenames{2});
                       fclose(fid);
                       for j=2:3:size(fieldnames(data_to_write.section_3),1)
                           if j==2
                               data_type='SCALAR';
                           elseif j==5
                               data_type='SET';
                           elseif j==8
                               data_type='PARAMETER';
                           else
                               data_type='TABLE';
                           end
                           if ~isempty(data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)))
                                writeGamsLists(GAMS_FILE_NAME,openOption,sprintf('*     Load %ss     *',data_type),data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)),data_type,1,0,1);
                           end
                       end
                       fid=fopen(GAMS_FILE_NAME,'a+');
                       fprintf(fid,inputfilenames{1});
                       fclose(fid);
                       for j=3:3:size(fieldnames(data_to_write.section_3),1)
                           if j==3
                               data_type='SCALAR';
                           elseif j==6
                               data_type='SET';
                           elseif j==9
                               data_type='PARAMETER';
                           else
                               data_type='TABLE';
                           end
                           if ~isempty(data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)))
                                writeGamsLists(GAMS_FILE_NAME,openOption,sprintf('*     Declare remaining %ss     *',data_type),data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)),data_type,0,0,1);
                           end
                       end
                   elseif i == 5 || i == 7 || i == 13 || i == 15 || i == 17 || i == 19 || i == 21 || i == 23
                       writeGamsDefinitions(GAMS_FILE_NAME,openOption,sprintf('*     %s     *',GAMSsectionNames{i}),data_to_write.(sprintf('section_%d',i)));
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
                           if j==1 
                               writeGamsLists(GAMS_FILE_NAME,openOption,sprintf('*     %s     *',GAMSsectionNames{i}),data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)),data_type,0,0,use_final_semicolon);
                           else
                               writeGamsLists(GAMS_FILE_NAME,openOption,'',data_to_write.(sprintf('section_%d',i)).(sprintf('definition_%d',j)),data_type,0,0,use_final_semicolon);
                           end
                       end
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
    try
        gams_model_figure=evalin('base','gams_model_figure');
        close(gams_model_figure);
    catch
    end
end