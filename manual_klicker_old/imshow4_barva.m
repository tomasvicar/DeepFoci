function varargout = imshow4_barva(varargin)
% IMSHOW4_BARVA MATLAB code for imshow4_barva.fig
%      IMSHOW4_BARVA, by itself, creates a new IMSHOW4_BARVA or raises the existing
%      singleton*.
%
%      H = IMSHOW4_BARVA returns the handle to a new IMSHOW4_BARVA or the handle to
%      the existing singleton*.
%
%      IMSHOW4_BARVA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMSHOW4_BARVA.M with the given input arguments.
%
%      IMSHOW4_BARVA('Property','Value',...) creates a new IMSHOW4_BARVA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imshow4_barva_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imshow4_barva_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imshow4_barva

% Last Modified by GUIDE v2.5 15-Feb-2018 18:19:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imshow4_barva_OpeningFcn, ...
                   'gui_OutputFcn',  @imshow4_barva_OutputFcn, ...
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


% --- Executes just before imshow4_barva is made visible.
function imshow4_barva_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imshow4_barva (see VARARGIN)

% set(handles.figure1,'units','norm','position',[0 0 1 1]);
drawnow;
set(get(handle(gcf),'JavaFrame'),'Maximized',1);
global a b c k
a=varargin{1};
b=varargin{2};
c=varargin{3};

k=1;

imshow(cat(3,mat2gray(a(:,:,k)),mat2gray(b(:,:,k)),mat2gray(c(:,:,k))));

set(handles.figure1, 'WindowKeyPressFcn', @KeyPress);
% Choose default command line output for imshow4_barva
% handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imshow4_barva wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imshow4_barva_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;

% function ButtonPress(src,eventdata,handles,hObject)
function KeyPress(Source, EventData)
global k a b c
if strcmp('rightarrow',EventData.Key)
    k=k+1;
    k(k==size(a,3)+1)=size(a,3);
    
    imshow(cat(3,mat2gray(a(:,:,k)),mat2gray(b(:,:,k)),mat2gray(c(:,:,k))));
end

if strcmp('leftarrow',EventData.Key)
    k=k-1;
    k(k==0)=1;
    
    imshow(cat(3,mat2gray(a(:,:,k)),mat2gray(b(:,:,k)),mat2gray(c(:,:,k))));
end

