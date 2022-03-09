function data = matReader(tmp_filename,type,chanel_names,data_path,tmp_folder,img_size)

    %% replace tmp name with true filename and get part number (1-4)
    tmp_filename = replace(tmp_filename,'.mat','');

    num = str2num(tmp_filename(end));
    tmp_filename = tmp_filename(1:end-1);
    file_folder = replace(tmp_filename,'tmpmatfile','');

    data_path = replace(data_path,'\','/');
    tmp_folder = replace(tmp_folder,'\','/');
    file_folder = replace(file_folder,'\','/');

    file_folder = replace(file_folder,tmp_folder,data_path);


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
    data_all = {};
    for chanel_name = chanel_names
        chanel_name = chanel_name{1};

        name = [file_folder chanel_name '.mat'];
        matObject = matfile(name);
        data=single(matObject.data(postion_vec1,postion_vec2,:));

        %create gaussings from points
        if strcmp(type,'mask')
            data = imgaussfilt3(single(data),[2,2,1])*59.5238*10;
        end


        data_all = [data_all, data];

    end


    data = cat(4,data_all{:});


    
end




    