clc;clear all;close all;
addpath('utils')

% focan=(focan+0.17);
% focan(focan==0.17)=focan(focan==0.17).*rand(size(focan(focan==0.17)));
% focan(focan>1)=1;

% celprofiler=(celprofiler-0.04);
% celprofiler(celprofiler<0)=0;


load('res_deepfoci.mat','dice_res_ja','dice_res_jarda','dice_ja_jarda','counts_res','counts_ja','counts_jarda')

deepfoci_counts_res=counts_res;




load('opt_res_focan.mat','tmp')


focan_counts_res=tmp{4};




load('opt_res.mat','tmp')


autofoci_counts_res=tmp{4};


load('opt_res_cellprofiler.mat','tmp')



celprofiler_counts_res=tmp{4};









counts_mean=(counts_ja+counts_jarda)/2;



max_count=50;

% counts_ja(counts_ja>max_count)=max_count;
% counts_jarda(counts_jarda>max_count)=max_count;
% counts_mean(counts_mean>max_count)=max_count;
% deepfoci_counts_res(deepfoci_counts_res>max_count)=max_count;
% focan_counts_res(focan_counts_res>max_count)=max_count;
% autofoci_counts_res(autofoci_counts_res>max_count)=max_count;
% celprofiler_counts_res(celprofiler_counts_res>max_count)=max_count;

% plot_marker = 'r.';




plot_with_line(counts_ja,counts_jarda,max_count)
xlabel('Expert 1')
ylabel('Expert 2')


mkdir('../../resyyy')

print_png_eps_svg_fig('../../resyyy/plot_experts')




plot_with_line(counts_mean,deepfoci_counts_res,max_count)

xlabel('Experts Average')
ylabel('DeepFoci')


mkdir('../../resyyy')

print_png_eps_svg_fig('../../resyyy/plot_deepfoci')





plot_with_line(counts_mean,focan_counts_res,max_count)

xlabel('Experts Average')
ylabel('FocAn')


mkdir('../../resyyy')

print_png_eps_svg_fig('../../resyyy/plot_focan')





plot_with_line(counts_mean,autofoci_counts_res,max_count)


xlabel('Experts Average')
ylabel('AutoFoci')

mkdir('../../resyyy')

print_png_eps_svg_fig('../../resyyy/plot_autofoci')





plot_with_line(counts_mean,celprofiler_counts_res,max_count)

xlabel('Experts Average')
ylabel('CellProfiler')

mkdir('../../resyyy')

print_png_eps_svg_fig('../../resyyy/plot_cellprofiler')



