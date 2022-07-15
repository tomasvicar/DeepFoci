clc;clear all;close all;
addpath('../utils')
addpath('../nuclei_segmentation_training')



data_folders = {...
    'Z:\000000-My Documents\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


shapes = {};
shapes_filenames = {};

for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_analyze_size'];
    mkdir(error_folder)
    
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    
    for file_num = 1:length(filenames)
        try
%         while 1
            disp(file_num)
 
        
            filename = filenames{file_num};

%             data = read_ics_3_files(filename);
            data_2D = read_ics_3_files_2D(filename);
            
            shape = size(data_2D{1});

            shapes = [shapes;shape];
            shapes_filenames = [shapes_filenames;filename];
           
%             drawnow;
           

       catch exception
            save([error_folder '/' num2str(file_num) '.mat'])

       end


   end


end

save('analyze_size_results.mat','shapes','shapes_filenames')


% u = unique(for_uniques);

