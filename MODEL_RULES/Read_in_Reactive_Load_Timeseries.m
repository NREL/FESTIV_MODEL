% Retrieve actual reactive load and bus distributions if possible
%
%After forecsating data input
%

[Q_LOAD_DIST_VAL, Q_LOAD_DIST_STRING] = xlsread(inputPath,'Q_LOAD_DIST','A2:B10000'); % Get Q load bus distributions
for a =1:size(Q_LOAD_DIST_VAL,1)
    for b=1:size(Q_LOAD_DIST_VAL,2)
        if isfinite(Q_LOAD_DIST_VAL(a,b)) == 0
            Q_LOAD_DIST_VAL(a,b) = 0;
        end;
    end;
end;
ACTUAL_Q_LOAD_FULL=[];
for d = 1:simulation_days % Get actual Q demand from 3rd column in actual load timesereies input sheets
    ACTUAL_Q_LOAD_FULL_TMP = xlsread(cell2mat(actual_load_input_file(d,1)),'Sheet1','A1:C30000');
    ACTUAL_Q_LOAD_FULL_TMP = [ACTUAL_Q_LOAD_FULL_TMP(:,1) , ACTUAL_Q_LOAD_FULL_TMP(:,3)];
    actual_load_multiplier_tmp = zeros(size(ACTUAL_Q_LOAD_FULL_TMP));
    actual_load_multiplier_tmp(:,1) = d-1;
    ACTUAL_Q_LOAD_FULL_TMP = ACTUAL_Q_LOAD_FULL_TMP + actual_load_multiplier_tmp;
    ACTUAL_Q_LOAD_FULL = [ACTUAL_Q_LOAD_FULL; ACTUAL_Q_LOAD_FULL_TMP];
end;

