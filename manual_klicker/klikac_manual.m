function varargout = klikac_manual(varargin)
% KLIKAC_MANUAL MATLAB code for klikac_manual.fig
%      KLIKAC_MANUAL, by itself, creates a new KLIKAC_MANUAL or raises the existing
%      singleton*.
%
%      H = KLIKAC_MANUAL returns the handle to a new KLIKAC_MANUAL or the handle to
%      the existing singleton*.
%
%      KLIKAC_MANUAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KLIKAC_MANUAL.M with the given input arguments.
%
%      KLIKAC_MANUAL('Property','Value',...) creates a new KLIKAC_MANUAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before klikac_manual_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to klikac_manual_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help klikac_manual

% Last Modified by GUIDE v2.5 03-Dec-2018 18:42:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @klikac_manual_OpeningFcn, ...
                   'gui_OutputFcn',  @klikac_manual_OutputFcn, ...
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


% --- Executes just before klikac_manual is made visible.
function klikac_manual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to klikac_manual (see VARARGIN)

% drawnow;
% set(get(handle(gcf),'JavaFrame'),'Maximized',1);


global r g b r_min g_min b_min r_max g_max b_max maska tecky poprve_kreslim conts save_name

poprve_kreslim=1;

r=varargin{1};
g=varargin{2};
b=varargin{3};

save_name=varargin{4};

maska=zeros(size(r));


% set(gcf,'toolbar','figure');
H = uitoolbar('parent',handles.figure1);
C = uitoolfactory(H,'Exploration.ZoomIn');
C = uitoolfactory(H,'Exploration.ZoomOut');
 
p=0.01;
r_min =prctile(r(:),p);
g_min =prctile(g(:),p);
b_min =prctile(b(:),p);
r_max =prctile(r(:),100-p);
g_max =prctile(g(:),100-p);
b_max =prctile(b(:),100-p);

% r_min =min(r(:));
% g_min =min(g(:));
% b_min =min(b(:));
% r_max =max(r(:));
% g_max =max(g(:));
% b_max =max(b(:));



tecky=[];

conts={};

prekresleni(hObject, eventdata, handles)


% Choose default command line output for klikac_manual
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



set(handles.figure1,'WindowButtonDownFcn',{@MousePress,handles,hObject});

% UIWAIT makes klikac_manual wait for user response (see UIRESUME)
uiwait(handles.figure1);


function MousePress(src,eventdata,handles,hObject)
global tecky
cursor = get(gca,'CurrentPoint');
cursor = round(cursor(1,[1,2]));

if strcmp(get(handles.figure1, 'pointer'),'arrow')


    if strcmp(get(gcf,'selectiontype'),'normal')
        tecky(end+1,:)=cursor;


    else
        if length(tecky)>0
            [~,nejmin]=min((tecky(:,1)-cursor(1)).^2+(tecky(:,2)-cursor(2)).^2);
            tecky(nejmin,:)=[];
        end
    end

    prekresleni(hObject, eventdata, handles)
end










function prekresleni(hObject, eventdata, handles)


global r g b r_min g_min b_min r_max g_max b_max maska tecky poprve_kreslim c cc ccc conts h

axes(handles.axes1)

set(handles.text4, 'String', num2str(round(r_min)));
set(handles.text5, 'String', num2str(round(g_min)));
set(handles.text6, 'String', num2str(round(b_min)));


set(handles.text8, 'String', num2str(round(r_max)));
set(handles.text9, 'String', num2str(round(g_max)));
set(handles.text10, 'String', num2str(round(b_max)));


img=cat(3,mat2gray(r,[r_min r_max]),mat2gray(g,[g_min g_max]),mat2gray(b,[b_min b_max]));
% % img=cat(3,mat2gray(r),mat2gray(g),mat2gray(b));
if poprve_kreslim
    hold off
    h=imshow(img);
end

hold on

if ~poprve_kreslim
    for cont = conts
        delete(cont)
    end
end

conts={};
for k=1:max(maska(:))
    cont=visboundaries(maska==k,'Color','r');
    conts=[conts cont];
end


if ~poprve_kreslim
    delete(c);delete(cc);delete(ccc);
end

if length(tecky)>0
    c=plot(tecky(:,1), tecky(:,2), 'ro');
    cc=plot(tecky(:,1), tecky(:,2), 'b*');
    ccc=plot(tecky(:,1), tecky(:,2), 'yx');
end

poprve_kreslim=0;







% --- Outputs from this function are returned to the command line.
function varargout = klikac_manual_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

disp('out')
global tecky maska
varargout{1} = tecky;
varargout{2} = maska;





% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maska h
c=imfreehand;
d=createMask(c,h);
delete(c)

maska(d)=max(maska(:))+1;
prekresleni(hObject, eventdata, handles)
uiwait(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maska h
c=impoint;
d=createMask(c,h);
delete(c)

lbl=maska(d);
maska(maska==lbl)=0;
prekresleni(hObject, eventdata, handles)
uiwait(handles.figure1);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;

global r_min
r_min=r_min*1.1;
prekresleni(hObject, eventdata, handles)
uiwait(handles.figure1);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global poprve_kreslim
poprve_kreslim=1;
global r_min
r_min=r_min*0.9;
prekresleni(hObject, eventdata, handles)
uiwait(handles.figure1);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global poprve_kreslim
poprve_kreslim=1;
global g_min
g_min=g_min*1.1;
prekresleni(hObject, eventdata, handles)
uiwait(handles.figure1);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;

global g_min
g_min=g_min*0.9;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;

global b_min
b_min=b_min*1.1;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);



% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;

global b_min
b_min=b_min*0.9;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);




% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global poprve_kreslim
poprve_kreslim=1;
global r_max
r_max=r_max*1.1;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);




% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;

global r_max
r_max=r_max*0.9;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global poprve_kreslim
poprve_kreslim=1;
global g_max
g_max=g_max*1.1;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global poprve_kreslim
poprve_kreslim=1;
global g_max
g_max=g_max*0.9;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;
global b_max
b_max=b_max*1.1;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global poprve_kreslim
poprve_kreslim=1;
global b_max
b_max=b_max*0.9;
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);





function text4_Callback(hObject, eventdata, handles)
global poprve_kreslim
poprve_kreslim=1;
global r_min
r_min=str2double(get(handles.text4, 'String'));
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);


function text5_Callback(hObject, eventdata, handles)
global poprve_kreslim
poprve_kreslim=1;
global g_min
g_min=str2double(get(handles.text5, 'String'));
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);


function text6_Callback(hObject, eventdata, handles)
global poprve_kreslim
poprve_kreslim=1;
global b_min
b_min=str2double(get(handles.text6, 'String'));
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);


function text8_Callback(hObject, eventdata, handles)
global poprve_kreslim
poprve_kreslim=1;
global r_max
r_max=str2double(get(handles.text8, 'String'));
prekresleni(hObject, eventdata, handles)
uiwait(handles.figure1);


function text9_Callback(hObject, eventdata, handles)
global poprve_kreslim
poprve_kreslim=1;
global g_max
g_max=str2double(get(handles.text9, 'String'));
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);


function text10_Callback(hObject, eventdata, handles)
global poprve_kreslim
poprve_kreslim=1;
global b_max
b_max=str2double(get(handles.text10, 'String'));
prekresleni(hObject, eventdata, handles)

uiwait(handles.figure1);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global save_name
print(save_name,'-dpng')

delete(handles.figure1);
