clc;clear all;close all;
addpath('../utils')


data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_show_results'];
    mkdir(error_folder)
    
    mkdir(error_folder)
    
    results_folder_feature_extraction1 = [data_folder '_feature_extraction1'];

    results_folder = [data_folder '_show_results'];
    

    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];

    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    results_folder_names = {};
    resutls_data = {};

    for file_num = 1:length(filenames)
%         try
        if 1
            disp(file_num)
            filename = filenames{file_num};
            filename_save_res_features = [results_folder_feature_extraction1, replace(filename,data_folder,'')];

            if ~isfile([filename_save_res_features 'extracted_features.mat'])
                continue;
            end

            features = load([filename_save_res_features 'extracted_features.mat']);

            
            if size(features.nuc_features_table,1) ==0
                continue;
            end

            for cell_num = 1:length(size(features.nuc_features_table,1))

                tmp1 = features.detection_table_r.r_value;
                tmp2 = features.detection_table_r.r_segm;
                detection_value_r = median(tmp1(tmp2==cell_num));
                detection_count_r = length(tmp1(tmp2==cell_num));

                tmp1 = features.detection_table_g.g_value;
                tmp2 = features.detection_table_g.g_segm;
                detection_value_g = median(tmp1(tmp2==cell_num));
                detection_count_g = length(tmp1(tmp2==cell_num));

                tmp1 = features.detection_table_rg.rg_value;
                tmp2 = features.detection_table_rg.rg_segm;
                detection_value_rg = median(tmp1(tmp2==cell_num));
                detection_count_rg = length(tmp1(tmp2==cell_num));

                tmp1 = features.features_foci_table.VolumeUm;
                tmp2 = features.features_foci_table.MaxIntensity_seg;
                foci_volume = sum(tmp1(tmp2==cell_num));
                tmp1 = features.features_foci_table.VolumeUm;
                tmp2 = features.features_foci_table.MaxIntensity_seg;
                tmp3 = features.nuc_features_table.VolumeUmNuc;
                volume_occupied_per = sum(tmp1(tmp2==cell_num)) ./ tmp3(cell_num);
                tmp1 = features.features_foci_table.Correltaion;
                tmp2 = features.features_foci_table.MaxIntensity_seg;
                correlation = median(tmp1(tmp2==cell_num));
                tmp1 = features.features_foci_table.MaxIntensityR;
                tmp2 = features.features_foci_table.MaxIntensity_seg;
                intensty_r = median(tmp1(tmp2==cell_num));
                tmp1 = features.features_foci_table.MaxIntensityG;
                tmp2 = features.features_foci_table.MaxIntensity_seg;
                intensity_g = median(tmp1(tmp2==cell_num));



                tmp = table(detection_count_r,detection_count_g,detection_value_r,detection_value_g,...
                    detection_count_rg,foci_volume,volume_occupied_per,...
                    correlation,intensty_r,intensity_g);
                resutls_data = [resutls_data,{tmp}];



                tmp = filename_save_res_features;
                tmp = replace(tmp,[results_folder_feature_extraction1 '\'],'');
                tmp = split(tmp,'\');
                tmp = join(tmp(1:end-3),'/');

                

                tmp = replace(tmp,'gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)','NHDF');
                tmp = replace(tmp,'gamma-IR_U87_RAD51+gH2AX_2021_6_8  (Acquiarium)','U87');
                tmp = replace(tmp,'IR ','');
                tmp = replace(tmp,'U87_IR ','');
                tmp = replace(tmp,'U87_non IR','');
                tmp = replace(tmp,'non-IR ','');
                tmp = replace(tmp,'_2021_10_11','');
                tmp = replace(tmp,'experiment','Exp');


                tmp = replace(tmp,'protons','');
                tmp = replace(tmp,'Protons','');
                tmp = replace(tmp,'protony','');
                tmp = replace(tmp,'Protony','');
                tmp = replace(tmp,'Structure_Acquiarium','');
                tmp = replace(tmp,'Structure-LAS to Acquarium','');
                tmp = replace(tmp,'structure_Acquiarium','');
                tmp = replace(tmp,'Acquiarium','');

                tmp = replace(tmp,'NHDF N15 angle 90 LET 183keV E 13 MeV','');
                tmp = replace(tmp,'U87 N15 angle 90 LET 183keV E 13 MeV','');
                
                tmp = replace(tmp,'hod','h');
                tmp = replace(tmp,' h','h');
                tmp = replace(tmp,'IR','');
                tmp = replace(tmp,'PI','');
                tmp = replace(tmp,'_','-');
                tmp = replace(tmp,',','.');
                tmp = replace(tmp,'0.5','00.5');
                tmp = replace(tmp,'1h','01h');
                tmp = replace(tmp,'2h','02h');
                tmp = replace(tmp,'24h','xxh');
                tmp = replace(tmp,'4h','04h');
                tmp = replace(tmp,'xxh','24h');
                tmp = replace(tmp,'8h','08h');
                


                results_folder_names = [results_folder_names,tmp];
            

                

            end
            

        end

    end
    resutls_data = cat(1,resutls_data{:});
    tmp = resutls_data.foci_volume;
    tmp(isnan(tmp)) = 0;
    resutls_data.foci_volume = tmp;


    
    feature_names = resutls_data.Properties.VariableNames;
    for feature_num=1:numel(feature_names)

        feature_name = feature_names{feature_num};
        data_feature = resutls_data.(feature_name);
        
        non_nans = ~isnan(data_feature);
        data_feature = data_feature(non_nans);
        data_names = categorical(results_folder_names(non_nans));

        figure();
        boxchart(data_names,data_feature)
        title(replace(feature_name,'_','-'))


    end

end



