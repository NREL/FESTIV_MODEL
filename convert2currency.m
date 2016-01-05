function [temp2]=convert2currency(num2conv)
% Convert number to currency format
% must be less that 9 999 999 999 999.99

negative = 0;
if num2conv < 0
    num2conv=abs(num2conv);
    negative=1;
end
cents=round(mod(num2conv,1)*10*10);
num2conv=floor(num2conv);
numdigits=size(num2str(num2conv),2);
z1=[];
for i=1:floor((numdigits-0.0001)/3)+1
    z1=[mod(num2conv,1000) z1];
    num2conv=floor(num2conv/1000);
end
z1(end)=z1(end);
if negative == 0
    temp2=['$ ' num2str(z1(1))];
else
    temp2=['$ -' num2str(z1(1))];
end
for j=2:size(z1,2)
    temp2=[temp2 ',' sprintf('%03d',z1(j))];
end
temp2=[temp2 '.' sprintf('%02d',round(cents))];
end
