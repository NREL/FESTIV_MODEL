function FESTIVhelper
% Potential real time FESTIV execution interface

% create the figure
f=figure('Visible','off','name','FESTIV HELPER','NumberTitle','off','units','pixels','position',[50 50 800 300],'color','white');

% create the GUI components and properly locate them
uicontrol('Parent',f,'Style','pushbutton','String','ACE','units','normalized','Position', [.685 .58 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_ACE_callback});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Realized<br>Generation</center></html>','units','normalized','Position', [.685 .86 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_realizedgen_callback});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>DASCUC<br>Schedules</center></html>','units','normalized','Position', [.83 .86 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_dagen_callback});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>RTSCED<br>Schedules</center></html>','units','normalized','Position', [.685 .72 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_rtdgen_callback});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Generation<br>Vs. Load</center></html>','units','normalized','Position', [.83 .58 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_genvload_callback});
uicontrol('Parent',f,'Style','pushbutton','String','Energy Prices','units','normalized','Position', [.685 .44 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_dalmp_callback});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Instant VG<br>Penetration</center></html>','units','normalized','Position', [.83 .44 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_vg_penetration});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Comparison Across<br> Sched Processes</center></html>','units','normalized','Position',[.83 .72 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@Compare_Across_Schedule_Process_callback});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Compare ACE<br>Distributions</center></html>','units','normalized','Position',[.83 .30 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_aceDist});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Total Generation<br>By Gen Type</center></html>','units','normalized','Position',[.685 .30 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_gentotals});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>DA Load Vs<br>Actual Load</center></html>','units','normalized','Position',[.685 .16 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_daloadVactual});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Generation<br>Stack by Type</center></html>','units','normalized','Position',[.83 .16 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_genstack});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Number of<br>Committed Units</center></html>','units','normalized','Position',[.685 .02 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_statuses});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>VG Curtailment</center></html>','units','normalized','Position',[.83 .02 .13 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_vgcurtailment});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>RT Price<br>And ACE</center></html>','units','normalized','Position',[.55 .30 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_rtpriceNace});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Number Of<br>Start-Ups</center></html>','units','normalized','Position',[.415 .30 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_numsus});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Actual Vs<br>Capacity</center></html>','units','normalized','Position',[.275 .30 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_onlinecapacity});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Ramp<br>Utilization</center></html>','units','normalized','Position',[.55 .16 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_ramputilization});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Case<br>Summaries</center></html>','units','normalized','Position',[.415 .16 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@show_casesummaries});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Dispatch Vs<br>AGC Signal</center></html>','units','normalized','Position',[.275 .16 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_rtdVSagc});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Net Load</center></html>','units','normalized','Position',[.275 .02 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_netload});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>RT Reserve<br>Schedules</center></html>','units','normalized','Position',[.415 .44 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_reserves});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>RT Market<br>Infeasibilities</center></html>','units','normalized','Position',[.55 .02 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_lossload});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Unused Thermal<br>Capacity</center></html>','units','normalized','position',[.55 .44 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_unused});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Online Time<br>Per Unit</center></html>','units','normalized','position',[.415 .02 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@show_onlinetime});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>RT Reserve<br>Prices</center></html>','units','normalized','position',[.275 .44 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_reserve_prices});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>DA Reserve<br>Prices</center></html>','units','normalized','position',[.275 .58 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_da_reserve_prices});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>DA Reserve<br>Schedules</center></html>','units','normalized','position',[.415 .58 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_da_reserve});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Generator<br>Revenues</center></html>','units','normalized','position',[.55 .58 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_revenues});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Access<br>Variables</center></html>','units','normalized','position',[.55 .72 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@access_variables});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Line<br>Congestion</center></html>','units','normalized','position',[.415 .72 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@plot_congestion});
uicontrol('Parent',f,'Style','pushbutton','String','<html><center>Custom<br>Script</center></html>','units','normalized','position',[.275 .72 .12 .115],'fontunits','normalized','fontsize',0.30,'Callback',{@eval_custom});
listOfCases=uicontrol('Parent',f,'Style','listbox','Max',10,'units','normalized','Position',[0.02 0.20 .23 .76],'FontName','Courier','String','Cases','Max',10,'value',[],'callback',{@loadOnDoubleClick_callback});
uicontrol('Parent',f,'Style','pushbutton','String','Add Case','units','normalized','Position',[0.02 .10 .11 .07],'fontunits','normalized','fontsize',0.5,'Callback',{@addCase_callback});
uicontrol('Parent',f,'Style','pushbutton','String','Remove Case','units','normalized','Position',[.02 .02 .11 .07],'fontunits','normalized','fontsize',0.5,'Callback',{@removeCase_callback});
% outputsummary=uitable('Parent',f,'units','normalized','position',[.275 .44 .395 .525],'ColumnFormat',{'char','char'},'ColumnEditable',[false false],'ColumnWidth',{220 90},'ColumnName',[],'RowName',[]);
uicontrol('Parent',f,'Style','pushbutton','String','Move Up','units','normalized','Position',[0.14 .10 .11 .07],'fontunits','normalized','fontsize',0.5,'Callback',{@moveUp_callback});
uicontrol('Parent',f,'Style','pushbutton','String','Move Down','units','normalized','Position',[0.14 .02 .11 .07],'fontunits','normalized','fontsize',0.5,'Callback',{@moveDown_callback});
currentCase=uipanel('Parent',f,'Title','Current Case','units','normalized','position',[.275 .86 .395 .14],'backgroundcolor','white');
currentCaseName=uicontrol('Parent',currentCase,'style','text','units','normalized','position',[.01 .01 .99 .95],'string','- - -','backgroundcolor','white','fontunits','normalized','fontsize',0.5,'horizontalalignment','left');
movegui('center');
set(f,'Visible','on');
pause on;pause(0.1);pause off;

PathNames=cell(0,1);
row = 1;
assignin('base','PathNames',PathNames);
assignin('base','row',row);
listOfVars=[];
listOfCaseNames=[];
outputVariableName_edit=[];
addpath(strcat(pwd,filesep, 'MODEL_RULES'));   


% plot ACE
function plot_ACE_callback(~,~)
    x=evalin('base','ACE');
    y=evalin('base','ACE_time_index');
    z=evalin('base','CPS2_ACE_index');
    w=evalin('base','raw_ACE_index');
    name=evalin('base','outputname');
    figure;plot(x(:,y),x(:,w:z));
    titlename=sprintf('ACE levels: %s',name);
    title(titlename);
    legend('raw Ace','Continuous integrated ACE','CPS2 ACE');
    xlabel('Time [hr]');
    ylabel('Magnitude [MW]');
end

% plot realized generation
function plot_realizedgen_callback(~,~)
    ACTUAL_GENERATION=evalin('base','ACTUAL_GENERATION');
    ACTUAL_PUMP=evalin('base','ACTUAL_PUMP');
    ngen=evalin('base','ngen');
    nESR=evalin('base','nESR');
    storage_to_gen_index=evalin('base','storage_to_gen_index');
    GEN_VAL=evalin('base','GEN_VAL');
    name=evalin('base','outputname');
    temp=ACTUAL_GENERATION(:,2:ngen+1);
    temp(:,storage_to_gen_index) = temp(:,storage_to_gen_index)  - ACTUAL_PUMP(:,2:nESR+1);
    figure;plot(ACTUAL_GENERATION(:,1),temp);
    titlename=sprintf('Actual Generation: %s',name);
    title(titlename)
    hlegend=legend(GEN_VAL,'interpreter','none');
    set(hlegend,'visible','off');
    xlabel('Time [hr]');
    ylabel('Output [MW]');
end

% plot DASCUC scheudles
function plot_dagen_callback(~,~)
    DASCUCSCHEDULE=evalin('base','DASCUCSCHEDULE');
    DASCUCPUMPSCHEDULE=evalin('base','DASCUCPUMPSCHEDULE');
    ngen=evalin('base','ngen');
    nESR=evalin('base','nESR');
    GEN_VAL=evalin('base','GEN_VAL');
    storage_to_gen_index=evalin('base','storage_to_gen_index');
    name=evalin('base','outputname');
    temp=DASCUCSCHEDULE(:,2:ngen+1);
    temp(:,storage_to_gen_index) = temp(:,storage_to_gen_index)  - DASCUCPUMPSCHEDULE(:,2:nESR+1);
    figure;plot(DASCUCSCHEDULE(:,1),temp(:,1:ngen))
    titlename=sprintf('Day-Ahead Schedules: %s',name);
    title(titlename);
    hlegend=legend(GEN_VAL,'interpreter','none');
    set(hlegend,'visible','off');
    xlabel('Time [hr]');
    ylabel('Output [MW]');
end

% plot RTDCED scheudles
function plot_rtdgen_callback(~,~)
    RTSCEDBINDINGSCHEDULE=evalin('base','RTSCEDBINDINGSCHEDULE');
    RTSCEDBINDINGPUMPSCHEDULE=evalin('base','RTSCEDBINDINGPUMPSCHEDULE');
    ngen=evalin('base','ngen');
    nESR=evalin('base','nESR');
    GEN_VAL=evalin('base','GEN_VAL');
    storage_to_gen_index=evalin('base','storage_to_gen_index');
    name=evalin('base','outputname');
    temp=RTSCEDBINDINGSCHEDULE(:,2:ngen+1);
    temp(:,storage_to_gen_index) = temp(:,storage_to_gen_index)  - RTSCEDBINDINGPUMPSCHEDULE(:,2:nESR+1);
    figure;plot(RTSCEDBINDINGSCHEDULE(:,1),temp);
    titlename=sprintf('RTSCED Schedules: %s',name);
    title(titlename)
    hlegend=legend(GEN_VAL,'interpreter','none');
    set(hlegend,'visible','off'); 
    xlabel('Time [hr]');
    ylabel('Output [MW]');
end

% plot DA prices
function plot_dalmp_callback(~,~)
    w=evalin('base','BUS_VAL');
    DASCUCLMP=evalin('base','DASCUCLMP');
    lmpFigure=figure('visible','off','name','Locational Marginal Prices (LMPs)','NumberTitle','off','units','pixels','position',[50 50 750 500],'color',[.9412 .9412 .9412]);
    movegui(lmpFigure,'center');
    set(lmpFigure,'visible','on');
    ha=axes('Units','normalized','Position',[0.37,0.10,0.60,0.82]);
    plot(DASCUCLMP(:,1),DASCUCLMP(:,2:end));
    network_button_group=uibuttongroup('parent',lmpFigure,'title','Select Model','units','normalized','position',[.025 .65 .26 .20],'fontunits','normalized','fontsize',0.15,'SelectionChangeFcn',{@changeLMPPlot});
    uicontrol('parent',network_button_group,'style','radiobutton','units','normalized','position',[.07 .60 .90 .40],'string','Day Ahead SCUC','fontsize',10,'tag','plotDASCUClmp');
    uicontrol('parent',network_button_group,'style','radiobutton','units','normalized','position',[.07 .10 .90 .40],'string','Real Time SCED','fontsize',10,'tag','plotRTSCEDlmp');
    hlegend=legend(w,'interpreter','none');
    set(hlegend,'visible','off')
    xlabel(gca,'Time [hr]');
    ylabel(gca,'LMP [$/MWh]');
    name=evalin('base','outputname');
    titlename=sprintf('Day-Ahead Prices: %s',name);
    title(gca,titlename);
end

function changeLMPPlot(~,eventdata)
    switch get(eventdata.NewValue,'tag');
        case 'plotDASCUClmp'
            DASCUCLMP=evalin('base','DASCUCLMP');
            plot(DASCUCLMP(:,1),DASCUCLMP(:,2:end));
            w=evalin('base','BUS_VAL');hlegend=legend(w,'interpreter','none');set(hlegend,'visible','off')
            xlabel(gca,'Time [hr]');
            ylabel(gca,'LMP [$/MWh]');
            name=evalin('base','outputname');
            titlename=sprintf('Day-Ahead Prices: %s',name);
            title(gca,titlename);
        case 'plotRTSCEDlmp'
            RTSCEDBINDINGLMP=evalin('base','RTSCEDBINDINGLMP');
            plot(RTSCEDBINDINGLMP(:,1),RTSCEDBINDINGLMP(:,2:end));
            w=evalin('base','BUS_VAL');hlegend=legend(w,'interpreter','none');set(hlegend,'visible','off')
            xlabel(gca,'Time [hr]');
            ylabel(gca,'LMP [$/MWh]');
            name=evalin('base','outputname');
            titlename=sprintf('Real-Time Prices: %s',name);
            title(gca,titlename);
    end
end

% plot instantaneous VG penetration
function plot_vg_penetration(~,~)
    GENVALUE_VAL=evalin('base','DEFAULT_DATA.GENVALUE.val');
    GEN_VAL=evalin('base','GEN_VAL');
    ACE=evalin('base','ACE');
    ACTUAL_VG_FIELD=evalin('base','ACTUAL_VG_FIELD');
    ACTUAL_VG_FULL=evalin('base','ACTUAL_VG_FULL');
    ACTUAL_LOAD_FULL=evalin('base','ACTUAL_LOAD_FULL');
    daystosimulate=evalin('base','daystosimulate');
    gen_type=evalin('base','gen_type'); 
    wind_gen_type_index=evalin('base','wind_gen_type_index'); 
    PV_gen_type_index=evalin('base','PV_gen_type_index'); 
    ACTUAL_GENERATION=evalin('base','ACTUAL_GENERATION');
    gentypes=GENVALUE_VAL(:,gen_type);
    windidx=gentypes==wind_gen_type_index;
    solaridx=gentypes==PV_gen_type_index;
    vgidx=windidx+solaridx;
    vg_names=GEN_VAL(find(vgidx));
    vgidx=find(vgidx);
    actual_vg_idx=zeros(size(vg_names));
    for i=1:size(actual_vg_idx,1)
        actual_vg_idx(i)=find(strcmp(vg_names{i},ACTUAL_VG_FIELD));
    end
    total_vg_input=sum(ACTUAL_VG_FULL(:,actual_vg_idx),2);
    total_vg_output=sum(ACTUAL_GENERATION(:,vgidx+1),2);
    figure;plot(ACE(:,1),(total_vg_input./ACTUAL_LOAD_FULL(:,2)).*100,'blue');
    % hold on
    % plot(ACE(:,1),(total_vg_output./ACTUAL_LOAD_FULL(:,2)).*100,'red');
    axis([0 daystosimulate*24 ylim]);
    xlabel('Time [hr]');
    ylabel('Penetration Level [%]');
    name=evalin('base','outputname');
    titlename=sprintf('Instantaneous VG Penetration: %s',name);
    title(titlename);
end

% plot generation vs. load
function plot_genvload_callback(~,~)
    ACTUAL_GENERATION=evalin('base','ACTUAL_GENERATION');
    ACTUAL_PUMP=evalin('base','ACTUAL_PUMP');
    ngen=evalin('base','ngen');
    nESR=evalin('base','nESR');
    storage_to_gen_index=evalin('base','storage_to_gen_index');
    ACTUAL_LOAD_FULL=evalin('base','ACTUAL_LOAD_FULL');
    AGC_interval_index=evalin('base','AGC_interval_index');
    storelosses=evalin('base','storelosses');
    name=evalin('base','outputname');
    sumgen = sum(ACTUAL_GENERATION(:,2:ngen+1)')'-sum(ACTUAL_PUMP(:,2:nESR+1)')';
    figure;plot(ACTUAL_GENERATION(:,1),sumgen);
    hold('on')
    line(ACTUAL_GENERATION(:,1),ACTUAL_LOAD_FULL(1:AGC_interval_index-1,2)+storelosses,'color','red');
    titlename=sprintf('Generation and Load: %s',name);
    legend('Total Generation','Total Load');
    title(titlename);
    xlabel('Time [hr]');
    ylabel('Magnitude [MW]');
end

% plot da vg vs actual vg
function Compare_Across_Schedule_Process_callback(~,~)
    sched_figure = figure('Visible','on','name','Schedule Comparison','NumberTitle','off','units','pixels','position',[500 500 600 150],'color','white');
    uicontrol('parent',sched_figure,'style','text','string','Schedule Data Type','units','normalized','position',[.02 .43 .18 .2],'BackgroundColor',get(sched_figure,'color'));
    Sched_Data_Type=uicontrol('parent',sched_figure','style','popupmenu','units','normalized','position',[.2 .45 .2 .2],'string','1 - VG |2 - Load|3 - Net Load|4 - Variable Capacity Resource|5 - Conventional Gen','backgroundcolor','white');
    uicontrol('parent',sched_figure,'style','text','string','Schedule Process','units','normalized','position',[.45 .65 .2 .2],'BackgroundColor',get(sched_figure,'color'));
    Sched_Process1=uicontrol('parent',sched_figure','style','popupmenu','units','normalized','position',[.7 .65 .2 .2],'string','1 - DASCUC |2 - RTSCUC|3 - RTSCED|4 - ACTUAL','backgroundcolor','white');
    uicontrol('parent',sched_figure,'style','text','string','Compared With','units','normalized','position',[.45 .43 .2 .2],'BackgroundColor',get(sched_figure,'color'));
    uicontrol('parent',sched_figure,'style','text','string','Schedule Process','units','normalized','position',[.45 .25 .2 .2],'BackgroundColor',get(sched_figure,'color'));
    Sched_Process2=uicontrol('parent',sched_figure','style','popupmenu','units','normalized','position',[.7 .25 .2 .2],'string','1 - DASCUC |2 - RTSCUC|3 - RTSCED|4 - ACTUAL','backgroundcolor','white');
    uicontrol('Parent',sched_figure,'Style','pushbutton','String','COMPARE','units','normalized','Position', [.35 .05 .15 .15],'Callback',{@sched_proc_comparison});
    assignin('base','Sched_Data_Type',Sched_Data_Type);
    assignin('base','Sched_Process1',Sched_Process1);
    assignin('base','Sched_Process2',Sched_Process2);
end
    
    
function sched_proc_comparison(~,~)
    Sched_Data_Type = evalin('base','Sched_Data_Type');
    Sched_Process1 = evalin('base','Sched_Process1');
    Sched_Process2 = evalin('base','Sched_Process2');
    schd_proc_cmbn = [Sched_Data_Type.Value;Sched_Process1.Value;Sched_Process2.Value];
    close(gcf);
    for k=1:2
        switch schd_proc_cmbn(1,1)
            case 1
                COMPARE_TITLE = 'Variable Generation Comparison (No Curtailments)';
                GENVALUE_tmp = evalin('base','GENVALUE');
                gen_type=evalin('base','gen_type');
                wind_gen_type_index=evalin('base','wind_gen_type_index');
                PV_gen_type_index=evalin('base','PV_gen_type_index');
                nvg = evalin('base','nvg');
                tmp_vg_idx = [find(GENVALUE_tmp.val(:,gen_type)==wind_gen_type_index);find(GENVALUE_tmp.val(:,gen_type)==PV_gen_type_index)];
                Names = GENVALUE_tmp.uels{1,1};
                tmp_vg_names=Names(tmp_vg_idx);
                switch schd_proc_cmbn(k+1,1)
                    case 1 
                        tmp=evalin('base','DAC_VG_FULL');
                        tmp_sched_names = evalin('base','DAC_VG_FIELD');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp(:,2) zeros(size(tmp,1),1)];
                        for z=1:nvg
                            w=3;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    SCHED_COMPARE.(sprintf('part_%d',k))(:,2)=SCHED_COMPARE.(sprintf('part_%d',k))(:,2) + tmp(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_NAME.(sprintf('part_%d',k))='DASCUC';
                    case 2
                        tmp=evalin('base','RTC_VG_FULL');
                        HRTC=evalin('base','HRTC');
                        tmp_sched_names = evalin('base','RTC_VG_FIELD');
                        tmp_new=[24.*tmp(:,2) zeros(size(tmp,1),1)];
                        for z=1:nvg
                            w=3;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    tmp_new(:,2)=tmp_new(:,2) + tmp(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp_new(1:HRTC:size(tmp_new,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCUC';
                    case 3
                        tmp=evalin('base','RTD_VG_FULL');
                        HRTD=evalin('base','HRTD');
                        tmp_sched_names = evalin('base','RTD_VG_FIELD');
                        tmp_new=[24.*tmp(:,2) zeros(size(tmp,1),1)];
                        for z=1:nvg
                            w=3;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    tmp_new(:,2)=tmp_new(:,2) + tmp(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp_new(1:HRTD:size(tmp_new,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCED';
                    case 4
                        tmp = evalin('base','ACTUAL_VG_FULL');
                        tmp_sched_names = evalin('base','ACTUAL_VG_FIELD');
                        tmp_new=[24.*tmp(:,1) zeros(size(tmp,1),1)];
                        for z=1:nvg
                            w=2;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    tmp_new(:,2)=tmp_new(:,2) + tmp(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_COMPARE.(sprintf('part_%d',k))=tmp_new;
                        SCHED_NAME.(sprintf('part_%d',k))='ACTUAL';
                end;
            case 2
                COMPARE_TITLE = 'Load Comparison';
                switch schd_proc_cmbn(k+1,1)
                    case 1 
                        tmp=evalin('base','DAC_LOAD_FULL');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp(:,2) tmp(:,3)];
                        SCHED_NAME.(sprintf('part_%d',k))='DASCUC';
                    case 2
                        tmp=evalin('base','RTC_LOAD_FULL');
                        HRTC=evalin('base','HRTC');
                        tmp = [24.*tmp(:,2) tmp(:,3)];
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:HRTC:size(tmp,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCUC';
                    case 3
                        tmp=evalin('base','RTD_LOAD_FULL');
                        HRTD=evalin('base','HRTD');
                        tmp = [24.*tmp(:,2) tmp(:,3:end)];
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:HRTD:size(tmp,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCED';
                    case 4
                        tmp = evalin('base','ACTUAL_LOAD_FULL');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp(:,1) tmp(:,2)];
                        SCHED_NAME.(sprintf('part_%d',k))='ACTUAL';
                end;
            case 3
                COMPARE_TITLE = 'Net Load Comparison (No curtailments)';
                GENVALUE_tmp = evalin('base','GENVALUE');
                gen_type=evalin('base','gen_type');
                wind_gen_type_index=evalin('base','wind_gen_type_index');
                PV_gen_type_index=evalin('base','PV_gen_type_index');
                nvg = evalin('base','nvg');
                tmp_vg_idx = [find(GENVALUE_tmp.val(:,gen_type)==wind_gen_type_index);find(GENVALUE_tmp.val(:,gen_type)==PV_gen_type_index)];
                Names = GENVALUE_tmp.uels{1,1};
                tmp_vg_names=Names(tmp_vg_idx);
                switch schd_proc_cmbn(k+1,1)
                    case 1 
                        tmp1=evalin('base','DAC_LOAD_FULL');
                        tmp2=evalin('base','DAC_VG_FULL');
                        tmp_sched_names = evalin('base','DAC_VG_FIELD');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp1(:,2) tmp1(:,3)];
                        for z=1:nvg
                            w=3;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    SCHED_COMPARE.(sprintf('part_%d',k))(:,2)=SCHED_COMPARE.(sprintf('part_%d',k))(:,2) - tmp2(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_NAME.(sprintf('part_%d',k))='DASCUC';
                    case 2
                        tmp1=evalin('base','RTC_LOAD_FULL');
                        tmp2=evalin('base','RTC_VG_FULL');
                        tmp_sched_names = evalin('base','RTC_VG_FIELD');
                        HRTC=evalin('base','HRTC');
                        tmp = [24.*tmp1(:,2) tmp1(:,3)];
                        for z=1:nvg
                            w=3;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    tmp(:,2)=tmp(:,2) - tmp2(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:HRTC:size(tmp,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCUC';
                    case 3
                        tmp1=evalin('base','RTD_LOAD_FULL');
                        tmp2=evalin('base','RTD_VG_FULL');
                        HRTD=evalin('base','HRTD');
                        tmp_sched_names = evalin('base','RTD_VG_FIELD');
                        tmp = [24.*tmp1(:,2) tmp1(:,3)];
                        for z=1:nvg
                            w=3;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    tmp(:,2)=tmp(:,2) - tmp2(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:HRTD:size(tmp,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCED';
                    case 4
                        tmp1 = evalin('base','ACTUAL_LOAD_FULL');
                        tmp2 = evalin('base','ACTUAL_VG_FULL');
                        tmp_sched_names = evalin('base','ACTUAL_VG_FIELD');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp1(:,1) tmp1(:,2)];
                        for z=1:nvg
                            w=2;
                            while w<=size(tmp_sched_names,2)
                                if strcmp(tmp_vg_names(z),tmp_sched_names(w))
                                    SCHED_COMPARE.(sprintf('part_%d',k))(:,2)=SCHED_COMPARE.(sprintf('part_%d',k))(:,2) - tmp2(:,w);
                                    w=size(tmp_sched_names,2);
                                end;
                                w=w+1;
                            end;
                        end;
                        SCHED_NAME.(sprintf('part_%d',k))='ACTUAL';
                end;
            case 4
                COMPARE_TITLE = 'Variable Capacity Resource Comparison (No Curtailments)';
                switch schd_proc_cmbn(k+1,1)
                    case 1 
                        tmp=evalin('base','DAC_VG_FULL');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp(:,2) sum(tmp(:,3:end)')'];
                        SCHED_NAME.(sprintf('part_%d',k))='DASCUC';
                    case 2
                        tmp=evalin('base','RTC_VG_FULL');
                        HRTC=evalin('base','HRTC');
                        tmp = [24.*tmp(:,2) sum(tmp(:,3:end)')'];
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:HRTC:size(tmp,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCUC';
                    case 3
                        tmp=evalin('base','RTD_VG_FULL');
                        HRTD=evalin('base','HRTD');
                        tmp = [24.*tmp(:,2) sum(tmp(:,3:end)')'];
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:HRTD:size(tmp,1),:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCED';
                    case 4
                        tmp = evalin('base','ACTUAL_VG_FULL');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[24.*tmp(:,1) sum(tmp(:,2:end)')'];
                        SCHED_NAME.(sprintf('part_%d',k))='ACTUAL';
                end;
             case 5
                COMPARE_TITLE = 'Conventional Gen Comparison';
                GENVALUE_tmp = evalin('base','GENVALUE');
                gen_type=evalin('base','gen_type');
                tmp_convgen_idx = [find(GENVALUE_tmp.val(:,gen_type)==1);find(GENVALUE_tmp.val(:,gen_type)==2);find(GENVALUE_tmp.val(:,gen_type)==3);find(GENVALUE_tmp.val(:,gen_type)==4);find(GENVALUE_tmp.val(:,gen_type)==5)];
                switch schd_proc_cmbn(k+1,1)
                    case 1 
                        tmp=evalin('base','DASCUCSCHEDULE');
                        SCHED_COMPARE.(sprintf('part_%d',k))=[tmp(:,1) sum(tmp(:,tmp_convgen_idx+1),2)];
                        SCHED_NAME.(sprintf('part_%d',k))='DASCUC';
                    case 2
                        tmp=evalin('base','RTSCUCBINDINGSCHEDULE');
                        RTSCUC_binding_interval_index=evalin('base','RTSCUC_binding_interval_index');
                        tmp = [tmp(:,1) sum(tmp(:,tmp_convgen_idx+1),2)];
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:RTSCUC_binding_interval_index-1,:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCUC';
                    case 3
                        tmp=evalin('base','RTSCEDBINDINGSCHEDULE');
                        RTSCED_binding_interval_index=evalin('base','RTSCED_binding_interval_index');
                        tmp = [tmp(:,1) sum(tmp(:,tmp_convgen_idx+1),2)];
                        SCHED_COMPARE.(sprintf('part_%d',k)) = tmp(1:RTSCED_binding_interval_index-1,:);
                        SCHED_NAME.(sprintf('part_%d',k))='RTSCED';
                    case 4
                        tmp = evalin('base','ACTUAL_GENERATION');
                        AGC_interval_index=evalin('base','AGC_interval_index');
                        tmp=[tmp(:,1) sum(tmp(:,tmp_convgen_idx+1),2)];
                        SCHED_COMPARE.(sprintf('part_%d',k))=tmp(1:AGC_interval_index-1,:);
                        SCHED_NAME.(sprintf('part_%d',k))='ACTUAL';
                end;
       end;
    end;
    figure;
    title(COMPARE_TITLE);
    line(SCHED_COMPARE.part_1(:,1),SCHED_COMPARE.part_1(:,2),'color','k');
    xlabel('Time [hr]');
    ylabel('Power [MW]');
    ax1=gca;
    set(ax1,'xcolor','k','ycolor','k')
    ax2=axes('Position',get(ax1,'Position'),'xaxislocation','top','yaxislocation','right','color','none','xcolor','r','ycolor','r','visible','off');
    line(SCHED_COMPARE.part_2(:,1).*24,SCHED_COMPARE.part_2(:,2),'color','r','parent',ax2);
    linkaxes([ax1 ax2],'xy');
    text(0.3,0.95,SCHED_NAME.part_1,'units','normalized','color','k');
    text(0.80,0.95,SCHED_NAME.part_2,'units','normalized','color','r');
end

% plot ace vs percentage of time
function plot_aceDist(~,~)
    caseValues=get(listOfCases, 'Value');
    caseNames=get(listOfCases, 'String');
    selectedNames=caseNames(caseValues);
    colors={'blue';'red';'black';'green';'magenta';'cyan'};
    for i=1:size(selectedNames,1)
        x.(sprintf('case%d',i))=eval(sprintf('load(PathNames{caseValues(%d)},''ACE'');',i));
        x.(sprintf('L10_%d',i))=eval(sprintf('load(PathNames{caseValues(%d)},''L10'');',i));
    end
    for i=1:size(selectedNames,1)
        x.(sprintf('data%d',i))=x.(sprintf('case%d',i)).ACE(:,2);
    end
    maxACE=zeros(size(selectedNames,1),1);
    minACE=zeros(size(selectedNames,1),1);
    for i=1:size(selectedNames,1)
        maxACE(i)=max(x.(sprintf('data%d',i)));
        minACE(i)=min(x.(sprintf('data%d',i)));
    end
    ACEmax=ceil(max(maxACE)/100)*100;
    ACEmin=floor(min(minACE)/100)*100;
    for i=1:size(selectedNames,1)
        [temp1,temp2]=hist(x.(sprintf('data%d',i)),(ACEmin:(ACEmax+abs(ACEmin))/((ACEmax+abs(ACEmin))*2):ACEmax));
        x.(sprintf('a%d',i))=temp1;
        x.(sprintf('b%d',i))=temp2;
    end
    for i=1:size(selectedNames,1)
        x.(sprintf('a%d',i))=x.(sprintf('a%d',i))/sum(x.(sprintf('a%d',i)));
    end
    for i=1:size(selectedNames,1)
        z=x.(sprintf('L10_%d',i));
        x.(sprintf('X1_%d',i))=[z.L10 z.L10];
        x.(sprintf('X2_%d',i))=-[z.L10 z.L10];
    end       
    figure;
    for i=1:size(selectedNames,1)
        coloridx=mod(i,size(colors,1));
        if coloridx==0;coloridx=size(colors,1);end;
        plot(x.(sprintf('b%d',i)),x.(sprintf('a%d',i)),colors{coloridx});
        hold on;
    end
    legend(selectedNames,'interpreter','none');
    Y=get(gca,'ylim');
    hold on
    for i=1:size(selectedNames,1)
        plot(x.(sprintf('X1_%d',i)),Y,'red');
        plot(x.(sprintf('X2_%d',i)),Y,'red');
        text(-x.(sprintf('X1_%d',i))(1)+1,0.75*Y(2),'- L10','verticalalignment','top','horizontalalignment','left','color','red')
        text(x.(sprintf('X1_%d',i))(1)-1,0.75*Y(2),' L10','verticalalignment','top','horizontalalignment','right','color','red')
        hold on;
    end
    xlabel('ACE [MW]');
    ylabel('Percentage of Intervals');
    title('Comparison of ACE Distributions');  
    axis([-x.(sprintf('X1_%d',i))(1)*1.75 x.(sprintf('X1_%d',i))(1)*1.75 ylim]);
end

% plot total generation by gen type
function plot_gentotals(~,~)
    b1=evalin('base','(sum(ACTUAL_GENERATION(:,2:end)).*t_AGC./60./60)'';');
    c1=evalin('base','GENVALUE.val(:,8);');
    name=evalin('base','outputname');
    temptotal=[];
    x=unique(c1);
    for i=1:size(x,1)
        tempsum=0;
        for j=1:size(b1,1)
            if c1(j) == x(i)
                tempsum=tempsum+b1(j);
            end
        end
        temptotal=[temptotal;tempsum,x(i)];
    end
    figure;bar(temptotal(:,2),temptotal(:,1));
    text(temptotal(:,2),temptotal(:,1),num2str(temptotal(:,1),'%0.f'),'HorizontalAlignment','center','VerticalAlignment','bottom');
    xlabel('Gen Type');
    ylabel('Output [MWh]');
    titlename=sprintf('Cumulative Generator Outputs by Type: %s',name);
    title(titlename);
end

% plot da load vs actual load
function plot_daloadVactual(~,~)
    x=evalin('base','ACTUAL_GENERATION');
    y=evalin('base','ACTUAL_LOAD_FULL');
    z1=evalin('base','DASCUCSCHEDULE');
    z2=evalin('base','DAC_LOAD_FULL');
    name=evalin('base','outputname');
    figure;plot(x(:,1),y(:,2));
    hold on
    plot(z1(:,1),z2(1:size(z1,1),3),'red');
    legend('Actual','DA');
    xlabel('Time [hr]');
    ylabel('Load [MW]');
    titlename=sprintf('DA Load Vs Actual Load: %s',name);
    title(titlename);
end

% plot generation stack
function plot_genstack(~,~)
    GENVALUE_VAL=evalin('base','DEFAULT_DATA.GENVALUE.val');
    gen_type=evalin('base','gen_type'); 
    ACTUAL_GENERATION=evalin('base','ACTUAL_GENERATION');
    t_AGC=evalin('base','t_AGC');
    RTD_LOAD_FULL=evalin('base','RTD_LOAD_FULL');
    IRTD=evalin('base','IRTD');
    total=zeros(size(ACTUAL_GENERATION,1),16);
    for t=1:16
        temp=[];temp2=[];
        for i=1:size(GENVALUE_VAL,1)
            if GENVALUE_VAL(i,gen_type) == t
                temp = [temp,ACTUAL_GENERATION(:,i+1)];
            end
        end
        temp2=sum(temp,2);
        if isempty(temp2)
        else
            total(:,t)=temp2;
        end
    end
    temp=[total(1,:); total((1:size(ACTUAL_GENERATION,1)/(60/t_AGC*IRTD))*(60/t_AGC*IRTD),:)];
    temp2=[temp(:,5),temp(:,1),temp(:,3),temp(:,2),temp(:,4),temp(:,6:end)];
    xval=unique(RTD_LOAD_FULL(:,1))*24;
    figure;handles=area(xval,temp2);
    set(handles(2),'facecolor','blue')
    set(handles(4),'facecolor','red')
    set(handles(7),'facecolor','green')
    set(handles(10),'facecolor','yellow')
    set(handles(3),'facecolor',[0.5 0 1])
    set(handles(5),'facecolor',[43/255 159/255 1])
    set(handles(1),'facecolor','black')
    set(handles(6),'facecolor',[0.5 0.5 0.5])
    set(handles(8),'facecolor',[1 109/255 23/255])
    set(handles(9),'facecolor',[1 109/255 23/255])
    set(handles(11),'facecolor',[1 109/255 23/255])
    set(handles(12),'facecolor',[0.5 0.5 0.5])
    set(handles(13),'facecolor',[1 0 1])
    set(handles(14),'facecolor',[1 0 1])
    set(handles(15),'facecolor',[1 0 1])
    set(handles(16),'facecolor',[0 1 1])
    hlegend=legend('Nuclear','Steam','CC','CT','Hydro','Pumped Storage','Wind','CAES','LESR','PV','CSP','Var Pump PSH','Virtual','Intertie','Outage','NVCR');
    set(hlegend,'orientation','horizontal','location','north','edgecolor',[1 1 1]);
    name=evalin('base','outputname');
    titlename=sprintf('Generation Stack by Generator Type: %s',name);
    title(titlename);
    xlabel('Time [hr]');
    ylabel('Output [MW]');
end

% plot number of units committed per RTC interval
function plot_statuses(~,~)
    Z=evalin('base','daystosimulate');
    X=evalin('base','RTSCUCBINDINGCOMMITMENT(:,1)');
    W=evalin('base','IRTC');
    GENVALUE=evalin('base','GENVALUE');
    y=evalin('base','STATUS');
    
    for gt=1:16
        masterind.(sprintf('indicies%d',gt))=find(GENVALUE.val(:,8)==gt);
    end
    
    Y1=zeros(size(y,1),1);Y2=Y1;Y3=Y1;Y4=Y1;Y5=Y1;Y6=Y1;Y7=Y1;Y8=Y1;Y9=Y1;Y10=Y1;Y11=Y1;Y12=Y1;Y13=Y1;Y14=Y1;Y15=Y1;Y16=Y1;

    for gt=1:16
        for i=1:size(y,1)
            sum2 = 0;
            for k=1:size(masterind.(sprintf('indicies%d',gt)),1)
                sum2=sum2+y(i,1+masterind.(sprintf('indicies%d',gt))(k,1));
            end
            eval(sprintf('Y%d(i)=sum2;',gt));
        end
    end

    for gt=1:16
        eval(sprintf('Y%d=Y%d(1:60*24*Z/W+1,1);',gt,gt));
    end
    temp=[Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8,Y9,Y10,Y11,Y12,Y13,Y14,Y15,Y16];
    X=X(1:60*24*Z/W+1,1);
    figure;plot(X,Y1,X,Y2,X,Y3,X,Y4,X,Y5,X,Y6,X,Y7,X,Y8,X,Y9,X,Y10,X,Y11,X,Y12,X,Y13,X,Y14,X,Y15,X,Y16);
    axis([0 max(max(X,1)) 0 max(max(max(temp,1)))+1]);
    name=evalin('base','outputname');
    titlename=sprintf('Number of Units Committed: %s',name);
    title(titlename);
    xlabel('Time [hr]');
    ylabel('Number of Units');
    legend('STEAM','CT','CC','HYDRO','NUCLEAR','PSH','WIND','CAES','LESR','PV','CSP','VAR PSH','VIRTUAL','TIE','OUTAGE','VCG');
    text(0.65,0.92,sprintf('Average = %0.1f Units online',sum(Y1+Y2+Y3+Y4+Y5+Y6+Y7+Y8+Y9+Y10+Y11+Y12+Y13+Y14+Y15+Y16)/size(X,1)),'units','normalized')
end

% plot VG curtailment
function plot_vgcurtailment(~,~)
    x=evalin('base','ACTUAL_GENERATION');
    y=evalin('base','ACTUAL_VG_FULL');
    z=evalin('base','GENVALUE');
    w=evalin('base','t_AGC');
    q=evalin('base','ACTUAL_VG_FIELD');
    gen_type=evalin('base','gen_type');
    wind_gen_type_index=evalin('base','wind_gen_type_index');
    PV_gen_type_index=evalin('base','PV_gen_type_index');
    types=z.val(:,gen_type);indices=[];names=[];
    for i=1:size(types,1)
        if types(i) == wind_gen_type_index || types(i) == PV_gen_type_index 
            indices=[indices;i];
            names=[names;z.uels{1,1}(1,i)];
        end
    end
    vgtemp=[];actualtemp=[];
    for i=1:size(indices,1)
        for vg=1:size(q,2)
            if strcmp(names{i},q{vg})
                index=vg;
            end
        end
        actualtemp=[actualtemp y(:,index)];
        vgtemp=[vgtemp x(:,indices(i)+1)];
    end
    vgcurtailment=max(zeros(size(y,1),size(indices,1)),actualtemp-vgtemp);
    figure;plot(x(:,1),vgcurtailment);
    assignin('base','actual_vg_curtailment',vgcurtailment);
    hlegend=legend(names);
    set(hlegend,'visible','off');
    xlabel('Time [hr]');
    ylabel('Curtailment [MW]');
    name=evalin('base','outputname');
    titlename=sprintf('VG Curtailment: %s',name);
    title(titlename);
    text(0.65,0.92,sprintf('Total = %d MWh',round(sum(sum(vgcurtailment))*w/60/60)),'units','normalized')
end

% plot RT Price and ACE in one figure
function plot_rtpriceNace(~,~)
    figure;
    daystosimulate=evalin('base','daystosimulate');
    h1=subplot(2,1,1);
    x=evalin('base','RTSCEDBINDINGLMP');
    y=evalin('base','nbus');
    w=evalin('base','BUS.uels');
    name=evalin('base','outputname');
    plot(x(:,1),x(:,2:y+1));
    titlename=sprintf('Real-Time Prices: %s',name);
    title(titlename);
    hlegend=legend(w','interpreter','none');
    set(hlegend,'visible','off');
    axis([0 24*daystosimulate ylim]);
    ylabel('LMP [$/MWh]');
    xlabel('Time [hr]');
    h2=subplot(2,1,2);
    x=evalin('base','ACE');
    y=evalin('base','ACE_time_index');
    w=evalin('base','raw_ACE_index');
    name=evalin('base','outputname');
    plot(x(:,y),x(:,w));
    titlename=sprintf('ACE levels: %s',name);
    title(titlename);
    xlabel('Time [hr]');
    ylabel('ACE [MW]');
    axis([0 24*daystosimulate ylim]);

    linkaxes([h1 h2],'x'); 
end

% plot the number of unit startups by gen type
function plot_numsus(~,~)
    ACTUAL_GENERATION=evalin('base','RTSCEDBINDINGSCHEDULE');
    ngen=evalin('base','ngen');
    su=zeros(size(ACTUAL_GENERATION,1),ngen);
    GENVALUE=evalin('base','GENVALUE');
    for i=2:size(ACTUAL_GENERATION,1)
        for j=1:ngen
               if ACTUAL_GENERATION(i,j+1) > 0 && ACTUAL_GENERATION(i-1,j+1) == 0
                    su(i,j)=1;
               end
        end
    end

    ind1=GENVALUE.val(:,8)==1;
    ind2=GENVALUE.val(:,8)==2;
    ind3=GENVALUE.val(:,8)==3;
    ind4=GENVALUE.val(:,8)==4;
    ind5=GENVALUE.val(:,8)==5;
    ind6=GENVALUE.val(:,8)==6;
    ind7=GENVALUE.val(:,8)==7;
    ind8=GENVALUE.val(:,8)==8;
    ind9=GENVALUE.val(:,8)==9;
    ind10=GENVALUE.val(:,8)==10;
    ind11=GENVALUE.val(:,8)==11;
    ind12=GENVALUE.val(:,8)==12;
    ind13=GENVALUE.val(:,8)==13;
    ind14=GENVALUE.val(:,8)==14;
    ind15=GENVALUE.val(:,8)==15;
    ind16=GENVALUE.val(:,8)==16;

    SU1=su.*repmat(ind1',size(ACTUAL_GENERATION,1),1);
    SU2=su.*repmat(ind2',size(ACTUAL_GENERATION,1),1);
    SU3=su.*repmat(ind3',size(ACTUAL_GENERATION,1),1);
    SU4=su.*repmat(ind4',size(ACTUAL_GENERATION,1),1);
    SU5=su.*repmat(ind5',size(ACTUAL_GENERATION,1),1);
    SU6=su.*repmat(ind6',size(ACTUAL_GENERATION,1),1);
    SU7=su.*repmat(ind7',size(ACTUAL_GENERATION,1),1);
    SU8=su.*repmat(ind8',size(ACTUAL_GENERATION,1),1);
    SU9=su.*repmat(ind9',size(ACTUAL_GENERATION,1),1);
    SU10=su.*repmat(ind10',size(ACTUAL_GENERATION,1),1);
    SU11=su.*repmat(ind11',size(ACTUAL_GENERATION,1),1);
    SU12=su.*repmat(ind12',size(ACTUAL_GENERATION,1),1);
    SU13=su.*repmat(ind13',size(ACTUAL_GENERATION,1),1);
    SU14=su.*repmat(ind14',size(ACTUAL_GENERATION,1),1);
    SU15=su.*repmat(ind15',size(ACTUAL_GENERATION,1),1);
    SU16=su.*repmat(ind16',size(ACTUAL_GENERATION,1),1);

    SU1_2=sum(SU1,2);
    SU2_2=sum(SU2,2);
    SU3_2=sum(SU3,2);
    SU4_2=sum(SU4,2);
    SU5_2=sum(SU5,2);
    SU6_2=sum(SU6,2);
    SU7_2=sum(SU7,2);
    SU8_2=sum(SU8,2);
    SU9_2=sum(SU9,2);
    SU10_2=sum(SU10,2);
    SU11_2=sum(SU11,2);
    SU12_2=sum(SU12,2);
    SU13_2=sum(SU13,2);
    SU14_2=sum(SU14,2);
    SU15_2=sum(SU15,2);
    SU16_2=sum(SU16,2);

    X=ACTUAL_GENERATION(:,1);
    figure;plot(X,SU1_2,X,SU2_2,X,SU3_2,X,SU4_2,X,SU5_2,X,SU6_2,X,SU7_2,X,SU8_2,X,SU9_2,X,SU10_2,X,SU11_2,X,SU12_2,X,SU13_2,X,SU14_2,X,SU15_2,X,SU16_2);
    name=evalin('base','outputname');
    titlename=sprintf('Number of Start Ups: %s',name);
    title(titlename);
    xlabel('Time [hr]');
    ylabel('Number of Start Ups');
    legend('STEAM','CT','CC','HYDRO','NUCLEAR','PSH','WIND','CAES','LESR','PV','CSP','VAR PSH','VIRTUAL','TIE','OUTAGE','VCG');
    GENS={'STEAM';'CT';'CC';'HYDRO';'NUCLEAR';'PSH';'WIND';'CAES';'LESR';'PV';'CSP';'VAR PSH';'VIRTUAL';'TIE';'OUTAGE';'VCG'};
    totals=[sum(SU1_2),sum(SU2_2),sum(SU3_2),sum(SU4_2),sum(SU5_2),sum(SU6_2),sum(SU7_2),sum(SU8_2),sum(SU9_2),sum(SU10_2),sum(SU11_2),sum(SU12_2),sum(SU13_2),sum(SU14_2),sum(SU15_2),sum(SU16_2)];
    dispcount=1;
    for i=1:16
        if totals(1,i) ~= 0
            text(0.05,0.92-((dispcount-1)*0.04),sprintf('%s SUs = %d',cell2mat(GENS(i,1)),totals(1,i)),'units','normalized');
            dispcount=dispcount+1;
        end
    end
end

% plot ramp utilization
function plot_ramputilization(~,~)
    RTSCEDBINDINGSCHEDULE=evalin('base','RTSCEDBINDINGSCHEDULE');
    GENVALUE=evalin('base','GENVALUE');
    RTDRAMP=zeros(size(RTSCEDBINDINGSCHEDULE));
    RTDRAMPCAP=zeros(size(RTSCEDBINDINGSCHEDULE));
    TEMP=repmat(GENVALUE.val(:,8)',size(RTSCEDBINDINGSCHEDULE,1),1);
    RTDGENTYPES=[zeros(size(RTSCEDBINDINGSCHEDULE,1),1),TEMP];
    for t=1:size(RTSCEDBINDINGSCHEDULE,1)-1
        for i=1:size(RTSCEDBINDINGSCHEDULE,2)-1
            if RTSCEDBINDINGSCHEDULE(t,i+1) >= GENVALUE.val(i,7) && abs(RTSCEDBINDINGSCHEDULE(t+1,i+1)) >= GENVALUE.val(i,7)
                RTDRAMP(t,i+1)=abs(RTSCEDBINDINGSCHEDULE(t+1,i+1)-RTSCEDBINDINGSCHEDULE(t,i+1));
                if RTSCEDBINDINGSCHEDULE(t+1,i+1)-RTSCEDBINDINGSCHEDULE(t,i+1) > 0
                    RTDRAMPCAP(t,i+1)=min(GENVALUE.val(i,6)*5,GENVALUE.val(i,1)-RTSCEDBINDINGSCHEDULE(t,i+1));
                elseif RTSCEDBINDINGSCHEDULE(t+1,i+1)-RTSCEDBINDINGSCHEDULE(t,i+1) < 0
                    RTDRAMPCAP(t,i+1)=min(GENVALUE.val(i,6)*5,RTSCEDBINDINGSCHEDULE(t,i+1)-GENVALUE.val(i,7));
                else
                    RTDRAMPCAP(t,i+1)=min(GENVALUE.val(i,6)*5,min(RTSCEDBINDINGSCHEDULE(t,i+1)+GENVALUE.val(i,7),GENVALUE.val(i,1)-RTSCEDBINDINGSCHEDULE(t,i+1)));
                end
            end
        end
    end
    RTDRAMP(:,1)=RTSCEDBINDINGSCHEDULE(:,1);
    RTDONLINE=double(RTDRAMPCAP>0);
    ind1=0;ind2=0;ind3=0;ind4=0;ind4=0;ind5=0;ind6=0;ind7=0;ind8=0;ind9=0;ind10=0;ind11=0;ind12=0;ind13=0;ind14=0;ind15=0;ind16=0;
    for gt=1:16
        eval(sprintf('ind%d=find(GENVALUE.val(:,8)==%d);',gt,gt));
    end
    sum_1=zeros(size(RTSCEDBINDINGSCHEDULE,1),16);
    sum_2=zeros(size(RTSCEDBINDINGSCHEDULE,1),16);
    for gt=1:16
        eval(sprintf('sum_1(:,%d)=sum(RTDRAMP(:,ind%d+1),2);',gt,gt));
        eval(sprintf('sum_2(:,%d)=sum(RTDRAMPCAP(:,ind%d+1),2);',gt,gt));
    end
    X=RTSCEDBINDINGSCHEDULE(:,1);
    figure;
%     plot(X,sum_1(:,1),X,sum_1(:,2),X,sum_1(:,3),X,sum_1(:,4),X,sum_1(:,5),X,sum_1(:,6),X,sum_2(:,1),X,sum_2(:,2),X,sum_2(:,3),X,sum_2(:,4),X,sum_2(:,5),X,sum_2(:,6));
%     legend('STEAM RAMP','CT RAMP','CC RAMP','HYDRO RAMP','NUCLEAR RAMP','PSH RAMP','STEAM RAMP CAP','CT RAMP CAP','CC RAMP CAP','HYDRO RAMP CAP','NUCLEAR RAMP CAP','PSH RAMP CAP');
    
%     plot(X,sum(sum_1(:,1:5),2),X,sum(sum_2(:,1:5),2))
    plot(X,sum(sum_2(:,1:5),2)-sum(sum_1(:,1:5),2))
%     legend('Thermal Ramp','Thermal Ramp Cap');
    ytemp=ylim;
    axis([0 (size(RTSCEDBINDINGSCHEDULE,1)-1)/(60/round((RTSCEDBINDINGSCHEDULE(2,1)-RTSCEDBINDINGSCHEDULE(1,1))*60)) ytemp]);
    assignin('base','RampUtil',sum(sum_1(:,1:5),2));
    assignin('base','RampCap',sum(sum_2(:,1:5),2));
    
    xlabel('Time [hr]');
    ylabel('Ramp [MW/5 min]');
    name=evalin('base','outputname');
    titlename=sprintf('Unused Thermal Ramping Capacity: %s',name);
    title(titlename);
end

% plot the actual output vs online capacity by gen type
function plot_onlinecapacity(~,~)
    wb=waitbar(0,'Calculating...');
    ACTUAL_GENERATION=evalin('base','ACTUAL_GENERATION');
    size_AG=size(ACTUAL_GENERATION,1);
    ngen=evalin('base','ngen');
    GENVALUE_VAL=evalin('base','GENVALUE_VAL');
    ramp_rate=evalin('base','ramp_rate');
    gen_type=evalin('base','gen_type');
    wind_gen_type_index=evalin('base','wind_gen_type_index');
    PV_gen_type_index=evalin('base','PV_gen_type_index');
    outage_gen_type_index=evalin('base','outage_gen_type_index');
    min_gen=evalin('base','min_gen');
    su_time=evalin('base','su_time');
    sd_time=evalin('base','sd_time');
    capacity=evalin('base','capacity');
    data=zeros(size(ACTUAL_GENERATION));
    data(:,1)=ACTUAL_GENERATION(:,1);
    for gen=1:ngen
        if GENVALUE_VAL.val(gen,gen_type) ~= wind_gen_type_index && GENVALUE_VAL.val(gen,gen_type) ~= PV_gen_type_index && GENVALUE_VAL.val(gen,gen_type) ~= outage_gen_type_index
            sus=zeros(151200,1);sds=zeros(151200,1);    
            for i=1:size_AG-1
               if  round(ACTUAL_GENERATION(i,gen+1)/.0001)*.0001 == round((GENVALUE_VAL.val(gen,min_gen)-(GENVALUE_VAL.val(gen,min_gen)/GENVALUE_VAL.val(gen,su_time)/3600*4))/.0001)*.0001 && round(ACTUAL_GENERATION(i+1,gen+1)/.0001)*.0001 > round(ACTUAL_GENERATION(i,gen+1)/.0001)*.0001
                    sus(i,1)=1;
               end
               if  round(ACTUAL_GENERATION(i,gen+1)/.0001)*.0001 == round((GENVALUE_VAL.val(gen,min_gen)-(GENVALUE_VAL.val(gen,min_gen)/GENVALUE_VAL.val(gen,sd_time)/3600*4))/.0001)*.0001 && round(ACTUAL_GENERATION(i+1,gen+1)/.0001)*.0001 < round(ACTUAL_GENERATION(i,gen+1)/.0001)*.0001
                    sds(i,1)=1;
               end
            end
            temp2=sus+sds;
            ind=find(temp2);
            whats=ones(size(ind,1),1);
            temp3=find(sus);
            for i=1:size(ind,1)
                for j=1:size(temp3,1)
                    if temp3(j,1) == ind(i,1)
                        whats(i,1)=2; % startups = 2
                    end
                end
            end
            onint=[];
            for i=1:size(ind,1)-1
                if whats(1,1)==1 && i == 1
                    onint=[onint;1 ind(1,1)]; % unit starting off 'on'
                end
                if whats(i,1)-whats(i+1,1)==1
                    onint=[onint;ind(i) ind(i+1,1)-ind(i,1)];
                end
                if whats(size(ind,1),1)==2 && i == size(ind,1)-1
                    onint=[onint;ind(size(ind,1),1) 151200-ind(size(ind,1),1)];
                end
            end

            onoffints=[];
            for i=1:size(onint,1)
                if onint(i,1)==1
                    onoffints(i,1:3)=[onint(i,1) 1 onint(i,2)];
                else
                    onoffints(i,1:3)=[onint(i,1) round(onint(i,2)/2) round(onint(i,2)/2)];
                end
            end
            if size(whats,1)==1 && whats(1,1) == 2
                onint=[ind(1,1) size_AG-ind(1,1) 0];
                onoffints=[ind(1,1) size_AG-ind(1,1)+1 0];
            end


            data(:,gen+1)=ACTUAL_GENERATION(:,gen+1);

            for k=1:size(onoffints,1)
                for o1=1:onoffints(k,2)
                    data(onoffints(k,1)+o1-1,gen+1)=min(GENVALUE_VAL.val(gen,capacity),data(onoffints(k,1),gen+1)+(GENVALUE_VAL.val(gen,ramp_rate)/60*4)*o1);
                end
                for o2=1:onoffints(k,3)
                    data(onoffints(k,1)+onoffints(k,2)+o2-1,gen+1)=max(GENVALUE_VAL.val(gen,min_gen),min(GENVALUE_VAL.val(gen,capacity),(data(onoffints(k,1),gen+1)+(GENVALUE_VAL.val(gen,ramp_rate)/60*4)*o1)-(GENVALUE_VAL.val(gen,ramp_rate)/60*4)*o2));
                end
            end

            onlinecheck=data(:,gen+1)>=GENVALUE_VAL.val(gen,min_gen);
            if sum(onlinecheck) == size_AG
                data(:,gen+1)=GENVALUE_VAL.val(gen,capacity);
            end

        end
        waitbar(gen/ngen,wb);
    end
    close(wb);

    G1indicies=GENVALUE_VAL.val(:,gen_type)==1;
    G2indicies=GENVALUE_VAL.val(:,gen_type)==2;
    G3indicies=GENVALUE_VAL.val(:,gen_type)==3;
    G4indicies=GENVALUE_VAL.val(:,gen_type)==4;
    G5indicies=GENVALUE_VAL.val(:,gen_type)==5;
    G6indicies=GENVALUE_VAL.val(:,gen_type)==6;
    G7indicies=GENVALUE_VAL.val(:,gen_type)==7;
    G8indicies=GENVALUE_VAL.val(:,gen_type)==8;
    G9indicies=GENVALUE_VAL.val(:,gen_type)==9;
    G10indicies=GENVALUE_VAL.val(:,gen_type)==10;
    G11indicies=GENVALUE_VAL.val(:,gen_type)==11;
    G12indicies=GENVALUE_VAL.val(:,gen_type)==12;
    G13indicies=GENVALUE_VAL.val(:,gen_type)==13;
    G14indicies=GENVALUE_VAL.val(:,gen_type)==14;
    G15indicies=GENVALUE_VAL.val(:,gen_type)==15;
    G16indicies=GENVALUE_VAL.val(:,gen_type)==16;
    
    genOutputs=ACTUAL_GENERATION(:,2:end);
    G1outputs=genOutputs.*repmat(G1indicies',size(genOutputs,1),1);
    G2outputs=genOutputs.*repmat(G2indicies',size(genOutputs,1),1);
    G3outputs=genOutputs.*repmat(G3indicies',size(genOutputs,1),1);
    G4outputs=genOutputs.*repmat(G4indicies',size(genOutputs,1),1);
    G5outputs=genOutputs.*repmat(G5indicies',size(genOutputs,1),1);
    G6outputs=genOutputs.*repmat(G6indicies',size(genOutputs,1),1);
    G7outputs=genOutputs.*repmat(G7indicies',size(genOutputs,1),1);
    G8outputs=genOutputs.*repmat(G8indicies',size(genOutputs,1),1);
    G9outputs=genOutputs.*repmat(G9indicies',size(genOutputs,1),1);
    G10outputs=genOutputs.*repmat(G10indicies',size(genOutputs,1),1);
    G11outputs=genOutputs.*repmat(G11indicies',size(genOutputs,1),1);
    G12outputs=genOutputs.*repmat(G12indicies',size(genOutputs,1),1);
    G13outputs=genOutputs.*repmat(G13indicies',size(genOutputs,1),1);
    G14outputs=genOutputs.*repmat(G14indicies',size(genOutputs,1),1);
    G15outputs=genOutputs.*repmat(G15indicies',size(genOutputs,1),1);
    G16outputs=genOutputs.*repmat(G16indicies',size(genOutputs,1),1);
    
    totalG1=sum(G1outputs,2);
    totalG2=sum(G2outputs,2);
    totalG3=sum(G3outputs,2);
    totalG4=sum(G4outputs,2);
    totalG5=sum(G5outputs,2);
    totalG6=sum(G6outputs,2);
    totalG7=sum(G7outputs,2);
    totalG8=sum(G8outputs,2);
    totalG9=sum(G9outputs,2);
    totalG10=sum(G10outputs,2);
    totalG11=sum(G11outputs,2);
    totalG12=sum(G12outputs,2);
    totalG13=sum(G13outputs,2);
    totalG14=sum(G14outputs,2);
    totalG15=sum(G15outputs,2);
    totalG16=sum(G16outputs,2);    

    t1=ACTUAL_GENERATION>0;
%     t3=[0 GENVALUE.val(:,capacity)'];
    tg1=[0 G1indicies'];
    tg2=[0 G2indicies'];
    tg3=[0 G3indicies'];
    tg4=[0 G4indicies'];
    tg5=[0 G5indicies'];
    tg6=[0 G6indicies'];
    tg7=[0 G7indicies'];
    tg8=[0 G8indicies'];
    tg9=[0 G9indicies'];
    tg10=[0 G10indicies'];
    tg11=[0 G11indicies'];
    tg12=[0 G12indicies'];
    tg13=[0 G13indicies'];
    tg14=[0 G14indicies'];
    tg15=[0 G15indicies'];
    tg16=[0 G16indicies'];
    
    max1capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max2capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max3capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max4capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max5capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max6capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max7capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max8capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max9capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max10capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max11capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max12capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max13capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max14capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max15capacity=zeros(size(ACTUAL_GENERATION,1),1);
    max16capacity=zeros(size(ACTUAL_GENERATION,1),1);

    for i=1:size(ACTUAL_GENERATION,1)
        max1capacity(i,1)=sum(data(i,:).*tg1.*t1(i,:));
        max2capacity(i,1)=sum(data(i,:).*tg2.*t1(i,:));
        max3capacity(i,1)=sum(data(i,:).*tg3.*t1(i,:));
        max4capacity(i,1)=sum(data(i,:).*tg4.*t1(i,:));
        max5capacity(i,1)=sum(data(i,:).*tg5.*t1(i,:));
        max6capacity(i,1)=sum(data(i,:).*tg6.*t1(i,:));
        max7capacity(i,1)=sum(data(i,:).*tg7.*t1(i,:));
        max8capacity(i,1)=sum(data(i,:).*tg8.*t1(i,:));
        max9capacity(i,1)=sum(data(i,:).*tg9.*t1(i,:));
        max10capacity(i,1)=sum(data(i,:).*tg10.*t1(i,:));
        max11capacity(i,1)=sum(data(i,:).*tg11.*t1(i,:));
        max12capacity(i,1)=sum(data(i,:).*tg12.*t1(i,:));
        max13capacity(i,1)=sum(data(i,:).*tg13.*t1(i,:));
        max14capacity(i,1)=sum(data(i,:).*tg14.*t1(i,:));
        max15capacity(i,1)=sum(data(i,:).*tg15.*t1(i,:));
        max16capacity(i,1)=sum(data(i,:).*tg16.*t1(i,:));
    end

    X=ACTUAL_GENERATION(:,1);
    figure;plot(X,totalG1,X,max1capacity,X,totalG2,X,max2capacity,X,totalG3,X,max3capacity,X,totalG4,X,max4capacity,X,totalG5,X,max5capacity,X,totalG6,X,max6capacity,X,totalG7,X,max7capacity,X,totalG8,X,max8capacity,X,totalG9,X,max9capacity,X,totalG10,X,max10capacity,X,totalG11,X,max11capacity,X,totalG12,X,max12capacity,X,totalG13,X,max13capacity,X,totalG14,X,max14capacity,X,totalG15,X,max15capacity,X,totalG16,X,max16capacity);
    legend('STEAM','STEAM CAPACITY','CT','CT CAPACITY','CC','CC CAPACITY','HYDRO','HYDRO CAPACITY','NUCLEAR','NUCLEAR CAPACITY','PSH','PSH CAPACITY','WIND','WIND CAPACITY','CAES','CAES CAPACITY','LESR','LESR CAPACITY','PV','PV CAPACITY','CSP','CSP CAPACITY','VAR PSH','VAR PSH CAPACITY','VIRTUAL','VIRTUAL CAPACITY','TIE','TIE CAPACITY','OUTAGE','OUTAGE CAPACITY','VCG','VCG CAPACITY');
    xlabel('Time [hour]');
    ylabel('Output [MW]');
    name=evalin('base','outputname');
    titlename=sprintf('Total Output by Gen Type: %s',name);
    title(titlename);
end

% show case summaries from all listed cases
function show_casesummaries(~,~)
    PathNames=evalin('base','PathNames');
    numcases=size(PathNames,1);
    Cost_Result_Total_all=cell(numcases,1);Revenue_Result_Total_all=cell(numcases,1);Profit_Result_Total_all=cell(numcases,1);adjusted_cost_all=cell(numcases,1);Total_MWH_Absolute_ACE_all=cell(numcases,1);sigma_ACE_all=cell(numcases,1);CPS2_violations_all=cell(numcases,1);CPS2_all=cell(numcases,1);
    Cost_Result_Total=0;Revenue_Result_Total=0;Profit_Result_Total=0;adjusted_cost=0;Total_MWH_Absolute_ACE=0;sigma_ACE=0;CPS2_violations=0;CPS2=0;
    for c=1:numcases
        t=PathNames(c);
        load(char(t(1,1)),'Cost_Result_Total','Revenue_Result_Total','Profit_Result_Total','adjusted_cost','Total_MWH_Absolute_ACE','sigma_ACE','CPS2_violations','CPS2');
        Cost_Result_Total_all(c,1)={convert2currency(Cost_Result_Total)};
        Revenue_Result_Total_all(c,1)={convert2currency(Revenue_Result_Total)};
        Profit_Result_Total_all(c,1)={convert2currency(Profit_Result_Total)};
        adjusted_cost_all(c,1)={convert2currency(adjusted_cost)};
        Total_MWH_Absolute_ACE_all(c,1)={num2str(Total_MWH_Absolute_ACE)};
        sigma_ACE_all(c,1)={num2str(sigma_ACE)};
        CPS2_violations_all(c,1)={num2str(CPS2_violations)};
        CPS2_all(c,1)={num2str(CPS2)};
    end    
    total_data=[Cost_Result_Total_all';adjusted_cost_all';Revenue_Result_Total_all';Profit_Result_Total_all';Total_MWH_Absolute_ACE_all';sigma_ACE_all';CPS2_violations_all';CPS2_all'];
    table_data=cell(9,numcases+1);
    table_data(2:9,1)={'Production Cost';'Adjusted Cost';'Revenue';'Profit';'AACEE';'Sigma ACE';'CPS2 Violations';'CPS2'};
    table_data(2:9,2:end)=total_data;
    casenames=cellstr(get(listOfCases,'string'));
    table_data(1,2:end)=casenames;
    csf=figure('Visible','off','name','Case Summaries','NumberTitle','off','units','pixels','position',[50 50 800 210],'menubar','none');
    movegui(csf,'center');
    set(csf,'Visible','on');
    casesummariestable=uitable('Parent',csf,'units','normalized','position',[.025 .05 .95 .90],'columnwidth','auto','RowName',[],'ColumnName',[]);
    set(casesummariestable,'data',table_data); 
    colwidths=num2cell(max(cellfun(@length,table_data))*5.75);
    set(casesummariestable,'ColumnWidth',colwidths)
end

% add case to list of cases
function addCase_callback(~,~)
    PathNames=evalin('base','PathNames');
    row=evalin('base','row');
    a=size(PathNames,1);
    dname = uigetdir(['OUTPUT',filesep]);
    if dname ~= 0
        [~,r2]=system(sprintf('dir /S /B "%s"  Workspace.mat',dname));
        files=regexp(r2,'\n','split')';
        clear r2
        tempListOfFiles=cell(size(files));
        for i=1:size(files,1)
            foundcheck1=strfind(files{i},dname);
            foundcheck2=strfind(files{i},'Workspace.mat');
            if size(foundcheck1,1) > 0 && size(foundcheck2,1) > 0
                tempListOfFiles{i}=files{i};
            end
        end
        ind=find(~cellfun(@isempty,tempListOfFiles));
        listOfFiles=tempListOfFiles(ind);
        listOfFiles=unique(listOfFiles);     
        PathNames(a+1:a+size(listOfFiles,1),1)=listOfFiles;
        assignin('base','PathNames',PathNames);
        for i=1:size(listOfFiles,1)
            ik2=load(listOfFiles{i},'outputname');
            temp=cellstr(get(listOfCases,'string'));
            temp(row,1)={ik2.outputname};
            row = row + 1;
            assignin('base','row',row);
            set(listOfCases,'string',temp);
        end
    else
        % Cancel button was pressed
    end
end

% list variables from highlighted case
function loadVariables_callback(~,~)
    PathNames=evalin('base','PathNames');
    temp=get(listOfCases,'value');
    assignin('base','temploadname',PathNames{temp});
    evalin('base','load(char(temploadname))')
    name=evalin('base','outputname');
    set(currentCaseName,'String',name);
end

function plot_rtdVSagc(~,~)
    agcind=evalin('base','find(GENVALUE.val(:,agc_qualified));');
    Y1=evalin('base','zeros(size(ACTUAL_GENERATION));');
    Y1(:,1)=evalin('base','ACTUAL_GENERATION(:,1);');
    Y2=evalin('base','ACTUAL_GENERATION;');
    X=evalin('base','RTSCEDBINDINGSCHEDULE;');
    NUMBER_OF_DAYS=evalin('base','daystosimulate;'); % number of consecutive days to consider
    AGC_RESOLUTION=evalin('base','t_AGC;'); % in seconds
    INPUT_RESOLUTION=evalin('base','IRTD;'); % in minutes
    ngen=evalin('base','ngen;');
    wb=waitbar(0,'Calculating...');
    for cc=1:ngen
        raw_load_data=X(:,cc+1);
        number_of_raw_data_points_per_day=60*24/INPUT_RESOLUTION;
        number_of_agc_intervals_per_N_minutes=60/AGC_RESOLUTION*INPUT_RESOLUTION;
        total_number_of_agc_data_points=number_of_raw_data_points_per_day*number_of_agc_intervals_per_N_minutes*NUMBER_OF_DAYS;
        linearized_load_temp=zeros(total_number_of_agc_data_points,1);k=1;
        for i=1:number_of_raw_data_points_per_day*NUMBER_OF_DAYS-1
            agc_load_increment=(raw_load_data(i+1,1)-raw_load_data(i,1))/number_of_agc_intervals_per_N_minutes;
            for j=1:number_of_agc_intervals_per_N_minutes
                linearized_load_temp(k,1)=raw_load_data(i,1)+agc_load_increment*(j-1);
                k=k+1;
            end
        end
        for j=1:number_of_agc_intervals_per_N_minutes
            linearized_load_temp(k,1)=raw_load_data(end,1)+agc_load_increment*(j-1);
            k=k+1;
        end
        Y1(:,cc+1)=linearized_load_temp;
        waitbar(cc/ngen,wb);
    end
    close(wb);
    w=sum(Y2(:,2:end));
    nonzero=sum(w(1,agcind)~=0);
    plotind=find(w(:,agcind)~=0);
    numrow=floor(sqrt(nonzero));
    numcol=ceil(nonzero/numrow);
    temp=evalin('base','GEN_VAL');
    plotnames=temp(agcind(plotind),1);
    f3=figure;
    for i=1:nonzero
        x=subplot(numrow,numcol,i);
        plot(x,Y1(:,1),Y2(:,agcind(plotind((i)))+1),'red',Y1(:,1),Y1(:,agcind(plotind((i)))+1),'blue');
        temp=Y1(:,agcind(plotind((i)))+1)-Y2(:,agcind(plotind((i)))+1);
        temp2=abs(temp)>0.0001;
        temp3=abs(temp(temp2));
        avgdev=sum(temp3)/size(temp3,1);
        if isnan(avgdev);avgdev=0;end;
        text(0.10,0.93,sprintf('<Deviation>: %.4f MW',avgdev),'units','normalized');
        title(plotnames{i},'interpreter','none');
    end
    allowaxestogrow(f3);
    name=evalin('base','outputname');
    titlename=sprintf('Realized Generation Vs Dispatch Instruction: %s',name);
    axes('position',[0,0,1,1],'visible','off');
    tx = text(0.38,0.985,titlename,'units','normalized');
    set(tx,'fontweight','bold');
    text(0.38,0.02,'Note: Double click bottom left corner of enlarged plot to shrink.','units','normalized');
    text(0.01,0.97,'RTD','units','normalized','color','blue');
    text(0.01,0.92,'AGC','units','normalized','color','red');
end

function plot_netload(~,~)
    gentypes=evalin('base','GENVALUE.val(:,gen_type);');
    wind_gen_type_index=evalin('base','wind_gen_type_index');
    PV_gen_type_index=evalin('base','PV_gen_type_index');
    X=gentypes==wind_gen_type_index|gentypes==PV_gen_type_index;
    X=[0;X];
    temp=evalin('base','ACTUAL_GENERATION');
    Y=temp*X;
    temp2=evalin('base','ACTUAL_LOAD_FULL(:,2)');
    NETLOAD=temp2-Y;
    figure;plot(temp(:,1),NETLOAD);
    name=evalin('base','outputname');
    titlename=sprintf('Net Load: %s',name);
    title(titlename);
    xlabel('Time [hour]');
    ylabel('Net Load [MW]');
end

function plot_reserves(~,~)
    nreserve=evalin('base','nreserve');
    numrow=floor(sqrt(nreserve));
    numcol=ceil(nreserve/numrow);
    tempnames=evalin('base','RTD_RESERVE_FIELD(3:end)');
    f4=figure;
    q=evalin('base','RESERVEVALUE.val');
    ind=zeros(nreserve,nreserve);
    RESERVEVALUE=evalin('base','RESERVEVALUE');
    RTSCEDBINDINGRESERVE=evalin('base','RTSCEDBINDINGRESERVE');
    for i=1:nreserve
        j=1;
        if RESERVEVALUE.val(i,7) ~= 0
            ind(i,j)=RESERVEVALUE.val(i,7);
            check=ind(i,j);
            j=j+1;
            while check ~= 0
                if RESERVEVALUE.val(check,7) ~= 0
                    ind(i,j)=RESERVEVALUE.val(check,7);
                    check=ind(i,j);
                    j=j+1;
                else
                    check=0;
                end
            end
        end
    end
    for r=1:nreserve
        x2=subplot(numrow,numcol,r);
        x=RTSCEDBINDINGRESERVE(:,:,r);
        x=x(2:end,:);
        y=sum(x(:,2:end),2);
        % includes another reserve
        temp=ind(r,:);
        if any(temp)
            incind=temp(temp~=0);
            sumtemp=0;
            for i=1:size(incind,2)
                s=RTSCEDBINDINGRESERVE(:,:,incind(i));
                s=s(2:end,:);
                t=sum(s(:,2:end),2);
                sumtemp=sumtemp+t;
            end
            y=y+sumtemp;
        end
        z=evalin('base',sprintf('RTD_RESERVE_FULL(1:HRTD:size(RTD_LOAD_FULL,1),%d)',r+2));
        plot(x2,x(:,1),z,'-xb',x(:,1),y,'red');
        title(tempnames{r},'interpreter','none');
    end
    allowaxestogrow(f4);
    name=evalin('base','outputname');
    titlename=sprintf('RT Reserves And Reserve Requirement: %s',name);
    axes('position',[0,0,1,1],'visible','off');
    tx = text(0.38,0.985,titlename,'units','normalized');
    set(tx,'fontweight','bold');
    text(0.38,0.02,'Note: Double click bottom left corner of enlarged plot to shrink.','units','normalized');
    text(0.01,0.97,'Sch','units','normalized','color','red');
    text(0.01,0.92,'Req','units','normalized','color','blue');
end

function plot_lossload(~,~)
    x=evalin('base','RTSCEDBINDINGLOSSLOAD');
    x2=evalin('base','RTSCEDBINDINGOVERGENERATION');
    figure;plot(x(:,1),x(:,2),'blue',x(:,1),x2(:,2),'red');
    name=evalin('base','outputname');
    titlename=sprintf('Lost Load and Overgeneration: %s',name);
    title(titlename);
    legend('Lost Load','Overgen');
    xlabel('Time [hr]');
    ylabel('Magnitude [MW]');
    total=sum(x(:,2));
    y=evalin('base','IRTD');
    text(0.60,0.77,sprintf('Load Lost = %d MWh',round(total/(60/y))),'units','normalized');
    total=sum(x2(:,2));
    text(0.60,0.82,sprintf('Overgeneration = %d MWh',round(total/(60/y))),'units','normalized')
end

function plot_unused(~,~)
    GENVALUE=evalin('base','GENVALUE');
    RTSCEDBINDINGSCHEDULE=evalin('base','RTSCEDBINDINGSCHEDULE');
    GEN_VAL=evalin('base','GEN_VAL');
    gen_type=evalin('base','gen_type');
    wind_gen_type_index=evalin('base','wind_gen_type_index');
    PV_gen_type_index=evalin('base','PV_gen_type_index');
    outage_gen_type_index=evalin('base','outage_gen_type_index');
    variable_dispatch_gen_type_index=evalin('base','variable_dispatch_gen_type_index');
    onlinegens=GENVALUE.val(:,gen_type)~=outage_gen_type_index;
    solar=GENVALUE.val(:,gen_type)==PV_gen_type_index;
    wind=GENVALUE.val(:,gen_type)==wind_gen_type_index;
    vcrs=GENVALUE.val(:,gen_type)==variable_dispatch_gen_type_index;
    onlinegens=logical(onlinegens-wind-solar-vcrs);
    X1=RTSCEDBINDINGSCHEDULE(:,2:end);
    X1=X1(:,onlinegens);
    X2=repmat(GENVALUE.val(onlinegens,1)',size(RTSCEDBINDINGSCHEDULE,1),1); %capacity
    ikcount=1;
    for i=1:size(onlinegens,1)
        if onlinegens(i)==1
            traj_idx=RTSCEDBINDINGSCHEDULE(:,i+1)>eps & RTSCEDBINDINGSCHEDULE(:,i+1) < GENVALUE.val(i,7);
            X2(traj_idx,ikcount)=RTSCEDBINDINGSCHEDULE(traj_idx,i+1);
            ikcount=ikcount+1;
        end
    end
    temp=RTSCEDBINDINGSCHEDULE(:,2:end)>0.0001;
    temp=double(temp(:,onlinegens));
    X2=X2.*temp;
    Y=X2-X1;
    assignin('base','totalUnused',sum(Y,2));
    figure;area(RTSCEDBINDINGSCHEDULE(:,1),Y);
    L=legend(GEN_VAL(onlinegens),'interpreter','none');
    set(L,'visible','off');
    xlabel('Time [hr]');
    ylabel('Unused Capacity [MW]');
    name=evalin('base','outputname');
    titlename=sprintf('Unused Thermal Capacity: %s',name);
    title(titlename);
end

function show_onlinetime(~,~)
    STATUS=evalin('base','STATUS');
    GENVALUE=evalin('base','GENVALUE');
    IRTC=evalin('base','IRTC');
    daystosimulate=evalin('base','daystosimulate');
    GEN=evalin('base','GEN');
    avgONtime=zeros(1,size(STATUS,2)-1);
    for j=1:size(STATUS,2)-1
       count=0;
       for i=1:size(STATUS,1)
            if STATUS(i,j+1) == 1
                count=count+1;        
            end
       end
       avgONtime(1,j)=count;
    end
    output=cell(4,size(GENVALUE.val,1));
    for i=1:size(avgONtime,2)
        output{1,i+1}=GEN.uels{i};
        output{2,i+1}=sprintf('%d',GENVALUE.val(i,8));
        output{3,i+1}=sprintf('%.2f',avgONtime(1,i)/(60/IRTC));
        output{4,i+1}=sprintf('%.2f %%',min(100,(avgONtime(1,i)/(60/IRTC))/(24*daystosimulate)*100));
    end
    output{2,1}='Gen Type';output{3,1}='Time Online [hr]';output{4,1}='% ON';
    otf=figure('Visible','off','name','Online Time Per Generator','NumberTitle','off','units','pixels','position',[50 50 800 110],'menubar','none');
    movegui(otf,'center');
    set(otf,'Visible','on');
    onlinetimetable=uitable('Parent',otf,'units','normalized','position',[.025 .05 .95 .90],'columnwidth','auto','RowName',[],'ColumnName',[]);
    set(onlinetimetable,'data',output); 
    colwidths=num2cell(max(cellfun(@length,output))*7.5);
    set(onlinetimetable,'ColumnWidth',colwidths)
end

function plot_reserve_prices(~,~)
    reservePrices=evalin('base','RTSCEDBINDINGRESERVEPRICE');
    reserveNames=evalin('base','RTD_RESERVE_FIELD');
    figure;plot(reservePrices(:,1),reservePrices(:,2:end));
    L=legend(reserveNames{3:end});
    set(L,'interpreter','none');
    xlabel('Time [hr]');
    ylabel('RCP [$/MWh]');
    name=evalin('base','outputname');
    titlename=sprintf('Real Time Reserve Prices: %s',name);
    title(titlename);
end

function plot_da_reserve_prices(~,~)
    reservePrices=evalin('base','DASCUCRESERVEPRICE');
    reserveNames=evalin('base','DAC_RESERVE_FIELD');
    figure;plot(reservePrices(:,1),reservePrices(:,2:end));
    L=legend(reserveNames{3:end});
    set(L,'interpreter','none');
    xlabel('Time [hr]');
    ylabel('RCP [$/MWh]');
    name=evalin('base','outputname');
    titlename=sprintf('Day Ahead Reserve Prices: %s',name);
    title(titlename);
end

function plot_da_reserve(~,~)
    nreserve=evalin('base','nreserve');
    numrow=floor(sqrt(nreserve));
    numcol=ceil(nreserve/numrow);
    tempnames=evalin('base','DAC_RESERVE_FIELD(3:end)');
    f4=figure;
    q=evalin('base','RESERVEVALUE.val');
    ind=zeros(nreserve,nreserve);
    RESERVEVALUE=evalin('base','RESERVEVALUE');
    DASCUCRESERVE=evalin('base','DASCUCRESERVE');
    for i=1:nreserve
        j=1;
        if RESERVEVALUE.val(i,7) ~= 0
            ind(i,j)=RESERVEVALUE.val(i,7);
            check=ind(i,j);
            j=j+1;
            while check ~= 0
                if RESERVEVALUE.val(check,7) ~= 0
                    ind(i,j)=RESERVEVALUE.val(check,7);
                    check=ind(i,j);
                    j=j+1;
                else
                    check=0;
                end
            end
        end
    end
    for r=1:nreserve
        x2=subplot(numrow,numcol,r);
        x=DASCUCRESERVE(:,:,r);
        y=sum(x(:,2:end),2);
        % includes another reserve
        temp=ind(r,:);
        if any(temp)
            incind=temp(temp~=0);
            sumtemp=0;
            for i=1:size(incind,2)
                s=DASCUCRESERVE(:,:,incind(i));
                t=sum(s(:,2:end),2);
                sumtemp=sumtemp+t;
            end
            y=y+sumtemp;
        end
        z=evalin('base',sprintf('DAC_RESERVE_FULL(1:size(DAC_LOAD_FULL,1),%d)',r+2));
        plot(x2,x(:,1),z,'-xb',x(:,1),y,'red');
        title(tempnames{r},'interpreter','none');
    end
    allowaxestogrow(f4);
    name=evalin('base','outputname');
    titlename=sprintf('DA Reserves And Reserve Requirement: %s',name);
    axes('position',[0,0,1,1],'visible','off');
    tx = text(0.38,0.985,titlename,'units','normalized');
    set(tx,'fontweight','bold');
    text(0.38,0.02,'Note: Double click bottom left corner of enlarged plot to shrink.','units','normalized');
    text(0.01,0.97,'Sch','units','normalized','color','red');
    text(0.01,0.92,'Req','units','normalized','color','blue');
end

function plot_revenues(~,~)
    revenues=evalin('base','Revenue_Result');
    genNames=evalin('base','GEN_VAL');
    GENVALUE=evalin('base','GENVALUE');
    nonOutagedGens=GENVALUE.val(:,8)~=15;
    temp=(1:size(nonOutagedGens))';
    indexNumberOfNonOutagedGens=temp.*nonOutagedGens;
    indexNumberOfNonOutagedGens=indexNumberOfNonOutagedGens(indexNumberOfNonOutagedGens~=0);
    Names=genNames(nonOutagedGens);
    sumRevenues=sum(revenues);
    sumRevenues=sumRevenues(nonOutagedGens);
    figure;bar(1:size(Names,1),sumRevenues);
    xlabel('Generator Number');
    ylabel('Revenue [$]');
    name=evalin('base','outputname');
    titlename=sprintf('Generator Revenues: %s',name);
    title(titlename);
    displayRevenues=cell(size(Names));
    for i=1:size(Names,1)
        displayRevenues(i,1)={convert2currency(abs(sumRevenues(i)))};
    end
    negativeRevenues=sumRevenues<=-.01;
    displayRevenues(negativeRevenues)=strcat('- ',displayRevenues(negativeRevenues));
    axis([xlim ylim*1.05]);
    table_data=cell(size(Names,1)+1,4);
%     table_data(1,:)={'Gen Number','Gen Name','Revenue'};
    table_data(1,:)={'idx',' #  ','Gen Name','Revenue'};
    table_data(2:end,2)=cellstr(num2str(indexNumberOfNonOutagedGens));
    table_data(2:end,1)=cellstr(num2str((1:size(Names,1))'));
    table_data(2:end,3)=Names;
    sizeTable=[table_data(:,1),table_data(:,2),table_data(:,3),[table_data(1,4);displayRevenues]];
    colwidths=num2cell(max(cellfun(@length,sizeTable))*7.75);
    colergen = @(color,text) sprintf('<html><table border=0 width=%d bgcolor=%s><TR><TD>%s</TD></TR> </table></html>',ceil(sum(cell2mat(colwidths))/50)*50,color,text);
    for i=1:size(displayRevenues,1)
        if negativeRevenues(i) == 1
            table_data{1+i,4}=colergen('#FF5050',displayRevenues{i});
        else
            table_data{1+i,4}=colergen('#FFFFFF',displayRevenues{i});
        end
    end
    rt=figure('Visible','off','name',sprintf('Revenues Per Generator: %s',name),'NumberTitle','off','units','pixels','position',[50 50 ceil(sum(cell2mat(colwidths))/50)*50 min(600,20*(size(Names,1)+1))],'menubar','none');
    movegui(rt,'center');
    set(rt,'Visible','on');
    revenue_table=uitable('Parent',rt,'units','normalized','position',[.02 .02 .96 .96],'columnwidth','auto','RowName',[],'ColumnName',[]);
    set(revenue_table,'data',table_data); 
    set(revenue_table,'ColumnWidth',colwidths)
end

function access_variables(~,~)
    acf=figure('Visible','off','name','Access Variables','NumberTitle','off','units','pixels','position',[50 50 500 600],'menubar','none');
    movegui(acf,'center');set(acf,'Visible','on');
    % Get list of loaded cases
    caseNames = get(listOfCases,'string');
    listOfCaseNames=uicontrol('Parent',acf,'Style','listbox','Max',10,'units','normalized','Position',[0.025 0.15 .45 .825],'FontName','Courier','String',caseNames,'Max',10,'value',[]);
    % Get list of workspace variables
    PathNames=evalin('base','PathNames');
    temp=load(PathNames{1});
    vars=fieldnames(temp);vars=sort(vars);
    listOfVars=uicontrol('Parent',acf,'Style','listbox','Max',10,'units','normalized','Position',[0.525 0.15 .45 .825],'FontName','Courier','String',vars,'Max',10,'value',[]);
    % Output Variable Name
    uicontrol('style','text','string','Output Variable Name:','units','normalized','position',[.05 .079 .30 .05],'fontunits','normalized','fontsize',0.50,'horizontalalignment','left','BackgroundColor',get(acf,'color'));
    outputVariableName_edit=uicontrol('style','edit','string','COMPARE_DATA','units','normalized','position',[.10 .03 .30 .05],'backgroundcolor','white');
    % Get Data
    uicontrol('Parent',acf,'Style','pushbutton','String','<html><center>Get Data</center></html>','units','normalized','position',[.44 .025 .25 .10],'fontunits','normalized','fontsize',0.30,'Callback',{@get_comp_var});
    % Close
    uicontrol('Parent',acf,'Style','pushbutton','String','Close','units','normalized','Position', [0.72 0.025 0.25 0.10],'fontunits','normalized','fontsize',0.30,'Callback', 'close(gcf)');
end

function get_comp_var(~,~)
    selectedVars=get(listOfVars,'value');
    selectedCases=get(listOfCaseNames,'value');
    caseNames=get(listOfCaseNames,'string');
    variableNames=get(listOfVars,'string');
    PathNames=evalin('base','PathNames');
    selectedCaseNames=caseNames(selectedCases);
    totalIterations=size(selectedCases,2)*size(selectedVars,2);
    count = 1;
    wb = waitbar(0,'Gathering Data...');
    for c=1:size(selectedCases,2)
        temp=load(PathNames{selectedCases(c)});
        for v=1:size(selectedVars,2)
            temp2.(sprintf('case%d',c)).(sprintf('%s',variableNames{selectedVars(v)}))=temp.(sprintf('%s',variableNames{selectedVars(v)}));
            waitbar(count/totalIterations,wb);
            count = count + 1;
        end
    end
    waitbar(1,wb,'Gathering Data...Complete!');
    pause on;pause(0.5);pause off;
    waitbar(1,wb,'Finalizing Data...');
    for v=1:size(selectedVars,2)
        for c=1:size(selectedCases,2)
            temp3.(sprintf('%s',variableNames{selectedVars(v)})).(sprintf('case%d',c))=temp2.(sprintf('case%d',c)).(sprintf('%s',variableNames{selectedVars(v)}));
        end
    end
    temp3.Case_Names=selectedCaseNames;
    tempname=get(outputVariableName_edit,'string');
    assignin('base',sprintf('%s',tempname),temp3);
    waitbar(1,wb,'Finalizing Data...Complete!');close(wb);
    evalin('base',sprintf('open %s',tempname));
end

function loadOnDoubleClick_callback(source,~)
    x=get(source, 'UserData');
    if size(x,2) >= 2
        x=x(1);
    end
    if x == get(source, 'Value')
        ztime1=evalin('base','ztime1');
        ztime2=toc(ztime1);
        if ztime2 < 0.3
            loadVariables_callback;
        end
    end
    set(source, 'UserData', get(source, 'Value'))
    ztime1=tic;
    assignin('base','ztime1',ztime1);
%     end
end

function removeCase_callback(source,eventdata)
    PathNames=evalin('base','PathNames');
    row=evalin('base','row');
    del_ind=get(listOfCases,'value');
    row=row-1;
    PathNames(del_ind)=[];
    temp=cellstr(get(listOfCases,'string'));
    temp(del_ind)=[];
    assignin('base','row',row);
    assignin('base','PathNames',PathNames);
    set(listOfCases,'value',row-1);
    set(listOfCases,'string',temp);    
end

function moveUp_callback(~,~)
    mov_ind=get(listOfCases,'value');
    if mov_ind ~= 1
        tempCaseNames=cellstr(get(listOfCases,'string'));
        temp=tempCaseNames{mov_ind};
        tempCaseNames{mov_ind}=tempCaseNames{mov_ind-1};
        tempCaseNames{mov_ind-1}=temp;
        set(listOfCases,'string',tempCaseNames); 
        set(listOfCases,'value',mov_ind-1);
        PathNames=evalin('base','PathNames');
        temp=PathNames{mov_ind};
        PathNames{mov_ind}=PathNames{mov_ind-1};
        PathNames{mov_ind-1}=temp;
        assignin('base','PathNames',PathNames);
    end
end

function moveDown_callback(~,~)
    mov_ind=get(listOfCases,'value');
    PathNames=evalin('base','PathNames');
    if mov_ind ~= size(PathNames,1)
        tempCaseNames=cellstr(get(listOfCases,'string'));
        temp=tempCaseNames{mov_ind};
        tempCaseNames{mov_ind}=tempCaseNames{mov_ind+1};
        tempCaseNames{mov_ind+1}=temp;
        set(listOfCases,'string',tempCaseNames); 
        set(listOfCases,'value',mov_ind+1);
        temp=PathNames{mov_ind};
        PathNames{mov_ind}=PathNames{mov_ind+1};
        PathNames{mov_ind+1}=temp;
        assignin('base','PathNames',PathNames);
    end
end

function plot_congestion(~,~)
    LFCHECK=evalin('base','exist(''RTD_LF'',''var'')');
    IRTD=evalin('base','IRTD');
    nbranch=evalin('base','nbranch');
    BRANCHDATA=evalin('base','BRANCHDATA');
    line_rating=evalin('base','line_rating');
    daystosimulate=evalin('base','daystosimulate');
    if LFCHECK == 0
        LOAD_DIST=evalin('base','LOAD_DIST');
        nbus=evalin('base','nbus');
        BUS_VAL=evalin('base','BUS_VAL');
        HRTD=evalin('base','HRTD');
        RTD_LOAD_FULL=evalin('base','RTD_LOAD_FULL');
        GENBUS_CALCS_VAL=evalin('base','GENBUS_CALCS_VAL');
        RTSCEDBINDINGSCHEDULE=evalin('base','RTSCEDBINDINGSCHEDULE');
        PTDF_VAL=evalin('base','PTDF_VAL');
        size_RTD_LOAD_FULL=evalin('base','size_RTD_LOAD_FULL');
        ngen=evalin('base','ngen');
        if size(LOAD_DIST.val,1) ~= nbus
            fullLoadDist=zeros(nbus,1);
            for i=1:size(LOAD_DIST.val,1)
                found=0;j=1;
                while found==0
                    if strcmp(LOAD_DIST.uels{i},BUS_VAL{j})
                        fullLoadDist(j)=LOAD_DIST.val(i);
                        found=1;
                    else
                        j=j+1;
                    end
                end
            end
        else
            fullLoadDist=LOAD_DIST.val;
        end
        rtd_idx=(1:HRTD:size_RTD_LOAD_FULL)';
        RTD_LF=zeros(size(RTSCEDBINDINGSCHEDULE,1)-1,nbranch);
        for rtd_int=1:size(rtd_idx,1)
            bus_injection=-1*fullLoadDist*RTD_LOAD_FULL(rtd_idx(rtd_int),3);
            temp1=zeros(nbus,ngen);temp2=sortrows(GENBUS_CALCS_VAL,1);
            temp1(sub2ind([nbus ngen],temp2(:,2),(1:ngen)'))=1;
            bus_injection=temp1*RTSCEDBINDINGSCHEDULE(rtd_int,2:end)' + bus_injection;
            RTD_LF(rtd_int,:) = (PTDF_VAL*bus_injection)';
        end
    else
        RTD_LF=evalin('base','RTD_LF');
    end
    RTD_LF=abs(RTD_LF);
    percentLoaded=RTD_LF./repmat(BRANCHDATA.val(:,line_rating)',60/IRTD*24*daystosimulate,1).*100;
    percentLoaded=min(100,percentLoaded);
    figure;imagesc((IRTD/60:IRTD/60:24*daystosimulate)',1:nbranch,percentLoaded');
    colormap('autumn');colorbar;xlabel('Time [hr]');ylabel('Branch Number');
    name=evalin('base','outputname');
    titlename=sprintf('Percent Loading for each Branch: %s',name);
    title(titlename);
    assignin('base','numberOfCongestedIntervals',sum(sum(percentLoaded>=95)));
end

function eval_custom(~,~)
    caseValues=get(listOfCases, 'Value');
    caseNames=get(listOfCases, 'String');
    selectedNames=caseNames(caseValues);
    PathNames=evalin('base','PathNames');
    CASE1DATA = load(PathNames{caseValues(1,1),1});
    try CASE2DATA = load(PathNames{caseValues(1,2),1});catch;end;
    [custom_chart_script,~] = uigetfile(['MODEL_RULES',filesep,'*.m'],'Select Custom Chart Script');
    if ischar(custom_chart_script) 
        run(custom_chart_script);
    end
end

end















