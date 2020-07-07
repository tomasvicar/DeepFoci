clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\dva_pacienti_tif';


counts={};

bad=0;
all=0;


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders2=dir([path '/' folders(k).name]);
    
    for kk=3:length(folders2)
        folders3=dir([path '/' folders(k).name '/' folders2(kk).name]);
        for kkk=3:length(folders3)
            
            folders_new=[folders_new [path '/' folders(k).name '/' folders2(kk).name '/' folders3(kkk).name]];
            
        end
    end
end
folders=folders_new;

folders=sort(folders);



voxel_size_um=[0.065*1.8182,0.065*1.8182,0.3];

n_foci=[];
sum_vol_foci=[];
avg_vol_foci=[];
std_vol_foci=[];
avg_3d_roudness=[];
avg_3d_vol_solidity=[];
avg_red=[];
std_red=[];
avg_green=[];
std_green=[];
avg_coloc=[];
std_coloc=[];
vol_nuc=[];

result_folder_names={};


for folder_num=1:length(folders)
    
    
    folder=folders{folder_num};

    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};

    count=[];
    
    

    for img_num=1:length(names)
        img_num
    
        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');

        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        
        save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
        save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
        
        
        save_unet_foci_detection_res_points=strrep(name,'3D_','unet_foci_detection_res_points');
        save_unet_foci_detection_res_points=strrep(save_unet_foci_detection_res_points,'.tif','.mat');
        
        
        save_unet_foci_segmentation_res=strrep(name,'3D_','unet_foci_segmentation_res');
        
        
%         save_results_table_unet=strrep(name,'3D_','results_table_unet');
%         save_results_table_unet=strrep(save_results_table_unet,'.tif','.csv');

        save_results_table_unet=strrep(name,'3D_','results_table_unet_t29');
        save_results_table_unet=strrep(save_results_table_unet,'.tif','.csv');
        
        
        res_table=readtable(save_results_table_unet);
        
        tmp=repmat({folder},[size(res_table,1),1]);
        res_table= addvars(res_table,tmp,'NewVariableNames','Folder');
        tmp=repmat({name},[size(res_table,1),1]);
        res_table= addvars(res_table,tmp,'NewVariableNames','ImgName');
         if ~isempty(res_table)
            for k=1:res_table.MaxCellNum(1)
                use_row=res_table.CellNum==k;
                count=sum(use_row);
                
                
                foci_volume=res_table.Volume;
                nuc_volume=res_table.NucVolume;
                nuc_area=res_table.SurfaceArea;
                foci_volume=foci_volume(use_row);
                nuc_volume=nuc_volume(use_row);
                nuc_area=nuc_area(use_row);
                
                solidity=res_table.Solidity;
                solidity=mean(solidity(use_row));
                
                
                sum_foci_volume=sum(foci_volume)*prod(voxel_size_um);
                
                mean_foci_volume=mean(foci_volume)*prod(voxel_size_um);
                
                std_foci_volume=std(foci_volume)*prod(voxel_size_um);
                
                
%                 rV=((3*nuc_volume)/(4*pi)).^(1/3);
%                 rA=((nuc_area)/(4*pi)).^(1/2);
%                 roudness=(rV*12.57)./(rA);
                
                                
                MeanIntensityR=res_table.MeanIntensityR;
                MeanIntensityR=MeanIntensityR(use_row);
                mr=mean(MeanIntensityR);
                sr=std(MeanIntensityR);

                MeanIntensityG=res_table.MeanIntensityG;
                MeanIntensityG=MeanIntensityG(use_row);
                mg=mean(MeanIntensityG);
                sg=std(MeanIntensityG);
                
                MeanIntensityRG=res_table.MeanIntensityRG;
                MeanIntensityRG=MeanIntensityRG(use_row);
                mrg=mean(MeanIntensityRG);
                srg=std(MeanIntensityRG);
                
                n_foci=[n_foci,count];
                sum_vol_foci=[sum_vol_foci,sum_foci_volume];
                avg_vol_foci=[avg_vol_foci,mean_foci_volume];
                std_vol_foci=[std_vol_foci,std_foci_volume];
                avg_3d_roudness=[];
                avg_3d_vol_solidity=[avg_3d_vol_solidity,solidity];
                avg_red=[avg_red,mr];
                std_red=[std_red,sr];
                avg_green=[avg_green,mg];
                std_green=[std_green,sg];
                avg_coloc=[avg_coloc,mrg];
                std_coloc=[std_coloc,srg];
                if ~isempty(nuc_volume)
                    vol_nuc=[vol_nuc,nuc_volume(1)*prod(voxel_size_um)];
                else
                    vol_nuc=[vol_nuc,nan];
                end

                
                folder_name=split(folder,{'\','/'});
                result_folder_names=[result_folder_names,folder_name{end}];
                
            end
        end
        
    end

end


volume_fractions=sum_vol_foci./vol_nuc;
volume_weithed_count=1.8978e+06*n_foci./vol_nuc;


n_foci=n_foci';
sum_vol_foci=sum_vol_foci';
avg_vol_foci=avg_vol_foci';
std_vol_foci=std_vol_foci';
avg_3d_vol_solidity=avg_3d_vol_solidity';
avg_red=avg_red';
std_red=std_red';
avg_green=avg_green';
std_green=std_green';
avg_coloc=avg_coloc';
std_coloc=std_coloc';
vol_nuc=vol_nuc';


volume_fractions_percent=volume_fractions'*100;
volume_weithed_count=volume_weithed_count';


X=table(n_foci,sum_vol_foci,avg_vol_foci,avg_3d_vol_solidity,avg_red,avg_green,avg_coloc,vol_nuc,volume_fractions_percent,volume_weithed_count);



for kkkk=1:2

    
if kkkk==1
    gs={'75-18 non IR','75-18 30min PI','75-18 8h PI','75-18 24h PI',...
        '77-18 nonIR','77-18 30min PI','77-18 8h PI','77-18 24h PI'};
elseif kkkk==2
    gs={'79-18 nonIR','79-18 30min PI','79-18 8h PI','79-18 24h PI',...
        '76-18 nonIR','76-18 30min PI','76-18 8h PI','76-18 24h PI'};
end


g=[];
XX={};
for g_num = 1:length(gs)
    tmp=strcmp(result_folder_names,gs{g_num});
    XX=[XX,{X(tmp,:)}];
    g=[g;g_num*ones(sum(tmp),1)];
end
XXX=cat(1,XX{:});

if kkkk==1
    f='../res_pacos1_ten_co_pca';
elseif kkkk==2
    f='../res_pacos2';
end
    
mkdir(f)

var_names=XXX.Properties.VariableNames;

for var_num=1:length(var_names)
    
    var_name=var_names{var_num};
    figure;
    boxplot(XXX.(var_name),g)
    
    
    ylabel(replace(var_name,'_',' '))
    print_png_eps_svg_fig([f '/box_' var_name])
end


end






