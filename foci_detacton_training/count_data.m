clc;clear all;close all;
addpath('../utils')



path = 'C:\Data\Vicar\foci_new\data_u87_nhdf_resaved';

names = subdirx([path '/*mask.tif']);


data_lbls = {};
for name_num = 1:length(names)
    
    file_name = names{name_num};

    have_any = 0;
    
    for cell_type = {'U87-MG','NHDF'}

        for time = {'30min','8h'}

            for gy = {'0,5Gy','1Gy','2Gy','4Gy','8Gy'}

                tmp_file_name = replace(file_name,' ','');
                tmp1 = contains(tmp_file_name,cell_type{1});
                tmp2 = contains(tmp_file_name,time{1});
                tmp3 = contains(tmp_file_name,gy{1});
                
                if tmp1 && tmp2 && tmp3
                    
                    data_lbls = [data_lbls,[cell_type{1},' ',time{1},' ',gy{1}]];
                    have_any = 1;
                    continue

                end
                

            end

        end

    end
    
    
    

end


u = unique(data_lbls);

cel_num = [];
img_num = [];

for u_ind = 1:length(u)
    
    uu = u(u_ind);
    
    cell_num_tmp = 0;
    img_num_tmp = 0;
    
    
    names_tmp = names(strcmp(data_lbls,uu));
    for name_ind = 1:length(names_tmp)
        
        name = names_tmp{name_ind};
        
        mask = imread(name);
        mask = bwlabeln(mask);
        
        cell_num_tmp = cell_num_tmp+max(mask(:));
        img_num_tmp = img_num_tmp+1;
        
        drawnow;
    end
    
    
    cel_num = [cel_num,cell_num_tmp];
    img_num = [img_num,img_num_tmp];
end

u = u';
cel_num = cel_num';
img_num = img_num';

T = table(u,cel_num,img_num);

writetable(T,'pocty_sloupce.xlsx')





