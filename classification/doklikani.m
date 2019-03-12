function varargout = doklikani(varargin)
% DOKLIKANI MATLAB code for doklikani.fig
%      DOKLIKANI, by itself, creates a new DOKLIKANI or raises the existing
%      singleton*.
%
%      H = DOKLIKANI returns the handle to a new DOKLIKANI or the handle to
%      the existing singleton*.
%
%      DOKLIKANI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOKLIKANI.M with the given input arguments.
%
%      DOKLIKANI('Property','Value',...) creates a new DOKLIKANI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before doklikani_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to doklikani_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help doklikani

% Last Modified by GUIDE v2.5 09-Feb-2018 17:35:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @doklikani_OpeningFcn, ...
    'gui_OutputFcn',  @doklikani_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before doklikani is made visible.
function doklikani_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to doklikani (see VARARGIN)
% Choose default command line output for doklikani

% set(handles.figure1,'units','norm','position',[0 0 1 1]);

drawnow;
set(get(handle(gcf),'JavaFrame'),'Maximized',1);








% figure('CloseRequestFcn',@my_closereq)
set(handles.figure1,'CloseRequestFcn',@figure1_CloseRequestFcn);

global soubory
global ukladaci_cesta
global  soubory_listbox celkem pocet_chyb pom_cislo modik


modik=varargin{1};

celkem=0;
pocet_chyb=0;
soubory={};
soubory_listbox={};


pom=pwd;



ukladaci_cesta=pom;

t = datetime('now','TimeZone','local','Format','yyyy-MM-dd_hh-mm');
pom_cislo=['_' char(t)];

ukladaci_cesta=[ukladaci_cesta '/vys_' pom_cislo];
set(handles.text6,'string',ukladaci_cesta);




handles.output = hObject;

% Update handles structure
guidata(hObject, handles);




% UIWAIT makes doklikani wait for user response (see UIRESUME)
uiwait(handles.figure1);

% drawnow;
% set(get(handle(gcf),'JavaFrame'),'Maximized',1);

% drawnow;
% robot = java.awt.Robot; 
% robot.keyPress(java.awt.event.KeyEvent.VK_ALT);      %// send ALT
% robot.keyPress(java.awt.event.KeyEvent.VK_SPACE);    %// send SPACE
% robot.keyRelease(java.awt.event.KeyEvent.VK_SPACE);  %// release SPACE
% robot.keyRelease(java.awt.event.KeyEvent.VK_ALT);    %// release ALT
% robot.keyPress(java.awt.event.KeyEvent.VK_X);        %// send X
% robot.keyRelease(java.awt.event.KeyEvent.VK_X); 








% --- Outputs from this function are returned to the command line.
function varargout = doklikani_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=[];
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global soubory hotovo celkem cesta soubory_listbox ukladaci_cesta pom_cislo modik

if strcmp(modik,'doklik')
    dotaz='Vyber složku s pøedzpracovanými daty';
else
    dotaz='Vyber složku typu vys__xxxx-xx-xx_xx-xx';
end

cesta = uigetdir(pwd,dotaz);
if cesta
    if strcmp(modik,'doklik')
        listing=subdir([cesta '/*data.mat']);
        ukladaci_cesta=cesta;
    else
        listing=subdir([cesta '/*vysledky_b*.mat']);
%         ukladaci_cesta=cesta(1:end-22);
        ccc=strfind(cesta,'\');
        ukladaci_cesta=cesta(1:ccc(end)-1);
    end
    
    
    
    t = datetime('now','TimeZone','local','Format','yyyy-MM-dd_hh-mm');
    pom_cislo=['_' char(t)];
    
    ukladaci_cesta=[ukladaci_cesta '/vys_' pom_cislo];
    set(handles.text6,'string',ukladaci_cesta);
    % pom=pwd;
    
    if ~isempty(listing)
        soubory=[soubory {listing.name}];
    end
    % pom=soubory{1};
    % ukladaci_cesta=pom;
    % set(handles.text6,'string',pom);
    % mkdir([ukladaci_cesta '/cele'])
    % mkdir([ukladaci_cesta '/bunky'])
    
    
    % rng(50);
    % soubory=soubory(randperm(length(soubory)));
    
    soubory=unique(soubory);
    
    set(handles.listbox1,'string',soubory);
    hotovo=0;
    celkem=length(soubory);
    % pom_cesta=[cesta '_preulozeni'];
    for k=1:celkem
        %     pom=soubory{k};
        %     pom(1:length(cesta))=[];
        %     pom(end-5:end)=[];
        %     pom=[pom_cesta pom];
        %     ukladani_soubory{k}=pom;
        soubory_listbox{k} =[num2str(k) ' -  '  soubory{k}] ;
    end
    % soubory_listbox=unique(soubory_listbox);
    
    set(handles.listbox1,'string',soubory_listbox);
    set(handles.text2,'string',[num2str(hotovo) '/' num2str(celkem)]);
    
end



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global soubory hotovo celkem ukladani_soubory ukladaci_cesta pocet_chyb pom_cislo modik


for k=1:celkem
    pom=soubory{k};
    pom(end-7:end)=[];
    ukladani_soubory{k}=pom;
end
prah=0;
velikost=300;
intenzita=140;
set(handles.text4,'string',['pracuji']);
drawnow;

fea=[];
lab=[];
bun=[];

load('svm_7_vel_med_99p_p.mat')
vysledkova_tabulka=table([],[],{},[],[],[],[],[],[],[],[]);
vysledkova_tabulka.Properties.VariableNames = {'cislo_snimku','cislo_bunky','nazev','pocet','prum_int_cer','prum_int_zel','prum_cerxzel','vel_foku_voxel','vel_foku_um3','vel_jadra_px','vel_jadra_um2'};
% pom_cislo=num2str(round(randi(9999)));

ukl_tab=[ukladaci_cesta '/tabulka' pom_cislo '.csv'];
mkdir([ukladaci_cesta '/cele' pom_cislo])
mkdir([ukladaci_cesta '/bunky' pom_cislo])

mkdir([ukladaci_cesta '/bunky' pom_cislo '/pom_data' pom_cislo])

mkdir([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo])

for k=1:length(soubory)
    
    try
        soubor=soubory{k};
        soubor_ulozit=ukladani_soubory{k};
        
        
        if strcmp(modik,'doklik')
            mkdir([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d')])
        end
        
        
        if strcmp(modik,'doklik')
            
            load([soubor_ulozit 'data.mat'])
            load([soubor_ulozit 'pomocna.mat'])
            
            a=single(au);
            b=single(bu);
            c=single(cu);
            
            reset=1;
            while reset
                [maska_krajena,reset]=malovatko_freehand(barva,maska_krajena,soubor_ulozit,a,b,c);
                drawnow
            end
            
            maska_krajena=bwareafilt(maska_krajena,[400 9999999999]);
            save([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '/maska_upravena' pom_cislo '.mat'],'maska_krajena')
            
            
            maska=maska_krajena>0;
            pom=barva.barva3;
            maskaa=maska-imerode(maska,strel('disk',3));
            maskaa=maskaa>0;
            pomm=pom(:,:,1);
            pomm(maskaa)=1;
            pom(:,:,1)=pomm;
            pomm=pom(:,:,2);
            pomm(maskaa)=0;
            pom(:,:,2)=pomm;
            pomm=pom(:,:,3);
            pomm(maskaa)=0;
            pom(:,:,3)=pomm;
            l=bwlabel(maska>0,4);
            s = regionprops(l,'centroid');
            centroids = cat(1, s.Centroid);
            for kq=1:size(centroids,1)
                pom= insertText(pom,centroids(kq,1:2),num2str(kq),'BoxOpacity',0,'FontSize',26);
            end
            pom=[ones([50,size(pom,2),3]);pom];
            pom= insertText(pom,[0 0],soubor,'BoxOpacity',0,'FontSize',20);
            imwrite(pom,[ukladaci_cesta '/cele' pom_cislo '/' num2str(k,'%03d') '.tif'])
            
            
            [normy,barvyv1,barvyv2,barvyv3,maskyv,foky_rgv,av,bv,cv,rohy,ostrev,smaz_foky_rgv]=bound_all2(barva,maska_krajena,foky_rg,a,b,c,size(a,3),rg_odstranene);
            
            vysledek=zeros(1,size(rg,2));
            bunka=zeros(1,size(rg,2));
            
            featuress=zeros(size(rg,2),7);
            
            
        else
            maskyv=1;
        end
        
        
        
        
        
        
        
        for cislo_bunky=1:length(maskyv)
            
            if strcmp(modik,'doklik')
                mvv=maskyv{cislo_bunky};avv=av{cislo_bunky};bvv=bv{cislo_bunky};
                cvv=cv{cislo_bunky};roh=rohy{cislo_bunky};
                foky_rgvv=foky_rgv{cislo_bunky};
                ostrevv=ostrev{cislo_bunky}; normyv=normy{cislo_bunky};
                smaz_foky_rgvv=smaz_foky_rgv{cislo_bunky};
                barvav1=barvyv1{cislo_bunky};
                barvav2=barvyv2{cislo_bunky};
                barvav3=barvyv3{cislo_bunky};
                
                
                
                m_pom=zeros(size(maska_krajena));
                
                mvv0=mvv;
                mvv=mvv==1;
                
                [m_pom]=insertmatrix(m_pom,mvv,roh([1 2 3]));
                
                %         tic
                %         m_pom=imdilate(m_pom,strel('disk',12));
                m_pom=repmat(m_pom,[1 1 size(foky_rg,3)]);
                
                
                CC = bwconncomp(ones([3 3 3]));
                CC.ImageSize=size(m_pom);
                CC.NumObjects=size(rg,1);
                CC.PixelIdxList=rg.VoxelIdxList;
                
                
                s = regionprops(CC,m_pom,'MeanIntensity');
                ktere=[s.MeanIntensity]>0.5;
                %         toc
                tecky=rg.Centroid;
                
                
                
                
                
                tecky=tecky(find(ktere),:);
                
                tecky(:,1)=tecky(:,1)-roh(2);
                tecky(:,2)=tecky(:,2)-roh(1);
                
                
                
                data=rg(find(ktere),:);
                
                
                [features]=get_features(data,avv,bvv,ostrevv,mvv);
                
                
                featuress(find(ktere),:)=features;
                vys_stare=[];
                cislo_snimku=k;
                cislo_bunky=cislo_bunky;
                pouzit=1;
                
            else
                load(soubory{k});
                barvav1=barvav.baravva1;
                barvav2=barvav.baravav2;
                barvav3=barvav.baravav3;
                vys_stare=vys;
            end
            
            
            
            uk_snimek=[ukladaci_cesta '/bunky' pom_cislo '/' num2str(k,'%03d') '-' num2str(cislo_bunky,'%03d') pom_cislo '.png'];
            
            
            mkdir([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d')])
            
            
            
            
            
            reset=1;
            while reset
                [vys,pouzit,prah,reset]=doklik_new(barvav1,barvav2,barvav3,foky_rgvv,data,tecky,prah,features,soubor_ulozit,smaz_foky_rgvv,mvv0,Mdl,uk_snimek,normyv,vys_stare,pouzit);
                drawnow;
            end
            
            %         imwrite(snimek,)
            vyss=vys;
            if pouzit==0
                 vyss=zeros(size(vys));
            end
            
            
            if strcmp(modik,'doklik')
                
                
                
                bunka(ktere>0)=cislo_bunky;
                
                if pouzit
                    
                    
                    vys(vys==1)=2;
                    vys(vys==0)=1;
                    
                    vysledek(ktere>0)=vys;
                    
                else
                    vysledek(ktere>0)=-1;
                end
                
                barvav.baravva1=barvav1;
                barvav.baravav2=barvav2;
                barvav.baravav3=barvav3;
            end
            %         tic
            mkdir([ukladaci_cesta '/bunky' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '-' num2str(cislo_bunky,'%03d')])
            save([ukladaci_cesta '/bunky' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '-' num2str(cislo_bunky,'%03d') '/vysledky_b' num2str(cislo_bunky,'%03d') pom_cislo  '.mat'],'vys','vyss','pouzit','barvav','foky_rgvv','cislo_snimku','cislo_bunky','data','tecky','features','normyv','smaz_foky_rgvv','pouzit','soubor_ulozit','mvv0','prah')
            %         toc
            
            if pouzit
                radek={cislo_snimku,cislo_bunky,soubor_ulozit,sum(vyss),mean(data{find(vyss==1),7}),mean(data{find(vyss==1),9}),mean(data{find(vyss==1),7}.*data{find(vyss==1),9}),mean(data{find(vyss==1),1}),mean(data{find(vyss==1),1})*0.081675,sum(mvv0(:)), sum(mvv0(:))*0.027225};
                vysledkova_tabulka=[vysledkova_tabulka;radek];
                writetable(vysledkova_tabulka,ukl_tab,'Delimiter','semi');
            end
        end
        
        if strcmp(modik,'doklik')
            save([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '/' num2str(k,'%03d') 'labely.mat'],'vysledek','bunka','featuress','rg')
        end
        
        % load([soubor_ulozit 'labely.mat'])
        
        % % fea=[fea;featuress];
        % lab=[lab;vysledek'];
        % bun=[bun;bunka'];
        
        
        % vys=vysledek(ktere);
        % if k==22
        %     stop=1
        % end
        
        
        
        hotovo=k;
        set(handles.text2,'string',[num2str(hotovo) '/' num2str(celkem)]);
        
    catch ME
        pocet_chyb=pocet_chyb+1;
        set(handles.text7,'string',['pocet chyb:' num2str(pocet_chyb)]);
        set(handles.text7,'Visible','on');
        mkdir([ukladaci_cesta '/error'])
        save([ukladaci_cesta '/error/vse' num2str(pocet_chyb) '.mat'])
        
        
    end
    %
    
    drawnow;
end
v=vysledkova_tabulka;
radekmean={0,0,'mean',nanmean(v{:,4}),nanmean(v{:,5}),nanmean(v{:,6}),nanmean(v{:,7}),nanmean(v{:,8}),nanmean(v{:,9}),nanmean(v{:,10}),nanmean(v{:,11})};
radekmedian={0,0,'median',nanmedian(v{:,4}),nanmedian(v{:,5}),nanmedian(v{:,6}),nanmedian(v{:,7}),nanmedian(v{:,8}),nanmedian(v{:,9}),nanmedian(v{:,10}),nanmedian(v{:,11})};
radekstd={0,0,'std',nanstd(v{:,4}),nanstd(v{:,5}),nanstd(v{:,6}),nanstd(v{:,7}),nanstd(v{:,8}),nanstd(v{:,9}),nanstd(v{:,10}),nanstd(v{:,11})};
n=numel(v{:,4});
radekste={0,0,'ste',nanstd(v{:,4})/sqrt(n),nanstd(v{:,5})/sqrt(n),nanstd(v{:,6})/sqrt(n),nanstd(v{:,7})/sqrt(n),nanstd(v{:,8})/sqrt(n),nanstd(v{:,9})/sqrt(n),nanstd(v{:,10})/sqrt(n),nanstd(v{:,11})/sqrt(n)};
radekn={0,0,'n',n,n,n,n,n,n,n,n};
vysledkova_tabulka=[radekmean;radekmedian;radekstd;radekste;radekn;vysledkova_tabulka];
writetable(vysledkova_tabulka,ukl_tab,'Delimiter','semi');


set(handles.text4,'string',['hotovo']);



% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% % --- Executes on button press in pushbutton4.
% function pushbutton4_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton4 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global soubory hotovo celkem
%
% folder_name = uigetdir;
% listing=subdir([folder_name '/*01.ics']);
% soubory_add={listing.name};
% soubory=[soubory soubory_add] ;
% set(handles.listbox1,'string',soubory);
% hotovo=0;
% celkem=length(soubory);
% set(handles.listbox1,'string',soubory);
% set(handles.text2,'string',[num2str(hotovo) '/' num2str(celkem)]);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global soubory soubory_listbox celkem hotovo
imageNumber = get((handles.listbox1), 'Value');


if isempty(soubory)
    imageNumber=[];
end

soubory(imageNumber )=[];

hotovo=0;
celkem=length(soubory);
clear soubory_listbox
% pom_cesta=[cesta '_preulozeni'];
for k=1:celkem
    %     pom=soubory{k};
    %     pom(1:length(cesta))=[];
    %     pom(end-5:end)=[];
    %     pom=[pom_cesta pom];
    %     ukladani_soubory{k}=pom;
    soubory_listbox{k} =[num2str(k) ' -  '  soubory{k}] ;
end
set(handles.listbox1,'Value',1);

if ~exist('soubory_listbox','var')
    soubory_listbox=[];
end

set(handles.listbox1,'string',soubory_listbox);
set(handles.text2,'string',[num2str(hotovo) '/' num2str(celkem)]);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ukladaci_cesta pom_cislo
pom = uigetdir;
if pom
    ukladaci_cesta=pom;
    
    t = datetime('now','TimeZone','local','Format','yyyy-MM-dd_hh-mm');
    pom_cislo=['_' char(t)];
    
    
    ukladaci_cesta=[ukladaci_cesta '/vys_' pom_cislo];
    
    set(handles.text6,'string',pom);
    
end



function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
% brak;
% return
% quit force
% brek;
ukoncit=questdlg('Ukonèit program?','Ukonèení','Ano','Ne','');

if strcmp(ukoncit,'Ano')
    close all force
    quit force
    % exit()
    delete(hObject);
    %
    %
end
