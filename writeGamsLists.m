function writeGamsLists(path,rw_option,header,data,data_type,include_load,include_semicolon,include_final_semicolon)
    if ~isempty(data)
        fid=fopen(path,rw_option);
        fprintf(fid,header);
        fprintf(fid,'\r\n\r\n');

        %test
        fprintf(fid,data_type);
        fprintf(fid,'\r\n');

        for i=1:size(data,1)
    %         if include_semicolon
    %             fprintf(fid,'%s',[data_type,' ',data{i,1},';']);
    %         else
    %             fprintf(fid,'%s',[data_type,' ',data{i,1}]);
    %         end
            %test
            if include_semicolon
                fprintf(fid,'%s',[data{i,1},';']);
            else
                fprintf(fid,'%s',[data{i,1}]);
            end
            fprintf(fid,'\r\n');
    %         if include_load
    %             temp=strfind(data{i,1},'(');
    %             if isempty(temp)
    %                 fprintf(fid,'%s',['$load ',data{i,1}]);
    %                 fprintf(fid,'\r\n');
    %             else
    %                 fprintf(fid,'%s',['$load ',data{i,1}(1:temp-1)]);
    %                 fprintf(fid,'\r\n');
    %             end
    %         end
        end
        if include_final_semicolon
            fprintf(fid,';\r\n');
        else
            fprintf(fid,'\r\n');
        end


        if include_load
            fprintf(fid,'\r\n');
            for i=1:size(data,1)
                temp=strfind(data{i,1},'(');
                if isempty(temp)
                    fprintf(fid,'%s',['$load ',data{i,1}]);
                    fprintf(fid,'\r\n');
                else
                    fprintf(fid,'%s',['$load ',data{i,1}(1:temp-1)]);
                    fprintf(fid,'\r\n');
                end
            end
        end
        fprintf(fid,'\r\n');
        fclose(fid);
    end
end