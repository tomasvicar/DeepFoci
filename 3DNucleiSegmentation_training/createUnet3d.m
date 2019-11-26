function lgraph = createUnet3d(inputSize)
% Create a 3-D U-Net
%
% Copyright 2018 The MathWorks, Inc.

inputL = image3dInputLayer(inputSize,'Normalization','none','Name','input');

% Create the contracting path of the 3-D U-Net
encoder_d1 = createUnet3dEncoderModule(1,[16 16 ]);
encoder_d2 = createUnet3dEncoderModule(2,[32 32 ]);
encoder_d3 = createUnet3dEncoderModule(3,[64 64 ]);

% Create the expanding path of the 3-D U-Net
decoder_l4 = createUnet3dDecoderModule(4,[64 64]);
decoder_l3 = createUnet3dDecoderModule(3,[64 64]);
decoder_l2 = createUnet3dDecoderModule(2,[32 32]);
decoder_l1 = createUnet3dFinalDecoderModule(1,[16 16]);

% layers = [inputL;preluLayer; encoder_d1; encoder_d2; encoder_d3; decoder_l4];
layers = [inputL; encoder_d1; encoder_d2; encoder_d3; decoder_l4];
lgraph = layerGraph(layers);

lgraph = addLayers(lgraph,decoder_l3);
lgraph = addLayers(lgraph,decoder_l2);
lgraph = addLayers(lgraph,decoder_l1);

% Create the skip level connections between encoder and decoder sections
concat1 = concatenationLayer(4,2,'Name','concat1');
lgraph = addLayers(lgraph,concat1);

concat2 = concatenationLayer(4,2,'Name','concat2');
lgraph = addLayers(lgraph,concat2);

concat3 = concatenationLayer(4,2,'Name','concat3');
lgraph = addLayers(lgraph,concat3);

% Connect the encoder and decoder section through concatenationLayer
lgraph = connectLayers(lgraph,encoder_d1(end-1).Name,[concat1.Name '/' 'in1']);
lgraph = connectLayers(lgraph,decoder_l2(end).Name,[concat1.Name '/' 'in2']);

lgraph = connectLayers(lgraph,encoder_d2(end-1).Name,[concat2.Name '/' 'in1']);
lgraph = connectLayers(lgraph,decoder_l3(end).Name,[concat2.Name '/' 'in2']);

lgraph = connectLayers(lgraph,encoder_d3(end-1).Name,[concat3.Name '/' 'in1']);
lgraph = connectLayers(lgraph,decoder_l4(end).Name,[concat3.Name '/' 'in2']);

% Connect output of concatenationLayer to next decoder section
lgraph = connectLayers(lgraph,[concat3.Name '/' 'out'],decoder_l3(1).Name);
lgraph = connectLayers(lgraph,[concat2.Name '/' 'out'],decoder_l2(1).Name);
lgraph = connectLayers(lgraph,[concat1.Name '/' 'out'],decoder_l1(1).Name);


end

function layers = createUnet3dEncoderModule(ModuleNum,NumFilters)
layers = [];
for id=1:length(NumFilters)
    
%     if id==1
        sublayers = [
            convolution3dLayer(3,NumFilters(id),'Padding','same', ...
                'WeightsInitializer','narrow-normal', ...
                'Name',iGetName('en','conv',ModuleNum,id));
            batchNormalizationLayer('Name',iGetName('en','bn',ModuleNum,id));
            reluLayer('Name',iGetName('en','relu',ModuleNum,id));
            ];
%     else
%         sublayers = [
%             convolution3dLayer(3,NumFilters(id),'Padding','same', ...
%                 'WeightsInitializer','narrow-normal', ...
%                 'Name',iGetName('en','conv',ModuleNum,id));
%             reluLayer('Name',iGetName('en','relu',ModuleNum,id));
%             ];
%     end
    layers = [layers; sublayers];
end

maxpool = maxPooling3dLayer(2,'stride',2,'Padding','same', ...
    'Name',iGetName('en','maxpool',ModuleNum));
layers = [layers; maxpool];
end

function layers = createUnet3dDecoderModule(ModuleNum,NumFilters)
layers = [];
for id=1:length(NumFilters)
    sublayers = [
        convolution3dLayer(3,NumFilters(id),'Padding','same', ...
            'WeightsInitializer','narrow-normal', ...
            'Name',iGetName('de','conv',ModuleNum,id));
        batchNormalizationLayer('Name',iGetName('de','bn',ModuleNum,id));
        reluLayer('Name',iGetName('de','relu',ModuleNum,id));
        ];
    layers = [layers; sublayers];
end

transConv = transposedConv3dLayer(2,NumFilters(end),'stride',2, ...
    'Name',iGetName('de','transconv',ModuleNum));
layers = [layers; transConv];
end

function layers = createUnet3dFinalDecoderModule(ModuleNum,NumFilters)
layers = [];
for id=1:length(NumFilters)
    sublayers = [
        convolution3dLayer(3,NumFilters(id),'Padding','same', ...
            'Name',iGetName('de','conv',ModuleNum,id));
        reluLayer('Name',iGetName('de','relu',ModuleNum,id));
        ];
    layers = [layers; sublayers];
end

numLabels = 2;
convLast = convolution3dLayer(1,numLabels,'Name','convLast');
softmaxL = softmaxLayer('Name','softmax');
pixelCL = dicePixelClassification3dLayer('output');
layers = [layers; convLast; softmaxL; pixelCL];
end

function myName = iGetName(moduleType,layerType,varargin)
if numel(varargin) == 1
    myName = [moduleType num2str(varargin{1}) '_' layerType];
elseif numel(varargin) == 2
    myName = [moduleType num2str(varargin{1}) '_' layerType num2str(varargin{2})];
end
end