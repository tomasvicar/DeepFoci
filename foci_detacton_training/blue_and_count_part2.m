clc;clear all;close all;
addpath('plotSpread')

load('../../blue_and_count.mat')

files_part1 = {};
file_names = split(file_names,'C:');
file_names = file_names(2:end);
file_names = cellfun(@(x) ['C:' x],file_names,'UniformOutput',0);


data_lbls = {};
for file_num = 1:length(file_names)

    file_name = file_names{file_num};

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
    if have_any == 0
        error('no valid data lbl')
    end
    

end




order_by = {};
for cell_type = {'U87-MG','NHDF'}

    for time = {'30min','8h'}

        for gy = {'0,5Gy','1Gy','2Gy','4Gy','8Gy'}
            
            
            order_by = [order_by,[cell_type{1},' ',time{1},' ',gy{1}]];

        end
        
    end
    
end


% 'NHDF'
% order_by = {};
% for cell_type = {'NHDF'}
% 
%     for time = {'30min'}
% 
%         for gy = {'1Gy','2Gy','4Gy'}
%             
%             
%             order_by = [order_by,[cell_type{1},' ',time{1},' ',gy{1}]];
% 
%         end
%         
%     end
%     
% end


foci_lim = [0 100];
blue_lim = [100 350];





g = data_lbls;


blues_nuc_tmp = [];
counts_res_ab_post_tmp = [];
gg = {};
for order_by_num = 1:length(order_by)
    tmpx = strcmp(g,order_by{order_by_num});
    
    tmp_count = counts_res_ab_post(tmpx);
%     tmp_count = (tmp_count-mean(tmp_count))/std(tmp_count);
    counts_res_ab_post_tmp = [counts_res_ab_post_tmp,tmp_count];
    
    tmp_blue = blues_nuc(tmpx);
%     tmp_blue = (tmp_blue-mean(tmp_blue))/std(tmp_blue);
    blues_nuc_tmp = [blues_nuc_tmp,tmp_blue];
    
%     tmp_count(tmp_count<foci_lim(1))=foci_lim(1);
%     tmp_count(tmp_count>foci_lim(2))=foci_lim(2);
%     
%     tmp_blue(tmp_blue<blue_lim(1))=blue_lim(1);
%     tmp_blue(tmp_blue>blue_lim(2))=blue_lim(2);

    tt = tmp_count < foci_lim(1);
    tmp_count(tt) = [];
    tmp_blue(tt) = [];
    
    tt = tmp_count > foci_lim(2);
    tmp_count(tt) = [];
    tmp_blue(tt) = [];
    
    
    tt = tmp_count > foci_lim(2);
    tmp_count(tt) = [];
    tmp_blue(tt) = [];
    
    tt = tmp_blue > blue_lim(2);
    tmp_count(tt) = [];
    tmp_blue(tt) = [];
    
    
    
    figure('Position', [10 100 1800 1000]);
    plot(tmp_count,tmp_blue,'*')
    title(order_by{order_by_num})
    xlabel('number of foci')
    ylabel('avg blue')
    xlim(foci_lim)
    ylim(blue_lim)
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_count' order_by{order_by_num}],'-dpng')
    savefig(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_count' order_by{order_by_num}])
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_count' order_by{order_by_num}],'-depsc')
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_count' order_by{order_by_num}],'-dsvg')
    
    figure('Position', [10 100 1800 1000]);
    tmp = linspace(blue_lim(1),blue_lim(2),27);
    tmp = tmp(2:end-1);
    hist(tmp_blue,tmp)
%     xlim(blue_lim)
    title(order_by{order_by_num})
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_hist' order_by{order_by_num}],'-dpng')
    savefig(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_hist' order_by{order_by_num}])
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_hist' order_by{order_by_num}],'-depsc')
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\blue_hist' order_by{order_by_num}],'-dsvg')
    
    
    figure('Position', [10 100 1800 1000]);
    tmp = linspace(foci_lim(1),foci_lim(2),27);
    tmp = tmp(2:end-1);
    hist(tmp_count,tmp)
%     xlim(foci_lim)
    title(order_by{order_by_num})
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\count_hist' order_by{order_by_num}],'-dpng')
    savefig(['C:\Data\Vicar\foci_new\blue_res\sep2\count_hist' order_by{order_by_num}])
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\count_hist' order_by{order_by_num}],'-depsc')
    print(['C:\Data\Vicar\foci_new\blue_res\sep2\count_hist' order_by{order_by_num}],'-dsvg')
    gg = [gg,g(tmpx)];
    
    
end
counts_res_ab_post = counts_res_ab_post_tmp;
blues_nuc = blues_nuc_tmp;
g = gg;

% % 
% figure('Position', [10 100 1800 1000]);
% plot(counts_res_ab_post,blues_nuc,'*')
% xlabel('number of foci')
% ylabel('avg blue')
% print(['C:\Data\Vicar\foci_new\blue_res\n-30min_1-4Gy\blue_count'],'-dpng')
% 
% figure('Position', [10 100 1800 1000]);
% hist(blues_nuc,30)
% ylabel('avg blue')
% print(['C:\Data\Vicar\foci_new\blue_res\n-30min_1-4Gy\blue_hist'],'-dpng')
% 
% 
% figure('Position', [10 100 1800 1000]);
% hist(counts_res_ab_post,30)
% ylabel('number of foci')
% print(['C:\Data\Vicar\foci_new\blue_res\n-30min_1-4Gy\count_hist'],'-dpng')


% [R,P] = corrcoef(counts_res_ab_post,blues_nuc);
