function varargout = malovatko_freehand(varargin)
% MALOVATKO_FREEHAND MATLAB code for malovatko_freehand.fig
%      MALOVATKO_FREEHAND, by itself, creates a new MALOVATKO_FREEHAND or raises the existing
%      singleton*.
%
%      H = MALOVATKO_FREEHAND returns the handle to a new MALOVATKO_FREEHAND or the handle to
%      the existing singleton*.
%
%      MALOVATKO_FREEHAND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MALOVATKO_FREEHAND.M with the given input arguments.
%
%      MALOVATKO_FREEHAND('Property','Value',...) creates a new MALOVATKO_FREEHAND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before malovatko_freehand_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to malovatko_freehand_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help malovatko_freehand

% Last Modified by GUIDE v2.5 13-May-2019 14:29:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @malovatko_freehand_OpeningFcn, ...
                   'gui_OutputFcn',  @malovatko_freehand_OutputFcn, ...
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


% --- Executes just before malovatko_freehand is made visible.
function malovatko_freehand_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to malovatko_freehand (see VARARGIN)

% set(handles.figure1,'units','norm','position',[0 0 1 1]);
% pause(0.01)

drawnow;
set(get(handle(gcf),'JavaFrame'),'Maximized',1);


global maska barva1 r_koef g_koef b_koef reset img slice maska_3d zahodit

reset=0;

zahodit=0;


% set(gcf,'toolbar','figure');
 H = uitoolbar('parent',handles.figure1);
 C = uitoolfactory(H,'Exploration.ZoomIn');
 C = uitoolfactory(H,'Exploration.ZoomOut');
 
 
r_koef=1;
g_koef=1;
b_koef=1;


img=varargin{1};
slice=1;
barva1=img(:,:,:,slice);

maska_3d=varargin{2};
maska=maska_3d(:,:,slice);

set(handles.text2,'string',varargin{3})


prekresleni(hObject, eventdata, handles)



axes(handles.axes1)

% Choose default command line output for malovatko_freehand
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes malovatko_freehand wait for user response (see UIRESUME)
uiwait(handles.figure1);





function prekresleni(hObject, eventdata, handles)

global barva1 r_koef g_koef b_koef axik maska h


axes(handles.axes1)

set(handles.text3, 'String', num2str(r_koef));
set(handles.pushbutton17, 'String', num2str(g_koef));
set(handles.pushbutton18, 'String', num2str(b_koef));





h=imshow(barva1);
hold on
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 







% --- Outputs from this function are returned to the command line.
function varargout = malovatko_freehand_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global maska reset zahodit
% handles.output = maska;

varargout{1} = maska;

varargout{2} = reset;

varargout{3} = zahodit;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

global maska  h

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% h=imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 

axes(handles.axes1)
% imshow(barva3, [])
% hold on
% axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
% hold off 


c=imfreehand;
d=createMask(c,h);


maska(d)=0;
% imshow(obrazek, 'InitialMag', 'fit')


global axik
hold on
delete(axik)
delete(c)
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 

uiwait(handles.figure1);



    

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)


global maska h

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% h=imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 
 axes(handles.axes1)


c=imfreehand;
d=createMask(c,h);

maska(d)=1;


% imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r'); 
% hold off 

global axik
hold on
delete(axik)
delete(c)
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 


uiwait(handles.figure1);





    
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
global maska

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% h=imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 
%  

axes(handles.axes1)
M=imfreehand('Closed',false);

F = false(size(M.createMask));
P00 = M.getPosition;
 
try

% P0 = unique(round(P00),'rows');
P00=P00+(rand(size(P00))-0.6);
[~,ia1,~]=unique(round(P00(:,1)*10)/10,'rows');
[~,ia2,~]=unique(round(P00(:,2)*10)/10,'rows');
vektor=zeros(1,size(P00,1));
vektor(ia1)=vektor(ia1)+1;
vektor(ia2)=vektor(ia2)+2;
P0=P00(find(vektor>0),:);

D = round([0; cumsum(sum(abs(diff(P0)),2))]);
[D,ia1,~]=unique(D,'rows');
P0=P0(ia1,:);
P = interp1(D,P0,D(1):.3:D(end)); % ...to close the gaps

P = unique(round(P),'rows');

P(P<1)=1;
P1=P(:,1);
P2=P(:,2);
P1(P1>size(maska,2))=size(maska,2);
P2(P2>size(maska,1))=size(maska,1);
S = sub2ind(size(maska),P2,P1);


F(S) = true;
F=imdilate(F,strel('disk',1));

maska(F)=0;
catch
    blabla=5;
end

delete(M)


% imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r'); 
% hold off 

global axik
hold on
% delete(M)
delete(axik)
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 


uiwait(handles.figure1);

% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
global maska h

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% h=imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 

axes(handles.axes1)

c=impoint;
d=createMask(c,h);

l=bwlabel(maska,4);

ll=l(d);
ll=ll(ll>0);

if ~isempty(ll)
    ll=mode(ll);
    vymazat=ll==l;
    
    maska(vymazat)=0;
end

% 
% imshow(obrazek, 'InitialMag', 'fit')
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 


global axik
hold on
delete(axik)
delete(c)
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 

uiwait(handles.figure1);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maska h

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% h=imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 

axes(handles.axes1)

c=imfreehand;
d=createMask(c,h);

maska(d)=0;
% imshow(obrazek, 'InitialMag', 'fit')
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 

global axik
hold on
delete(axik)
delete(c)
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 


uiwait(handles.figure1);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try
global maska

% h=imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r')
% hold off 
% 




axes(handles.axes1)
M=imfreehand('Closed',false);

F = false(size(M.createMask));
P00 = M.getPosition;
 
try

[~,ia1,~]=unique(round(P00(:,1)*10)/10,'rows');
[~,ia2,~]=unique(round(P00(:,2)*10)/10,'rows');
vektor=zeros(1,size(P00,1));
vektor(ia1)=vektor(ia1)+1;
vektor(ia2)=vektor(ia2)+2;
P0=P00(find(vektor>0),:);

D = round([0; cumsum(sum(abs(diff(P0)),2))]);

[D,ia1,~]=unique(D,'rows');
P0=P0(ia1,:);

P = interp1(D,P0,D(1):.3:D(end)); % ...to close the gaps
P = unique(round(P),'rows');

P(P<1)=1;
P1=P(:,1);
P2=P(:,2);
P1(P1>size(maska,2))=size(maska,2);
P2(P2>size(maska,1))=size(maska,1);
S = sub2ind(size(maska),P2,P1);
F(S) = true;

l=bwlabel(maska);
spojit=unique(l(F));
spojit(spojit==0)=[];
na_spojeni=false(size(maska));
for k=spojit'
    na_spojeni(l==k)=true;
end
ne_spojene=maska;
ne_spojene(na_spojeni)=false;
final=ne_spojene;
% na_spojeni= bwconvhull(na_spojeni);

na_spojeni= imclose(na_spojeni,strel('disk',5));


na_spojeni(imdilate(ne_spojene,strel('square',3)))=0;
final(na_spojeni)=true;
maska=final;









catch
    blabla=5;
end

delete(M)


% imshow(obrazek, 'InitialMag', 'fit');
% hold on
% visboundaries(maska,'LineWidth',0.1,'Color','r'); 
% hold off 

global axik
hold on
% delete(M)
delete(axik)
axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
hold off 







% axes(handles.axes1)
% M=imfreehand('Closed',false);
% 
% try
% F = false(size(M.createMask));
% P0 = M.getPosition;
% D = round([0; cumsum(sum(abs(diff(P0)),2))]); 
% P = interp1(D,P0,D(1):.5:D(end)); % ...to close the gaps
% P = unique(round(P),'rows');
% S = sub2ind(size(maska),P(:,2),P(:,1));
% F(S) = true;
% l=bwlabel(maska);
% spojit=unique(l(F));
% spojit(spojit==0)=[];
% na_spojeni=false(size(maska));
% for k=spojit'
%     na_spojeni(l==k)=true;
% end
% ne_spojene=maska;
% ne_spojene(na_spojeni)=false;
% final=ne_spojene;
% % na_spojeni= bwconvhull(na_spojeni);
% 
% na_spojeni= imclose(na_spojeni,strel('disk',5));
% 
% 
% na_spojeni(imdilate(ne_spojene,strel('square',3)))=0;
% final(na_spojeni)=true;
% maska=final;
% 
% % imshow(obrazek, 'InitialMag', 'fit')
% % hold on
% % visboundaries(maska,'LineWidth',0.1,'Color','r')
% % hold off 
% 
% % end
% 
% global axik
% hold on
% delete(axik)
% 
% axik=visboundaries(maska,'LineWidth',0.1,'Color','r');
% hold off 
% 
% 
% 
% catch
%     blabla=5;
% end
% 
% delete(M)

uiwait(handles.figure1);




% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global r_koef
r_koef=r_koef-0.1;
prekresleni(hObject, eventdata, handles)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global r_koef
r_koef=r_koef+0.1;
prekresleni(hObject, eventdata, handles)

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_koef
g_koef=g_koef-0.1;
prekresleni(hObject, eventdata, handles)

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_koef
g_koef=g_koef+0.1;
prekresleni(hObject, eventdata, handles)

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global b_koef
b_koef=b_koef-0.1;
prekresleni(hObject, eventdata, handles)

% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global b_koef
b_koef=b_koef+0.1;
prekresleni(hObject, eventdata, handles)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global reset

reset=1;

delete(handles.figure1);


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



global slice maska_3d maska barva1 img

maska_3d(:,:,slice)=maska;

slice=slice-1;
slice(slice<1)=1;

barva1=img(:,:,:,slice);
maska=maska_3d(:,:,slice);

prekresleni(hObject, eventdata, handles)

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global slice maska_3d maska barva1 img

maska_3d(:,:,slice)=maska;

slice=slice+1;
slice(slice>size(img,4))=size(img,4);

barva1=img(:,:,:,slice);
maska=maska_3d(:,:,slice);

prekresleni(hObject, eventdata, handles)




% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zahodit

zahodit=1;

delete(handles.figure1);


