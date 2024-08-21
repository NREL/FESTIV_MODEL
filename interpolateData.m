function linearized_data_temp = interpolateData(Input_Data,Number_Of_Days,Target_Resolution_In_Seconds,Input_Resolution_In_Minutes)

    raw_load_data=Input_Data;
    number_of_raw_data_points_per_day=60*24/Input_Resolution_In_Minutes;
    number_of_agc_intervals_per_N_minutes=60/Target_Resolution_In_Seconds*Input_Resolution_In_Minutes;
    total_number_of_agc_data_points=number_of_raw_data_points_per_day*number_of_agc_intervals_per_N_minutes*Number_Of_Days;
    number_of_agc_intervals_per_day=total_number_of_agc_data_points/Number_Of_Days;
    linearized_data_temp=zeros(total_number_of_agc_data_points,1);k=1;
    for i=1:number_of_raw_data_points_per_day*Number_Of_Days-1
        agc_load_increment=(raw_load_data(i+1,1)-raw_load_data(i,1))/number_of_agc_intervals_per_N_minutes;
        for j=1:number_of_agc_intervals_per_N_minutes
            linearized_data_temp(k,1)=raw_load_data(i,1)+agc_load_increment*(j-1);
            k=k+1;
        end
    end
    for j=1:number_of_agc_intervals_per_N_minutes
        linearized_data_temp(k,1)=raw_load_data(end,1)+agc_load_increment*(j-1);
        k=k+1;
    end

end