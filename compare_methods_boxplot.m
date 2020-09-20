clc;clear all;close all;

% focan=(focan+0.17);
% focan(focan==0.17)=focan(focan==0.17).*rand(size(focan(focan==0.17)));
% focan(focan>1)=1;

% celprofiler=(celprofiler-0.04);
% celprofiler(celprofiler<0)=0;


load('res_deepfoci.mat','dice_res_ja','dice_res_jarda','dice_ja_jarda')

deep_foci=(dice_res_ja+dice_res_jarda)/2;




load('opt_res_focan.mat','tmp')

dice_res_ja=tmp{1};
dice_res_jarda=tmp{2};
dice_ja_jarda=tmp{3};

focan=(dice_res_ja+dice_res_jarda)/2;



load('opt_res.mat','tmp')

dice_res_ja=tmp{1};
dice_res_jarda=tmp{2};
dice_ja_jarda=tmp{3};

autofoci=(dice_res_ja+dice_res_jarda)/2;




load('opt_res_cellprofiler.mat','tmp')

dice_res_ja=tmp{1};
dice_res_jarda=tmp{2};
dice_ja_jarda=tmp{3};

celprofiler=(dice_res_ja+dice_res_jarda)/2;



X=[deep_foci,focan,autofoci,celprofiler];

g=[1*ones(size(deep_foci)),2*ones(size(focan)),3*ones(size(autofoci)),4*ones(size(celprofiler))];


boxplot(X,g)

xticklabels({'DeepFoci','FocAn','AutoFoci','CellProfiler'})


mkdir('../../resxxx')

print_png_eps_svg_fig('../../resxxx/boxplot_comparemethods')


