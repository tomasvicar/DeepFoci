rmpath('../utils_old')
rmpath('../3DNucleiSegmentation_training')
addpath('../utils')


data_folders = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} 'dodelavky_foci_seg'];
    mkdir(error_folder)
    
    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];
    results_folder_rad51 = [data_folder '_rad51'];
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    
    for file_num = 1:length(filenames)
        disp(data_folder)
        disp([num2str(file_num) '/' num2str(length(filenames))])

    
        filename = filenames{file_num};

    
        filename_save_fociseg = [results_folder_fociseg, replace(filename,data_folder,'')];
%             if exist([filename_save_fociseg 'foci_semgentaton.tif'],'file')
%                 continue;
%                 disp('continue')
%             end
        mkdir(filename_save_fociseg)
%             filename_save_examle_fociseg= [results_folder_examle_fociseg, replace(filename,data_folder,'')];
%             mkdir(filename_save_examle_fociseg)

        filename_save_oldseg = [results_folder_oldseg, replace(filename,data_folder,'')];
        filename_save_res1= [results_folder_res1, replace(filename,data_folder,'')];
        filename_save_rad51= [results_folder_rad51, replace(filename,data_folder,'')];
       
        %%%% dodelani kanalu
        if exist([filename 'fov.txt'],'file')
            name_fov_file = [filename 'fov.txt'];
        elseif exist([filename 'roi.txt'],'file')
            name_fov_file = [filename 'roi.txt'];
        else
            error('no textfile')
        end
        chanel_names={};
        fid = fopen(name_fov_file);
        tline = 'dfdf';
        while ischar(tline)
            if contains(tline,'Name=')
                chanel_names=[chanel_names tline(6:end)];
            end
            tline = fgetl(fid);
        end
        fclose(fid);

        if length(chanel_names)~=3
            save([error_folder '/' num2str(file_num) 'no_channels.mat'])
            continue
        end

%             disp(chanel_names)
%             if contains(lower(chanel_names{1}),'gh2ax') && (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
%                 disp('chanels ok')
%                 channels_check = [channels_check;chanel_names([2,1,3])];
%                 continue
%             end
       
        order = [0,0,0];
        if (contains(lower(chanel_names{1}),'53bp1')||contains(lower(chanel_names{1}),'rad51'))
            order(1) = 1;
        elseif (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
            order(1) = 2;
        elseif (contains(lower(chanel_names{3}),'53bp1')||contains(lower(chanel_names{3}),'rad51'))  
            order(1) = 3;
        else
            save([error_folder '/channelproblem' num2str(file_num) '.mat'])
            continue;
        end

        if contains(lower(chanel_names{1}),'gh2ax')
            order(2) = 1;
        elseif contains(lower(chanel_names{2}),'gh2ax')
            order(2) = 2;
        elseif contains(lower(chanel_names{3}),'gh2ax') 
            order(2) = 3;
        else
            save([error_folder '/channelproblem' num2str(file_num) '.mat'])
            continue;
        end

        if (contains(lower(chanel_names{1}),'dapi')||contains(lower(chanel_names{1}),'topro'))
            order(3) = 1;
        elseif (contains(lower(chanel_names{2}),'dapi')||contains(lower(chanel_names{2}),'topro'))
            order(3) = 2;
        elseif (contains(lower(chanel_names{3}),'dapi')||contains(lower(chanel_names{3}),'topro'))  
            order(3) = 3;
        else
            save([error_folder '/channelproblem' num2str(file_num) '.mat'])
            continue;
        end
        disp('corrected order:')
        disp(chanel_names(order))
        channels_check = [channels_check;chanel_names(order)];
        %%%% dodelani kanalu

        if ~(contains(lower(chanel_names{1}),'rad51') || contains(lower(chanel_names{2}),'rad51') ||contains(lower(chanel_names{3}),'rad51'))
            continue
        end


        clear data;clear a;clear b;clear c;clear predicted_detection;
        try
            data = read_ics_3_files(filename);
        catch exception
            save([error_folder '/' num2str(file_num) '.mat'])
            continue;
        end
        if length(size(data{1}))~=3
            save([error_folder '/' num2str(file_num) 'size_error.mat']) 
            continue
        end

        %%%% dodelani kanalu
        data = data([2,1,3]);
        data = data(order);
        %%%% dodelani kanalu
        


       
        segmentation = imread([filename_save_oldseg 'nuclei_semgentaton.tif']);
        
        segmentation = bwlabeln(segmentation);
        

        data{1} = preprocess_filters(data{1},1);
        data{2} = preprocess_filters(data{2},1);
        data{3} = preprocess_filters(data{3},1);

        data = single(cat(3,max(data{1},[],3),max(data{2},[],3),max(data{3},[],3)));
        data(:,:,1) = norm_percentile(data(:,:,1),0.0001);
        data(:,:,2) = norm_percentile(data(:,:,2),0.0001);
        data(:,:,3) = norm_percentile(data(:,:,3),0.0001);
        
        
        segmentation = max(segmentation,[],3);

        mkdir(filename_save_rad51)
        save([filename_save_rad51 'for_class.mat'],'segmentation','data','-v7.3')
        



    end


end