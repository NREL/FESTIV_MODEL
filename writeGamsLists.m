function writeGamsLists(path,rw_option,header,data)
    if ~isempty(data)
        fid=fopen(path,rw_option);
        fprintf(fid,header);
        fprintf(fid,'\r\n\r\n');

        fprintf(fid,'\r\n');
        fclose(fid);
    end
end