function [a]=norm_percentile(a,perc)

normalizacia=[double(prctile(a(:),perc*100)) double(prctile(a(:),100-perc*100))];
a=mat2gray(a,normalizacia);