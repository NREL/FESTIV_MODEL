% Input file validation checks


% BUS!A2:A6 => BUS.uels{1:5}
  % LOAD_DIST!A2:A4 => LOAD_DIST.uels{1:3} % i) LOAD_DIST.uels subset of BUS.uels{1:5} :
    a=LOAD_DIST.uels; b=BUS.uels;
      find_cells_among_cells(a,b,'LOAD_DIST bus ',' is missing from the list of BUS(es)');
% LOAD_DIST!B2:B4 => LOAD_DIST.val % values for distributing the load; i) >=0; ii) sum()=1
  % check non-negative:
    v=LOAD_DIST.val; for i=1:length(v);if v(i)<0;display(['Negative LOAD_DIST value ',num2str(v(i)),' for bus ',a{i}]);end;end
  % check sum:
    if abs(sum(v)-1)>eps; display(['LOAD_DIST sum ',num2str(sum(v)),' does not = 1']);end
% Generators GEN!A2:A8 => GEN.uels; 
  g=GEN.uels;
% GENBUS!A1:A8 => GENBUS; B1:B8 => INJECTION_FACTOR % NOTE: participation factors are matrices (.val, also in GENBUS)
  bg=GENBUS_STRING{1,1}; gb=GENBUS_STRING{1,2}; % respectively, buses and generators from GENBUS
    find_cells_among_cells(bg, b, 'GENBUS bus ',' is missing from the list of BUS(es)');
      find_cells_among_cells(gb, g, 'GENBUS generator ',' is missing from the list of GENerators');
        find_cells_among_cells(g, gb, 'GENerator ',' is missing from the list of GENBUS generators');
  pf=INJECTION_FACTOR.val;
   for i=1:length(gb);s=sum(pf(:,i));if abs(s-1)>eps;display(['Participation ',num2str(s),'<>1 for ',gb{i}]);end;end
% COST!A2:A8 => COST_CURVE.uels{1,1}
  gc = COST_CURVE.uels{1,1} ; % generators having COST info % COST_CURVE_STRING has the same list of generators
    find_cells_among_cells(gc, g, 'COST tab generator ',' is missing from the list of GENerators');
      find_cells_among_cells(g, gc, 'GENerator ',' is missing from the list of COST tab generators');
% ASC!A2:A8 => RESERVE_COST.uels{1,1}
  gr = RESERVE_COST.uels{1,1};
    find_cells_among_cells(gr, g, 'ASC tab generator ',' is missing from the list of GENerators');
      find_cells_among_cells(g, gr, 'GENerator ',' is missing from the list of ASC tab generators');
% STARTUP!A2 => STARTUP_VALUE.uels{1,1} ;
  gs = STARTUP_VALUE.uels{1,1} ;
    find_cells_among_cells(gs, g, 'STARTUP tab generator ',' is missing from the list of GENerators');
% BRANCHDATA!B2:B7 => BRANCHBUS.uels {1,2} and {1,3}
  b4 = BRANCHBUS.uels{1,2}; b2 = BRANCHBUS.uels{1,3};
    find_cells_among_cells(b4, b, 'Branch bus "from" ',' is missing from the list of BUS(es)');
      find_cells_among_cells(b2, b, 'Branch bus "to" ',' is missing from the list of BUS(es)');
        find_cells_among_cells(b, cat(2,b4,b2) , 'Bus ',' has no branch attached to it');
clear a b v g bg gb pf gc gr gs b4 b2