clc;clear all;close all;
addpath('../utils')


data_folders = {...
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Late gH2AX+53BP1 foci - different IR types, doses, cell types';
%     'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\15N 90st 4Gy NHDF+U87 gH2AX+53BP1';
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení';
    };


for data_folder_num = 1:length(data_folders)

    data_folder = data_folders{data_folder_num};
    error_folder = split(data_folder,'\');
    error_folder = [error_folder{end} '_labeling_new'];
    mkdir(error_folder)
    
    mkdir(error_folder)
    
    results_folder = [data_folder '_labeling_new'];

    results_folder_oldseg = [data_folder '_net_results_oldseg'];
    results_folder_fociseg = [data_folder '_fociseg'];
    results_folder_examle_fociseg = [data_folder '_example_fociseg'];
    results_folder_res1 = [data_folder '_net_results'];

    filenames = subdir([data_folder '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);

    for file_num = 1:length(filenames) %254
        try
%         if 1
            disp(file_num)
            filename = filenames{file_num};
            filename_save_labeling_new = [results_folder, replace(filename,data_folder,'')];
            mkdir(filename_save_labeling_new)


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
%             channels_check = [channels_check;chanel_names(order)];
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

            

            filename_save_fociseg = [results_folder_fociseg, replace(filename,data_folder,'')];
            filename_save_oldseg = [results_folder_oldseg, replace(filename,data_folder,'')];
            filename_save_res1= [results_folder_res1, replace(filename,data_folder,'')];


            resized_img_size = [505  681   48];
            img_size = size(data{1});

%             for channel_num = 1:3
%                 data{channel_num} = imresize3(single(data{channel_num}),resized_img_size);
%             end

            a = data{1};
            b = data{2};
            c = data{3};
            clear data; 
           
           
            segmentation = imread([filename_save_oldseg 'nuclei_semgentaton.tif']);
            segmentation = bwlabeln(segmentation);
            segmentation = imresize3(segmentation, img_size,'Method','nearest');

            result_irif_segmentation = imread([filename_save_fociseg 'foci_semgentaton.tif']);

            af = preprocess_filters(a,1);
            bf = preprocess_filters(b,1);
            cf = preprocess_filters(c,1);

            mask = bwlabeln(segmentation);
            bbs = regionprops3(mask,'BoundingBox');
            bbs = bbs.BoundingBox;
            
            for bb_num = 1:size(bbs,1)

                bb = bbs(bb_num,:);
        
                img_crop = apply_bb(cat(4,af,bf,cf),bb);
                mask_crop = apply_bb(cat(4,mask==bb_num),bb);
                img_crop = uint16(img_crop);
                
                img_crop_orig = apply_bb(cat(4,a,b,c),bb);
                img_crop_orig = uint16(img_crop_orig);
                
                
                rImg_main=max(img_crop(:,:,:,1),[],3);
                gImg_main=max(img_crop(:,:,:,2),[],3);
                bImg_main=max(img_crop(:,:,:,3),[],3);
        
                rImg_left=squeeze(max(img_crop(:,:,:,1),[],2));
                gImg_left=squeeze(max(img_crop(:,:,:,2),[],2));
                bImg_left=squeeze(max(img_crop(:,:,:,3),[],2));
        
                rImg_right=squeeze(max(img_crop(:,:,:,1),[],2));
                gImg_right=squeeze(max(img_crop(:,:,:,2),[],2));
                bImg_right=squeeze(max(img_crop(:,:,:,3),[],2));
        
                rImg_right=rImg_right(:,end:-1:1);
                gImg_right=gImg_right(:,end:-1:1);
                bImg_right=bImg_right(:,end:-1:1);
        
                rImg_down=squeeze(max(img_crop(:,:,:,1),[],1))';
                gImg_down=squeeze(max(img_crop(:,:,:,2),[],1))';
                bImg_down=squeeze(max(img_crop(:,:,:,3),[],1))';
                
                
                tmp = img_crop(:,:,:,1);
                p95_R = prctile(tmp(mask_crop),95);
                tmp = img_crop(:,:,:,2);
                p95_G = prctile(tmp(mask_crop),95);
                
                
                
                
                rImg_main_orig=max(img_crop_orig(:,:,:,1),[],3);
                gImg_main_orig=max(img_crop_orig(:,:,:,2),[],3);
                bImg_main_orig=max(img_crop_orig(:,:,:,3),[],3);
        
                rImg_left_orig=squeeze(max(img_crop_orig(:,:,:,1),[],2));
                gImg_left_orig=squeeze(max(img_crop_orig(:,:,:,2),[],2));
                bImg_left_orig=squeeze(max(img_crop_orig(:,:,:,3),[],2));
        
                rImg_right_orig=squeeze(max(img_crop_orig(:,:,:,1),[],2));
                gImg_right_orig=squeeze(max(img_crop_orig(:,:,:,2),[],2));
                bImg_right_orig=squeeze(max(img_crop_orig(:,:,:,3),[],2));
        
                rImg_right_orig=rImg_right_orig(:,end:-1:1);
                gImg_right_orig=gImg_right_orig(:,end:-1:1);
                bImg_right_orig=bImg_right_orig(:,end:-1:1);
        
                rImg_down_orig=squeeze(max(img_crop_orig(:,:,:,1),[],1))';
                gImg_down_orig=squeeze(max(img_crop_orig(:,:,:,2),[],1))';
                bImg_down_orig=squeeze(max(img_crop_orig(:,:,:,3),[],1))';
                
                
                tmp = img_crop_orig(:,:,:,1);
                p95_R_orig = prctile(tmp(mask_crop),95);
                tmp = img_crop_orig(:,:,:,2);
                p95_G_orig = prctile(tmp(mask_crop),95);
                
                
                
        
                
                save([filename_save_labeling_new '/cell' num2str(bb_num,'%03.f') '.mat'],'img_crop','mask_crop','bb',...
                    'rImg_main','gImg_main','bImg_main',...
                    'rImg_left','gImg_left','bImg_left',...
                    'rImg_right','gImg_right','bImg_right',...
                    'rImg_down','gImg_down','bImg_down',...
                    'p95_R','p95_G','-v7.3')
                
                
                
                save([filename_save_labeling_new '/cell_orig' num2str(bb_num,'%03.f') '.mat'],'img_crop_orig','mask_crop','bb',...
                    'rImg_main_orig','gImg_main_orig','bImg_main_orig',...
                    'rImg_left_orig','gImg_left_orig','bImg_left_orig',...
                    'rImg_right_orig','gImg_right_orig','bImg_right_orig',...
                    'rImg_down_orig','gImg_down_orig','bImg_down_orig',...
                    'p95_R_orig','p95_G_orig','-v7.3')

                drawnow;


            end




        catch exception
            save([error_folder '/' num2str(file_num) '.mat'])


        end

    end
end
