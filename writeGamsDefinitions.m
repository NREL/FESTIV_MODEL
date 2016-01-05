function writeGamsDefinitions(path,rw_option,header,data)
    fid=fopen(path,rw_option);
    fprintf(fid,header);
    fprintf(fid,'\r\n\r\n');
    for i=1:size(fieldnames(data),1)
%         for j=1:size(eval(sprintf('data.definition_%d.constraint',i)),1)
        for j=1:size(eval(sprintf('data.definition_%d',i)),1)
%             fprintf(fid,'%s',eval(sprintf('data.definition_%d.constraint{%d,:}',i,j)));
            fprintf(fid,'%s',eval(sprintf('data.definition_%d{%d,:}',i,j)));
            fprintf(fid,'\r\n');
        end
        fprintf(fid,'\r\n');
    end
    fprintf(fid,'\r\n');
    fclose(fid);
end