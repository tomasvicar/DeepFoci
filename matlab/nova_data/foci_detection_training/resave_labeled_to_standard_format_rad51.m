clc;clear all;close all;
addpath('../../utils')

orig_data_path = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení\RAD51 + gH2AX';
labeled_path = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení_labeling_new\RAD51 + gH2AX';
save_folder = 'C:\Data\Vicar\foky_final_cleaning\FOR ANALYSIS\Prioritně + 15N  ion tracks (originálně z Acquiarium) pro analýzu a nové učení_resaved_labeled\RAD51 + gH2AX';




orig_filenames = subdirx([orig_data_path '/*01.ics']);

labled_filenames = subdirx([labeled_path '/*' 'result*.mat']);
pos = regexp(labled_filenames,'result\d\d\d\.mat$');
labled_filenames = labled_filenames(cellfun(@(x) ~isempty(x),pos));




labled_filenames_pahts = cellfun(@(x) fileparts(x),labled_filenames,'UniformOutput',false);

counter = 0;
unique_folders = unique(labled_filenames_pahts);
for unique_folder = unique_folders
    counter = counter +1;
    disp([num2str(counter) ' / ' num2str(length(unique_folders)) ])
    
    unique_folder_labled = unique_folder{1};
    unique_folder_orig = replace(unique_folder_labled,labeled_path,orig_data_path);
    unique_folder_save = replace(unique_folder_labled,labeled_path,save_folder);
    
    
    orig_filename = orig_filenames(cellfun(@(x)  contains(x,unique_folder_orig), orig_filenames));
    labeled_filenames_allcells = labled_filenames(cellfun(@(x)  contains(x,unique_folder_labled), labled_filenames));
    


    if exist([replace(char(orig_filename),'01.ics','') 'fov.txt'],'file')
        name_fov_file = [replace(char(orig_filename),'01.ics','') 'fov.txt'];
    elseif exist([replace(char(orig_filename),'01.ics','') 'roi.txt'],'file')
        name_fov_file = [replace(char(orig_filename),'01.ics','') 'roi.txt'];
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
        error('gfdgdfg')
    end
    
    order = [0,0,0];
    if (contains(lower(chanel_names{1}),'53bp1')||contains(lower(chanel_names{1}),'rad51'))
        order(1) = 1;
    elseif (contains(lower(chanel_names{2}),'53bp1')||contains(lower(chanel_names{2}),'rad51'))
        order(1) = 2;
    elseif (contains(lower(chanel_names{3}),'53bp1')||contains(lower(chanel_names{3}),'rad51'))  
        order(1) = 3;
    else
        error('gfdgdfg')
    end

    if contains(lower(chanel_names{1}),'gh2ax')
        order(2) = 1;
    elseif contains(lower(chanel_names{2}),'gh2ax')
        order(2) = 2;
    elseif contains(lower(chanel_names{3}),'gh2ax') 
        order(2) = 3;
    else
        error('gfdgdfg')
    end

    if (contains(lower(chanel_names{1}),'dapi')||contains(lower(chanel_names{1}),'topro'))
        order(3) = 1;
    elseif (contains(lower(chanel_names{2}),'dapi')||contains(lower(chanel_names{2}),'topro'))
        order(3) = 2;
    elseif (contains(lower(chanel_names{3}),'dapi')||contains(lower(chanel_names{3}),'topro'))  
        order(3) = 3;
    else
        error('gfdgdfg')
    end
    disp('corrected order:')
    disp(chanel_names(order))


    

    
    if isempty(labeled_filenames_allcells)
        
        save(['errors/' replace(replace(datestr(now),' ','_'),':','_') 'no_cells.mat'],'orig_filename')
        continue
    end

    data = read_ics_3_files(replace(char(orig_filename),'01.ics',''));
    data = data([2,1,3]);
    data = data(order);
    

%     imshow(imadjust(max(data{1},[],3)))
%     hold on

    all_points_r = [];
    all_points_g = [];

    for labeled_cell_num = 1:length(labeled_filenames_allcells)
        labeled_filename_allcells = labeled_filenames_allcells{labeled_cell_num};
        labeled_filename_allcells_input = replace(labeled_filename_allcells,'result','cell');
        
        
        lbls = load(labeled_filename_allcells);
        input = load(labeled_filename_allcells_input); 

        if ~isempty(lbls.points_R)
            all_points_r = [all_points_r;lbls.points_R + floor(input.bb(1:3))];
        end
        if ~isempty(lbls.points_G)
            all_points_g = [all_points_g;lbls.points_G + floor(input.bb(1:3))];
        end


    end

    mkdir(unique_folder_save)
    imwrite_uint16_3D([unique_folder_save '/data_RAD51.tif'],data{1})
    imwrite_uint16_3D([unique_folder_save '/data_gH2AX.tif'],data{2})
    imwrite_uint16_3D([unique_folder_save '/data_DAPI.tif'],data{3})


    s = struct();
    s.points_RAD51 = all_points_r;
    s.points_gH2AX = all_points_g;
    json_data = jsonencode(s);
    fileID = fopen([unique_folder_save '/labels.json'],'w');
    fprintf(fileID, json_data);
    fclose(fileID);

    drawnow; 

    
%     plot(all_points_r(:,1), all_points_r(:,2),'r*')
%     plot(all_points_g(:,1), all_points_g(:,2),'g*')
%     
%     drawnow;
% 
% %     all_points_r = all_points_r(:,[2,1,3]); %% should be in order without reordering - correnct in plot
% %     all_points_g = all_points_g(:,[2,1,3]);
%     bin = zeros(size(data{1}));
%     positions_linear= sub2ind(size(bin),all_points_r(:,2),all_points_r(:,1),all_points_r(:,3));
%     bin(positions_linear) = true;
%     hold off;
%     imshow(imadjust(max(bin,[],3)),[])
%     drawnow;

    
    
    
    
end








