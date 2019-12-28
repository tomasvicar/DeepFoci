function varargout = predzpracovani(varargin)

addpath('../funkce')
% PREDZPRACOVANI MATLAB code for predzpracovani.fig
%      PREDZPRACOVANI, by itself, creates a new PREDZPRACOVANI or raises the existing
%      singleton*.
%
%      H = PREDZPRACOVANI returns the handle to a new PREDZPRACOVANI or the handle to
%      the existing singleton*.
%
%      PREDZPRACOVANI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREDZPRACOVANI.M with the given input arguments.
%
%      PREDZPRACOVANI('Property','Value',...) creates a new PREDZPRACOVANI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before predzpracovani_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to predzpracovani_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help predzpracovani

% Last Modified by GUIDE v2.5 06-Dec-2017 22:55:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @predzpracovani_OpeningFcn, ...
                   'gui_OutputFcn',  @predzpracovani_OutputFcn, ...
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


% --- Executes just before predzpracovani is made visible.
function predzpracovani_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to predzpracovani (see VARARGIN)
global pom_cesta pocet_chyb net


% nett=load('net_checkpoint__322__2019_01_07__18_53_12_test.mat');
nett=load('net_checkpoint__912__2019_01_08__04_24_37_test.mat');
net=nett.net;

% set(handles.figure1,'units','norm','position',[0 0 1 1]);
% drawnow;
% set(get(handle(gcf),'JavaFrame'),'Maximized',1);

% Choose default command line output for predzpracovani
handles.output = hObject;
set(handles.figure1,'CloseRequestFcn',@figure1_CloseRequestFcn);
pocet_chyb=0;
% Update handles structure
guidata(hObject, handles);

pom_cesta=pwd;
set(handles.text3,'string',pom_cesta);

% UIWAIT makes predzpracovani wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = predzpracovani_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


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
global soubory hotovo celkem cesta soubory_listbox


cesta = uigetdir;
if cesta

listing=subdir([cesta '/*.tif']);
soubory={listing.name};

rng(50);
% soubory=soubory(randperm(length(soubory)));

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
set(handles.listbox1,'string',soubory_listbox);
set(handles.text2,'string',[num2str(hotovo) '/' num2str(celkem)]);
end




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global soubory hotovo celkem cesta ukladani_soubory pom_cesta pocet_chyb net

% aaa=genpath(cesta);
% aaa = strsplit(aaa,';');
% % pom_cesta=[cesta '_preulozeni'];
% for k=1:length(aaa)
%     akt=aaa{k};
%     if ~isempty(aaa{k})
%         akt(1:length(cesta))=[];
%         akt=[pom_cesta akt];
%         mkdir(akt)
%     end
% end


% for k=1:celkem
%     pom=soubory{k};
%     pom(1:length(cesta))=[];
%     pom(end-5:end)=[];
%     pom=[pom_cesta pom];
%     ukladani_soubory{k}=pom;
% end



% aaa=soubory;
% for k=aaa
%     [filepath,name,ext] = fileparts(k{1});
%     akt=[pom_cesta akt '/' name];
% end

for k=1:celkem
    pom=soubory{k};
    [filepath,name,ext] = fileparts(pom);
    pom=filepath;
    pom(1:length(cesta))=[];
    pom=[pom_cesta pom '/' name '/'];
    mkdir(pom);
    ukladani_soubory{k}=pom;
end



set(handles.text4,'string',['pracuji']);
drawnow;
for k=1:length(soubory)
%     try
    soubor=soubory{k};
    soubor_ulozit=ukladani_soubory{k};
    
    
    
    [au,bu,cu,maska,maska_krajena,barva,foky_rg,rg_odstranene,rg]=predzpracovat(soubor,net);
    
    f=figure(2);
    hold off
    imshow(barva.barva3)
    hold on
    visboundaries(maska_krajena>0,'LineWidth',0.1,'Color','g')
    plot(rg.Centroid(:,1),rg.Centroid(:,2),'r*')
    plot(rg.Centroid(:,1),rg.Centroid(:,2),'bx')

    print(f,[soubor_ulozit 'preproc_check'],'-dpng')
    
    
    save([soubor_ulozit 'data.mat'],'au','bu','cu','-v6');
    save([soubor_ulozit 'pomocna.mat'],'maska','maska_krajena','barva','foky_rg','rg_odstranene','rg');
    hotovo=k;
    set(handles.text2,'string',[num2str(hotovo) '/' num2str(celkem)]);

%     catch ME
%         pocet_chyb=pocet_chyb+1;
%         set(handles.text5,'string',['pocet chyb:' num2str(pocet_chyb)]);
%         set(handles.text5,'Visible','on');
%         
%         mkdir([pom_cesta '/error'])
%         save([pom_cesta '/error/vse' num2str(pocet_chyb) '.mat'])
%         
% 
%     end
    drawnow;
end
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


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pom_cesta
pom_cesta= uigetdir;
if pom_cesta
set(handles.text3,'string',pom_cesta);
end

% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
ukoncit=questdlg('Ukonèit program?','Ukonèení','Ano','Ne','');

if strcmp(ukoncit,'Ano')
close all force
quit force
% exit()
delete(hObject);
% 
% 
end

