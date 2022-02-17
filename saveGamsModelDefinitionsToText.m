% save gams model definitions
for m=1:3
    if m==1
        model=gamsFilesPaths_DAC;
        outputn='gamsDAC.txt';
    elseif m==2
        model=gamsFilesPaths_RTC;
        outputn='gamsRTC.txt';
    else
        model=gamsFilesPaths_RTD;
        outputn='gamsRTD.txt';
    end
    fn=fieldnames(model);
    fid=fopen(outputn,'w+');
    for n=1:size(fn)
        header_str = [';----- ',strrep(fn{n},'_',' '),' -----;'];
        if size(model.(fn{n}),1) > 0
            tmp=model.(fn{n}){1};
            if size(model.(fn{n}),1) > 1
                for t=1:size(model.(fn{n}),1)-1
                    tmpstr=[',',model.(fn{n}){t+1}];
                    tmp=[tmp,tmpstr];
                end
            end
        else
            tmp='';
        end
        body_str = [fn{n},' = ',tmp];

        fprintf(fid,'%s\n%s\n\n',header_str,body_str);
    end
    fclose(fid);
end