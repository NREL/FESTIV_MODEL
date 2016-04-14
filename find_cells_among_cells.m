function find_cells_among_cells(a_,b_,prefix,bodytext)
% scans cell array b_ looking for cells from a_
% the function is called from script festiv_inps_consistency.m
 for i=1:length(a_);found=0;for j=1:length(b_);
   if length(a_{i})==length(b_{j}) & a_{i}==b_{j};found=1;end;end;
     if found==0;display([prefix, a_{i}, bodytext]);end;end;
end % function
