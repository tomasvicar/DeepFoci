function varargout = klikac(varargin)
% KLIKAC MATLAB code for klikac.fig
%      KLIKAC, by itself, creates a new KLIKAC or raises the existing
%      singleton*.
%
%      H = KLIKAC returns the handle to a new KLIKAC or the handle to
%      the existing singleton*.
%
%      KLIKAC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KLIKAC.M with the given input arguments.
%
%      KLIKAC('Property','Value',...) creates a new KLIKAC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before klikac_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to klikac_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help klikac

% Last Modified by GUIDE v2.5 24-May-2018 17:44:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @klikac_OpeningFcn, ...
    'gui_OutputFcn',  @klikac_OutputFcn, ...
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


% --- Executes just before klikac is made visible.
function klikac_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to klikac (see VARARGIN)

% Choose default command line output for klikac
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes klikac wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = klikac_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton1,'visible','off');
[file,path] = uigetfile('*.*','xxx','..\..\man_nahodny_vzorek_tif');

save_name=[path '\' file(1:end-4) '_control'];
save_name_maska=[path '\' file(1:end-4) '_maska.mat'];
save_name_tecky=[path '\' file(1:end-4) '_tecky.mat'];
save_name_cas=[path '\' file(1:end-4) '_cas.mat'];


if (file(1)==0)||(strcmp(file(end-3:end),'.tif')==0)
    set(handles.pushbutton1,'visible','on');
    return
end

name=[path '\' file];

tic
info=imfinfo(name);

r=zeros(info(1).Height,info(1).Width,length(info));
g=zeros(info(1).Height,info(1).Width,length(info));
b=zeros(info(1).Height,info(1).Width,length(info));
for k=1:length(info)
    rgb=imread(name,k);
    r(:,:,k)=rgb(:,:,1);
    g(:,:,k)=rgb(:,:,2);
    b(:,:,k)=rgb(:,:,3);
end

r=max(r,[],3);
g=max(g,[],3);
b=max(b,[],3);

r=imgaussfilt(r,1);
g=imgaussfilt(g,1);
b=imgaussfilt(b,1);

cas_nacitani=toc;

% img=cat(3,mat2gray(r),mat2gray(g),mat2gray(b));
% imshow(img)
tic
[tecky,maska]=klikac_manual(r,g,b,save_name);
cas_klikani=toc;

save(save_name_maska,'maska')
save(save_name_tecky,'tecky')
save(save_name_cas,'cas_nacitani','cas_klikani')
drawnow;


set(handles.pushbutton1,'visible','on');




    

