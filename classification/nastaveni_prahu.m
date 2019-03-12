function varargout = nastaveni_prahu(varargin)
% NASTAVENI_PRAHU MATLAB code for nastaveni_prahu.fig
%      NASTAVENI_PRAHU, by itself, creates a new NASTAVENI_PRAHU or raises the existing
%      singleton*.
%
%      H = NASTAVENI_PRAHU returns the handle to a new NASTAVENI_PRAHU or the handle to
%      the existing singleton*.
%
%      NASTAVENI_PRAHU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NASTAVENI_PRAHU.M with the given input arguments.
%
%      NASTAVENI_PRAHU('Property','Value',...) creates a new NASTAVENI_PRAHU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nastaveni_prahu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nastaveni_prahu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nastaveni_prahu

% Last Modified by GUIDE v2.5 07-Dec-2017 10:05:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nastaveni_prahu_OpeningFcn, ...
                   'gui_OutputFcn',  @nastaveni_prahu_OutputFcn, ...
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


% --- Executes just before nastaveni_prahu is made visible.
function nastaveni_prahu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nastaveni_prahu (see VARARGIN)
drawnow;
set(get(handle(gcf),'JavaFrame'),'Maximized',1);
global avv bvv cvv maskyv foky_rvv akt_maxima akt_velikosti_r akt_intenzity_r intenzita velikost barvav

avv=varargin{1};
bvv =varargin{2};
cvv =varargin{3};
maskyv =varargin{4};
foky_rvv=varargin{5};
akt_maxima=varargin{6};
akt_velikosti_r=varargin{7};
akt_intenzity_r=varargin{8};
intenzita=varargin{9};
velikost=varargin{10};
barvav=varargin{11};

prepis(hObject, eventdata, handles);


% Choose default command line output for nastaveni_prahu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nastaveni_prahu wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nastaveni_prahu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
global intenzita velikost

varargout={intenzita,velikost};



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

global intenzita
intenzita=str2double(get(hObject,'String')) ;
prepis(hObject, eventdata, handles);



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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global intenzita
intenzita=intenzita+5;
prepis(hObject, eventdata, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global intenzita
intenzita=intenzita-5;
prepis(hObject, eventdata, handles);



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
global velikost
velikost=str2double(get(hObject,'String')) ;
prepis(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global velikost
velikost=velikost+5;
prepis(hObject, eventdata, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global velikost
velikost=velikost-5;
prepis(hObject, eventdata, handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


function prepis(hObject, eventdata, handles)

global velikost intenzita barvav akt_maxima akt_velikosti_r akt_intenzity_r


set(handles.edit1, 'String', num2str(intenzita));
set(handles.edit3, 'String', num2str(velikost));
% figure;
imshow(barvav)
hold on


pouzite=(akt_intenzity_r>intenzita)&(akt_velikosti_r>velikost);

tecky=akt_maxima;
try
    plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'k+')
    plot(tecky(find(pouzite),1), tecky(find(pouzite),2), 'yx')
end
pause(0.1);













