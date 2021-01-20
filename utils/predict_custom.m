function Y = predict(this, X, varargin)
% predict   Make predictions on data with network
%
%   Y = predict(net, X) will compute predictions of the network net on the
%   data X. The format of X will depend on the input layer for the network.
%
%   For a network with an image input layer, X may be:
%       - A single image. 
%       - A 4D array of images, where the first three dimensions index the
%         height, width and channels of an image, and the fourth dimension
%         indexes the individual images.
%       - A 5D array of images, where the first four dimensions index the
%         height, width, depth and channels of an image, and the fifth
%         dimension indexes the individual images.
%       - A datastore, where the output of the datastore read function is
%         one image, a cell array of images, or a table whose first column
%         contains images.
%       - A table, where the first column contains either image paths or 
%         images.
%
%   For a network with a sequence input layer, X may be:
%       - A cell array of C-by-S matrices, where C is the number of
%         features and S is the number of time steps.
%       - A cell array of H-by-W-by-C-by-S arrays, where H-by-W-by-C is the
%         2-D image size and S is the number of time steps.
%       - A cell array of H-by-W-by-D-by-C-by-S arrays, where
%         H-by-W-by-D-by-C is the 3-D image size and S is the number of
%         time steps.
%   For sequences with one observation, X can be a numeric array.
%
%   For a classification problem, Y will contain the predicted scores,
%   arranged in an N-by-K matrix, where N is the number of observations,
%   and K is the number of classes.
%
%   For a regression problem, Y will contain the predicted responses,
%   arranged in an N-by-R matrix, where N is the number of observations,
%   and R is the number of responses, or in an H-by-W-by-C-by-N 4D array,
%   where N is the number of observations and H-by-W-by-C is the size of a
%   single response.
%
%   Y = predict(net, X, 'PARAM1', VAL1, ...) will compute predictions with
%   the following optional name/value pairs:
%
%       'MiniBatchSize'         - The size of the mini-batches for
%                                 computing predictions. Larger mini-batch
%                                 sizes lead to faster predictions, at the
%                                 cost of more memory. The default is 128.
%       'ExecutionEnvironment'  - The execution environment for the
%                                 network. This determines what hardware
%                                 resources will be used to run the
%                                 network.
%                                   - 'auto' - Use a GPU if it is
%                                     available, otherwise use the CPU.
%                                   - 'gpu' - Use the GPU. To use a
%                                     GPU, you must have Parallel Computing
%                                     Toolbox(TM), and a CUDA-enabled
%                                     NVIDIA GPU with compute capability
%                                     3.0 or higher. If a suitable GPU is
%                                     not available, predict returns an
%                                     error message.
%                                   - 'cpu' - Use the CPU.
%                                 The default is 'auto'.
%       'Acceleration'          - Optimizations that can improve
%                                 performance at the expense of some
%                                 overhead on the first call and possible
%                                 additional memory usage.
%                                   - 'auto' - Automatically select 
%                                   optimizations suitable for the input 
%                                   network and environment. 
%                                   - 'mex' - (GPU only) Generate and 
%                                   execute a MEX function. Subsequent 
%                                   calls with the same network and options
%                                   use the MEX function.
%                                   - 'none' - Disable all acceleration.
%                                 The default is 'auto'.
%       'SequenceLength'        - Strategy to determine the length of the
%                                 sequences used per mini-batch. Options
%                                 are:
%                                   - 'longest' to pad all sequences in a
%                                     batch to the length of the longest
%                                     sequence.
%                                   - 'shortest' to truncate all sequences
%                                     in a batch to the length of the
%                                     shortest sequence.
%                                   - Positive integer - For each
%                                     mini-batch, pad the sequences to the
%                                     nearest multiple of the specified
%                                     length that is greater than the
%                                     longest sequence length in the
%                                     mini-batch, and then split the
%                                     sequences into smaller sequences of
%                                     the specified length. If splitting
%                                     occurs, then the software creates
%                                     extra mini-batches.
%                                 The default is 'longest'.
%       'SequencePaddingValue'  - Scalar value used to pad sequences where 
%                                 necessary. The default is 0.

%   Copyright 2018-2019 The MathWorks, Inc.

% iAssertNetworkHasSingleInput( this.PrivateNetwork.NumInputs );
% iAssertNetworkHasSingleOutput( this.PrivateNetwork.NumOutputs );

% Set desired precision
precision = nnet.internal.cnn.util.Precision('single');

[miniBatchSize, executionEnvironment, ...
    sequenceLength, sequencePaddingValue, acceleration] = ...
    this.parseAndValidatePredictNameValuePairs( varargin{:} );

% Check if we have a single observation
if ~this.NetworkInfo.IsRNN && iSingleNumericObservation( ...
        X, this.NetworkInfo.InputSizes{1})
    Y = predictSingle( ...
        this, X, miniBatchSize, executionEnvironment, precision, ...
        acceleration );
else
    Y = predictBatch( ...
        this, X, miniBatchSize, executionEnvironment, precision, ...
        acceleration, sequenceLength, sequencePaddingValue );
end
end

function iAssertNetworkHasSingleInput(numInputs)
if numInputs ~= 1
    exception = iCreateExceptionFromErrorID( ...
        'nnet_cnn:DAGNetwork:InferenceInvalidForMultipleInputs');
    throwAsCaller(exception);
end
end

function iAssertNetworkHasSingleOutput(numOutputs)
if numOutputs ~= 1
    exception = iCreateExceptionFromErrorID( ...
        'nnet_cnn:DAGNetwork:InferenceInvalidForMultipleOutputs');
    throwAsCaller(exception);
end
end

function tf = iSingleNumericObservation(X, inputSize)
tf = isnumeric(X) && isreal(X) && ~issparse(X) && isequal(size(X), inputSize);
end

function iValidateDispatcherHasThisInputSize(dispatcher, inputSize)
if isequal(dispatcher.ImageSize, inputSize)
else
    exception = iCreateExceptionFromErrorID( ...
        'nnet_cnn:DAGNetwork:WrongSizePredictDataForImageInputLayer', ...
        mat2str(inputSize));
    throwAsCaller(exception);
end
end

function exception = iCreateExceptionFromErrorID(errorID, varargin)
exception = MException(message(errorID, varargin{:}));
end

function tf = iNumObservationsUnknown(dispatcher)
tf = ~isfinite(dispatcher.NumObservations);
end

function Y = iBatchNDCellOutput(Y, outputSize)
% Batch N element cell array. Assume batch dim is ndim+1.
batchDim = numel(outputSize)+1;
Y = cat(batchDim,Y{:});
end

function [newOutputSize, formattedObservationDim] = iInit2DRowResponsesFormat(outputSize, numObservations, observationDim)
if all(outputSize(1:observationDim-2) == 1)
    % New output size will be [N K]
    newOutputSize = [numObservations , outputSize(observationDim-1)];
    formattedObservationDim = 1; % Observation dim becomes the first dimension
else
    % New output size will be [H W (D) K N]
    newOutputSize = [outputSize, numObservations];
    formattedObservationDim = observationDim; % Unchanged
end
end

function YFormatted = iFormatPredictionsAs2DRowResponses(Y, observationDim)
% iFormatPredictionsAs2DRowResponses   Format predictions according to the
% problem.
% If Y is [1 1 K N]/[1 1 1 K N], then YFormatted will be [N K].
% If Y is [H W (D) K N], with H, W or D not singleton, then YFormatted will
% be the same as Y.
YSize = ones(1, observationDim);
YSize(1:ndims(Y)) = size(Y);
if all(YSize(1:observationDim-2)==1)
    % Get rid of first two/three/ObsDim-2 singleton dimensions for 2D/3D/ND
    YFormatted = shiftdim(Y,observationDim-2);
    % Transpose [K N] -> [N K]
    YFormatted = YFormatted';
else
    YFormatted = Y;
end
end

function Y = predictSingle( net, X, miniBatchSize, executionEnvironment, ...
    precision, acceleration )
% Cache variables that are slow to recalculate to optimize calling of
% predict in a tight loop
inferenceInfo = nnet.internal.cnn.InferenceInfo( ...
    "predict", net.NetworkInfo.InputSizes, ...
    miniBatchSize, 1, executionEnvironment, precision, [] );
[predictNetwork, gpuShouldBeUsed] = setupPredictionEnvironment( ...
    net, inferenceInfo, acceleration);
X = precision.cast(X);

isMex = strcmpi(acceleration,  "mex");
if gpuShouldBeUsed && ~isMex
    X = gpuArray(X);
end

Y = predictNetwork.predict( X );
Y = gather( Y{1} );

if ~isMex
    outputSize = net.NetworkInfo.OutputSizes{1};
    outputObservationDim = numel(outputSize) + 1;
    Y = iFormatPredictionsAs2DRowResponses(Y,outputObservationDim);
end
end

function Y = predictBatch( net, X, miniBatchSize, executionEnvironment, ...
    precision, acceleration, sequenceLength, sequencePaddingValue )
% Create dispatcher
dispatcher = net.createDispatcher(X, miniBatchSize, precision, ...
    sequenceLength, sequencePaddingValue, net.NetworkInfo);

% Cache variables that are slow to recalculate to optimize
% calling of predict in a tight loop
inferenceInfo = nnet.internal.cnn.InferenceInfo( "predict", net.NetworkInfo.InputSizes, ...
    miniBatchSize, dispatcher.NumObservations, executionEnvironment, precision, [] );

networkIsRNN = net.NetworkInfo.IsRNN;

if ~networkIsRNN
    iValidateDispatcherHasThisInputSize(dispatcher, net.NetworkInfo.InputSizes{1});
end

[predictNetwork, gpuShouldBeUsed] = setupPredictionEnvironment(net, inferenceInfo, acceleration);
isMex = strcmpi(acceleration,  "mex");

if networkIsRNN
    Y = net.predictRNN(X, dispatcher, precision, predictNetwork, gpuShouldBeUsed);
else
    outputSize = net.NetworkInfo.OutputSizes{1};
    outputObservationDim = numel(outputSize) + 1;
    
    if iNumObservationsUnknown(dispatcher)
        % Input is a datastore.
        
        % Output size is unknown.
        Y = cell(0,1);
        
        % Should error out if MEX acceleration is selected
        
        % Use the dispatcher to run the network on the data
        dispatcher.start();
        
        while ~dispatcher.IsDone
            [X, ~, ~] = dispatcher.next();
            
            if(gpuShouldBeUsed)
                X = gpuArray(X);
            end
            
            YBatch = predictNetwork.predict(X);
            Y{end+1} = gather(YBatch{1}); %#ok<AGROW>
        end
        Y = iBatchNDCellOutput(Y,outputSize);
        Y = iFormatPredictionsAs2DRowResponses(Y,outputObservationDim);
    else
        
        % Allocate space for the output data.
        if isMex
            [outputSize, outputObservationDim] = iInit2DRowResponsesFormat(outputSize, dispatcher.NumObservations, outputObservationDim);
        else
            outputSize = [outputSize dispatcher.NumObservations];
        end
        Y = zeros(outputSize, precision.Type);
        
        % Use the dispatcher to run the network on the data
        dispatcher.start();
        
        while ~dispatcher.IsDone
            [X, ~, indices] = dispatcher.next();
            
            % MEX version doesn't support receiving GPU data
            if gpuShouldBeUsed && ~isMex
                X = gpuArray(X);
            end
            
            YBatch = predictNetwork.predict(X);
            if isMex
                Y = nnet.internal.cnn.util.mergeOutput( ...
                    YBatch{1}, Y, outputObservationDim, indices );
            else
                % The following code is equivalent to this for 4-D
                % input case- Y(:,:,:,indices) = gather(YBatch{1});
                Y = nnet.internal.cnn.util.aggregateArrayFromObservations(Y,...
                    indices, gather(YBatch{1}), outputObservationDim);
            end
        end
    end
    if ~isMex
        Y = iFormatPredictionsAs2DRowResponses(Y, outputObservationDim);
    end
end
end
