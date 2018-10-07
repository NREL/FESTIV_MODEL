%{
USE:    AFTER POST PROCESSING OR BEFORE SAVING DATA
%}

figure
plot(FREQUENCY(:,1),FREQUENCY(:,2));
title('SYSTEM FREQUENCY')
ylabel('Frequency (Hz)')

