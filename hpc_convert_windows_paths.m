% This script converts Windows paths in the workspace to Linux paths for use
% on Peregrine.
%
% Example:
%   Windows : inputPath = C:\Users\dbiagion\FESTIV\trunk\Input\5_Bus_Tutorial\PJM_5_BUS.xlsx
%   Linux   : inputPath = <festiv_root_dir>/Input/5_Bus_Tutorial/PJM_5_BUS.xlsx
%
% where festiv_root_dir is defined at the top of FESTIV.m.
% This is useful when running no-gui mode on Peregrine. You can generate the
% tempws*.mat files on your personal machine and copy them over to
% <festiv_root_dir> on Peregrine.  FESTIV will then figure out that you're
% on peregrine and convert the path names.

% initialize temp structure
tmp = [];               
tmp.whos = whos;
tmp.first = 1;
tmp.pwd = pwd;

% iterate through the workspace
for i = 1:length(tmp.whos)
  
  % find character variables
  if isequal(tmp.whos(i).class, 'char')
    
    % find and replace windows wrong-slashes
    tmp.ix = findstr('\', eval(tmp.whos(i).name));
    if ~isempty(tmp.ix)
      
      % print that this is script is doing something the first time
      if tmp.first
        fprintf([mfilename, ' :\n'])
        tmp.first = 0;
      end
      
      % print old value
      fprintf([' ', tmp.whos(i).name, ':\n'])
      fprintf('  old value: ')
      disp(eval(tmp.whos(i).name))
      
      % replace wrong-slash with right-slash
      eval([tmp.whos(i).name, '(tmp.ix) = ''/'';']);
      
      % now modify paths to point to the new location on peregrine
      tmp.input = findstr('/Input', eval(tmp.whos(i).name));
      if ~isempty(tmp.input)
        eval([tmp.whos(i).name, ' = ', tmp.whos(i).name, '(tmp.input:end);']);
        eval([tmp.whos(i).name, ' = [tmp.pwd, ', tmp.whos(i).name, '];']);
      end
      
      % print new value
      fprintf('  new value: ')
      disp(eval(tmp.whos(i).name))
      fprintf('\n')
      
    end
  end
end
clear tmp