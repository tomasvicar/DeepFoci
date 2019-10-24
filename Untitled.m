clc;clear all;close all;

listing=dir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 336 (33-17, 37-17)\mix CD90+- (33-17)');


paths={};



for k=3:length(listing)
    paths=[paths [listing(k).folder '\' listing(k).name '\']];
    
    
end

listing=dir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 336 (33-17, 37-17)\prilehla tkan (37-17)');

for k=3:length(listing)
    paths=[paths [listing(k).folder '\' listing(k).name '\']];
    
    
end






T=table(paths');


writetable(T,'table.xlsx')  