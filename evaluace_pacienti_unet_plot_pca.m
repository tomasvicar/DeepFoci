clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\dva_pacienti_tif';

mkdir('../res_pca')

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
        
        
        save_results_table_unet=strrep(name,'3D_','results_table_unet');
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
                
                
                sum_foci_volume=sum(foci_volume)*(0.1650^3);
                
                mean_foci_volume=mean(foci_volume)*(0.1650^3);
                
                std_foci_volume=std(foci_volume)*(0.1650^3);
                
                
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
                    vol_nuc=[vol_nuc,nuc_volume(1)];
                else
                    vol_nuc=[vol_nuc,nan];
                end

                
                folder_name=split(folder,{'\','/'});
                result_folder_names=[result_folder_names,folder_name{end}];
                
            end
        end
        
    end

end
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

% X=table(n_foci,sum_vol_foci,avg_vol_foci,std_vol_foci,...
%    avg_3d_vol_solidity,avg_red,avg_green,std_green,avg_coloc,std_coloc,vol_nuc );

X=table(n_foci,sum_vol_foci,avg_vol_foci,avg_3d_vol_solidity,avg_red,avg_green,avg_coloc,vol_nuc );



nonan=~isnan(sum(X{:,:},2))&(X{:,1}>1);
X_nonan=X(nonan,:);

result_folder_names_nonan=result_folder_names(nonan);



%   Columns 1 through 5
% 
%     {'75-18 24h PI'}    {'75-18 30min PI'}    {'75-18 8h PI'}    {'75-18 non IR'}    {'76-18 24h PI'}
% 
%   Columns 6 through 11
% 
%     {'76-18 30min PI'}    {'76-18 8h PI'}    {'76-18 nonIR'}    {'77-18 24h PI'}    {'77-18 30min PI'}    {'77-18 8h PI'}
% 
%   Columns 12 through 16
% 
%     {'77-18 nonIR'}    {'79-18 24h PI'}    {'79-18 30min PI'}    {'79-18 8h PI'}    {'79-18 nonIR'}

% gs={'77-18 30min PI','77-18 8h PI'};


for qq=1:2

if qq==1
gs={'77-18 30min PI','75-18 30min PI'};
elseif qq==2
gs={'77-18 30min PI','77-18 8h PI','77-18 24h PI'};
end
    
    
g=[];
XX={};
for g_num = 1:length(gs)
    tmp=strcmp(result_folder_names_nonan,gs{g_num});
    XX=[XX,{X_nonan(tmp,:)}];
    g=[g;g_num*ones(sum(tmp),1)];
end


   

XXX=cat(1,XX{:});
XXX_arr=XXX{:,:};

mu=mean(XXX_arr,1);
sig=std(XXX_arr,1);

XXX_arr_norm=(XXX_arr-mu)./sig;
[coefs,score,latent,tsquared,explained,mu] = pca(XXX_arr_norm);

s=score(:,1:2);
d=sqrt(s(:,1).^2+s(:,2).^2);
[ss,ii]=sort(d);
s=s(ii(1:end-15),:);
g=g(ii(1:end-15));

var_names=XXX.Properties.VariableNames;
var_names=cellfun(@(x) replace(x,'_',' '),var_names,'UniformOutput',0);


format = { {'Marker', 'v','MarkerSize', 4,'MarkerEdgeColor',[0,0.4470,0.7410],'MarkerFaceColor',[0,0.4470,0.7410]};...
    {'Marker', '^','MarkerSize', 4,'MarkerEdgeColor',[0.850,0.3250,0.0980],'MarkerFaceColor',[0.850,0.3250,0.0980]};...
    {'Marker', 'o','MarkerSize', 4,'MarkerEdgeColor',[0.9290,0.6940,0.1250],'MarkerFaceColor',[0.9290,0.6940,0.1250]}};

if qq==1
    format =format(1:2);
end


figure()
subset=biplotG(coefs(:,1:2),s,'VarLabels',var_names,'Groups',g,'Format',format);

xlabel(['Component 1  (' num2str(explained(1),'%4.2f') '%)'])
ylabel(['Component 2  (' num2str(explained(2),'%4.2f') '%)'])

if qq==1
    legend(subset,{'Adjacent tissue','Mix'})
elseif qq==2
    legend(subset,{'0.5 h','8 h','24 h'})
end


print_png_eps_svg_fig(['../res_pca/pca_biplot_' num2str(qq)])

end

