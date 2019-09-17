clc;clear al;close all force;
addpath('utils')

folders={};

folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 122 (31-17)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 130 (36-17)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 132 (30-17)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 156 (41-17)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 309 (1-16,18-16)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 314 (2-16,5-16,9-16)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 315 (3-16,10-16,11-16)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 316 (4-16,6-16,8-16)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 318 (7-16,12-16,14-16)'];
folders=[folders,'Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 321 (20-16, 21-16)'];

color_order=[1 2 3];

for folder_num=1:length(folders)
    folder=folders{folder_num};
    
    folder_save=[folder '_tif'];    
    mkdir(folder_save)

    names=subdir([folder filesep '*01.ics']);
    names={names(:).name};
    
    for name_num=1:length(names)
        name=names{name_num};
        name_save=strrep(name,folder,folder_save);
        tmp=strsplit(name_save,filesep);
        name_save0=strjoin(tmp([1:end-3 end]),filesep);
        
        name_save=strrep(name_save0,'01.ics',['3D_' num2str(name_num,'%05.f') '.tif']);
        name_save_2d=strrep(name_save0,'01.ics',['2D_' num2str(name_num,'%05.f') '.tif']);
        name_save_control=strrep(name_save0,'01.ics',['control_' num2str(name_num,'%05.f') '.png']);
        
        [filepath,~,~] = fileparts(name_save0);
        mkdir(filepath)
        
        [a,b,c]=read_ics_3_files(name);
        
        tmp=cat(4,a,b,c);
        imwrite_single_4D(name_save,tmp(:,:,:,color_order))
        tmp=cat(3,mean(a,3),mean(b,3),mean(c,3));
        imwrite_single_3D(name_save_2d,tmp(:,:,color_order))
        
        
        name_fov_file=strrep(name,'01.ics','fov.txt');
        
        
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
        chanel_names=chanel_names([2,1,3]);
        chanel_names=chanel_names(color_order);
        
        
        tmp=cat(3,norm_percentile(mean(a,3),0.005),norm_percentile(mean(b,3),0.005),norm_percentile(mean(c,3),0.005));
        color_img=tmp(:,:,color_order);
        
        posun=25;
        color_img = insertText(color_img,[1 1],name,'FontSize',10);
        color_img = insertText(color_img,[1 1+posun],chanel_names{1},'BoxColor','red','FontSize',14);
        color_img = insertText(color_img,[1 1+posun*2],chanel_names{2},'BoxColor','green','FontSize',14);
        color_img = insertText(color_img,[1 1+posun*3],chanel_names{3},'BoxColor',[30,144,255]/255,'FontSize',14);
        
        imwrite(color_img,name_save_control)
        
    end
end