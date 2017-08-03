function varargout = CellFinder(varargin)
%CELLFINDER M-file for CellFinder.fig
%      CELLFINDER, by itself, creates a new CELLFINDER or raises the existing
%      singleton*.
%
%      H = CELLFINDER returns the handle to a new CELLFINDER or the handle to
%      the existing singleton*.
%
%      CELLFINDER('Property','Value',...) creates a new CELLFINDER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to CellFinder_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CELLFINDER('CALLBACK') and CELLFINDER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CELLFINDER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellFinder

% Last Modified by GUIDE v2.5 11-Jul-2017 11:18:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CellFinder_OpeningFcn, ...
    'gui_OutputFcn',  @CellFinder_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before CellFinder is made visible.
function CellFinder_OpeningFcn(hObject, eventdata, handles, varargin)
% Load CellFinder logo. NAK addition April 2017
axes(handles.cellFinderLogo_axes);
logo = imread('cellFinderLogo.png');
image(logo)
axis off;
axis image;

% Post blank images as placeholders for figures for proper rendering
axes(handles.greenImg_axes);
imshow(ones(512,512));

axes(handles.redImg_axes);
imshow(ones(512,512));

axes(handles.finalImg_axes);
imshow(ones(512,512));

set(handles.circleAreaHisto_axes,'visible','off');
set(handles.axesRatio_axes,'visible','off');



% Add GUI and data folder info to handles
handles.dataFolder = [];
handles.programFolder = pwd;


% Placeholders for images and their corresponsing cmaps
handles.redImg = [];
handles.redCmap = [];
handles.greenImg = [];
handles.greenCmap = [];
handles.cellCenters = [];
handles.backgroundSubImg = [];
handles.hmFilteredImg = [];
handles.redImgGainAdjusted = [];
handles.greenImgGainAdjusted = [];
handles.finalImgGainAdjusted = [];
handles.greenImgContrast = [];
handles.backgroundSubEvent = 0;
handles.redGreenSubImg = [];
handles.previousDiskSize = 0;
handles.previousHMSigma = 0;
handles.hmFilterEvent = 0;
handles.deleteCentersEvent = 0;
handles.GaborFilteredImg = [];
handles.cellCenters_edit = [];
handles.rmvedCenters_manual = [];
handles.addedCenters = [];
handles.deleteMethod = 0;
handles.circleAreas = [];
handles.axesRatios = [];
handles.rmvedCenters_auto = [];
handles.previous_GAradius_fauxRed = 0;
handles.previous_diskSize_fauxRed = 0;
handles.previousSmooth_fauxRedEvent = 0;
set(handles.greenFileName_push,'UserData',0);
set(handles.redFileName_push,'UserData',0);
set(handles.running_txt,'visible','off');
set(handles.greenChannel_slider,'min',0,'max',100,'Value',1);
set(handles.redChannel_slider,'min',0,'max',100,'Value',1);
set(handles.gainGreen_edit,'String',1);
set(handles.gainRed_edit,'String',1);
set(handles.hmSigma_edit,'String',2);
set(handles.filterRadius_edit,'String',5);

% Update objects
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes CellFinder wait for user response (see UIRESUME)
% uiwait(handles.main_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = CellFinder_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%++++++++++++++++++++++++LOAD AVERAGE IMAGES++++++++++++++++++++++++++++++%
function greenFileName_push_Callback(hObject, eventdata, handles)
if ~isempty(handles.dataFolder)
    cd(handles.dataFolder);
end

[fileName,folder] = uigetfile('*.tif;*.mat','Choose Green Channel');
cd(folder);

if strcmp(fileName(end-2:end),'tif') | strcmp(fileName(end-3:end),'tiff')
    [xmat,cmap] = imread(fileName);
    %xmat = double(xmat);
    xmat = mat2gray(xmat);
    xmat = xmat / max(xmat(:));
elseif strcmp(fileName(end-2:end),'mat')
    xmat = load(fileName);
    fName = fieldnames(xmat);
    xmat = getfield(xmat,fName{1});
    xmat = mat2gray(xmat);
    cmap = [];
end

%set(hObject,'UserData',{fileName;folder;xmat;cmap});
set(hObject,'UserData',1);
set(handles.greenFileName_txt,'String',fileName);
if isempty(handles.dataFolder)
    handles.dataFolder = folder;
end
handles.greenImg = xmat;
handles.redCmap = cmap;

cd(handles.programFolder);
set(handles.makeFauxRedImg_checkbox,'Value',0);

guidata(hObject, handles);

function greenFileName_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function redFileName_push_Callback(hObject, eventdata, handles)
if ~isempty(handles.dataFolder)
    cd(handles.dataFolder);
end

[fileName,folder] = uigetfile('*.tif;*.mat','Choose Red Channel');
cd(folder);

if strcmp(fileName(end-2:end),'tif') | strcmp(fileName(end-3:end),'tiff')
    [xmat,cmap] = imread(fileName);
    %xmat = double(xmat);
    xmat = mat2gray(xmat);
    xmat = xmat / max(xmat(:));
elseif strcmp(fileName(end-2:end),'mat')
    xmat = load(fileName);
    fName = fieldnames(xmat);
    xmat = getfield(xmat,fName{1});
    xmat = mat2gray(xmat);
    cmap = [];
end
set(hObject,'UserData',1);
set(handles.redFileName_txt,'String',fileName);

if isempty(handles.dataFolder)
    handles.dataFolder = folder;
end
handles.redImg = xmat;
handles.redCmap = cmap;
cd(handles.programFolder);
set(handles.makeFauxRedImg_checkbox,'Value',0);

guidata(hObject, handles);

function redFileName_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in greenOnly_radio.
function greenOnly_radio_Callback(hObject, eventdata, handles)
set(handles.both_radio,'Value',0);
set(handles.redOnly_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);
set(handles.viewRed_radio,'Value',0);
set(handles.viewGreen_radio,'Value',1);
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);


set(handles.makeFauxRedImg_checkbox,'Value',0);
set(handles.smoothTempRedImg_checkbox,'Value',0);
handles.previousSmooth_fauxRedEvent = 0;
set(handles.GAFilterRadius_fauxRedImg_edit,'String',1);
set(handles.diskSize_fauxRedImg_edit,'String',5);

set(handles.redChannelImg_txt,'String','Red Channel','ForegroundColor',[0 0 0]);

handles = plotSingleChannel(hObject);

axes(handles.redImg_axes);
imshow(ones(512,512));

if get(hObject,'Value')
    axes(handles.finalImg_axes);
    imshow(handles.greenImgGainAdjusted);
else
    axes(handles.finalImg_axes);
    imshow(ones(512,512));
end

guidata(hObject, handles);

% --- Executes on button press in redOnly_radio.
function redOnly_radio_Callback(hObject, eventdata, handles)
set(handles.both_radio,'Value',0);
set(handles.greenOnly_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);
set(handles.viewRed_radio,'Value',1);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);


if ~get(handles.makeFauxRedImg_checkbox,'Value')
    set(handles.redChannelImg_txt,...
        'String','Red Channel',...
        'ForegroundColor',[0 0 0]);
else
    set(handles.redChannelImg_txt,...
        'String','Faux Red Channel Image',...
        'ForegroundColor',[1 0 0]);
end

handles = plotSingleChannel(hObject);

axes(handles.greenImg_axes);
imshow(ones(512,512));

if get(hObject,'Value')
    axes(handles.finalImg_axes);
    imshow(handles.redImgGainAdjusted);
else
    axes(handles.finalImg_axes);
    imshow(ones(512,512));
end

guidata(hObject, handles);



% --- Executes on button press in both_radio.
function both_radio_Callback(hObject, eventdata, handles)
set(handles.redOnly_radio,'Value',0);
set(handles.greenOnly_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);
set(handles.viewRed_radio,'Value',1);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);


if ~get(handles.makeFauxRedImg_checkbox,'Value')
    set(handles.redChannelImg_txt,...
        'String','Red Channel',...
        'ForegroundColor',[0 0 0]);
else
    set(handles.redChannelImg_txt,...
        'String','Faux Red Channel Image',...
        'ForegroundColor',[1 0 0]);
end

handles = plotSingleChannel(hObject);

guidata(hObject, handles);



function [stats,circArea,axesRatio,xmatAlt,centers] = findCellCenters(xmat,GA_radius)

% properties of Gabor Annulus filter (GAF)
dim = 75;
if GA_radius>=5
    lambda = 10;
    sigma = 15;
    radius = 5;
elseif GA_radius<5
    lambda = 5;
    sigma = 10;
    radius = 1;
end

[kernGaborReal, kernGaborImag] = gaborAnnulusKernel( dim, lambda, sigma, radius );

% Show GAF components
%figure(1000);imshow(kernGaborReal / max(kernGaborReal(:)))
%figure(1001);imshow(imadjust(kernGaborImag))

% Apply GAF
Q_Gabor_Real = imfilter(xmat, kernGaborReal, 'conv','replicate');
Q_Gabor_Imag = imfilter(xmat, kernGaborImag, 'conv','replicate');
Q_Gabor_Complex = complex(Q_Gabor_Real, Q_Gabor_Imag);
Q_Gabor_Abs = abs(Q_Gabor_Complex);

% Adjust pixel intensity of original image
xmatAlt = Q_Gabor_Abs .* xmat;


% Detect edges
BW_xmatAlt = edge(imadjust(xmatAlt),'Canny',[0.03]);


% Label edges and collect stats
CC = bwconncomp(BW_xmatAlt);
numPixels = cellfun(@numel,CC.PixelIdxList);
stats = regionprops(CC,'Centroid','Euler','Extent','Solidity',...
    'Area','MinorAxisLength','MajorAxisLength','BoundingBox');

for i = 1:length(numPixels)
    [I,J] = ind2sub(size(BW_xmatAlt),CC.PixelIdxList{i});
    circArea(i) = pi * (stats(i).MinorAxisLength/2)^2;
    c = stats(i).Centroid;
    axesRatio(i) = stats(i).MinorAxisLength/stats(i).MajorAxisLength;
    centers(i,:) = stats(i).Centroid;
end


% --- Executes on button press in restart_push.
function restart_push_Callback(hObject, eventdata, handles)

% Clear handles
handles.dataFolder = [];
handles.redImg = [];
handles.redCmap = [];
handles.greenImg = [];
handles.greenCmap = [];
handles.cellCenters = [];
handles.backgroundSubImg = [];
handles.hmFilteredImg = [];
handles.redImgGainAdjusted = [];
handles.greenImgGainAdjusted = [];
handles.finalImgGainAdjusted = [];
handles.greenImgContrast = [];
handles.backgroundSubEvent = 0;
handles.redGreenSubImg = [];
handles.previousDiskSize = 0;
handles.previousHMSigma = 0;
handles.hmFilterEvent = 0;
handles.deleteMethod = 0;
handles.previous_GAradius_fauxRed = 0;
handles.previous_diskSize_fauxRed = 0;
handles.previousSmooth_fauxRedEvent = 0;
set(handles.greenFileName_push,'UserData',0);
set(handles.redFileName_push,'UserData',0);
set(handles.makeFauxRedImg_checkbox,'Value',0);
set(handles.GAFilterRadius_fauxRedImg_edit,'String',1);
set(handles.diskSize_fauxRedImg_edit,'String',5);
set(handles.smoothTempRedImg_checkbox,'Value',0);

% Clear figures
axes(handles.finalImg_axes);
imshow(ones(512,512));

axes(handles.redImg_axes);
imshow(ones(512,512));

axes(handles.greenImg_axes);
imshow(ones(512,512));

cla(handles.circleAreaHisto_axes);
cla(handles.axesRatio_axes);
set(handles.circleAreaHisto_axes,'visible','off');
set(handles.axesRatio_axes,'visible','off');


% Reset color of buttons
set(handles.subBackground_push,'BackgroundColor',[0.94 0.94 0.94]);
set(handles.hmfilter_push,'BackgroundColor',[0.94 0.94 0.94]);

% Reset all radio buttons
set(handles.viewGaborAnnulus_radio,'Value',0);
set(handles.viewRed_radio,'Value',0);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);
set(handles.both_radio,'Value',0);
set(handles.greenOnly_radio,'Value',0);
set(handles.redOnly_radio,'Value',0);
set(handles.showEditedCellCenters_checkbox,'Value',0);
set(handles.showAddedCellCenters_checkbox,'Value',0);
set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',0);

% Reset sliders
set(handles.greenChannel_slider,'Value',1);
set(handles.redChannel_slider,'Value',1);


% Reset string objects & pull down menus
set(handles.diskSize_edit,'String',1);
set(handles.maxCircArea_edit,'String','#');
set(handles.minCircArea_edit,'String','#');
set(handles.axesRatio_edit,'String','#');
set(handles.greenFileName_txt,'String','Green Channel File Name');
set(handles.redFileName_txt,'String','Red Channel File Name');
set(handles.chooseImgHomoFilt_menu,'Value',1);
set(handles.chooseImgGabor_menu,'Value',1);
set(handles.gainGreen_edit,'String',1);
set(handles.gainRed_edit,'String',1);
set(handles.hmSigma_edit,'String',2);
set(handles.diskSize_edit,'String',5);
set(handles.filterRadius_edit,'String',5);
set(handles.redChannelImg_txt,...
    'String','Red Channel',...
    'ForegroundColor',[0 0 0]);

% Reset Gabor data
handles.circleAreas = [];
handles.cellCenters = [];
handles.cellCenters_edit = [];
handles.GaborFilteredImg = [];
handles.circleAreas = [];
handles.axesRatios = [];
handles.addedCenters = [];
handles.rmvedCenters_manual = [];



% Update handles and GUI data
handles.output = hObject;
guidata(hObject, handles);





function minCircArea_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minCircArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minCircArea_edit as text
%        str2double(get(hObject,'String')) returns contents of minCircArea_edit as a double


% --- Executes during object creation, after setting all properties.
function minCircArea_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minCircArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axesRatio_edit_Callback(hObject, eventdata, handles)
% hObject    handle to axesRatio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axesRatio_edit as text
%        str2double(get(hObject,'String')) returns contents of axesRatio_edit as a double


% --- Executes during object creation, after setting all properties.
function axesRatio_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesRatio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diskSize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to diskSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diskSize_edit as text
%        str2double(get(hObject,'String')) returns contents of diskSize_edit as a double



% --- Executes during object creation, after setting all properties.
function diskSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diskSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in subBackground_push.
function subBackground_push_Callback(hObject, eventdata, handles)

clc
value = get(handles.diskSize_edit,'String');
if strcmp(value,'NA');
    value = 0;
else
    value = str2double(value);
end

if get(handles.makeFauxRedImg_checkbox,'Value')
    set(handles.diskSize_edit,'String','NA');
    handles.backgroundSubEvent = 0;
    set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
else
    if handles.previousDiskSize ~= value | ~handles.backgroundSubEvent% | handles.hmFilterEvent
        handles.backgroundSubEvent = 1;
        guidata(hObject, handles);
        
        handles = plotSingleChannel(hObject); %plot r-g-background
        set(hObject,'BackgroundColor',[1 0 0]);
        handles.previousDiskSize = value;
    elseif handles.previousDiskSize == value & handles.backgroundSubEvent  %turn off
        handles.backgroundSubEvent = 0;
        guidata(hObject, handles);
        
        handles = plotSingleChannel(hObject); %plot r-g
        set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
        handles.backgroundSubImg = [];
    end
end


guidata(hObject, handles);





% --- Executes on slider movement.
function greenChannel_slider_Callback(hObject, eventdata, handles)
sliderValue = get(hObject,'Value');

if get(handles.greenFileName_push,'UserData')
    set(handles.gainGreen_edit,'String',sliderValue);
    handles = plotSingleChannel(hObject);
else
    axes(greenImg_axes);
    text(0,1,'Load Green Average Image','color','g');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function greenChannel_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to greenChannel_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function redChannel_slider_Callback(hObject, eventdata, handles)
sliderValue = get(hObject,'Value');

if ~isempty(handles.redImg)
    set(handles.gainRed_edit,'String',sliderValue);
    handles = plotSingleChannel(hObject);
else
    axes(handles.redImg_axes);
    text(0,1,'Load red average image or generate faux red image','color','r');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function redChannel_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to redChannel_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function gainGreen_edit_Callback(hObject, eventdata, handles)
editValue = str2double(get(hObject,'String'));

if editValue <= 0
    editValue = 1;
    set(hObject,'String',editValue);
end

if get(greenFileName_push,'UserData')
    set(handles.greenChannel_slider,'Value',editValue);
    plotSingleChannel(hObject,eventdata,handles);
else
    axes(greenImg_axes);
    text(0,1,'Load Green Average Image','color','g');
end


% --- Executes during object creation, after setting all properties.
function gainGreen_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainGreen_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gainRed_edit_Callback(hObject, eventdata, handles)
editValue = str2double(get(hObject,'String'));
if editValue <= 0
    editValue = 1;
    set(hObject,'String',editValue);
end

if get(redFileName_push,'UserData')
    set(handles.redChannel_slider,'Value',editValue);
    plotSingleChannel(hObject,eventdata,handles);
else
    axes(redImg_axes);
    text(0,1,'Load Red Average Image','color','r');
end


% --- Executes during object creation, after setting all properties.
function gainRed_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainRed_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- NAF's addition April 2017
% --- SJGS editted April 2017
function viewHmFilter_radio_Callback(hObject, eventdata, handles)
set(handles.viewRed_radio,'Value',0);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);

%if get(hObject,'Value') %hObject when show cell centers is clicked is the
%show cell center toggle button hObject
if get(handles.viewHmFilter_radio,'Value') & ~isempty(handles.hmFilteredImg)
    axes(handles.finalImg_axes);
    cla;
    imshow(handles.hmFilteredImg);
    hold on;
    if get(handles.showCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters)
        plot(handles.cellCenters(:,1),handles.cellCenters(:,2),'r.');
    elseif get(handles.showEditedCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters_edit)
        plot(handles.cellCenters_edit(:,1),handles.cellCenters_edit(:,2),'r.');
    end
    if get(handles.showRmvedCellCenters_checkbox,'Value') & ~isempty(handles.rmvedCenters_manual)
        rmved_manual = handles.rmvedCenters_manual;
        rmved_auto = handles.rmvedCenters_auto;
        plot(rmved_manual(:,1),rmved_manual(:,2),'g^');
    end
    if get(handles.showAddedCellCenters_checkbox,'Value') & ~isempty(handles.addedCenters)
        plot(handles.addedCenters(:,1),handles.addedCenters(:,2),'g+');
    end
    hold off;
else
    axes(handles.finalImg_axes);
    cla;
    imshow(ones(512,512));
end

guidata(hObject, handles);



% --- NAF's addition April 2017
% --- SJGS editted April 2017
function viewRed_radio_Callback(hObject, eventdata, handles)
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);

%if get(hObject,'Value') %hObject when show cell centers is clicked is the
%show cell center toggle button hObject
if get(handles.viewRed_radio,'Value') & ~isempty(handles.redImgGainAdjusted)
    axes(handles.finalImg_axes);
    cla;
    if get(handles.makeFauxRedImg_checkbox,'Value')
        redTemp = handles.redImgGainAdjusted - handles.greenImgGainAdjusted;
        img = redTemp - handles.greenImgContrast;
        img(img < 0) = 0;
        imshow(img);
    else
        imshow(handles.redImgGainAdjusted / max(handles.redImgGainAdjusted(:)));
    end
    hold on;
    if get(handles.showCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters)
        plot(handles.cellCenters(:,1),handles.cellCenters(:,2),'r.');
    elseif get(handles.showEditedCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters_edit)
        plot(handles.cellCenters_edit(:,1),handles.cellCenters_edit(:,2),'r.');
    end
    if get(handles.showRmvedCellCenters_checkbox,'Value') & ~isempty(handles.rmvedCenters_manual)
        rmved_manual = handles.rmvedCenters_manual;
        rmved_auto = handles.rmvedCenters_auto;
        plot(rmved_manual(:,1),rmved_manual(:,2),'g^');
    end
    if get(handles.showAddedCellCenters_checkbox,'Value') & ~isempty(handles.addedCenters)
        plot(handles.addedCenters(:,1),handles.addedCenters(:,2),'g+');
    end
    hold off;
else
    axes(handles.finalImg_axes);
    cla;
    imshow(ones(512,512));
end

guidata(hObject, handles);



% --- NAF's addition April 2017
% --- SJGS editted April 2017
function viewGreen_radio_Callback(hObject, eventdata, handles)
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewRed_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);

%if get(hObject,'Value') %hObject when show cell centers is clicked is the
%show cell center toggle button hObject
if get(handles.viewGreen_radio,'Value') & ~isempty(handles.greenImgGainAdjusted)
    axes(handles.finalImg_axes);
    cla;
    imshow(handles.greenImgGainAdjusted / max(handles.greenImgGainAdjusted(:)));
    hold on;
    if get(handles.showCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters)
        plot(handles.cellCenters(:,1),handles.cellCenters(:,2),'r.');
    elseif get(handles.showEditedCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters_edit)
        plot(handles.cellCenters_edit(:,1),handles.cellCenters_edit(:,2),'r.');
    end
    if get(handles.showRmvedCellCenters_checkbox,'Value') & ~isempty(handles.rmvedCenters_manual)
        rmved_manual = handles.rmvedCenters_manual;
        rmved_auto = handles.rmvedCenters_auto;
        plot(rmved_manual(:,1),rmved_manual(:,2),'g^');
    end
    if get(handles.showAddedCellCenters_checkbox,'Value') & ~isempty(handles.addedCenters)
        plot(handles.addedCenters(:,1),handles.addedCenters(:,2),'g+');
    end
    hold off;
else
    axes(handles.finalImg_axes);
    cla;
    imshow(ones(512,512));
end

guidata(hObject, handles);


% --- NAF's addition April 2017
% --- SJGS editted April 2017
function viewBackgroundSub_radio_Callback(hObject, eventdata, handles)
set(handles.viewRed_radio,'Value',0);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewGaborAnnulus_radio,'Value',0);

%if get(hObject,'Value') %hObject when show cell centers is clicked is the
%show cell center toggle button hObject
if get(handles.viewBackgroundSub_radio,'Value') & ~isempty(handles.backgroundSubImg)
    axes(handles.finalImg_axes);
    cla;
    imshow(handles.backgroundSubImg);
    hold on;
    if get(handles.showCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters)
        plot(handles.cellCenters(:,1),handles.cellCenters(:,2),'r.');
    elseif handles.deleteMethod | get(handles.showEditedCellCenters_checkbox,'Value')
        if isempty(handles.cellCenters_edit)
            handles.cellCenters_edit = handles.cellCenters;
        end
        plot(handles.cellCenters_edit(:,1),handles.cellCenters_edit(:,2),'r.');
    end
    if get(handles.showRmvedCellCenters_checkbox,'Value') & ~isempty(handles.rmvedCenters_manual)
        plot(handles.rmvedCenters_manual(:,1),handles.rmvedCenters_manual(:,2),'g^');
    end
    if get(handles.showAddedCellCenters_checkbox,'Value') & ~isempty(handles.addedCenters)
        plot(handles.addedCenters(:,1),handles.addedCenters(:,2),'g+');
    end
    hold off;
else
    axes(handles.finalImg_axes);
    cla;
    imshow(ones(512,512));
end

guidata(hObject, handles);





% --- Executes on button press in gaborFilter_push.
function gaborFilter_push_Callback(hObject, eventdata, handles)

handles.cellCenters = [];

contents = cellstr(get(handles.chooseImgGabor_menu,'String'));
choice = contents{get(handles.chooseImgGabor_menu,'Value')};

switch choice
    case contents{1}
        warnH = warndlg('Select an image from the drop down menu.','!! Warning !!');
        uiwait(warnH);
        img = [];
    case contents{2}
        img = handles.redImgGainAdjusted;
    case contents{3}
        img = handles.backgroundSubImg;
    case contents{4}
        img = handles.hmFilteredImg;
end

if ~isempty(img)
    GA_radius = str2double(get(handles.filterRadius_edit,'String'));
    if GA_radius < 2 | GA_radius > 30
        GA_radius = 2;
    end
    
    disp('Running......');
    tic;
    [stats,circleAreas,axesRatios,imgGaborFiltered,cellCenters] = findCellCenters(img,GA_radius);
    disp(['Total time: ' num2str(toc) ' seconds.']);
    disp(['There are ' num2str(size(cellCenters,1)) ' cells.']);

    handles.cellCenters = cellCenters;
    handles.cellCenters_edit = cellCenters;
    handles.GaborFilteredImg = imgGaborFiltered;
    handles.circleAreas = circleAreas;
    handles.axesRatios = axesRatios;
    handles.addedCenters = [];
    handles.rmvedCenters_manual = [];

    
    % Find centers & plot
    cla(handles.finalImg_axes);
    axes(handles.finalImg_axes);
    imshow(imadjust(imgGaborFiltered));
    hold on;
    plot(cellCenters(:,1),cellCenters(:,2),'r.');
    hold off;    
    
    set(handles.circleAreaHisto_axes,'visible','on');
    set(handles.axesRatio_axes,'visible','on');
    
    cla(handles.circleAreaHisto_axes);
    axes(handles.circleAreaHisto_axes);
    hist(circleAreas,length(circleAreas));
    hold on;
    aa = axis(handles.circleAreaHisto_axes);
    xlabel('Areas (\pi * minorAxisLength)');
    ylabel('Count');
    hold off;
    set(gca,'xlim',[0 500]);
    
    cla(handles.axesRatio_axes);
    axes(handles.axesRatio_axes);
    hist(axesRatios,length(axesRatios));
    hold on;
    aa = axis(handles.axesRatio_axes);
    xlabel('minor axis :: minor axis');
    ylabel('Count');
    hold off;
    
    set(handles.showCellCenters_checkbox,'Value',1);
    set(handles.showEditedCellCenters_checkbox,'Value',0);
    set(handles.showAddedCellCenters_checkbox,'Value',0);
    set(handles.showRmvedCellCenters_checkbox,'Value',0);
    set(handles.viewGaborAnnulus_radio,'Value',1);
    set(handles.viewRed_radio,'Value',0);
    set(handles.viewGreen_radio,'Value',0);
    set(handles.viewHmFilter_radio,'Value',0);
    set(handles.viewBackgroundSub_radio,'Value',0);
end

guidata(hObject, handles);



% --- Executes on button press in filterCenter_push.
function filterCenter_push_Callback(hObject, eventdata, handles)
circleAreas = handles.circleAreas;

if ~isempty(circleAreas)
    disp('Filtering based upon cell body stats.........');
    
    tic;
    
    axesRatios = handles.axesRatios;
    cellCenters = handles.cellCenters;
    imgGaborFiltered = handles.GaborFilteredImg;
    axesRatioThresh = str2double(get(handles.axesRatio_edit,'String'));
    if isempty(axesRatioThresh) | ~isnumeric(axesRatioThresh) | isnan(axesRatioThresh) | axesRatioThresh<=0
        axesRatioThresh = 0.25;
        set(handles.axesRatio_edit,'String',axesRatioThresh);
    end
    
    maxCircleArea = str2double(get(handles.maxCircArea_edit,'String'));
    if isempty(maxCircleArea) | ~isnumeric(maxCircleArea) | isnan(maxCircleArea) | maxCircleArea<=0
        maxCircleArea = roundn(max(circleAreas),0);
        set(handles.maxCircArea_edit,'String',maxCircleArea);
    end
    
    minCircleArea = str2double(get(handles.minCircArea_edit,'String'));
    if isempty(minCircleArea) | ~isnumeric(minCircleArea) | isnan(minCircleArea) | minCircleArea<=0
        minCircleArea = roundn(min(circleAreas),0);
        set(handles.minCircArea_edit,'String',minCircleArea);
    end
    
    
    
    % Find centers & plot
    cla(handles.finalImg_axes);
    axes(handles.finalImg_axes);
    imshow(imadjust(imgGaborFiltered));
    idx = find(circleAreas >= minCircleArea & circleAreas <= maxCircleArea & axesRatios >= axesRatioThresh);
    rmvedIdx = setdiff(1:length(circleAreas),idx);
    handles.rmvedCenters_auto = cellCenters(rmvedIdx,:);
    hold on;
    plot(cellCenters(idx,1),cellCenters(idx,2),'r.');
    hold off;
    handles.cellCenters_edit = cellCenters(idx,:);
    disp(['Cells decreased from ' num2str(size(cellCenters,1)) ' to ' num2str(length(idx)) '.']);

    
    set(handles.circleAreaHisto_axes,'visible','on');
    set(handles.axesRatio_axes,'visible','on');
    
    cla(handles.circleAreaHisto_axes);
    axes(handles.circleAreaHisto_axes);
    hist(circleAreas,length(circleAreas));
    hold on;
    aa = axis(handles.circleAreaHisto_axes);
    plot([minCircleArea minCircleArea],[aa(3) aa(4)],'r--','linewidth',1.5);
    plot([maxCircleArea maxCircleArea],[aa(3) aa(4)],'r--','linewidth',1.5);
    xlabel('Areas (\pi * minorAxisLength)');
    ylabel('Count');
    hold off;
    set(gca,'xlim',[0 500]);
    
    cla(handles.axesRatio_axes);
    axes(handles.axesRatio_axes);
    hist(axesRatios,length(axesRatios));
    hold on;
    aa = axis(handles.axesRatio_axes);
    plot([axesRatioThresh(1) axesRatioThresh(1)],[aa(3) aa(4)],'r--','linewidth',1.5);
    xlabel('minor axis :: minor axis');
    ylabel('Count');
    hold off;
    
    set(handles.showCellCenters_checkbox,'Value',0);
    set(handles.showEditedCellCenters_checkbox,'Value',1);
    set(handles.showAddedCellCenters_checkbox,'Value',0);
    set(handles.showRmvedCellCenters_checkbox,'Value',0);
    set(handles.viewGaborAnnulus_radio,'Value',1);
    set(handles.viewRed_radio,'Value',0);
    set(handles.viewGreen_radio,'Value',0);
    set(handles.viewHmFilter_radio,'Value',0);
    set(handles.viewBackgroundSub_radio,'Value',0);
    
    disp(['Total time: ' num2str(toc) ' seconds.']);
else
    warndlg('Run Gabor Annulus Filter!!');
end

guidata(hObject, handles);




function maxCircArea_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxCircArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxCircArea_edit as text
%        str2double(get(hObject,'String')) returns contents of maxCircArea_edit as a double


% --- Executes during object creation, after setting all properties.
function maxCircArea_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxCircArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- NAF's addition April 2017
% --- SJGS editted April 2017
function addCellCenter_push_Callback(hObject, eventdata, handles)
set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',0);
set(handles.showEditedCellCenters_checkbox,'Value',1);
set(handles.showAddedCellCenters_checkbox,'Value',0);
guidata(hObject,handles);

showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles);

[xc, yc] = getpts(handles.finalImg_axes);
imgBoundingBox_x = [0 512 512 0]; %verticies of image, xv
imgBoundingBox_y = [0 0 512 512]; %yv

inArr = [];
onArr = [];
for i = 1:length(xc)
    [in,on] = inpolygon(xc(i),yc(i),imgBoundingBox_x,imgBoundingBox_y);
    inArr = [inArr in];
    onArr = [onArr on];
    
    if ~in
        xc(i) = [];
        yc(i) = [];
        warndlg('Selection(s) out of frame! Outliers removed...');
    end
end

handles.cellCenters_edit = [handles.cellCenters_edit; xc(:) yc(:)];
handles.addedCenters = [handles.addedCenters; xc(:) yc(:)];

set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',0);
set(handles.showEditedCellCenters_checkbox,'Value',1);
set(handles.showAddedCellCenters_checkbox,'Value',1);
guidata(hObject,handles);

showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles);
showAddedCellCenters_checkbox_Callback(hObject, eventdata, handles);

guidata(hObject,handles);






% --- NAF's addition April 2017
% --- SJGS editted April 2017
function deleteCellCenter_push_Callback(hObject, eventdata, handles)
% hObject    handle to deleteCellCenter_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.deleteMethod = 1;
set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',0);
set(handles.showEditedCellCenters_checkbox,'Value',1);
set(handles.showAddedCellCenters_checkbox,'Value',0);
showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

dcm_obj = datacursormode(handles.main_GUI);
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','on');
set(dcm_obj,'UpdateFcn',@myupdatefcn)
pause
c_info = getCursorInfo(dcm_obj);
dcm_obj.removeAllDataCursors;
set(dcm_obj,'Enable','off');

rmvCenters = [];
for i = 1:numel(c_info)
    rmvCenters = [rmvCenters;c_info(i).Position];
end

if isempty(handles.cellCenters_edit)
    handles.cellCenters_edit = handles.cellCenters;
end

if size(rmvCenters,1) > 0
    idx = find(ismember(rmvCenters,handles.cellCenters,'rows'));
    rmvCenters = rmvCenters(idx,:);
    handles.rmvedCenters_manual = [handles.rmvedCenters_manual;rmvCenters];
    
    rmvIdx = find(ismember(handles.cellCenters_edit,rmvCenters,'rows'));
    handles.cellCenters_edit(rmvIdx,:) = [];
    
    if ~isempty(handles.addedCenters)
        rmvIdx = find(ismember(handles.addedCenters,rmvCenters,'rows'));
        handles.addedCenters(rmvIdx,:) = [];
    end
end

set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',1);
set(handles.showEditedCellCenters_checkbox,'Value',1);
set(handles.showAddedCellCenters_checkbox,'Value',0);
handles.deleteMethod = 0;

guidata(hObject,handles);

showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles);
showRmvedCellCenters_checkbox_Callback(hObject, eventdata, handles);


guidata(hObject,handles);



% --- NAF's addition April 2017
% --- SJGS editted April 2017
function hmfilter_push_Callback(hObject, eventdata, handles)
% hObject    handle to hmfilter_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.chooseImgHomoFilt_menu,'String'));
choice = contents{get(handles.chooseImgHomoFilt_menu,'Value')};
sigma = str2double(get(handles.hmSigma_edit,'String'));

if handles.previousHMSigma == sigma
    handles.hmFilterEvent = 0;
    set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
elseif handles.previousHMSigma ~= sigma | handles.hmFilterEvent == 0
    handles.hmFilterEvent = 1;
    
    switch choice
        case contents{1}
            warnH = warndlg('Select an image from the drop down menu.','!! Warning !!');
            uiwait(warnH);
            img = [];
        case contents{2}
            if get(handles.makeFauxRedImg_checkbox,'Value')
                redTemp = handles.redImgGainAdjusted - handles.greenImgGainAdjusted;
                img = redTemp - handles.greenImgContrast;
                img(img < 0) = 0;
            else
                img = handles.redImgGainAdjusted / max(handles.redImgGainAdjusted(:));
            end
        case contents{3}
            img = handles.backgroundSubImg;
    end
    if ~isempty(img)
        [avgfilteredImage filteredImages] = hmfilter(img, sigma);
        handles.hmFilteredImg = avgfilteredImage;
        axes(handles.finalImg_axes);
        imshow(handles.hmFilteredImg);
        
        if strcmp(choice,contents{1})
            handles.hmFilterEvent = 0;
            set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
        end
        
        set(hObject,'BackgroundColor',[1 0 0]);
    end
end

guidata(hObject, handles);




function hmSigma_edit_Callback(hObject, eventdata, handles)
% hObject    handle to hmSigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hmSigma_edit as text
%        str2double(get(hObject,'String')) returns contents of hmSigma_edit as a double


% --- Executes during object creation, after setting all properties.
function hmSigma_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hmSigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- NAF's addition April 2017
% --- SJGS editted April 2017
function imgProcessing_reset_push_Callback(hObject, eventdata, handles)
axes(handles.finalImg_axes);
imshow(ones(512,512));

axes(handles.finalImg_axes);
imshow(ones(512,512));

handles.backgroundSubImg = [];
handles.hmFilteredImg = [];
handles.finalImgGainAdjusted = [];
handles.redGreenSubImg = [];
handles.previousDiskSize = 0;
handles.hmFilterEvent = 0;
handles.backgroundSubEvent = 0;

set(handles.subBackground_push,'BackgroundColor',[0.94 0.94 0.94]);
set(handles.hmfilter_push,'BackgroundColor',[0.94 0.94 0.94]);
set(handles.hmSigma_edit,'String',1);
set(handles.diskSize_edit,'String',1);
set(handles.chooseImgHomoFilt_menu,'Value',1);

guidata(hObject, handles);


function handles = plotSingleChannel(h)
handles = guidata(h);

gGain = str2double(get(handles.gainGreen_edit,'String'));
gImg = handles.greenImg;
handles.greenImgGainAdjusted = gGain * gImg;

rGain = str2double(get(handles.gainRed_edit,'String'));
rImg = handles.redImg;
handles.redImgGainAdjusted = rGain * rImg;

fillerImg = ones(512,512);

viewSummary = [get(handles.viewGreen_radio,'Value')...
    get(handles.viewRed_radio,'Value')...
    get(handles.viewBackgroundSub_radio,'Value')...
    get(handles.viewHmFilter_radio,'Value')...
    get(handles.viewGaborAnnulus_radio,'Value')];


if get(handles.both_radio,'Value') %& ~sum(viewSummary)
    if ~isempty(handles.redImgGainAdjusted) & ~isempty(handles.greenImgGainAdjusted)
        if get(handles.makeFauxRedImg_checkbox,'Value')
            redTemp = handles.redImgGainAdjusted - handles.greenImgGainAdjusted;
            img = redTemp - handles.greenImgContrast;
            img(img < 0) = 0;
        else
            img = handles.redImgGainAdjusted - handles.greenImgGainAdjusted;
            img(img < 0) = 0;
            handles.redGreenSubImg = img;
            if handles.backgroundSubEvent
                diskSize = str2double(get(handles.diskSize_edit,'String'));
                background = imopen(img,strel('disk',diskSize));
                tempImg = img - background;
                tempImg(tempImg < 0) = 0;
                handles.backgroundSubImg = tempImg;
                img = tempImg;
                
                if handles.hmFilterEvent
                    contents = cellstr(get(handles.chooseImgHomoFilt_menu,'String'));
                    choice = contents{get(handles.chooseImgHomoFilt_menu,'Value')};
                    sigma = str2double(get(handles.hmSigma_edit,'String'));
                    switch choice
                        case contents{2}
                            img = handles.redImgGainAdjusted;
                        case contents{3}
                            img = handles.backgroundSubImg;
                    end
                    
                    [img, ~] = hmfilter(img, sigma);
                    handles.hmFilteredImg = img;
                    axes(handles.finalImg_axes);
                    imshow(handles.hmFilteredImg);
                end
            end
        end
    else
        img = ones(512,512);
        warnH = warndlg('Please load an image from the red channel.','!! Warning !!');
        uiwait(warnH);
    end
    
    handles.finalImgGainAdjusted = img;
    axes(handles.finalImg_axes);
    imshow(handles.finalImgGainAdjusted);
    
    axes(handles.redImg_axes);
    imshow(handles.redImgGainAdjusted);
    
    axes(handles.greenImg_axes);
    imshow(handles.greenImgGainAdjusted);
    
    set(handles.viewHmFilter_radio,'Value',0);
    set(handles.viewGreen_radio,'Value',0);
    set(handles.viewBackgroundSub_radio,'Value',0);
    set(handles.viewGaborAnnulus_radio,'Value',0);
    set(handles.viewRed_radio,'Value',1);
else
    if get(handles.greenOnly_radio,'Value') | viewSummary(1)
        axes(handles.greenImg_axes);
        imshow(handles.greenImgGainAdjusted);
        axes(handles.finalImg_axes);
        imshow(handles.greenImgGainAdjusted);
    end
    
    if get(handles.redOnly_radio,'Value') | viewSummary(2)
        axes(handles.redImg_axes);
        imshow(handles.redImgGainAdjusted);
        if handles.backgroundSubEvent
            diskSize = str2double(get(handles.diskSize_edit,'String'));
            background = imopen(handles.redImgGainAdjusted,strel('disk',diskSize));
            handles.backgroundSubImg = handles.redImgGainAdjusted - background;
            axes(handles.finalImg_axes);
            imshow(handles.backgroundSubImg);
        else
            axes(handles.finalImg_axes);
            imshow(handles.redImgGainAdjusted);
        end
    end
    
    if get(handles.makeFauxRedImg_checkbox,'Value')
        axes(handles.redImg_axes);
        imshow(handles.redImgGainAdjusted);
        set(handles.both_radio,'Value',1);
        set(handles.redChannelImg_txt,...
            'String','Faux Red Channel Image',...
            'ForegroundColor',[1 0 0]);
    end
    
    if viewSummary(4)
        axes(handles.finalImg_axes);
        imshow(handles.hmFilteredImg);
    end
    
    if viewSummary(3)
        axes(handles.finalImg_axes);
        imshow(handles.backgroundSubImg);
    end
    
    if ~get(handles.redOnly_radio,'Value') & ~get(handles.greenOnly_radio,'Value')
        axes(handles.redImg_axes);
        imshow(fillerImg);
        
        axes(handles.greenImg_axes);
        imshow(fillerImg);
        
        axes(handles.finalImg_axes);
        imshow(fillerImg);
        
        set(handles.redChannelImg_txt,...
            'String','Red Channel',...
            'ForegroundColor',[0 0 0]);
        
        handles.backgroundSubEvent = 0;
        handles.hmFilterEvent = 0;
        set(handles.subBackground_push,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.hmfilter_push,'BackgroundColor',[0.94 0.94 0.94]);
    end
end

guidata(h, handles); %041717 note: guidata doesn't work. have to return handles to main


% --- Executes on button press in makeFauxRedImg_push.
% function makeFauxRedImg_push_Callback(hObject, eventdata, handles)
% set(handles.running_txt,'visible','on');
% guidata(hObject, handles);
% 
% set(handles.both_radio,'Value',0);
% set(handles.redOnly_radio,'Value',0);
% set(handles.greenOnly_radio,'Value',1);
% 
% set(handles.viewGaborAnnulus_radio,'Value',0);
% set(handles.viewRed_radio,'Value',0);
% set(handles.viewGreen_radio,'Value',0);
% set(handles.viewHmFilter_radio,'Value',0);
% set(handles.viewBackgroundSub_radio,'Value',0);
% set(handles.showCellCenters_checkbox,'Value',0);
% 
% %%%%
% % Step 1: enhance contrast via Gabor Annulus
% % filtering
% %%%%
% 
% % Gabor Annulus filter parameters
% width = 75;
% lambda = 5;
% sigma = 2;
% radius = 1;
% 
% % Generate Gabor Annulus
% [kernGaborReal, kernGaborImag] = gaborAnnulusKernel( width, lambda, sigma, radius );
% 
% % Apply filter
% Q_Gabor_Real = imfilter(handles.greenImgGainAdjusted, kernGaborReal, 'conv','replicate');
% Q_Gabor_Imag = imfilter(handles.greenImgGainAdjusted, kernGaborImag, 'conv','replicate');
% Q_Gabor_Complex = complex(Q_Gabor_Real, Q_Gabor_Imag);
% Q_Gabor_Abs = abs(Q_Gabor_Complex);
% xmatGreen = imadjust(Q_Gabor_Abs .* handles.greenImgGainAdjusted);
% handles.greenImgContrast = xmatGreen;
% 
% %%%%
% % Step 2: make a rough approximationg of cell bodies (rough faux red image)
% %%%%
% xmat_comp = imcomplement(handles.greenImgGainAdjusted);
% background = imopen(xmat_comp,strel('disk',5));
% xmat = xmat_comp - background;
% handles.redImg = xmat;
% guidata(hObject, handles);
% 
% handles = plotSingleChannel(hObject);
% both_radio_Callback(hObject,eventdata,handles);
% 
% disp('Faux Red Image Created');
% set(hObject,'BackgroundColor',[1 0 0]);
% set(hObject,'Value',1);
% set(handles.running_txt,'visible','off');
% set(handles.both_radio,'Value',1);
% 
% guidata(hObject, handles);
% 
% 
% --- Executes on selection change in chooseImgGabor_menu.
function chooseImgGabor_menu_Callback(hObject, eventdata, handles)
contents = cellstr(get(handles.chooseImgGabor_menu,'String'));
choice = contents{get(handles.chooseImgGabor_menu,'Value')};

switch choice
    case contents{1}
        img = ones(512,512);
    case contents{2}
        if get(handles.makeFauxRedImg_checkbox,'Value')
            redTemp = handles.redImgGainAdjusted - handles.greenImgGainAdjusted;
            img = redTemp - handles.greenImgContrast;
            img(img < 0) = 0;
        else
            img = handles.redImgGainAdjusted;
            img = img / max(img(:));
        end
        set(handles.viewGaborAnnulus_radio,'Value',0);
        set(handles.viewRed_radio,'Value',1);
        set(handles.viewGreen_radio,'Value',0);
        set(handles.viewHmFilter_radio,'Value',0);
        set(handles.viewBackgroundSub_radio,'Value',0);
    case contents{3}
        img = handles.backgroundSubImg;
        set(handles.viewGaborAnnulus_radio,'Value',0);
        set(handles.viewRed_radio,'Value',0);
        set(handles.viewGreen_radio,'Value',0);
        set(handles.viewHmFilter_radio,'Value',0);
        set(handles.viewBackgroundSub_radio,'Value',1);
    case contents{4}
        img = handles.hmFilteredImg;
        set(handles.viewGaborAnnulus_radio,'Value',0);
        set(handles.viewRed_radio,'Value',0);
        set(handles.viewGreen_radio,'Value',0);
        set(handles.viewHmFilter_radio,'Value',1);
        set(handles.viewBackgroundSub_radio,'Value',0);
end
axes(handles.finalImg_axes);
cla(handles.finalImg_axes);
imshow(img);

if strcmp(contents{1},choice)
    warndlg('Select an image from the drop down menu.');
end

guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function chooseImgGabor_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseImgGabor_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chooseImgHomoFilt_menu.
function chooseImgHomoFilt_menu_Callback(hObject, eventdata, handles)
contents = cellstr(get(handles.chooseImgHomoFilt_menu,'String'));
choice = contents{get(handles.chooseImgHomoFilt_menu,'Value')};

switch choice
    case contents{1}
        img = ones(512,512);
    case contents{2}
        if get(handles.makeFauxRedImg_checkbox,'Value')
            redTemp = handles.redImgGainAdjusted - handles.greenImgGainAdjusted;
            img = redTemp - handles.greenImgContrast;
            img(img < 0) = 0;
        else
            img = handles.redImgGainAdjusted;
            img = img / max(img(:));
        end
        set(handles.viewGaborAnnulus_radio,'Value',0);
        set(handles.viewRed_radio,'Value',1);
        set(handles.viewGreen_radio,'Value',0);
        set(handles.viewHmFilter_radio,'Value',0);
        set(handles.viewBackgroundSub_radio,'Value',0);
    case contents{3}
        img = handles.backgroundSubImg;
        set(handles.viewGaborAnnulus_radio,'Value',0);
        set(handles.viewRed_radio,'Value',0);
        set(handles.viewGreen_radio,'Value',0);
        set(handles.viewHmFilter_radio,'Value',0);
        set(handles.viewBackgroundSub_radio,'Value',1);
end
axes(handles.finalImg_axes);
cla(handles.finalImg_axes);
imshow(img);

if strcmp(contents{1},choice)
    warndlg('Select an image from the drop down menu.');
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chooseImgHomoFilt_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseImgHomoFilt_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- NAF's addition April 2017
% --- SJGS editted April 2017
function viewGaborAnnulus_radio_Callback(hObject, eventdata, handles)
set(handles.viewHmFilter_radio,'Value',0);
set(handles.viewGreen_radio,'Value',0);
set(handles.viewRed_radio,'Value',0);
set(handles.viewBackgroundSub_radio,'Value',0);

%if get(hObject,'Value') %hObject when show cell centers is clicked is the
%show cell center toggle button hObject
if get(handles.viewGaborAnnulus_radio,'Value') & ~isempty(handles.GaborFilteredImg)
    axes(handles.finalImg_axes);
    cla;
    imshow(handles.GaborFilteredImg * 10 / max(handles.GaborFilteredImg(:)));
    hold on;
    if get(handles.showCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters)
        plot(handles.cellCenters(:,1),handles.cellCenters(:,2),'r.');
    elseif get(handles.showEditedCellCenters_checkbox,'Value') & ~isempty(handles.cellCenters_edit)
        plot(handles.cellCenters_edit(:,1),handles.cellCenters_edit(:,2),'r.');
    end
    if get(handles.showRmvedCellCenters_checkbox,'Value') & ~isempty(handles.rmvedCenters_manual)
        rmved_manual = handles.rmvedCenters_manual;
        rmved_auto = handles.rmvedCenters_auto;
        plot(rmved_manual(:,1),rmved_manual(:,2),'g^');
    end
    if get(handles.showAddedCellCenters_checkbox,'Value') & ~isempty(handles.addedCenters)
        plot(handles.addedCenters(:,1),handles.addedCenters(:,2),'g+');
    end
    hold off;
else
    axes(handles.finalImg_axes);
    cla;
    imshow(ones(512,512));
end

guidata(hObject, handles);



% --- Executes on button press in showCellCenters_checkbox.
function showCellCenters_checkbox_Callback(hObject, eventdata, handles)

set(handles.showEditedCellCenters_checkbox,'Value',0);

cla(handles.finalImg_axes);


if get(handles.viewGaborAnnulus_radio,'Value')
    viewGaborAnnulus_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewHmFilter_radio,'Value')
    viewHmFilter_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewGreen_radio,'Value')
    viewGreen_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewRed_radio,'Value')
    viewRed_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewBackgroundSub_radio,'Value')
    viewBackgroundSub_radio_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);




% --- Executes on button press in showEditedCellCenters_checkbox.
function showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles)

if get(handles.showEditedCellCenters_checkbox,'Value') == 1
    
    set(handles.showCellCenters_checkbox,'Value',0);
    
    cla(handles.finalImg_axes);
    
    added = handles.addedCenters;
    rmved_manual = handles.rmvedCenters_manual;
    rmved_auto = handles.rmvedCenters_auto;
    original = handles.cellCenters;
    handles.cellCenters_edit = original;
    
    if size(added,1) > 0
        handles.cellCenters_edit = [handles.cellCenters; added];
    end
    if size(rmved_manual,1) > 0 | size(rmved_auto,1) > 0
        rmvedIdx = find(ismember(handles.cellCenters_edit,[rmved_manual;rmved_auto],'rows'));
        handles.cellCenters_edit(rmvedIdx,:) = [];
    end
    guidata(hObject, handles);
end


if get(handles.viewGaborAnnulus_radio,'Value')
    viewGaborAnnulus_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewHmFilter_radio,'Value')
    viewHmFilter_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewGreen_radio,'Value')
    viewGreen_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewRed_radio,'Value')
    viewRed_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewBackgroundSub_radio,'Value')
    viewBackgroundSub_radio_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);


% --- Executes on button press in showRmvedCellCenters_checkbox.
function showRmvedCellCenters_checkbox_Callback(hObject, eventdata, handles)

cla(handles.finalImg_axes);

added = handles.addedCenters;
rmved_manual = handles.rmvedCenters_manual;
rmved_auto = handles.rmvedCenters_auto;
original = handles.cellCenters;
handles.cellCenters_edit = original;

if size(added,1) > 0
    handles.cellCenters_edit = [handles.cellCenters; added];
end
if size(rmved_manual,1) > 0 | size(rmved_auto,1) > 0
    rmvedIdx = find(ismember(handles.cellCenters_edit,[rmved_manual;rmved_auto],'rows'));
    handles.cellCenters_edit(rmvedIdx,:) = [];
end
guidata(hObject, handles);


if get(handles.viewGaborAnnulus_radio,'Value')
    viewGaborAnnulus_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewHmFilter_radio,'Value')
    viewHmFilter_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewGreen_radio,'Value')
    viewGreen_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewRed_radio,'Value')
    viewRed_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewBackgroundSub_radio,'Value')
    viewBackgroundSub_radio_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);


% --- Executes on button press in showAddedCellCenters_checkbox.
function showAddedCellCenters_checkbox_Callback(hObject, eventdata, handles)
cla(handles.finalImg_axes);

added = handles.addedCenters;
rmved_manual = handles.rmvedCenters_manual;
rmved_auto = handles.rmvedCenters_auto;
original = handles.cellCenters;
handles.cellCenters_edit = original;

if size(added,1) > 0
    handles.cellCenters_edit = [handles.cellCenters; added];
end
if size(rmved_manual,1) > 0 | size(rmved_auto,1) > 0
    rmvedIdx = find(ismember(handles.cellCenters_edit,[rmved_manual;rmved_auto],'rows'));
    handles.cellCenters_edit(rmvedIdx,:) = [];
end
guidata(hObject, handles);


if get(handles.viewGaborAnnulus_radio,'Value')
    viewGaborAnnulus_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewHmFilter_radio,'Value')
    viewHmFilter_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewGreen_radio,'Value')
    viewGreen_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewRed_radio,'Value')
    viewRed_radio_Callback(hObject, eventdata, handles);
elseif get(handles.viewBackgroundSub_radio,'Value')
    viewBackgroundSub_radio_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);


% --- Executes on button press in export_push.
function export_push_Callback(hObject, eventdata, handles)
assignin('base', 'cellCenters_original', handles.cellCenters);
assignin('base', 'cellCenters_Rmved', handles.rmvedCenters_manual);
assignin('base', 'cellCenters_Added', handles.addedCenters);
assignin('base', 'cellCenters_FinalProcessed', handles.cellCenters_edit);

assignin('base','minCircleAreaThresh',get(handles.minCircArea_edit,'String'));
assignin('base','maxCircleAreaThresh',get(handles.maxCircArea_edit,'String'));
assignin('base','axesRatioThresh',get(handles.axesRatio_edit,'String'));

assignin('base', 'greenImg' , handles.greenImg);
assignin('base', 'redImg', handles.redImg);

assignin('base','dataFolder',handles.dataFolder);
assignin('base','codeFolder',pwd);
redFileName = get(handles.redFileName_txt,'String');
greenFileName = get(handles.greenFileName_txt,'String');

if ~strcmp(greenFileName,'Green Channel File Name') | ~isempty(greenFileName)
    fileName.greenChannel = greenFileName;
else
    fileName.greenChannel = [];
end

if ~strcmp(redFileName,'Red Channel File Name') | ~isempty(redFileName)
    fileName.redChannel = redFileName;
else
    fileName.redChannel = [];
end
assignin('base','fileName',fileName);

if ~isempty(handles.greenImgContrast)
    assignin('base', 'enhancedGreenImg', handles.greenImgContrast);
    saveVariables = {'cellCenters_original',...
        'cellCenters_Rmved',...
        'cellCenters_Added',...
        'cellCenters_FinalProcessed',...
        'greenImg',...
        'redImg',...
        'dataFolder',...
        'codeFolder',...
        'enhancedGreenImg',...
        'minCircleAreaThresh',...
        'maxCircleAreaThresh',...
        'axesRatioThresh',...
        'fileName'};
else
    saveVariables = {'cellCenters_original',...
        'cellCenters_Rmved',...
        'cellCenters_Added',...
        'cellCenters_FinalProcessed',...
        'greenImg',...
        'redImg',...
        'dataFolder',...
        'codeFolder',...
        'minCircleAreaThresh',...
        'maxCircleAreaThresh',...
        'axesRatioThresh',...
        'fileName'};
end
assignin('base','saveVariables',saveVariables);


function filterRadius_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filterRadius_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterRadius_edit as text
%        str2double(get(hObject,'String')) returns contents of filterRadius_edit as a double
value = str2double(get(hObject,'String'));
if value < 2
    set(hObject,'String','2');
end

% --- Executes during object creation, after setting all properties.
function filterRadius_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterRadius_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autoSelectionHelp_push.
function autoSelectionHelp_push_Callback(hObject, eventdata, handles)
msg = ['Input threshold values for cell shape parameters. ',...
    'It is recommended that the radius is 1 for low ',...
    'magnifications and 5 for higher magnification.'];
h = msgbox(msg,'Autoselection Instructions','help');

% --- Executes on button press in manualSelectionHelp_push.
function manualSelectionHelp_push_Callback(hObject, eventdata, handles)
msg = ['Adding points: click once per center, and double click ',...
    'the final center to end function.' char(10) char(10),...
    'Deselecting points: hold ALT while clicking in order to select '...
    'more than one point. When finished, release ALT and press enter.' char(10) char(10),...
    'Deselecting groups of points: Draw a polygon. Make sure to close the '
    'shape (first point == last point).'];
h = msgbox(msg,'Manual Selection Instructions','help');

% --- Executes on button press in subBackgroundHelp_push.
function subBackgroundHelp_push_Callback(hObject, eventdata, handles)
msg = ['Correct non-uniform background illumination via morphological '...
    'opening with a disk-shaped structuring element that is smaller '...
    'than the objects in the foreground (cells). It is recommended that '...
    'the radius of the disk is 5 for low magnification and 10 for high '...
    'magnification.'];
h = msgbox(msg,'Non-uniform Background Illumination Correction Instructions','help');


% --- Executes on button press in hmFilterHelp_push.
function hmFilterHelp_push_Callback(hObject, eventdata, handles)
msg = ['Homomorphic filter: select a size for the filter.'];
h = msgbox(msg,'Homomorphic Filter Instructions','help');


% --- Executes on button press in makeFauxRedImg_checkbox.
function makeFauxRedImg_checkbox_Callback(hObject, eventdata, handles)

if get(handles.makeFauxRedImg_checkbox,'Value')
    
    set(handles.running_txt,'visible','on');
    drawnow;
    
    set(handles.both_radio,'Value',0);
    set(handles.redOnly_radio,'Value',0);
    set(handles.greenOnly_radio,'Value',1);
    
    set(handles.viewGaborAnnulus_radio,'Value',0);
    set(handles.viewRed_radio,'Value',0);
    set(handles.viewGreen_radio,'Value',0);
    set(handles.viewHmFilter_radio,'Value',0);
    set(handles.viewBackgroundSub_radio,'Value',0);
    set(handles.showCellCenters_checkbox,'Value',0);
    
    GA_radius = str2double(get(handles.GAFilterRadius_fauxRedImg_edit,'String'));
    if GA_radius <= 0
        GA_radius = 1;
        set(handles.GAFilterRadius_fauxRedImg_edit,'String',GA_radius);
    end
    
    backgroundDiskRadius = str2double(get(handles.diskSize_fauxRedImg_edit,'String'));
    if backgroundDiskRadius <= 0 | ~isnumeric(backgroundDiskRadius)
        backgroundDiskRadius = 10;
        set(handles.diskSize_fauxRedImg_edit,'String',backgroundDiskRadius);
    end
    
    %%%%
    % Step 1: enhance contrast via Gabor Annulus
    % filtering
    %%%%
    
    % Gabor Annulus filter parameters
    width = 75;
    lambda = 5;
    sigma = 2;
    
    % Generate Gabor Annulus
    [kernGaborReal, kernGaborImag] = gaborAnnulusKernel( width, lambda, sigma, GA_radius );
    
    % Apply filter
    Q_Gabor_Real = imfilter(handles.greenImgGainAdjusted, kernGaborReal, 'conv','replicate');
    Q_Gabor_Imag = imfilter(handles.greenImgGainAdjusted, kernGaborImag, 'conv','replicate');
    Q_Gabor_Complex = complex(Q_Gabor_Real, Q_Gabor_Imag);
    Q_Gabor_Abs = abs(Q_Gabor_Complex);
    xmatGreen = imadjust(Q_Gabor_Abs .* handles.greenImgGainAdjusted);
    handles.greenImgContrast = xmatGreen;
    
    %%%%
    % Step 2: make a rough approximationg of cell bodies (rough faux red image)
    %%%%
    xmat_comp = imcomplement(handles.greenImgGainAdjusted);
    background = imopen(xmat_comp,strel('disk',backgroundDiskRadius));
    xmat = xmat_comp - background;
    if get(handles.smoothTempRedImg_checkbox,'Value')
        xmat = medfilt2(xmat);
    end
    
    handles.redImg = xmat;
    guidata(hObject, handles);
    
    handles = plotSingleChannel(hObject);
    both_radio_Callback(hObject,eventdata,handles);
    
    disp('Faux Red Image Created');
    set(handles.running_txt,'visible','off');
    set(handles.both_radio,'Value',1);
    set(handles.diskSize_edit,'String','NA');
    set(handles.subBackground_push,'String','Unavailable');
    handles.backgroundSubEvent = 0;
else
    set(handles.redChannelImg_txt,'String','Red Channel','ForegroundColor',[0 0 0]);
    set(handles.diskSize_edit,'String','5');
    set(handles.subBackground_push,'String','-Background?');
end

guidata(hObject, handles);


% --- Executes on button press in fauxRedHelp_push.
function fauxRedHelp_push_Callback(hObject, eventdata, handles)
msg = ['The defaul parameters (filter radius = 1, disk size = 10) work '...
    'for most images. Change the parameters for noisy images to enhance '...
    'the approximation of cell bodies.'...
    char(10) char(10)...    
    'This method first enhances '...
    'the contrast of the green image by applying the Gabor Annulus '...
    'filter. Next, the complement image of the un-enhanced green image is'...
    'subtracted from the enhanced green image to generate a faux red '...
    'image following background illumination correction.'...
    char(10) char(10)...
    'Input the radius of the Gabor Annulus and the radius of the disk '...
    'used for background illumination correction.'];
h = msgbox(msg,'Autoselection Instructions','help');



function GAFilterRadius_fauxRedImg_edit_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if  value ~= handles.previous_GAradius_fauxRed
    handles.previous_GAradius_fauxRed = value;
    set(handles.running_txt,'visible','on');
    drawnow;
    makeFauxRedImg_checkbox_Callback(hObject, eventdata, handles);
end    

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function GAFilterRadius_fauxRedImg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GAFilterRadius_fauxRedImg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diskSize_fauxRedImg_edit_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if  value ~= handles.previous_diskSize_fauxRed
    handles.previous_diskSize_fauxRed = value;
    set(handles.running_txt,'visible','on');
    drawnow;
    makeFauxRedImg_checkbox_Callback(hObject, eventdata, handles);
end    

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function diskSize_fauxRedImg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diskSize_fauxRedImg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in smoothTempRedImg_checkbox.
function smoothTempRedImg_checkbox_Callback(hObject, eventdata, handles)
%if get(handles.makeFauxRedImg_checkbox,'Value') &...
 %       handles.previousSmooth_fauxRedEvent ~= get(hObject,'Value')
if get(handles.makeFauxRedImg_checkbox,'Value') & get(hObject,'Value')
    makeFauxRedImg_checkbox_Callback(hObject, eventdata, handles);
    handles.previousSmooth_fauxRedEvent = get(hObject,'Value');
end


% --- Executes on button press in deleteXplePts_push.
function deleteXplePts_push_Callback(hObject, eventdata, handles)

handles.deleteMethod = 1;

set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',0);
set(handles.showEditedCellCenters_checkbox,'Value',1);
set(handles.showAddedCellCenters_checkbox,'Value',0);
showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

cellCenters = handles.cellCenters_edit;
axes(handles.finalImg_axes);
h = impoly();
nodes = getPosition(h);
[in, on] = inpolygon(cellCenters(:,1),cellCenters(:,2),nodes(:,1),nodes(:,2));
rmvCenters = cellCenters(find(in==1 | on==1),:);

disp(['Rmved points: ' num2str(size(rmvCenters,1))]);


if size(rmvCenters,1) > 0
    idx = find(ismember(rmvCenters,handles.cellCenters_edit,'rows'));
    rmvCenters = rmvCenters(idx,:);
    handles.rmvedCenters_manual = [handles.rmvedCenters_manual;rmvCenters];
    handles.cellCenters_edit(idx,:) = [];
    if ~isempty(handles.addedCenters)
        idx = find(ismember(handles.addedCenters,rmvCenters,'rows'));
        handles.addedCenters(idx,:) = [];
    end
end

set(handles.showCellCenters_checkbox,'Value',0);
set(handles.showRmvedCellCenters_checkbox,'Value',1);
set(handles.showEditedCellCenters_checkbox,'Value',1);
set(handles.showAddedCellCenters_checkbox,'Value',0);
handles.deleteMethod = 0;
guidata(hObject,handles);

showEditedCellCenters_checkbox_Callback(hObject, eventdata, handles);
showRmvedCellCenters_checkbox_Callback(hObject, eventdata, handles);

guidata(hObject,handles);
