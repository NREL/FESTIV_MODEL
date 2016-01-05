% online=zeros(size(RTSCEDBINDINGSCHEDULE,1)-1,nbus);
% gentypes=GENVALUE.val(:,gen_type);
% thermalidx=gentypes==1|gentypes==2|gentypes==3|gentypes==4|gentypes==5;
% nonthermalidx=~thermalidx;
% for i=1:size(RTSCEDBINDINGSCHEDULE,1)-1
%     statuses=double(RTSCEDBINDINGSCHEDULE(i+1,2:end)>0);
%     statuses(nonthermalidx)=0;
%     temp=sortrows(GENBUS,2);
%     for j=1:ngen
%         online(i,temp(j,1))=online(i,temp(j,1))+statuses(j);
%     end
% end
% figure;imagesc((IRTD/60:IRTD/60:24*daystosimulate)',1:nbus,online');
% colormap('gray');colorbar;xlabel('Time [hr]');ylabel('Bus Number');
% name=evalin('base','outputname');
% titlename=sprintf('Number of Online Generators at Each Bus: %s',name);
% title(titlename);

% % Ramping Capacity
% sced_schedules=RTSCEDBINDINGSCHEDULE(:,2:end);
% ramp_capacity=zeros(size(sced_schedules));
% ramp_utilized=zeros(size(sced_schedules));
% gen_capacities=GENVALUE.val(:,capacity);
% gen_mingen=GENVALUE.val(:,min_gen);
% gen_ramprate=GENVALUE.val(:,ramp_rate);
% for i=1:ngen
%     ramp_temp=sced_schedules(:,i);
%     % % return these lines to inlcude su&sd trajectories
% %     susd_idx=ramp_temp>eps&ramp_temp<gen_mingen(i);
% %     ramp_capacity(susd_idx,i)=sced_schedules(susd_idx,i);
% %     ramp_utilized(susd_idx,i)=sced_schedules(susd_idx,i);
%     online_idx=find(ramp_temp+eps>gen_mingen(i));
%     for t=1:size(online_idx)
%         if online_idx(t) ~= size(sced_schedules,1)
%             if ramp_temp(online_idx(t)+1)+eps > ramp_temp(online_idx(t)) % ramping up
%                 ramp_capacity(online_idx(t),i)=min(gen_ramprate(i)*IRTD,gen_capacities(i)-ramp_temp(online_idx(t)));
%                 ramp_utilized(online_idx(t),i)=ramp_temp(online_idx(t)+1) - ramp_temp(online_idx(t));
%             elseif ramp_temp(online_idx(t)+1)+eps < ramp_temp(online_idx(t)) % ramping down
%                 ramp_capacity(online_idx(t),i)=min(gen_ramprate(i)*IRTD,ramp_temp(online_idx(t))-gen_mingen(i));
%                 ramp_utilized(online_idx(t),i)=abs(ramp_temp(online_idx(t)+1) - ramp_temp(online_idx(t)));
%             else % not ramping
%                 ramp_capacity(online_idx(t),i)=gen_ramprate(i)*IRTD;
%                 ramp_utilized(online_idx(t),i)=0;
%             end
%         end
%     end
% end
% gen1=GENVALUE.val(:,gen_type)==1|GENVALUE.val(:,gen_type)==2|GENVALUE.val(:,gen_type)==3|GENVALUE.val(:,gen_type)==4|GENVALUE.val(:,gen_type)==5;
% unusedRamp=sum(ramp_capacity(1:end-1,gen1),2)-sum(ramp_utilized(1:end-1,gen1),2);
% % ft=figure;
% % figure(ft);
% % subplot(4,1,4);
% % hold on;
% % plot(RTSCEDBINDINGSCHEDULE(1:end-1,1),sum(ramp_capacity(1:end-1,gen1),2)-sum(ramp_utilized(1:end-1,gen1),2),'magenta');
% % ytemp=ylim;
% % xlabel('Time [hr]');ylabel('Unused Ramp [MW/5 min]');axis([0 168 0 ytemp(2)]);
% % title('Unused Thermal Ramping Capacity');
% % hold on
% % plot(RTSCEDBINDINGSCHEDULE(:,1),RTSCEDBINDINGLOSSLOAD(:,2),'blue');
% figure;plot(RTSCEDBINDINGSCHEDULE(1:end-1,1),sum(ramp_utilized(1:end-1,gen1),2),'red');
% hold on;
% plot(RTSCEDBINDINGSCHEDULE(1:end-1,1),sum(ramp_capacity(1:end-1,gen1),2),'blue');


% % Direction of ACE
% posACE=find(ACE(:,2)>0);
% negACE=find(ACE(:,2)<0);
% aaceetest=zeros(1,4);
% aaceetest(1)=trapz(0:t_AGC/3600:size(posACE,1)*4/3600-t_AGC/3600,abs(ACE(posACE,2)));
% aaceetest(2)=trapz(0:t_AGC/3600:size(negACE,1)*4/3600-t_AGC/3600,abs(ACE(negACE,2)));
% aaceetest(3)=aaceetest(1)+aaceetest(2);
% aaceetest(4)=trapz(ACE(:,1),abs(ACE(:,2)));
% aaceetest

% % Number of Committed Units
% onlineunits=zeros(684,9);
% col_counter=1;
% for ccc=10:18
%     load(PathNames{ccc});
%     gentypes=GENVALUE.val(:,gen_type);
%     thermalidx=gentypes==1|gentypes==2|gentypes==3|gentypes==4|gentypes==5;
%     nonthermalidx=~thermalidx;
%     I_TEMP=RTSCUCBINDINGCOMMITMENT(:,2:end);
%     online=sum(I_TEMP(:,find(thermalidx)),2);
% %     ft=figure;
%     % figure(ft);
%     % subplot(4,1,4);
%     % hold on;
% %     stairs(RTSCUCBINDINGSCHEDULE(:,1),online,'magenta');
%     onlineunits(:,col_counter)=online;
%     col_counter=col_counter+1;
% end
% open onlineunits

% Aggregate Generator Movements
% agcind=evalin('base','find(GENVALUE.val(:,agc_qualified));');
% Y1=evalin('base','zeros(size(ACTUAL_GENERATION));');
% Y1(:,1)=evalin('base','ACTUAL_GENERATION(:,1);');
% Y2=evalin('base','ACTUAL_GENERATION;');
% X=evalin('base','RTSCEDBINDINGSCHEDULE;');
% NUMBER_OF_DAYS=evalin('base','daystosimulate;'); % number of consecutive days to consider
% AGC_RESOLUTION=evalin('base','t_AGC;'); % in seconds
% INPUT_RESOLUTION=evalin('base','IRTD;'); % in minutes
% ngen=evalin('base','ngen;');
% wb=waitbar(0,'Calculating...');
% for cc=1:ngen
%     raw_load_data=X(:,cc+1);
%     number_of_raw_data_points_per_day=60*24/INPUT_RESOLUTION;
%     number_of_agc_intervals_per_N_minutes=60/AGC_RESOLUTION*INPUT_RESOLUTION;
%     total_number_of_agc_data_points=number_of_raw_data_points_per_day*number_of_agc_intervals_per_N_minutes*NUMBER_OF_DAYS;
%     linearized_load_temp=zeros(total_number_of_agc_data_points,1);k=1;
%     for i=1:number_of_raw_data_points_per_day*NUMBER_OF_DAYS-1
%         agc_load_increment=(raw_load_data(i+1,1)-raw_load_data(i,1))/number_of_agc_intervals_per_N_minutes;
%         for j=1:number_of_agc_intervals_per_N_minutes
%             linearized_load_temp(k,1)=raw_load_data(i,1)+agc_load_increment*(j-1);
%             k=k+1;
%         end
%     end
%     for j=1:number_of_agc_intervals_per_N_minutes
%         linearized_load_temp(k,1)=raw_load_data(end,1)+agc_load_increment*(j-1);
%         k=k+1;
%     end
%     Y1(:,cc+1)=linearized_load_temp;
%     waitbar(cc/ngen,wb);
% end
% close(wb);
% w=sum(Y2(:,2:end));
% nonzero=sum(w(1,agcind)~=0);
% plotind=find(w(:,agcind)~=0);
% numrow=floor(sqrt(nonzero));
% numcol=ceil(nonzero/numrow);
% temp=evalin('base','GEN_VAL');
% plotnames=temp(agcind(plotind),1);
% f3=figure;
% figure(f3);
% % subplot(4,1,4);
% plot(Y1(:,1),sum(Y2(:,agcind(plotind(([1:nonzero])))+1),2),'red',Y1(:,1),sum(Y1(:,agcind(plotind(([1:nonzero])))+1),2),'blue');
% temp=sum(Y1(:,agcind(plotind(([1:nonzero])))+1),2)-sum(Y2(:,agcind(plotind(([1:nonzero])))+1),2);
% temp2=abs(temp)>0.0001;
% temp3=abs(temp(temp2));
% avgdev=sum(temp3)/size(temp3,1);
% if isnan(avgdev);avgdev=0;end;
% text(0.10,0.93,sprintf('<Deviation>: %.4f MW',avgdev),'units','normalized');
% titlename=sprintf('Realized Generation Vs Dispatch Instruction:');
% axis([0 168 ylim]);
% legend('AGC Movements','RTD Instruction');





% % colors={'black';'green';'-.red';'-.red';'--blue';'--blue';':magenta';':magenta'};
% % colors={'--black';'red';'--black';'red';'--black';'red';'--black';'red'};
% onlinegens=GENVALUE.val(:,8)~=15;
% solar=GENVALUE.val(:,8)==10;
% wind=GENVALUE.val(:,8)==7;
% vcrs=GENVALUE.val(:,8)==16;
% onlinegens=logical(onlinegens-wind-solar-vcrs);
% X1=RTSCEDBINDINGSCHEDULE(:,2:end);
% X1=X1(:,onlinegens);
% X2=repmat(GENVALUE.val(onlinegens,1)',size(RTSCEDBINDINGSCHEDULE,1),1); %capacity
% temp=RTSCEDBINDINGSCHEDULE(:,2:end)>0.0001;
% temp=double(temp(:,onlinegens));
% X2=X2.*temp;
% Y=X2-X1;
% assignin('base','totalUnused',sum(Y,2));
% fc=figure;
% figure(fc);
% subplot(4,1,4);
% hold on;
% plot(RTSCEDBINDINGSCHEDULE(:,1),sum(Y,2),'magenta');
% xlabel('Time [hr]');
% ylabel('Unused Capacity [MW]');


gentypes=GENVALUE.val(:,gen_type);
thermalgens=gentypes==1|gentypes==2|gentypes==3|gentypes==4|gentypes==5;
thermalramps=diff(RTSCEDBINDINGSCHEDULE(:,find(thermalgens)+1));
averageramp_pos=mean(thermalramps(thermalramps>0));
averageramp_neg=mean(thermalramps(thermalramps<0));
maxvalue=ceil(max(max(thermalramps)));minvalue=floor(min(min(thermalramps)));
[a1,b1]=hist(thermalramps,(minvalue:(maxvalue+abs(minvalue))/(2*(maxvalue+abs(minvalue))):maxvalue));
[a2,b2]=hist(reshape(thermalramps,60/IRTD*24*sum(thermalgens),1),(minvalue:(maxvalue+abs(minvalue))/(2*(maxvalue+abs(minvalue))):maxvalue));
% [a1,b1]=hist(thermalramps,(minvalue:0.5:maxvalue));
% [a2,b2]=hist(reshape(thermalramps,60/IRTD*24*sum(thermalgens),1),(minvalue:0.5:maxvalue));
figure;
subplot(2,1,1);plot(b1,a1);title('Ramp Distribution per Thermal Generator');legend(GEN_VAL{thermalgens});xlabel('Ramp [MW]');ylabel('Number of Intervals');
subplot(2,1,2);plot(b2,a2);title('Aggregated Thermal Ramp Distribution');xlabel('Ramp [MW]');ylabel('Number of Intervals');
