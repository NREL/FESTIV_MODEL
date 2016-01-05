function forecastingplots(xxx_VG_FULL,HRTx,tRTx,column_of_generator,new_figure,plotcolor,plotname)
% (xxx_VG_FULL,HRTx,tRTx,column of generator,1 for new figure,trace color,trace name)
try
    
    X=xxx_VG_FULL;
    Y=HRTx;
    Z=tRTx;
    W=column_of_generator;
    newone=new_figure;

    if newone == 1
        figure; forecastplots=gcf; plotcount=0; 
        assignin('base','forecastplots',forecastplots);
    else
        plotcount=evalin('base','plotcount');
    end

    forecastplots=evalin('base','forecastplots');
    figure(forecastplots)
    plot(X(1:Y,2).*24,X(1:Y,W),'color',plotcolor);
    hold on;
    for i=1:size(X,1)/Y-1
        plot(X(i*Y+1:i*Y+Y,2).*24,X(i*Y+1:i*Y+Y,W),'color',plotcolor);
    end
    text(-.15,1.05-plotcount*.08,plotname,'units','normalized','color',plotcolor)
    xlabel('Time [hour]');
    ylabel('Forecast [MW]');
    plotcount=plotcount+1;
    figure(forecastplots)
    assignin('base','plotcount',plotcount);

catch
   s = lasterror; 
   Stack  = dbstack;
   stoppingpoint=Stack(1,1).line+4;
   stopcommand=sprintf('dbstop in forecastingplots.m at %d',stoppingpoint);
   eval(stopcommand);
   i;
end

end