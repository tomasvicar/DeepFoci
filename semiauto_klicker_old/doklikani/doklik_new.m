function varargout = doklik_new(varargin)
% DOKLIK_NEW MATLAB code for doklik_new.fig
%      DOKLIK_NEW, by itself, creates a new DOKLIK_NEW or raises the existing
%      singleton*.
%
%      H = DOKLIK_NEW returns the handle to a new DOKLIK_NEW or the handle to
%      the existing singleton*.
%
%      DOKLIK_NEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOKLIK_NEW.M with the given input arguments.
%
%      DOKLIK_NEW('Property','Value',...) creates a new DOKLIK_NEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before doklik_new_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to doklik_new_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help doklik_new

% Last Modified by GUIDE v2.5 17-Apr-2018 11:15:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @doklik_new_OpeningFcn, ...
    'gui_OutputFcn',  @doklik_new_OutputFcn, ...
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


% --- Executes just before doklik_new is made visible.
function doklik_new_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to doklik_new (see VARARGIN)
% set(handles.figure1,'units','norm','outerposition',[0 0 1 1]);
drawnow;
set(get(handle(handles.figure1),'JavaFrame'),'Maximized',1);

% set(handles.figure1,'units','norm','position',[0 0 1 1]);


global maska barva1 barva2 barva3 tecky data prah features pevne smazane maska_bunky cesticka poprve_kreslim
global a_koef b_koef normyv reset

reset=0;

global pouzit Mdl uk_snimek


barva1=varargin{1};
barva2=varargin{2};
barva3=varargin{3};
maska=varargin{4};
data=varargin{5};
tecky=varargin{6};
prah=varargin{7};
features=varargin{8};
set(handles.text2,'string',varargin{9})
cesticka=varargin{9};

a_koef=1;
b_koef=1;

poprve_kreslim=1;
smazane=varargin{10};

maska_bunky=varargin{11};
Mdl=varargin{12};
uk_snimek=varargin{13};





normyv=varargin{14};

vys_stare=varargin{15};

pouzit=varargin{16};


if ~isempty(vys_stare)
    pevne=vys_stare;
    set(handles.pushbutton12,'visible','on')
    set(handles.pushbutton4,'visible','off')
    set(handles.pushbutton3,'visible','off')
    set(handles.edit1,'visible','off')
else
    pevne=zeros(1,size(data,2));
    
end

if pouzit==0
    set(handles.text7,'visible','on')
end


% Choose default command line output for doklik_new
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



prepis_hodnot(hObject, eventdata, handles);

H = uitoolbar('parent',handles.figure1);
C = uitoolfactory(H,'Exploration.ZoomIn');
C = uitoolfactory(H,'Exploration.ZoomOut');



% UIWAIT makes doklik_new wait for user response (see UIRESUME)
% set(h1,'ButtonDownFcn',@MousePress);
set(handles.figure1,'WindowButtonDownFcn',{@MousePress,handles,hObject});
% set(handles.figure2,'WindowButtonDownFcn',{@MousePress2,handles,hObject});
% set(handles.figure3,'WindowButtonDownFcn',{@MousePress3,handles,hObject});



uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = doklik_new_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global vysledek pouzit prah reset

% handles.output = maska;

varargout{1} = vysledek;

varargout{2} = pouzit;
varargout{3} = prah;

varargout{4} = reset;
% hFigure = findall(0,'Name','doklik_new');
% F = getframe(hFigure);
% varargout{3}=F.cdata;




% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pouzit uk_snimek cesticka vysledek
pouzit=1;
set(handles.text2,'string',[cesticka '   pocet=' num2str(sum(vysledek))])
% hFigure = findall(0,'Name','doklik_new');
% F = getframe(hFigure);
print(uk_snimek,'-dpng')
delete(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pouzit uk_snimek cesticka
pouzit=0;
set(handles.text2,'string',[cesticka '   zahozeno'])
print(uk_snimek,'-dpng')
% hFigure = findall(0,'Name','My GUI');
% F = getframe(hFigure);
delete(handles.figure1);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global prah
prah=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
prepis_hodnot(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function prepis_hodnot(hObject, eventdata, handles)

global prah Mdl features vysledek pevne
if ~isempty(features)
    vys=SVM_bplus(Mdl,prah,features);
else
    vys=[];
end
vysledek=double(vys>0);


vysledek(pevne==2)=1;
vysledek(pevne==1)=0;
prepis(hObject, eventdata, handles)


function prepis(hObject, eventdata, handles)

global barva1 barva2 barva3 prah features tecky vysledek pevne maska h1 smazane maska_bunky Mdl cesticka poprve_kreslim
global cc1 cc2 cc3 cc4 cc5 cc6 cc7 cc8 cc9
global a_koef b_koef normyv


n1=normyv.norma;
n2=normyv.normb;

set(handles.text3, 'String', num2str(round(n1(1))));
set(handles.text4, 'String', [num2str(round(n1(2)*a_koef)) '(' num2str(round(a_koef*10)/10) ')']);
set(handles.text5, 'String', num2str(round(n2(1))));
set(handles.text6, 'String', [num2str(round(n2(2)*b_koef)) '(' num2str(round(b_koef*10)/10) ')']);



set(handles.edit1, 'String', num2str(prah));


% vysledek=double(features>prah);



set(handles.text2,'string',[cesticka '   pocet=' num2str(sum(vysledek))])

pouzite=vysledek;
% pouzite=ones(1,size(tecky,1));

% linkaxes([handles.axes3,handles.axes1],'y')


axes(handles.axes1)
if poprve_kreslim
    barva33=cat(3,mat2gray(barva3(:,:,1),[0  a_koef]),mat2gray(barva3(:,:,2),[0  b_koef]),barva3(:,:,3));
    h1=imshow(barva33);
end
% set(gca, 'Units', 'Pixels')
% p = get(gca, 'Position');
% px=(p(3)-p(1))/size(barva3,1);
% py=(p(4)-p(2))/size(barva3,2);
hold on

% if get(handles.checkbox2,'Value')
% visboundaries(sum(smazane,3),'LineWidth',0.1,'Color','b')
% end
% if get(handles.checkbox3,'Value')
% visboundaries(maska_bunky,'LineWidth',0.1,'Color','g')
% end

if ~poprve_kreslim
    delete(cc1);delete(cc2);delete(cc3);
end
try
    %     plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'k+')
    %     plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'yx')
    cc1=plot(tecky(:,1), tecky(:,2), 'b*');
    cc2=plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'ro');
    cc3=plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'g*');
end
hold off



axes(handles.axes2)
if poprve_kreslim
    barva22=cat(3,mat2gray(barva2(:,:,1),[0  a_koef]),mat2gray(barva2(:,:,2),[0  b_koef]),barva2(:,:,3));
    imshow(barva22)
end
hold on

if ~poprve_kreslim
    delete(cc4);delete(cc5);delete(cc6);
end

try
    cc4=plot(tecky(:,3), tecky(:,2), 'b*');
    cc5=plot(tecky(find(pouzite),3), tecky(find(pouzite),2), 'ro');
    cc6=plot(tecky(find(pouzite),3), tecky(find(pouzite),2), 'g*');
end
hold off



axes(handles.axes3)
if poprve_kreslim
    barva11=cat(3,mat2gray(barva1(:,:,1),[0  a_koef]),mat2gray(barva1(:,:,2),[0  b_koef]),barva1(:,:,3));
    imshow(barva11);
end
% h3=image(barva1);
hold on

if ~poprve_kreslim
    delete(cc7);delete(cc8);delete(cc9);
end
try
    cc7=plot(tecky(:,1), tecky(:,3), 'b*');
    cc8=plot(tecky(find(pouzite),1), tecky(find(pouzite),3), 'ro');
    cc9=plot(tecky(find(pouzite),1), tecky(find(pouzite),3), 'g*');
end
% camzoom(0.5)

% truesize(handles.axes1,[200 200])
% align([handles.axes1,handles.axes2],'None','Center')
% align([handles.axes1,handles.axes3],'Center','None')
% align([handles.axes1,handles.axes2],'Center','None')
poprve_kreslim=0;
hold off
% pos(3)
% pos=get(handles.axes1, 'Position');


% pos2=get(handles.axes3, 'Position');
% % set(handles.axes3, 'Position',[pos2(1) pos2(2) pos(3) pos2(4)])
% uiwait(handles.figure1);



%
% % figure;
% imshow(barvav)
% hold on
%
%
% pouzite=(akt_intenzity_r>intenzita)&(akt_velikosti_r>velikost);
%
% tecky=akt_maxima;
% try
%     plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'k+')
%     plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'yx')
% end
% pause(0.1);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global prah
prah=prah-0.1;
prepis_hodnot(hObject, eventdata, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global prah
prah=prah+0.1;
prepis_hodnot(hObject, eventdata, handles);



function MousePress(src,eventdata,handles,hObject)
global pevne vysledek tecky
cursor = get(gca,'CurrentPoint');
cursor = round(cursor(1,[1,2]));



% disp('klik')

% if get(handles.radiobutton1, 'Value')
%     tecky_par=tecky(vysledek,:);
%     pevne_par=tecky(vysledek,:);
% else
ax=gca;
if cursor>0
    
    if ax==handles.axes3
        [~,nejmin]=min((tecky(:,1)-cursor(1)).^2+(tecky(:,3)-cursor(2)).^2);
    end
    
    if ax==handles.axes2
        [~,nejmin]=min((tecky(:,2)-cursor(2)).^2+(tecky(:,3)-cursor(1)).^2);
    end
    
    if ax==handles.axes1
        [~,nejmin]=min((tecky(:,1)-cursor(1)).^2+(tecky(:,2)-cursor(2)).^2);
    end
    
    
    if vysledek(nejmin)==1
        pevne(nejmin)=1;
        vysledek(nejmin)=0;
    else
        pevne(nejmin)=2;
        vysledek(nejmin)=1;
    end
    prepis(hObject, eventdata, handles);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vis1 vis11 vis12
global maska

if get(handles.checkbox1,'Value')
    axes(handles.axes1)
    hold on
    vis1=visboundaries(sum(maska,3),'LineWidth',0.1,'Color','r');
    hold off
    
    axes(handles.axes2)
    hold on
    vis11=visboundaries(squeeze(sum(maska,2)),'LineWidth',0.1,'Color','r');
    hold off
    axes(handles.axes3)
    hold on
    vis12=visboundaries(squeeze(sum(maska,1))','LineWidth',0.1,'Color','r');
    hold off
else
    delete(vis1)
    delete(vis11)
    delete(vis12)
end
% Hint: get(hObject,'Value') returns toggle state of checkbox1

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
global vis2 smazane
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% prepis(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox2

axes(handles.axes1)
if get(handles.checkbox2,'Value')
    hold on
    vis2=visboundaries(sum(smazane,3),'LineWidth',0.1,'Color','r');
    hold off
else
    delete(vis2)
end



% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vis3 maska_bunky
axes(handles.axes1)
if get(handles.checkbox3,'Value')
    hold on
    vis3=visboundaries(maska_bunky,'LineWidth',0.1,'Color','g');
    hold off
else
    delete(vis3)
end
% Hint: get(hObject,'Value') returns toggle state of checkbox3






% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global visa1 visa2 visa3 tecky vysledek
% global maska
% global maska

teckyy=tecky(find(vysledek),:);
cisla=cellfun(@num2str,num2cell(1:length(teckyy)),'UniformOutput',false);

if get(handles.checkbox4,'Value')
    p1=2;
    p2=2;
    fo=8;
    axes(handles.axes1)
    hold on
    visa1=text(teckyy(:,1)+p1,teckyy(:,2)+p2,cisla,'FontSize',fo);
    %     vis1=visboundaries(sum(maska,3),'LineWidth',0.1,'Color','r');
    hold off
    
    axes(handles.axes2)
    hold on
    visa2=text(teckyy(:,3)+p1,teckyy(:,2)+p2,cisla,'FontSize',fo);
    %     vis11=visboundaries(squeeze(sum(maska,2)),'LineWidth',0.1,'Color','r');
    hold off
    axes(handles.axes3)
    hold on
    visa3=text(teckyy(:,1)+p1,teckyy(:,3)+p2,cisla,'FontSize',fo);
    %     vis12=visboundaries(squeeze(sum(maska,1))','LineWidth',0.1,'Color','r');
    hold off
else
    delete(visa1)
    delete(visa2)
    delete(visa3)
end



% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global visa1 visa2 visa3 tecky

cisla=cellfun(@num2str,num2cell(1:length(tecky)),'UniformOutput',false);

if get(handles.checkbox5,'Value')
    p1=2;
    p2=2;
    fo=8;
    axes(handles.axes1)
    hold on
    visa1=text(tecky(:,1)+p1,tecky(:,2)+p2,cisla,'FontSize',fo);
    %     vis1=visboundaries(sum(maska,3),'LineWidth',0.1,'Color','r');
    hold off
    
    axes(handles.axes2)
    hold on
    visa2=text(tecky(:,3)+p1,tecky(:,2)+p2,cisla,'FontSize',fo);
    %     vis11=visboundaries(squeeze(sum(maska,2)),'LineWidth',0.1,'Color','r');
    hold off
    axes(handles.axes3)
    hold on
    visa3=text(tecky(:,1)+p1,tecky(:,3)+p2,cisla,'FontSize',fo);
    %     vis12=visboundaries(squeeze(sum(maska,1))','LineWidth',0.1,'Color','r');
    hold off
else
    delete(visa1)
    delete(visa2)
    delete(visa3)
end





% Hint: get(hObject,'Value') returns toggle state of checkbox4




% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h1 a b

axes(handles.axes1)
c=impoint;
d=createMask(c,h1);
[y,x]=find(d);
% d=imdilate(d,strel('disk',4));
ab=a.*b;

kolik=20;
ab=ab(x-kolik:x+kolik,y-kolik:y+kolik,:);

m=ab>prctile(ab(:),80);

stats = regionprops3(m,ab,'Centroid','MeanIntensity');

[~,nej]=max(stats.MeanIntensity);
novy_tecky=5;


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a_koef b_koef poprve_kreslim
a_koef=a_koef-0.1;
poprve_kreslim=1;
prepis(hObject, eventdata, handles)

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a_koef b_koef poprve_kreslim
a_koef=a_koef+0.1;
poprve_kreslim=1;
prepis(hObject, eventdata, handles)

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a_koef b_koef poprve_kreslim
b_koef=b_koef-0.1;
poprve_kreslim=1;
prepis(hObject, eventdata, handles)

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a_koef b_koef poprve_kreslim
b_koef=b_koef+0.1;
poprve_kreslim=1;
prepis(hObject, eventdata, handles)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global reset

reset=1;

delete(handles.figure1);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pevne data
pevne=zeros(1,size(data,2));
prepis(hObject, eventdata, handles)
set(handles.pushbutton4,'visible','on')
set(handles.pushbutton3,'visible','on')
set(handles.edit1,'visible','on')