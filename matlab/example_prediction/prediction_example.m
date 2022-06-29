clc;clear all;close all;
addpath('../utils')
addpath('../foci_detection_training')
addpath('../nuclei_segmentation_training')


%% settings

names_53BP1 = {...
    "../../data_zenodo/part2/U87-MG/U87_8h PI/IR 1Gy_8h PI/0013/data_53BP1.tif",
%     "../../data_zenodo/part2/NHDF/NHDF_8h PI/IR 1Gy_8h PI/0029/data_53BP1.tif",
    };


results_folder = '../tmp';
mkdir(results_folder)


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



%% load nets

dlnet_detection = load('../foci_detection_training/detection_model.mat');
parameters_detection = dlnet_detection.optimal_params;
dlnet_detection = dlnet_detection.dlnet;
outputs_detection_chanels = {'points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap'}; 




%% nuclei segmetnation

dlnet_segmentation = load('../nuclei_segmentation_training/segmentation_model.mat','dlnet');
dlnet_segmentation = dlnet_segmentation.dlnet;
dlnet_segmentation = dlnet_segmentation.dlnet;

filenames.imgs_53BP1 = names_53BP1;
filenames.imgs_gH2AX = cellfun(@(x) replace(x,'53BP1','gH2AX'),filenames.imgs_53BP1,'UniformOutput',false);
filenames.imgs_DAPI = cellfun(@(x) replace(x,'53BP1','DAPI'),filenames.imgs_53BP1,'UniformOutput',false);


for img_num = 1:length(filenames.imgs_53BP1)

    fields = fieldnames(filenames);

    data_all = {};
    for field_num = 1:length(fields)
        field = fields{field_num};

        img_filename = filenames.(field){img_num};

        data = single(imread(img_filename));

        img_size = size(data);

        data = imresize3(data,resized_img_size);

        data = norm_percentile_nocrop(data,normalization_percentile);
        
        data_all = [data_all,data];
    end


    data = cat(4,data_all{:});
    data_all = [];

   
    %% IRIF detection
    predicted_detection = predict_by_parts(data(:,:,:,1:2),3,dlnet_detection,patchSize);

    detected_points_all = struct();
    binary_detection_all = struct();
    for out_chanel_index = 1:length(outputs_detection_chanels)
        params = parameters_detection.(outputs_detection_chanels{out_chanel_index});
        detected_points = detect(predicted_detection(:,:,:,out_chanel_index),params.T,params.h,params.d);
        detected_points_all.(outputs_detection_chanels{out_chanel_index}) = detected_points;

        
        binary_detection = false(size(data,[1,2,3]));
        binary_detection(sub2ind(size(data,[1,2,3]),...
            detected_points(:,2),...
            detected_points(:,1),...
            detected_points(:,3))) = true;
        
        binary_detection_all.(outputs_detection_chanels{out_chanel_index}) = binary_detection;
    end

    
    
    

    figure;
    imshow(squeeze(max(data,[],3))+0.5) ;
    hold on
    for out_chanel_index = 1:3
        detected_points=detected_points_all.(outputs_detection_chanels{out_chanel_index});
        plot(detected_points(:,1),detected_points(:,2),'*')
    end
    drawnow;



    
    %% nuclei segmetnation

    mask_predicted = predict_by_parts(data,1,dlnet_segmentation,patchSize);
    mask_split = split_nuclei(mask_predicted>0.5,minimal_nuclei_size,minimal_hole_size,h);
    result_nuclei_segmentation = balloon(mask_split,mask_dilatation);
    
    figure;
    imshow(squeeze(max(data,[],3))+0.5) ;
    hold on
    visboundaries(max(result_nuclei_segmentation,[],3))

    drawnow;








    %% IRIF segmetnation

    [a]=preprocess_filters(data(:,:,:,1),1);
    [b]=preprocess_filters(data(:,:,:,2),1);
    
    ab=a.*b;
    ab = norm_percentile(ab,normalization_percentile) - 0.5;

    ab_binary_detection = binary_detection_all.(outputs_detection_chanels{3});


%     a_uint_whole = uint8(mat2gray(a,[-0.5,0.5])*255).*uint8(result_nuclei_segmentation>0);
%     b_uint_whole = uint8(mat2gray(b,[-0.5,0.5])*255).*uint8(result_nuclei_segmentation>0);
    ab_uint_whole = uint8(mat2gray(ab,[-0.5,0.5])*255).*uint8(result_nuclei_segmentation>0);

    result_irif_segmentation = zeros(size(ab_uint_whole),'uint16');

    s = regionprops(result_nuclei_segmentation>0,'BoundingBox');
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



    figure;
    imshow(squeeze(max(data,[],3))+0.5) ;
    hold on
    visboundaries(max(result_irif_segmentation,[],3))

    drawnow;

    
    
    %% resize to orginal size
    result_irif_segmentation = bwlabeln(result_irif_segmentation);
    result_irif_segmentation = imresize3(result_irif_segmentation,img_size,"Method","nearest");

    result_nuclei_segmentation = bwlabeln(result_nuclei_segmentation);
    result_nuclei_segmentation = imresize3(result_nuclei_segmentation,img_size,"Method","nearest");


    detected_points_all_origsize = struct();
    binary_detection_all_origsize = struct();
    for out_chanel_index = 1:length(outputs_detection_chanels)
    
        detected_points = detected_points_all.(outputs_detection_chanels{out_chanel_index});


        factor = img_size ./ size(data,[1,2,3]);
        detected_points = round(detected_points .* repmat(factor([2,1,3]),[size(detected_points,1),1]));

        binary_detection = false(img_size);
        binary_detection(sub2ind(img_size,...
            detected_points(:,2),...
            detected_points(:,1),...
            detected_points(:,3))) = true;
        
        detected_points_all_origsize.(outputs_detection_chanels{out_chanel_index}) = detected_points;
        binary_detection_all_origsize.(outputs_detection_chanels{out_chanel_index}) = binary_detection;
    end

    

    %% save results
    

    for out_chanel_index = 1:length(outputs_detection_chanels)
        cn = outputs_detection_chanels{out_chanel_index};
        imwrite_uint16_3D([results_folder '/' num2str(img_num,'%03d') '_' cn '_binary_detections' '.tif'],binary_detection_all_origsize.(cn))
    end

    json_data = jsonencode(detected_points_all_origsize);
    fileID = fopen([results_folder '/' num2str(img_num,'%03d') '_' cn '_detections' '.json'],'w');
    fprintf(fileID, json_data);
    fclose(fileID);


    imwrite_uint16_3D([results_folder '/' num2str(img_num,'%03d') '_IRIF_segmentation' '.tif'],result_irif_segmentation)
    imwrite_uint16_3D([results_folder '/' num2str(img_num,'%03d') '_nuclei_segmentation' '.tif'],result_nuclei_segmentation)





end


