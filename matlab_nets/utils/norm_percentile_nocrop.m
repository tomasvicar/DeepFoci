function [a,normalizacia]=norm_percentile_nocrop(a,perc)

normalizacia=[double(prctile(a(:),perc*100)) double(prctile(a(:),100-perc*100))];
a = (a - normalizacia(1))/(normalizacia(2) - normalizacia(1)) - 0.5;

% a=mat2gray(a,normalizacia);