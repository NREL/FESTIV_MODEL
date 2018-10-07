function gamspath = getgamspath
 % Generically determine the path for gamside.exe
    if ispc()   %If running on Microsoft Windows
     % VD added several lines to skip searching for 'gamside.exe' (saves ~20 sec) where possible
     f=fopen('pathfile.txt') ; 
      if f<1 ; !path >> pathfile.txt
           f=fopen('pathfile.txt') ; end
        path = fread(f, 'int8=>char')' ; % read paths from 'pathfile.txt'
         fclose(f) ; % !del pathfile.txt % can delete it
          gamspathcell = regexp(path,'[^;]+[gG][aA][mM][sS][^;]+','match') ; %select GAMS-related paths
      if length(gamspathcell)==1 % if there is one path referring to GAMS, use it
       %a=(system(['dir ',[gamspathcell{1},'\gamside.exe] /w /s >> tmp.txt'])==0); !del tmp.txt
       fullpath=strcat(cellstr(gamspathcell{1}),'\gamside.exe');
       a=dir(fullpath{1});
         if isempty(a)==0  
             gamspath = gamspathcell{1} ;
      end % if length == 1
      else % if there are several GAMS paths or none is found, then search for 'gamside.exe' (takes longer though)
            [~,lines]=system('CD \ & dir gamside.exe /s');
            numlines=regexp(lines,'\n','split')';
            for i=1:size(numlines,1)
                if strfind(cell2mat(numlines(i,1)),'GAMS')
                     j=strfind(numlines(i,1),'C');
                     k=char(numlines(i,1));
                     gamspath=k(1,j{:}:end);
                end
            end
          end % if a (i.e. is gamside.exe found)

    else 
        warning('FESTIV:gamspath','For non-Windows platforms the path to gams matlab files are assumed to be in MATLABPATH')
        gamspath = '';
    end
end
