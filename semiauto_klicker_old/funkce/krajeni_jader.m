function [bin_krajeny,DT]=krajeni_jader(bin,h)

d=bwdist(bin==0);
DT=d;
d=-1*imhmax(d,h);
w=watershed(d)>0;
bin_krajeny=double(w).*double(bin);
bin_krajeny=bwareafilt(bin_krajeny>0,[1000 99999999999]);