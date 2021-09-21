clc;clear all;close all;
addpath('../utils')

name = 'C:\Users\vicar\Desktop\foky_new_tmp\data_resave\IR 0,5Gy_8h PI\0001\data_53BP1.mat1';
data = matReader(name,'data',{'a','b','c'});  

mask = matReader(name,'mask',{'a','b','ab'});  


p_a = imregionalmax(mask(:,:,:,1));
[r,c,v] = ind2sub(size(p_a),find(p_a));
p_a = [r,c,v];

p_b = imregionalmax(mask(:,:,:,2));
[r,c,v] = ind2sub(size(p_b),find(p_b));
p_b = [r,c,v];

p_ab = imregionalmax(mask(:,:,:,3));
[r,c,v] = ind2sub(size(p_ab),find(p_ab));
p_ab = [r,c,v];


tmp =squeeze( max(data,[],3));
tmp(:,:,1) = mat2gray(tmp(:,:,1));
tmp(:,:,2) = mat2gray(tmp(:,:,2));
tmp(:,:,3) = mat2gray(tmp(:,:,3));

imshow(tmp,[])
hold on
plot(p_a(:,2),p_a(:,1),'rx')
plot(p_b(:,2),p_b(:,1),'g+')
plot(p_ab(:,2),p_ab(:,1),'yo')


