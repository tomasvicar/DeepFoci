function data = matReader(tmp_filename,type,data_path,tmp_folder,img_size)

    %% replace tmp name with true filename and get part number (1-4)
    tmp_filename = replace(tmp_filename,'.mat','');

    num = str2num(tmp_filename(end));
    tmp_filename = tmp_filename(1:end-1);
    filename_img = replace(tmp_filename,'tmpmatfile','');

    data_path = replace(data_path,'\','/');
    tmp_folder = replace(tmp_folder,'\','/');
    filename_img = replace(filename_img,'\','/');

    filename_img = replace(filename_img,tmp_folder,data_path);
    filename_img = [filename_img '.mat'];


    %% based on number (1-4) select some part of image to read
    if num==1
        postion_vec1=1:floor(img_size(1)/2)+20;
        postion_vec2=1:floor(img_size(2)/2)+20;
    elseif num==2
        postion_vec1=floor(img_size(1)/2)-20:img_size(1);
        postion_vec2=1:floor(img_size(2)/2)+20;
    elseif num==3
        postion_vec1=1:floor(img_size(1)/2)+20;
        postion_vec2=floor(img_size(2)/2)-20:img_size(2);
    elseif num==4
        postion_vec1=floor(img_size(1)/2)-20:img_size(1);
        postion_vec2=floor(img_size(2)/2)-20:img_size(2);   
    elseif num==0
        postion_vec1 = 1:img_size(1);
        postion_vec2 = 1:img_size(2);
    end



    %% read data
    if strcmp(type,'mask')
        tmp = filename_img;
        [filepath,name,ext] = fileparts(tmp);
        filename_img = [filepath, '/mask' name(5:end) ext];
    end
    

    matObject = matfile(filename_img);
    if strcmp(type,'mask')
        data=single(matObject.data(postion_vec1,postion_vec2,:));
        data = cat(4,data);
    else
        data=single(matObject.data(postion_vec1,postion_vec2,:,:));
    end




    
end




    