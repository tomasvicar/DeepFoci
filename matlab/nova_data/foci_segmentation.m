clc;clear all;close all;
% rmpath('../utils')
% rmpath('../nuclei_segmentation_training')
% addpath('../utils_old')
% addpath('../3DNucleiSegmentation_training')

rmpath('../utils_old')
rmpath('../3DNucleiSegmentation_training')
addpath('../utils')


data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP2';
    };


% for_uniques = {};
% wholes = {};
% for data_folder_num = 1:length(data_folders)
% 
%     data_folder = data_folders{data_folder_num};
%     
%     
%     error_folder = split(data_folder,'\');
%     error_folder = [error_folder{end} '_prediction_colorfix'];
% 
%     listing = subdir([error_folder '/*.mat']);
% 
%     for error_num = 1:length(listing)
%         error_name = listing(error_num).name;
%         
%         load(error_name,'filename')
% 
%         tmp = split(filename,'\');
%         whole = join(tmp(end-5:end-1),'\');
%         whole = whole{1};
%         for_unique = join(tmp(end-5:end-3),'\');
%         for_unique = for_unique{1};
% 
%         for_uniques = [for_uniques,for_unique];
%         wholes = [wholes,whole];
%     end
% 
% 
% end




outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 



resized_img_size = [505  681   48]; %image is resized to this size
normalization_percentile = 0.0001;  %image is normalized into this percentile range
patchSize = [96 96 48];

minimal_nuclei_size = 10000;
minimal_hole_size = 10000;
mask_dilatation=[14 14 5];
h=2;


MinDiversity = 0.1;
MaxVariation = 0.95;
Delta = 1;
MinArea = 8;
MaxArea = 1000;


% errory navíc

channels_check = {};
for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} 'dodelavky_foci_seg'];
    mkdir(error_folder)
    
    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];
    
    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    
    for file_num = 1:length(filenames)
        try
%         if 1
            disp(data_folder)
            disp([num2str(file_num) '/' num2str(length(filenames))])

        
            filename = filenames{file_num};

%             if ~any(cellfun(@(x) contains(filename,x), wholes))
%                 disp("hotovo")
%                 continue;
%             end
        
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
            
            for channel_num = 1:3
                data{channel_num} = imresize3(single(data{channel_num}),resized_img_size);
            end


            detections = jsondecode(fileread([filename_save_res1 'detections.json']));
            detected_points = detections.(outputs_detection_chanels{3});
            if isempty(detected_points)
                detected_points = zeros(0,3);
            end
            if numel(detected_points)==3
                detected_points = detected_points';
            end
            binary_detection = false(size(data{1},[1,2,3]));
            binary_detection(sub2ind(size(data{1},[1,2,3]),...
                detected_points(:,2),...
                detected_points(:,1),...
                detected_points(:,3))) = true;
            



            result_nuclei_segmentation = imread([filename_save_oldseg 'nuclei_semgentaton.tif']);
            result_nuclei_segmentation = imresize3(result_nuclei_segmentation, resized_img_size,'Method','nearest');
            
            [a]=preprocess_filters(data{1},1);
            [b]=preprocess_filters(data{2},1);
            
            ab=a.*b;
            ab = norm_percentile(ab,normalization_percentile) - 0.5;
        
            ab_binary_detection = binary_detection;
        
            ab_uint_whole = uint8(mat2gray(ab,[-0.5,0.5])*255).*uint8(result_nuclei_segmentation>0);
        
            result_irif_segmentation = zeros(size(ab_uint_whole),'uint16');
            result_irif_segmentation_unproceessed = zeros(size(ab_uint_whole),'uint16');
        
            s = regionprops(result_nuclei_segmentation,'BoundingBox');
            bbs = cat(1,s.BoundingBox);
            for cell_num =1:size(bbs,1)
                bb=round(bbs(cell_num,:));
        %          a_uint = a_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
        %          b_uint = b_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
                ab_uint = ab_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
                
                ab_binary_detection_crop = ab_binary_detection(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
        
                r = vl_mser(ab_uint,'MinDiversity',MinDiversity,...
                    'MaxVariation',MaxVariation,...
                    'Delta',Delta,...
                    'MinArea', MinArea/ numel(ab_uint),...
                    'MaxArea', MaxArea/ numel(ab_uint));
        
                M = zeros(size(ab_uint),'uint16') ;
                for x=1:length(r)
                    s = vl_erfill(ab_uint,r(x)) ;
                    M(s) = M(s) + 1;
                end

                result_irif_segmentation_unproceessed(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1) = M;
        
                tmp = -double(ab_uint);
                tmp = imimposemin(tmp,ab_binary_detection_crop);
                ab_wateshed = watershed(tmp)>0;
                ab_wateshed(M==0) = 0;
                ab_wateshed = imfill(ab_wateshed,'holes');
        
                D = bwdistsc(ab_wateshed,[1,1,3]);
                D = imhmax(D,1);
        
                wab_krajeny_orez = (watershed(-D)>0) & ab_wateshed;
                
                
                L=bwlabeln(ab_wateshed);
                s=regionprops3(L,ab_binary_detection_crop,'MaxIntensity');
                s = s.MaxIntensity;
                for k=1:length(s)
                    if s(k)==0
                        L(L==k)=0;
                    end
                end
                ab_wateshed=L>0;
        
        
        
                result_irif_segmentation(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1) = ab_wateshed;
        
        
        
        
            end

            drawnow;

            imwrite_uint16_3D([filename_save_fociseg 'foci_semgentaton_unprocessed.tif'],result_irif_segmentation_unproceessed)

            imwrite_uint16_3D([filename_save_fociseg 'foci_semgentaton.tif'],result_irif_segmentation)







       catch exception
            save([error_folder '/' num2str(file_num) '.mat'])

       end


   end


end


