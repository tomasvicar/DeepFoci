clc;clear all;close all;
addpath('plotSpread')

load('../../tmp_count.mat')

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
            
            
            order_by = [order_by,[cell_type{1},' ',time{1},' ',gy{1} ' a']];
            
            order_by = [order_by,[cell_type{1},' ',time{1},' ',gy{1} ' b']];
            
            order_by = [order_by,[cell_type{1},' ',time{1},' ',gy{1} ' ab']];
            
        end
        
    end
    
end

y = [];
g = {};
for file_num = 1:length(file_names)
    
    title_name = 'count res';
%     y = [y,counts_manual_a(file_num),counts_manual_b(file_num),counts_manual_ab(file_num)];
%     y = [y,counts_res_a(file_num),counts_res_b(file_num),counts_res_ab(file_num)];
    y = [y,dices_a(file_num),dices_b(file_num),dices_ab(file_num)];
    g = [g,[data_lbls{file_num} ' a'],[data_lbls{file_num} ' b'],[data_lbls{file_num} ' ab']];
end

yy = [];
gg = {};
for order_by_num = 1:length(order_by)
    tmp = strcmp(g,order_by{order_by_num});
    yy = [yy,y(tmp)];
    gg = [gg,g(tmp)];
end
y = yy;
g = gg;


colors = repmat({[0, 0.4470, 0.7410],[0.8500, 0.3250, 0.0980],[0.9290, 0.6940, 0.1250]},[1,50]);

figure;
hold on
pozice=1:length(unique(g));

colorss=colors(end:-1:1);
h=boxplot(y,g,'positions', pozice,'colors','k','symbol',''); 
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),colorss{j});
end 
c = get(gca, 'Children');
for i=1:length(c)
    try
        set(c(i), 'FaceAlpha', 0.4);
    end
end
h=boxplot(y,g,'positions', pozice,'colors','k','symbol',''); 
%     set(h,'LineWidth',1)
xtickangle(-30)

% plotSpread(y,'distributionIdx',g,'distributionColors','k');
% c = get(gca, 'Children');
% for i=1:length(c)
%     try
%         set(c(i), 'MarkerSize',8,'MarkerEdgeColor','k');
%     end
% end
% 

ylim([0,200])




