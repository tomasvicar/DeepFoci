function [names] = subdirx(path)

names = subdir(path);
names = {names(:).name};

end

