function varargout = superpix_labeler(varargin)
% SUPERPIX_LABELER MATLAB code for superpix_labeler.fig
%      SUPERPIX_LABELER, by itself, creates a new SUPERPIX_LABELER or raises the existing
%      singleton*.
%
%      H = SUPERPIX_LABELER returns the handle to a new SUPERPIX_LABELER or the handle to
%      the existing singleton*.
%
%      SUPERPIX_LABELER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUPERPIX_LABELER.M with the given input arguments.
%
%      SUPERPIX_LABELER('Property','Value',...) creates a new SUPERPIX_LABELER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before superpix_labeler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to superpix_labeler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help superpix_labeler

% Last Modified by GUIDE v2.5 20-May-2019 08:51:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @superpix_labeler_OpeningFcn, ...
                   'gui_OutputFcn',  @superpix_labeler_OutputFcn, ...
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


% --- Executes just before superpix_labeler is made visible.
function superpix_labeler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to superpix_labeler (see VARARGIN)

drawnow;
pause(0.05)
set(get(handle(gcf),'JavaFrame'),'Maximized',1);
drawnow;
pause(0.05)
H = uitoolbar('parent',handles.figure1);
C = uitoolfactory(H,'Exploration.ZoomIn');
C = uitoolfactory(H,'Exploration.ZoomOut');

handles.img = varargin{1};
handles.lines = varargin{2};
handles.slice=20;
handles.slicex=200;
handles.slicey=200;
handles.drop=0;
handles.nasobiciKonstanta=1;
handles.mask=zeros(size(handles.img));
handles.lbl=bwlabeln(handles.lines==0,6);
handles.cell_num=1;
handles.cell_color='red';
set(handles.textCellNum, 'String', [num2str(handles.cell_num)  '  ' handles.cell_color])

handles.change='big';
guidata(hObject, handles);

update_imgs(handles,hObject)
handles = guidata(hObject);

set(handles.figure1,'WindowKeyPressFcn',{@KeyPress,handles,hObject});


% Choose default command line output for superpix_labeler
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes superpix_labeler wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = superpix_labeler_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.mask;
varargout{2} = handles.drop;






% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% delete(handles.figure1);
uiresume(handles.figure1);

% --- Executes on button press in pushbuttonDrop.
function pushbuttonDrop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.drop=1;
guidata(hObject, handles);
% delete(handles.figure1);
uiresume(handles.figure1);


function update_imgs(handles,hObject)

handles = guidata(hObject);

shape=size(handles.img);

% 
% elseif strcmp(EventData.Key,'numpad1')
%     handles.cell_num=1;
%     handles.cell_color='red';
% elseif strcmp(EventData.Key,'numpad2')
%     handles.cell_num=2;
%     handles.cell_color='green';
% elseif strcmp(EventData.Key,'numpad3')
%     handles.cell_num=3;
%     handles.cell_color='blue';
% elseif strcmp(EventData.Key,'numpad3')
%     handles.cell_num=4;
%     handles.cell_color='yellow';
% elseif strcmp(EventData.Key,'numpad3')
%     handles.cell_num=5;
%     handles.cell_color='orange';

colormap_cells=[1 0 0;0 1 0;0 0 1;1 1 0;1.0000 0.6471 0];
lines_alpha=0.7;
lbls_alpha=0.3;


color_img1 = cat(3, 0*ones(shape(1:2)),ones(shape(1:2)),ones(shape(1:2)));
color_img2 = ind2rgb(handles.mask(:,:,handles.slice),colormap_cells);
axes(handles.axes1)
if strcmp(handles.change,'big')
hold off
h=imshow(handles.img(:,:,handles.slice)*handles.nasobiciKonstanta);
set(h,'ButtonDownFcn',{@MousePressAxes1,handles,hObject});
hold on
h = imshow(color_img1); 
set(h,'ButtonDownFcn',{@MousePressAxes1,handles,hObject});
set(h, 'AlphaData', lines_alpha*handles.lines(:,:,handles.slice))
handles.h1 = imshow(color_img2); 
set(handles.h1 ,'ButtonDownFcn',{@MousePressAxes1,handles,hObject});
set(handles.h1 , 'AlphaData', lbls_alpha*double(handles.mask(:,:,handles.slice)>0))
h=plot([1 shape(2)],[handles.slicex handles.slicex],'b');
set(h,'ButtonDownFcn',{@MousePressAxes1,handles,hObject});
h=plot([handles.slicey handles.slicey],[1 shape(1)],'b');
set(h,'ButtonDownFcn',{@MousePressAxes1,handles,hObject});

else
    delete(handles.h1);
    handles.h1 = imshow(color_img2); 
    set(handles.h1 ,'ButtonDownFcn',{@MousePressAxes1,handles,hObject});
    set(handles.h1 , 'AlphaData', lbls_alpha*double(handles.mask(:,:,handles.slice)>0))
end



color_img1 = cat(3, 0*ones(shape([3 2])),ones(shape([3 2])),ones(shape([3 2])));
color_img2 = ind2rgb(rot90(squeeze(handles.mask(handles.slicex,:,:))),colormap_cells);
axes(handles.axesDown)
if strcmp(handles.change,'big')
hold off
h=imshow(rot90(squeeze(handles.img(handles.slicex,:,:)))*handles.nasobiciKonstanta);
set(h,'ButtonDownFcn',{@MousePressAxesDown,handles,hObject});
hold on
h = imshow(color_img1); 
set(h,'ButtonDownFcn',{@MousePressAxesDown,handles,hObject});
set(h, 'AlphaData', rot90(lines_alpha*squeeze(handles.lines(handles.slicex,:,:))))
handles.h2 = imshow(color_img2); 
set(handles.h2,'ButtonDownFcn',{@MousePressAxesDown,handles,hObject});
set(handles.h2, 'AlphaData', lbls_alpha*double(rot90(squeeze(handles.mask(handles.slicex,:,:)))>0))
h=plot([1 shape(2)],[size(handles.img,3)-handles.slice size(handles.img,3)-handles.slice],'b');
set(h,'ButtonDownFcn',{@MousePressAxesDown,handles,hObject});
h=plot([handles.slicey handles.slicey],[1 shape(1)],'b');
set(h,'ButtonDownFcn',{@MousePressAxesDown,handles,hObject});
else
    delete(handles.h2);
    handles.h2 = imshow(color_img2); 
    set(handles.h2,'ButtonDownFcn',{@MousePressAxesDown,handles,hObject});
    set(handles.h2, 'AlphaData', lbls_alpha*double(rot90(squeeze(handles.mask(handles.slicex,:,:)))>0))
end


color_img1 = cat(3, 0*ones(shape([1 3])),ones(shape([1 3])),ones(shape([1 3])));
color_img2 = ind2rgb(squeeze(handles.mask(:,handles.slicey,:)),colormap_cells);
axes(handles.axesLeft)
if strcmp(handles.change,'big')
hold off
h=imshow((squeeze(handles.img(:,handles.slicey,:)))*handles.nasobiciKonstanta);
set(h,'ButtonDownFcn',{@MousePressAxesLeft,handles,hObject});
hold on
h = imshow(color_img1); 
set(h,'ButtonDownFcn',{@MousePressAxesLeft,handles,hObject});
set(h, 'AlphaData', (lines_alpha*squeeze(handles.lines(:,handles.slicey,:))))
handles.h3 = imshow(color_img2); 
set(handles.h3,'ButtonDownFcn',{@MousePressAxesLeft,handles,hObject});
set(handles.h3, 'AlphaData', lbls_alpha*double(squeeze(handles.mask(:,handles.slicey,:))>0))
h=plot([1 shape(2)],[handles.slicex handles.slicex],'b');
set(h,'ButtonDownFcn',{@MousePressAxesLeft,handles,hObject});
h=plot([handles.slice handles.slice],[1 shape(1)],'b');
set(h,'ButtonDownFcn',{@MousePressAxesLeft,handles,hObject});
else
    delete(handles.h3);
    handles.h3 = imshow(color_img2); 
    set(handles.h3,'ButtonDownFcn',{@MousePressAxesLeft,handles,hObject});
    set(handles.h3, 'AlphaData', lbls_alpha*double(squeeze(handles.mask(:,handles.slicey,:))>0))


end


guidata(hObject, handles);










function KeyPress(Source, EventData,handles,hObject)

handles = guidata(hObject);

% disp(EventData.Key)

if strcmp(EventData.Key,'s')
    handles.slicex=handles.slicex+1;
    if handles.slicex>size(handles.img,1)
        handles.slicex=size(handles.img,1);
    end
elseif strcmp(EventData.Key,'w')
    handles.slicex=handles.slicex-1;
    if handles.slicex<1
        handles.slicex=1;
    end
    
elseif strcmp(EventData.Key,'d')
    handles.slicey=handles.slicey+1;
    if handles.slicey>size(handles.img,2)
        handles.slicey=size(handles.img,2);
    end
elseif strcmp(EventData.Key,'a')
    handles.slicey=handles.slicey-1;
    if handles.slicey<1
        handles.slicey=1;
    end    
    
elseif strcmp(EventData.Key,'q')
    handles.slice=handles.slice+1;
    if handles.slice>size(handles.img,3)
        handles.slice=size(handles.img,3);
    end
elseif strcmp(EventData.Key,'e')
    handles.slice=handles.slice-1;
    if handles.slice<1
        handles.slice=1;
    end
    
elseif strcmp(EventData.Key,'numpad1')
    handles.cell_num=1;
    handles.cell_color='red';
elseif strcmp(EventData.Key,'numpad2')
    handles.cell_num=2;
    handles.cell_color='green';
elseif strcmp(EventData.Key,'numpad3')
    handles.cell_num=3;
    handles.cell_color='blue';
elseif strcmp(EventData.Key,'numpad3')
    handles.cell_num=4;
    handles.cell_color='yellow';
elseif strcmp(EventData.Key,'numpad3')
    handles.cell_num=5;
    handles.cell_color='orange';
    
elseif strcmp(EventData.Key,'add')
    handles.nasobiciKonstanta=handles.nasobiciKonstanta*1.1;
elseif strcmp(EventData.Key,'subtract')
    handles.nasobiciKonstanta=handles.nasobiciKonstanta*(1/1.1);
    
else
    return
end

handles.change='big';
set(handles.textCellNum, 'String', [num2str(handles.cell_num)  '  ' handles.cell_color])
guidata(hObject, handles);
update_imgs( handles,hObject)






function MousePressAxes1(src,eventdata,handles,hObject)

handles = guidata(hObject);

cursor = get(gca,'CurrentPoint');
modifier= get(gcf,'currentkey');%control/shift
cursor = round(cursor(1,[2,1]));
mouseButton=get(gcf,'SelectionType');%%normal/alt

cursor(cursor<1)=1;
if cursor(1)>size(handles.img,1)
    cursor(1)=size(handles.img,1);
end
if cursor(2)>size(handles.img,2)
    cursor(2)=size(handles.img,2);
end
cursor(3)=handles.slice;

handles.modifier=modifier;
handles.cursor=cursor;
handles.mouseButton=mouseButton;

guidata(hObject, handles);
MousePressAll(handles,hObject)


function MousePressAxesDown(src,eventdata,handles,hObject)


handles = guidata(hObject);

cursor = get(gca,'CurrentPoint');
modifier= get(gcf,'currentkey');%control/shift
cursor_tmp = round(cursor(1,[2,1]));
mouseButton=get(gcf,'SelectionType');%%normal/alt



cursor([3,2])=cursor_tmp;
cursor(1)=handles.slicex;

cursor(3)=size(handles.img,3)-cursor(3);

cursor(cursor<1)=1;
if cursor(3)>size(handles.img,3)
    cursor(3)=size(handles.img,3);
end
if cursor(2)>size(handles.img,2)
    cursor(2)=size(handles.img,2);
end


handles.modifier=modifier;
handles.cursor=cursor;
handles.mouseButton=mouseButton;

guidata(hObject, handles);
MousePressAll(handles,hObject)



function MousePressAxesLeft(src,eventdata,handles,hObject)
handles = guidata(hObject);

cursor = get(gca,'CurrentPoint');
modifier= get(gcf,'currentkey');%control/shift
cursor_tmp = round(cursor(1,[2,1]));
mouseButton=get(gcf,'SelectionType');%%normal/alt


cursor([1,3])=cursor_tmp;
cursor(3)=cursor(3);
cursor(2)=handles.slicey;

cursor(cursor<1)=1;
if cursor(3)>size(handles.img,3)
    cursor(3)=size(handles.img,3);
end
if cursor(1)>size(handles.img,1)
    cursor(1)=size(handles.img,1);
end


handles.modifier=modifier;
handles.cursor=cursor;
handles.mouseButton=mouseButton;

guidata(hObject, handles);
MousePressAll(handles,hObject)





function MousePressAll(handles,hObject)

if strcmp(handles.modifier,'control')
    handles.change='small';
    
    x=handles.cursor(1);
    y=handles.cursor(2);
    z=handles.cursor(3);

    vel=[25 25 7];
    
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2)<=1;
    
    vel=(vel-1)/2;
    v1=x-vel(1):x+vel(1);
    v2=y-vel(2):y+vel(2);
    v3=z-vel(3):z+vel(3);
    if min(v1)<=0
        v1=v1-min(v1)+1;
    end
    if min(v2)<=0
        v2=v2-min(v2)+1;
    end
    if min(v3)<=0
        v3=v3-min(v3)+1;
    end
    
    shape=size(handles.img);
    if max(v1)>shape(1)
        v1=v1-(max(v1)-shape(1));
    end
    if max(v2)>shape(2)
        v2=v2-(max(v2)-shape(2));
    end
    if max(v3)>shape(3)
        v3=v3-(max(v3)-shape(3));
    end
    

    if strcmp(handles.mouseButton,'normal')
        number_to_insert=handles.cell_num;
        
        
        tmp=handles.mask(v1,v2,v3);
        tmp(sphere)=number_to_insert;
        handles.mask(v1,v2,v3)=tmp ;
    elseif strcmp(handles.mouseButton,'alt')
        number_to_insert=0;
        
        tmp=handles.mask(v1,v2,v3);
        tmp(sphere)=number_to_insert;
        handles.mask(v1,v2,v3)=tmp ;
    end
    
    
    
    
elseif strcmp(handles.modifier,'shift')
        handles.change='big';

        handles.slice=handles.cursor(3);
        handles.slicex=handles.cursor(1);
        handles.slicey=handles.cursor(2);
        
else
    handles.change='small';    
        
    if strcmp(handles.mouseButton,'normal')
        number_to_insert=handles.cell_num;
    elseif strcmp(handles.mouseButton,'alt')
        number_to_insert=0;
    end
        
        
    superpix_num=handles.lbl(handles.cursor(1),handles.cursor(2),handles.cursor(3));
    if superpix_num>0
        handles.mask(handles.lbl==superpix_num)=number_to_insert;
    end
end

guidata(hObject, handles);
update_imgs( handles,hObject)


% 
% function MousePress(src,eventdata,handles,hObject)
% 
% handles = guidata(hObject);
% 
% cursor = get(gca,'CurrentPoint');
% type= get(gcf,'currentkey');%control/shift
% cursor = round(cursor(1,[1,2]));
% button=get(gcf,'SelectionType');%%normal/alt
% get(gcf,'CurrentAxes')
% 
% if gca.Tag
% cursor(cursor<1)=1;
% if cursor(1)>size(handles.img,1)
%     cursor(1)=size(handles.img,1);
% end
% if cursor(2)>size(handles.img,2)
%     cursor(2)=size(handles.img,2);
% end
% cursor=cursor(1,[2 1]);
% cursor(3)=handles.slice;
% 
% end
% 
% 
% 
% 
% if strcmp(button,'normal')
%     number_to_insert=handles.cell_num;
% end
% if strcmp(button,'alt')
%     number_to_insert=0;
% end
% 
% superpix_num=handles.lbl(cursor(1),cursor(2),cursor(3));
% if superpix_num>0
%     handles.mask(handles.lbl==superpix_num)=number_to_insert;
% end
% 
% 
% guidata(hObject, handles);
% 
% update_imgs( handles,hObject)
% 
%   
