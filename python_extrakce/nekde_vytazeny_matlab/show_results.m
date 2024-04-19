clc;clear all; close all;
addpath('../utils')
addpath('plotSpread')

filenames_mat = subdir('extracted_features/*.mat');
filenames_mat = {filenames_mat(:).name};

all_data = {};
filenames = {};

%všechno načíst a všude to průměrovat přes buňky; přidat počty
for file_num = 1:length(filenames_mat)

    data = load(filenames_mat{file_num});
    filenames = [filenames,data.filename];
    
    num_of_nuc = size(data.nuc_features,1);

    table_names = {'foci_features','foci_features_r','foci_features_g','foci_features_rg'};

    for table_num = 1:length(table_names)
        table_name = table_names{table_num};
    
        varnames = data.(table_name).Properties.VariableNames;
        data.([table_name '_mean']) = table();
        for var_num = 1:length(varnames)
            tmp = zeros(num_of_nuc,1);
            varname = varnames{var_num};
            NucNum = data.(table_name).('NucNum');
            var = data.(table_name).(varname);
            for nuc_num = 1:num_of_nuc
                tmp(nuc_num) = mean(var(NucNum==nuc_num));
            end
            data.([table_name '_mean']) =  addvars(data.([table_name '_mean']),tmp,'NewVariableNames',varname);
        end

        tmp = zeros(num_of_nuc,1);
        for nuc_num = 1:num_of_nuc
            tmp(nuc_num) = sum(NucNum==nuc_num);
        end
        data.([table_name '_mean']) =  addvars(data.([table_name '_mean']),tmp,'NewVariableNames','Count');

    end
    all_data = [all_data,data];

end

to_use = {'CountR','CountG','CountRG','Correlation','AvgVolume','VolumeFrac'};

order_typenames = {...
    {'53BP1 + gH2AX/FB_Control_Early','53BP1 FB control-early'};
    {'53BP1 + gH2AX/FB_Control','53BP1 FB control'};
    {'53BP1 + gH2AX/FB_1,2Gy_10st_2h PI','53BP1 FB 2h'};
    {'53BP1 + gH2AX/FB_1,2Gy_10st_24h PI','53BP1 FB 24h'};
    {'53BP1 + gH2AX/U87_Control_Early','53BP1 U87 control-early'};
    {'53BP1 + gH2AX/U87_Control_Late','53BP1 U87 control-late'};
    {'53BP1 + gH2AX/U87_1.2Gy_10st_2hPI','53BP1 U87 2h'};
    {'53BP1 + gH2AX/U87_1.2Gy_10st_24hPI','53BP1 U87 24h'};
    {'RAD51 + gH2AX/FB_control','RAD51 FB control'};
    {'RAD51 + gH2AX/FB_1.25 Gy_2h PI pěkné','RAD51 FB 2h'};
    {'RAD51 + gH2AX/FB_1,25 Gy_24h PI pěkné','RAD51 FB 24h'};
    {'RAD51 + gH2AX/U87_1.25Gy_Control','RAD51 U87 control'};
    {'RAD51 + gH2AX/U87_1.25Gy_2hPI','RAD51 U87 2h'};
    {'RAD51 + gH2AX/U87_1.25Gy_24hPI','RAD51 U87 24h'};
};

order_names = cellfun(@(x) x{1}, order_typenames,UniformOutput=false);
order_names_short = cellfun(@(x) x{2}, order_typenames,UniformOutput=false);


% 

c = @(x) x{1};
a = @(x) c(join(x(end-4:end-3),'/'));
b = @(x) a(split(x,'\'));
filenames_part = cellfun(b,filenames,UniformOutput=false);

filenames_part_u = unique(filenames_part);


for_plots = struct();

for to_use_num = 1:length(to_use)
    to_use_current = to_use{to_use_num};

    values = [];
    names = {};
    for file_num = 1:length(filenames_mat)
        data = all_data{file_num};

        if strcmp(to_use_current,'CountR')
            tmp = data.foci_features_r_mean.Count;
        elseif strcmp(to_use_current,'CountG')
            tmp = data.foci_features_g_mean.Count;
        elseif strcmp(to_use_current,'CountRG')
            tmp = data.foci_features_rg_mean.Count;
        elseif strcmp(to_use_current,'Correlation')
            tmp = data.nuc_features.CorrelationNuc;
        elseif strcmp(to_use_current,'AvgVolume')
            tmp = data.foci_features_mean.VolumeUm;
        elseif strcmp(to_use_current,'VolumeFrac')
            tmp = data.foci_features_mean.VolumeUm .* data.foci_features_mean.Count ./  data.nuc_features.VolumeUm;
        else
            error('incorect data type');
        end

        values = [values;tmp];
        names = [names;repmat({filenames_part{file_num}},length(tmp),1)];


    end
    
    for_plots.(to_use_current) = struct();
    for_plots.(to_use_current).values = values;
    for_plots.(to_use_current).names = names;

end



for to_use_num = 1:length(to_use)
    to_use_current = to_use{to_use_num};

    lbl = to_use_current;

    y = for_plots.(to_use_current).values;

    g = for_plots.(to_use_current).names;
    
    u = unique(g);
    yy = [];
    gg = {};
    for uu_num = 1:length(order_names)
        uu = order_names{uu_num};
        ind = strcmp(g,uu);
        
        yy = [yy;y(ind)];
        gg = [gg;g(ind)];
    end
    
    y = yy;
    g = gg;
    
    gg = g;
    for k = 1:length(gg)
        tmp = strcmp(gg{k},order_names);
        gg(k) = {order_names_short{tmp}};
    end
    g = gg;
    
    u = unique(g);


    figure('units','normalized','outerposition',[0 0 1 1])
    hold on
    pozice=[1,2,3,4, 6,7,8,9, 11,12,13 15,16,17];
    colors = repmat({[0.3,0.3,0.3]},1,length(unique(g)));


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
    
    plotSpread(y,'distributionIdx',g,'distributionColors','k','xValues',pozice);
    c = get(gca, 'Children');
    for i=1:length(c)
        try
            set(c(i), 'MarkerSize',8,'MarkerEdgeColor','k');
        end
    end
    
    min_vals = zeros(1,length(u));
    max_vals = zeros(1,length(u));
    for uu_ind = 1:length(u)
        
        uu = u{uu_ind};
        ind = strcmp(g,uu);
        tmp = y(ind);
        tmp = tmp(~isnan(tmp));
        m = median(tmp);
        min_vals(uu_ind) =  m - 3.5*(m - quantile(tmp,0.25));
        max_vals(uu_ind) =  m + 3.5*(quantile(tmp,0.75)-m);
    end
    
    
    ylim([min(min_vals) max(max_vals)])
    ylabel(lbl)
        
    drawnow;

    print(['plots/' lbl],'-dpng')
    savefig(['plots/' lbl])

end


