clc;clear all;close all;


a=false(2000,2000,100);


save('tmp.mat','a','-v7.3')



exampleObject = matfile('tmp.mat');
b=exampleObject.a(200:300,200:300,10:20);


load('tmp.mat')