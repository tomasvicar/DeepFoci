function [split1_names,split2_names] = subfolder_based_split_xxx(files,fold,folds)



subfolders = {};
for file_num = 1:length(files)
    file = files{file_num};

    filepath = fileparts(file);

    subfolder = filepath(1:end-5) ;

    subfolders = [subfolders,subfolder];
end

subfolders_u = unique(subfolders);
rng(42)
perm = randperm(length(subfolders_u));




N = length(perm);
tmp = 1+round(N/folds*(fold-1)):round(N/folds*(fold));

if fold == 1
    tmp = [9,8,10,18];
end
if fold == 2
    tmp = [19,6,12,11];
end

split1_ind = perm(tmp);
split2_ind = perm;
split2_ind(tmp) = [];


split2_names = {};
split1_names = {};
for file_num = 1:length(files)
    file = files{file_num};

    is_split1 = 0;
    split1_subfolders = subfolders_u(split1_ind);
    for subfolder_num = 1:length(split1_subfolders)
        if contains(file,split1_subfolders{subfolder_num})
            is_split1 = 1;
        end
    end
    is_split2 = 0;
    split2_subfolders = subfolders_u(split2_ind);
    for subfolder_num = 1:length(split2_subfolders)
        if contains(file,split2_subfolders{subfolder_num})
            is_split2 = 1;
        end
    end

    drawnow;
    if is_split1 && ~is_split2
        split1_names = [split1_names,file];
    elseif ~is_split1 && is_split2
        split2_names = [split2_names,file];
    else
        error('mistake in split')
    end
end
    







end

