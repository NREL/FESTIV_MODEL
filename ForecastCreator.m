function ForecastCreator

% create the figure
f=figure('Visible','on','name','Real Time Forecast Creation for FESTIV','NumberTitle','off','units','pixels','position',[50 50 900 700],'menubar','none');
uicontrol('Parent',f,'Style','text','string','Real Time Forecast Creator','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.02 .95 .96 .04],'BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Input File: ','fontunits','normalized','fontsize',0.5,'unit','normalized','position',[0.05 0.86 .08 .05],'BackgroundColor',get(gcf,'color'));
filepath=uicontrol('Parent',f,'Style','edit','HorizontalAlignment','left','units','normalized','Position', [.14 0.87 0.69 0.05],'fontunits','normalized','fontsize',0.4); 
uicontrol('Parent',f,'Style','pushbutton','String','Browse','units','normalized','Position',[0.85 0.87 0.1 0.05],'fontunits','normalized','fontsize',0.4,'Callback',{@getfilepath});
uicontrol('Parent',f,'Style','pushbutton','String','Close','units','normalized','Position', [0.85 0.01 0.13 0.06],'fontunits','normalized','fontsize',0.40,'Callback', @(hObject,eventData) close(gcf));
uicontrol('Parent',f,'Style','pushbutton','String','Go!','units','normalized','Position', [.70 .01 .13 .06],'fontunits','normalized','fontsize',0.40,'Callback',{@createForecast_Callback}); 
tableofvgs=uitable('Parent',f,'units','normalized','position',[0.10 .12 .80 .51],'ColumnFormat',{'char','logical','logical','logical'},'ColumnName',{'Gen', 'Perfect','Persistance','Normally Distributed'},'ColumnEditable',[false true true true],'ColumnWidth',{300 129 129 129},'CellEditCallback',{@tableofvgs_CellEditCallback});
uicontrol('Parent',f,'Style','text','string','Error:','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.74 .82 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Number of Days:','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.74 .77 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Horizon (H):','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.52 .77 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','AGC Resolution:','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.30 .77 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Model Solve Time (P):','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.30 .82 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Update Interval (t):','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.07 .82 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Advisory Interval Length:','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.07 .77 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Interval Length (I):','fontunits','normalized','fontsize',0.9,'units','normalized','position',[.52 .82 .15 .02],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
updateinterval=uicontrol('Parent',f,'Style','edit','string','tRTC','units','normalized','Position', [.22 0.815 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
advisorylength=uicontrol('Parent',f,'Style','edit','string','IRTC','units','normalized','Position', [.22 0.765 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
intervallenth=uicontrol('Parent',f,'Style','edit','string','IRTC','units','normalized','Position', [.66 0.815 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
modelsolvetime=uicontrol('Parent',f,'Style','edit','string','PRTC','units','normalized','Position', [.44 0.815 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
AGCtime=uicontrol('Parent',f,'Style','edit','string','tAGC','units','normalized','Position', [.44 0.765 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
Horizon=uicontrol('Parent',f,'Style','edit','string','HRTC','units','normalized','Position', [.66 0.765 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
numdays=uicontrol('Parent',f,'Style','edit','string','1','units','normalized','Position', [.86 0.765 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
errordist=uicontrol('Parent',f,'Style','edit','string','0','units','normalized','Position', [.86 0.815 0.06 0.03],'fontunits','normalized','fontsize',0.7); 
uicontrol('Parent',f,'Style','text','string','NOTE: The actual vg output files must be already created in order to create real time forecasts for those generators','fontunits','normalized','fontsize',0.65,'units','normalized','position',[.10 .08 .80 .03],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','NOTE: Output files will have a number (1 - N) appended to them corresponding to the day','fontunits','normalized','fontsize',0.65,'units','normalized','position',[.10 .05 .59 .03],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
uicontrol('Parent',f,'Style','text','string','Output File Name:','fontunits','normalized','fontsize',0.7,'units','normalized','position',[.19 .705 .16 .03],'HorizontalAlignment','left','BackgroundColor',get(gcf,'color'));
outputname=uicontrol('Parent',f,'Style','edit','string','RTC_VG_INPUT_DAY_','units','normalized','Position', [.33 0.70 0.45 0.04],'fontunits','normalized','fontsize',0.6); 
uicontrol('Parent',f,'Style','pushbutton','String','Select All','units','normalized','position',[.490 .64 .10 .05],'Callback',{@selectAllPerfect});
uicontrol('Parent',f,'Style','pushbutton','String','Select All','units','normalized','position',[.635 .64 .10 .05],'Callback',{@selectAllPersistance});
uicontrol('Parent',f,'Style','pushbutton','String','Select All','units','normalized','position',[.775 .64 .10 .05],'Callback',{@selectAllNormal});
movegui('center');

function getfilepath(~,~)
    [FileName,PathName,~] = uigetfile('Input/*.xlsx','Select FESTIV Input File');
    if FileName ~= 0
        fullinputpath = strcat(PathName,FileName);
        [gendata,colHeaders]=xlsread(fullinputpath,'GEN');
        listofvgs = []; vgcapacities = [];
        for i=1:size(gendata,1)
            if gendata(i,8) == 7 || gendata(i,8) == 10 || gendata(i,8) == 16
                listofvgs=[listofvgs;colHeaders(i+1,1)];
                vgcapacities = [vgcapacities;gendata(i,1)];
            end
        end
        data=cell(size(listofvgs,1),4);
        data(:,1)=listofvgs;
        assignin('caller','vgcapacities',vgcapacities);
        assignin('caller','fullinputpath',fullinputpath);
        assignin('caller','listofvgs',listofvgs);
        assignin('caller','pathname',PathName);
        set(tableofvgs,'data',data);
        set(filepath,'string',FileName);
        [~, actual_vg_input_file] = xlsread(fullinputpath,'ACTUAL_VG_REF','A2:A10');
        nvg=size(listofvgs,1);days=str2double(get(numdays,'string'));
        ACTUAL_VG_FULL = [];ACTUAL_VG_FIELD = [];
        % read in complete realized vg data
        for d = 1:days
            if nvg > 0
                [ACTUAL_VG_FULL_TMP, ACTUAL_VG_FIELD] = xlsread(strcat(PathName,'TIMESERIES',filesep,cell2mat(actual_vg_input_file(d,1))),'Sheet1');
                ACTUAL_VG_FULL = [ACTUAL_VG_FULL; ACTUAL_VG_FULL_TMP];
            else
                ACTUAL_VG_FIELD = [];
                ACTUAL_VG_FULL = [];
            end;
        end;
        assignin('base','ACTUAL_VG_FULL',ACTUAL_VG_FULL);
        assignin('base','ACTUAL_VG_FIELD',ACTUAL_VG_FIELD);
    end
end

function createForecast_Callback(~,~,~)
    agctime=str2double(get(AGCtime,'string'));
    updateI=str2double(get(updateinterval,'string'));
    advtime=str2double(get(advisorylength,'string'));
    intlength=str2double(get(intervallenth,'string'));
    modeltime=str2double(get(modelsolvetime,'string'));
    horiz=str2double(get(Horizon,'string'));
    numberofdays=str2double(get(numdays,'string'));
    errord=str2double(get(errordist,'string'));
    vgcapacities=evalin('caller','vgcapacities');
    fullinputpath=evalin('caller','fullinputpath');
    listofvgs=evalin('caller','listofvgs');
    pathname=evalin('caller','pathname');
    data=get(tableofvgs,'data');
    outputfilename=get(outputname,'string');
    names=cell(size(data,1),1);
    whichforecast=zeros(size(data,1),4);
    for i=1:size(data,1)
        for j=1:size(data,2)
            x=cell2mat(data(i,j));
            if j == 1 % store name NOTE: names are in cell matrix
                names(i,1)={x};
            end
            if islogical(cell2mat(data(i,j))) &&  cell2mat(data(i,j))==1 % check which forecast to do
                whichforecast(i,j-1)=1;
            end
        end
    end
    perfectgensindicies=[];persistancegensindicies=[];cloudygensindicies=[];normallygensindicies=[];
    for i=1:size(whichforecast,1)
        for j=1:4
            if whichforecast(i,j) == 1 && j == 1
                perfectgensindicies = [perfectgensindicies;i];
            end
            if whichforecast(i,j) == 1 && j == 2
                persistancegensindicies = [persistancegensindicies;i];
            end
            if whichforecast(i,j) == 1 && j == 3
                normallygensindicies = [normallygensindicies;i];
            end
        end
    end
    
    message='';
    h=waitbar(0,message,'name','Status','position',[50 50 270 100]);
    movegui(h,'center');
    % create perfect forecasts
    if isempty(perfectgensindicies) == 0 
        perfectgenNames=[];perfectgenCapacities=[];
        for i=1:size(perfectgensindicies,1)
            perfectgenNames=[perfectgenNames;names(perfectgensindicies(i))];
            perfectgenCapacities=[perfectgenCapacities;vgcapacities(perfectgensindicies(i,1))];
        end
        message=sprintf('%sCreating Perfect Forecasts...',message);
        waitbar(0.1,h,message);
        perfectForecasts=windForecast(intlength,advtime,updateI,horiz,agctime,modeltime,numberofdays,errord,perfectgenCapacities,2,fullinputpath,perfectgenNames,pathname);
        assignin('base','perfectForecasts',perfectForecasts);
        sizeofforecast=size(perfectForecasts,1);
        message=sprintf('%sComplete!!                   \n',message);
        waitbar(0.2,h,message);
    end;
    % create persistance forecasts
    if isempty(persistancegensindicies) == 0
        persistancegenNames=[];persistancegenCapacities=[];
        for i=1:size(persistancegensindicies,1)
            persistancegenNames=[persistancegenNames;names(persistancegensindicies(i))];
            persistancegenCapacities=[persistancegenCapacities;vgcapacities(persistancegensindicies(i,1))];
        end
        message=sprintf('%sCreating Persistance Forecasts...',message);
        waitbar(0.3,h,message);
        persistanceForecasts=windForecast(intlength,advtime,updateI,horiz,agctime,modeltime,numberofdays,errord,persistancegenCapacities,3,fullinputpath,persistancegenNames,pathname);
        assignin('base','persistanceForecasts',persistanceForecasts);
        sizeofforecast=size(persistanceForecasts,1);
        message=sprintf('%sComplete!!            \n',message);
        waitbar(0.4,h,message);
    end;
    % create normally distributed forecasts
    if isempty(normallygensindicies) == 0
        normallygenNames=[];normallygenCapacities=[];
        for i=1:size(normallygensindicies,1)
            normallygenNames=[normallygenNames;names(normallygensindicies(i))];
            normallygenCapacities=[normallygenCapacities;vgcapacities(normallygensindicies(i,1))];
        end
        message=sprintf('%sCreating Normally Distributed Forecasts...',message);
        waitbar(0.7,h,message);
        normallyForecasts=windForecast(intlength,advtime,updateI,horiz,agctime,modeltime,numberofdays,errord,normallygenCapacities,4,fullinputpath,normallygenNames,pathname);
        assignin('base','normallyForecasts',normallyForecasts);
        sizeofforecast=size(normallyForecasts,1);
        message=sprintf('%sComplete!!\n',message);
        waitbar(0.8,h,message);
    end;
    % put all of the forecasts in one variable in the same order as the GEN tab
    message=sprintf('%sFinalizing Forecast...',message);
    waitbar(0.9,h,message);
    FORECAST_FIELDS=listofvgs';
    FORECAST=zeros(sizeofforecast,size(FORECAST_FIELDS,2)+2);
    for i=1:size(FORECAST_FIELDS,2)
        if isempty(perfectgensindicies) == 0
            for j=1:size(perfectgenNames,1)
                FORECAST(:,1:2)=perfectForecasts(:,1:2);
                FORECAST(:,perfectgensindicies(j)+2)=perfectForecasts(:,j+2);
            end
        end
        if isempty(persistancegensindicies) == 0
            for j=1:size(persistancegenNames,1)
                FORECAST(:,1:2)=persistanceForecasts(:,1:2);
                FORECAST(:,persistancegensindicies(j)+2)=persistanceForecasts(:,j+2);
            end
        end
        if isempty(normallygensindicies) == 0
            for j=1:size(normallygenNames,1)
                FORECAST(:,1:2)=normallyForecasts(:,1:2);
                FORECAST(:,normallygensindicies(j)+2)=normallyForecasts(:,j+2);
            end
        end
    end
    % write the output files
    Alphabet=char('A'+(1:26)-1)';
    [I3,J3,K3]=ndgrid(1:26,1:26,1:26);
    X1=[Alphabet(I3(:)), Alphabet(J3(:))];
    X1=cellstr(X1);
    X1=sort(X1);
    X1=unique(X1);
    X2=[Alphabet(I3(:)),Alphabet(J3(:)),Alphabet(K3(:))];
    X2=cellstr(X2);
    X2=sort(X2);
    X2=unique(X2);
    X0=cellstr(Alphabet);
    masterabc=[X0;X1;X2(1:15682)];
    genrangeend=char(masterabc(size(listofvgs,1)+2));

    for k=1:numberofdays
        temp=[];
        for i=1:size(FORECAST,1)
            if floor(FORECAST(i,1)+.0001) == k-1
                temp=[temp;FORECAST(i,:)];
            end
        end
        for j=1:2
            for i=1:size(temp,1)
                temp(i,j)=temp(i,j)-k+1;
                if temp(i,j) < 0.000001
                    temp(i,j) = 0;
                end
            end
        end
        tempname=strcat(pathname,outputfilename,num2str(k),'.xls');

        e = actxserver ('Excel.Application'); %# open Activex server
        ewb = e.Workbooks; 
        Workbook = invoke(ewb, 'Add');
        Activesheet = e.Activesheet;

        set(Activesheet.Range('A1'),'Value','START_TIME');
        set(Activesheet.Range('B1'),'Value','TIME_INTERVAL');
        range=strcat('C1:',genrangeend,'1');
        set(Activesheet.Range(range),'Value',listofvgs');
        range=strcat('A2:',genrangeend,num2str(size(temp,1)+1));
        set(Activesheet.Range(range),'Value',temp);

        invoke(Workbook, 'SaveAs', tempname);
        invoke(e, 'Quit');
        delete(e);
    end
    assignin('base','FORECAST',FORECAST);
    message=sprintf('%sComplete!!                             ',message);
    waitbar(1,h,message);
    pause on;pause(1);pause off;
    delete(h);
end

function tableofvgs_CellEditCallback(~, eventdata)
data=get(tableofvgs,'Data'); % get the data cell array of the table
cols=get(tableofvgs,'ColumnFormat'); % get the column formats
if strcmp(cols(eventdata.Indices(2)),'logical') % if the column of the edited cell is logical
    if eventdata.EditData % if the checkbox was set to true
        data{eventdata.Indices(1),eventdata.Indices(2)}=true; % set the data value to true
    else % if the checkbox was set to false
        data{eventdata.Indices(1),eventdata.Indices(2)}=false; % set the data value to false
    end
end
set(tableofvgs,'Data',data); % now set the table's data to the updated data cell array
assignin('base','data',data);
end

function selectAllPerfect(~,~)
    data=get(tableofvgs,'Data');
    x=sum(double(cell2mat(data(:,2))));
    if ~isempty(data) && x ~= size(data,1)
        for i=1:size(data,1)
            data{i,2}=true;
        end
        set(tableofvgs,'Data',data);
        assignin('base','data',data);
    end
    if ~isempty(data) && x == size(data,1)
        for i=1:size(data,1)
            data{i,2}=false;
        end
        set(tableofvgs,'Data',data);
        assignin('base','data',data);
    end
end

function selectAllPersistance(~,~)
    data=get(tableofvgs,'Data');
    x=sum(double(cell2mat(data(:,3))));
    if ~isempty(data) && x ~= size(data,1)
        for i=1:size(data,1)
            data{i,3}=true;
        end
        set(tableofvgs,'Data',data);
        assignin('base','data',data);
    end
    if ~isempty(data) && x == size(data,1)
        for i=1:size(data,1)
            data{i,3}=false;
        end
        set(tableofvgs,'Data',data);
        assignin('base','data',data);
    end
end

function selectAllNormal(~,~)
    data=get(tableofvgs,'Data');
    x=sum(double(cell2mat(data(:,4))));
    if ~isempty(data) && x ~= size(data,1)
        for i=1:size(data,1)
            data{i,4}=true;
        end
        set(tableofvgs,'Data',data);
        assignin('base','data',data);
    end
    if ~isempty(data) && x == size(data,1)
        for i=1:size(data,1)
            data{i,4}=false;
        end
        set(tableofvgs,'Data',data);
        assignin('base','data',data);
    end
end

end