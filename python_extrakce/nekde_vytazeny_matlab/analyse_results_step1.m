clc; clear all; close all;
addpath('../utils')

folders_data = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP',
    };
folders_detection = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP_net_results_rad51_2',
    };
folders_cellseg = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP_net_results_oldseg',
    };
folders_fociseg = {...
    'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\NANOREP_fociseg_rad51_2',
    };


outputs_detection_chanelss = {{'points_RAD51','points_gH2AX','points_53BP1_gH2AX_overlap'}};


file_counter = 0;

for folder_num = 1
    folder_data = folders_data{folder_num};
    folder_detection = folders_detection{folder_num};
    folder_cellseg = folders_cellseg{folder_num};
    folder_fociseg = folders_fociseg{folder_num};
    outputs_detection_chanels = outputs_detection_chanelss{folder_num};

    filenames = subdir([folder_data '/*01.ics']);
    filenames = {filenames(:).name};
    filenames = cellfun(@(x) replace(x,'01.ics',''),filenames,'UniformOutput',false);


    for file_num = 628:length(filenames)
        file_counter = file_counter + 1;

        if file_counter == 378
            continue
        end
        if file_counter == 379
            continue
        end
        if file_counter == 543
            continue
        end
        if file_counter == 627
            continue
        end

        filename = filenames{file_num};
        [data] = read_data_ordered(filename);

        filename_cellseg = [replace(filename,folder_data,folder_cellseg) 'nuclei_semgentaton.tif'];
        result_nuclei_segmentation = imread(filename_cellseg);
        result_nuclei_segmentation  = imresize3(result_nuclei_segmentation, size(data{1}),'Method','nearest');


        resized_img_size = [505  681   48];
        resize_factor = size(data{1}) ./ resized_img_size;
        filename_cellseg = [replace(filename,folder_data,folder_detection) 'detections.json'];
        detections_tmp = jsondecode(fileread(filename_cellseg));

        detections = struct();
        binary_detection = struct();
        channels = {'r','g','rg'};
        for outputs_detection_chanel_num =1:length(outputs_detection_chanels)

            
            detected_points = detections_tmp.(outputs_detection_chanels{outputs_detection_chanel_num});
            if isempty(detected_points)
                detected_points = zeros(0,3);
            end
            if numel(detected_points)==3
                detected_points = detected_points';
            end
            detected_points(:,2) = round(detected_points(:,2) * resize_factor(2));
            detected_points(:,1) = round(detected_points(:,1) * resize_factor(1));
            detected_points(:,3) = round(detected_points(:,3) * resize_factor(3));

            detections.(channels{outputs_detection_chanel_num}) = detected_points;

            binary_detection.(channels{outputs_detection_chanel_num}) = false(size(data{1},[1,2,3]));
            binary_detection.(channels{outputs_detection_chanel_num})(sub2ind(size(data{1},[1,2,3]),...
               detected_points(:,2),...
               detected_points(:,1),...
               detected_points(:,3))) = true;
        end


        filename_fociseg = [replace(filename,folder_data,folder_fociseg) 'foci_semgentaton.tif'];
        result_foci_segmentation = imread(filename_fociseg);
        result_foci_segmentation = imresize3(result_foci_segmentation,size(data{1}),'Method','nearest');


        voxel_size_um=[0.1650,0.1650,0.3];
        z_resize_faktor=1.8182;

        a = single(data{1});
        b = single(data{2});
        c = single(data{3});

        clear data;


%         for k = 1:length(data)
%         
%             tmp = single(data{k});
%     
%             tmp = norm_percentile_nocrop(tmp,0.0001);
%     
%             data_norm{k} = tmp;
%         end
% 
%         figure;
%         imshow(squeeze(max(cat(4,data_norm{:}),[],3))+0.5) ;
%         hold on
%         visboundaries(max(result_nuclei_segmentation,[],3))
%         for out_chanel_index = 1:3
%             detected_points=detections.(channels{out_chanel_index});
%             plot(detected_points(:,1),detected_points(:,2),'*')
%         end
%         drawnow;

        L_nuc = bwlabeln(result_nuclei_segmentation);
        L_res = bwlabeln(result_foci_segmentation);

        r_table = regionprops3(L_res,a,'MaxIntensity','MeanIntensity');
        r_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityR';
        r_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityR';

        g_table = regionprops3(L_res,b,'MaxIntensity','MeanIntensity');
        g_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityG';
        g_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityG';

        b_table = regionprops3(L_res,c,'MaxIntensity','MeanIntensity');
        b_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityB';
        b_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityB';
        
        rg_table = regionprops3(L_res,a.*b,'MaxIntensity','MeanIntensity');
        rg_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityRG';
        rg_table.Properties.VariableNames{'MeanIntensity'}='MeanIntensityRG';

        nuc_num_table = regionprops3(L_res,L_nuc,'MaxIntensity');
        nuc_num_table.Properties.VariableNames{'MaxIntensity'}='NucNum';

        shape=size(L_res);
        L_res_resize=imresize3(L_res ,[shape(1),shape(2),round(shape(3)*z_resize_faktor)],'nearest');
        shape_table = regionprops3(L_res_resize,'Volume','Solidity','SurfaceArea','EigenValues');


        N = max(L_res(:));
        correltaion = zeros(N,1);
        correltaion_spearman = zeros(N,1);
        for k = 1:N
            tmp_r = a(L_res==k);
            tmp_g = b(L_res==k);
            correltaion(k) = corr(tmp_r(:),tmp_g(:));
            correltaion_spearman(k) = corr(tmp_r(:),tmp_g(:),'Type','Spearman');
        end
            
        rg_table = addvars(rg_table,correltaion,'NewVariableNames','Correltaion');
        rg_table = addvars(rg_table,correltaion_spearman,'NewVariableNames','Correltaion_spearman');

        if isempty(shape_table)
            shape_table.EigenValues = {};
        end

        tmp = cellfun(@(x) x(1),shape_table.EigenValues);
        shape_table =  addvars(shape_table,tmp,'NewVariableNames','EigenValues1');
        tmp = cellfun(@(x) x(2),shape_table.EigenValues);
        shape_table =  addvars(shape_table,tmp,'NewVariableNames','EigenValues2');
        tmp = cellfun(@(x) x(3),shape_table.EigenValues);
        shape_table =  addvars(shape_table,tmp,'NewVariableNames','EigenValues3');
        shape_table = removevars(shape_table,'EigenValues');
        
        shape_table.Volume = shape_table.Volume*(voxel_size_um(1)^3);
        shape_table.Properties.VariableNames{'Volume'}='VolumeUm';
        
        shape_table.SurfaceArea = shape_table.SurfaceArea*(voxel_size_um(1)^2);
        shape_table.Properties.VariableNames{'SurfaceArea'}='SurfaceAreaUm';
        
        shape_table.EigenValues1 = shape_table.EigenValues1*(voxel_size_um(1));
        shape_table.Properties.VariableNames{'EigenValues1'}='EigenValues1Um';
        
        shape_table.EigenValues2 = shape_table.EigenValues2*(voxel_size_um(1));
        shape_table.Properties.VariableNames{'EigenValues2'}='EigenValues2Um';
        
        shape_table.EigenValues3 = shape_table.EigenValues3*(voxel_size_um(1));
        shape_table.Properties.VariableNames{'EigenValues3'}='EigenValues3Um';
        
        
        foci_features  = [r_table,g_table,b_table,rg_table,shape_table, nuc_num_table];


        shape=size(L_nuc);
        L_nuc_resize=imresize3(L_nuc,[shape(1),shape(2),round(shape(3)*z_resize_faktor)],'nearest');
        nuc_features = regionprops3(L_nuc,'Volume');
        nuc_features.Volume = nuc_features.Volume*(voxel_size_um(1)^3);
        nuc_features.Properties.VariableNames{'Volume'}='VolumeUm';
            
        
        vec = @(x) x(:);
        perc = @(x) prctile(x,99);
        
        N = max(L_nuc(:));

        MedianRNuc = zeros(N,1);
        MedianGNuc = zeros(N,1);
        MedianBNuc = zeros(N,1);
        MedianRGNuc = zeros(N,1);

        Percetile99RNuc = zeros(N,1);
        Percetile99GNuc = zeros(N,1);
        Percetile99BNuc = zeros(N,1);
        Percetile99RGNuc = zeros(N,1);
       
        CorrelationNuc = zeros(N,1);
        CorrelationNuc_Spearman = zeros(N,1);

        ab = a.*b;
        
        for cell_num = 1 : N
            mask3d = L_nuc == cell_num;
        
            MedianRNuc(cell_num) = median(vec(a(mask3d)));
            MedianGNuc(cell_num) = median(vec(b(mask3d)));
            MedianBNuc(cell_num) = median(vec(c(mask3d)));
            MedianRGNuc(cell_num) = median(vec(ab(mask3d)));
            
            Percetile99RNuc(cell_num) = perc(vec(a(mask3d)));
            Percetile99GNuc(cell_num) = perc(vec(b(mask3d)));
            Percetile99BNuc(cell_num) = perc(vec(c(mask3d)));
            Percetile99RGNuc(cell_num) = perc(vec(ab(mask3d)));

            tmp_r = a(mask3d);
            tmp_g = b(mask3d);
            CorrelationNuc(cell_num) = corr(tmp_r(:),tmp_g(:));
            CorrelationNuc_Spearman(cell_num) = corr(tmp_r(:),tmp_g(:),'Type','Spearman');
        end
            
        nuc_features =  addvars(nuc_features,MedianRNuc,'NewVariableNames','MedianRNuc');
        nuc_features =  addvars(nuc_features,MedianGNuc,'NewVariableNames','MedianGNuc');
        nuc_features =  addvars(nuc_features,MedianBNuc,'NewVariableNames','MedianBNuc');
        nuc_features =  addvars(nuc_features,MedianRGNuc,'NewVariableNames','MedianRGNuc');
        
        nuc_features =  addvars(nuc_features,Percetile99RNuc,'NewVariableNames','Percetile99RNuc');
        nuc_features =  addvars(nuc_features,Percetile99GNuc,'NewVariableNames','Percetile99GNuc');
        nuc_features =  addvars(nuc_features,Percetile99BNuc,'NewVariableNames','Percetile99BNuc');
        nuc_features =  addvars(nuc_features,Percetile99RGNuc,'NewVariableNames','Percetile99RGNuc');
        
        nuc_features =  addvars(nuc_features,CorrelationNuc,'NewVariableNames','CorrelationNuc');
        nuc_features =  addvars(nuc_features,CorrelationNuc_Spearman,'NewVariableNames','CorrelationNuc_Spearman');




        a = imgaussfilt3(a,[2,2,1]);
        b = imgaussfilt3(b,[2,2,1]);
        c = imgaussfilt3(c,[2,2,1]);
        
        channels = {'r','g','rg'};
        for channel_num = 1:length(channels)
            channel = channels{channel_num};

            tmp = bwlabeln( binary_detection.(channels{channel_num}));

            r_table = regionprops3(tmp,a,'MaxIntensity');
            r_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityR';
    
            g_table = regionprops3(tmp,b,'MaxIntensity');
            g_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityG';
    
            b_table = regionprops3(tmp,c,'MaxIntensity');
            b_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityB';
            
            rg_table = regionprops3(tmp,a.*b,'MaxIntensity');
            rg_table.Properties.VariableNames{'MaxIntensity'}='MaxIntensityRG';


            nuc_num_table = regionprops3(tmp,L_nuc,'MaxIntensity');
            nuc_num_table.Properties.VariableNames{'MaxIntensity'}='NucNum';
            
             eval(['foci_features_'  channel ' = [r_table,g_table,b_table,rg_table,nuc_num_table];']);
        end

        

        folder = 'extracted_features';
        mkdir(folder)
        save([folder '/' num2str(file_counter,'%05.f') '.mat'],'filename', 'nuc_features', 'foci_features', 'foci_features_r', 'foci_features_g', 'foci_features_rg')
        
        drawnow;
    end
end


