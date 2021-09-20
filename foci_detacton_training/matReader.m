function data = matReader(filename,type,imgs2read)


    num=str2num(filename(end));
    filename=filename(1:end-1);
    
    size_v=[505  681   48];
    
    if num==1
        postion_vec1=1:floor(size_v(1)/2)+20;
        postion_vec2=1:floor(size_v(2)/2)+20;
    elseif num==2
        postion_vec1=floor(size_v(1)/2)-20:size_v(1);
        postion_vec2=1:floor(size_v(2)/2)+20;
    elseif num==3
        postion_vec1=1:floor(size_v(1)/2)+20;
        postion_vec2=floor(size_v(2)/2)-20:size_v(2);
    elseif num==4
        postion_vec1=floor(size_v(1)/2)-20:size_v(1);
        postion_vec2=floor(size_v(2)/2)-20:size_v(2);   
    end
        
    
    name_53BP1 = filename;
    if strcmp(type,'data')
        
        data_all = {};
        for img = imgs2read
            img = img{1};
            
            if strcmp(img,'a')

                name = name_53BP1;
                matObject = matfile(name);
                data=single(matObject.a(postion_vec1,postion_vec2,:));
                
                
            elseif strcmp(img,'b')

                name = replace(name_53BP1,'data_53BP1.mat','data_gH2AX.mat');
                matObject = matfile(name);
                data=single(matObject.b(postion_vec1,postion_vec2,:));
                
            elseif strcmp(img,'c')
                
                name = replace(name_53BP1,'data_53BP1.mat','data_DAPI.mat');
                matObject = matfile(name);
                data=single(matObject.c(postion_vec1,postion_vec2,:));
                
            else
                error('wrong img')
                
            end
            data_all = [data_all, data];
        end
        
    elseif strcmp(type,'mask')
        
        data_all = {};
        for img = imgs2read
            img = img{1};
            
            
            if strcmp(img,'a')

                name = replace(name_53BP1,'data_53BP1.mat','points_53BP1.mat');
                matObject = matfile(name);
                data = matObject.mask_points_53BP1(postion_vec1,postion_vec2,:);

            elseif strcmp(img,'b')
                
                name = replace(name_53BP1,'data_53BP1.mat','points_gH2AX.mat');
                matObject = matfile(name);
                data = matObject.mask_points_gH2AX(postion_vec1,postion_vec2,:);
                
            elseif strcmp(img,'ab')
                
                name = replace(name_53BP1,'data_53BP1.mat','points_53BP1.mat');
                matObject = matfile(name);
                data1 = matObject.mask_points_53BP1(postion_vec1,postion_vec2,:);
                
                name = replace(name_53BP1,'data_53BP1.mat','points_gH2AX.mat');
                matObject = matfile(name);
                data2 = matObject.mask_points_gH2AX(postion_vec1,postion_vec2,:);
                
                [r,c,v] = ind2sub(size(data1),find(data1));
                pos2 = [r,c,v];
                
                [r,c,v] = ind2sub(size(data2),find(data2));
                pos2 = [r,c,v];
                
            else
                error('wrong img')
                
            end
        

            data = imgaussfilt3(single(data),[2,2,1])*59.5238*10;

            data = data(postion_vec1,postion_vec2,:);

%             data = repmat(data,[1,1,1,3]);   

            data_all = [data_all, data];
        
        end
        
        
    end
    data = cat(4,data_all{:});
    
end

% data = matReader('C:\Users\vicar\Desktop\foky_new_tmp\data_resave\IR 0,5Gy_8h PI\0001\data_53BP1.mat1','data',{'a','b','c'});
% mask = matReader('C:\Users\vicar\Desktop\foky_new_tmp\data_resave\IR 0,5Gy_8h PI\0001\data_53BP1.mat1','mask',{'a','b'});   

    