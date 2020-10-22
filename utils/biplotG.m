function subset = biplotG(loadings, scores, varargin)
% BIPLOTG is an alternative to Statistics and Machine Learning Toolbox's 
% 'biplot' that is able to show scores in different colors (groups).
% Unlike 'biplot', 'biplotG' is only able to plot 2 components (2D) and 
% does not impose any sign convention (loadings and scores are never 
% flipped). The input of scores is also different (see below). It is much 
% faster than 'biplot' for big datasets.
%
% SYNTAX:  
%    biplotG(loadings, scores)
%    h = biplotG(loadings, scores, Name, Value, ...)
%  
% INPUTS:
%    loadings   [nvar npc] loadings for the latent variables to be represented 
%                as vectors in the biplot (only first two columns are used)
%    scores     [nobs npc] scores for each observation to be represented as 
%                dots in the biplot (only first two columns are used)
% Optional vale-value pairs: 
% (case insensitive, accepts substrings)
%   'VarLabels' {1 nvar} cell array with labels of variables. Default: not shown 
%   'ObsLabels' {1 nobs} labels for observations. Default: not shown
%   'Groups'    [1 nobs] vector with a group number for each observation
%                Default: all observations in the same group
%   'Format'    {1 ngroups} cell array of cells with formatting options for each
%                group to pass to plot()
%
% RETURNS:
%    h          cell array with handles to: axis, origin lines, axis labels, 
%                scores (for each group), loadings lines, loadings tips, 
%                variable labels, observation labels
%
% EXAMPLES:
%
%    load fisheriris
%    data = meas;
%    labels = {'Sepal length' 'Sepal width' 'Petal length' 'Petal width'};
%    groups = species;
%    [loadings, scores] = pca(zscore(data));
%
%    % simple biplot
%    biplotG(loadings, scores)
%
%    % with groups and loadings labels
%    biplotG(loadings, scores, 'Groups', groups, 'VarLabels', labels)
%
%    % change formating of the second group only
%    format = { {}; {'Marker', '^', 'MarkerSize', 6}; {} }
%    biplotG(loadings, scores, 'Groups', groups, 'Format' , format)
%
%
% Requires: Statistics and Machine Learning Toolbox 
%
% See also: biplot, pca, fisherisis
%
% Copyright (c) 2015, Ines Azevedo Isidro
% Version history:
% 2015.07.31 by In?s A Isidro: function created
% 2015.10.09 by In?s A Isidro: added examples for iris data set
%------------- BEGIN CODE --------------
% ARGUMENTS
% loadings and scores


subset=[];


if nargin < 2, scores = []; end
[nvar, npc1] = size(loadings);
[nobs, npc2] = size(scores);
% cut unused dimensions
if npc1 > 2, loadings = loadings(:,1:2); end
if npc2 > 2, scores = scores(:,1:2); end
% parse varargin (could use inputParser but something much simpler will suffice)
defaults = struct('varLabels',  0, 'obsLabels', 0, ...
                  'groups', ones(1,nobs), 'format', 0 );
opts = parseopts(varargin, defaults);
% format
% default format is circles with changing color for each group
ngroups = length(unique(opts.groups));
if ngroups <= 7, obsColors = lines(ngroups); 
else obsColors = hsv(ngroups); end
formatDefault = arrayfun(@(i) {'Marker', 'o', 'MarkerEdgeColor', ...
    obsColors(i,:), 'MarkerSize', 4},  1:ngroups, 'unif', false)'; 
if ~iscell(opts.format) % no input given, use default
    opts.format = formatDefault;
else % use input when given, default otherwise
    opts.format = parseformat(opts.format, formatDefault);
end
% format loadings
varColor = [.3 .3 .3]; % for comatibility with multiple groups use gray
opts.formatLoadings = { ...
    {'MarkerEdgeColor', varColor, 'MarkerFaceColor', varColor, ...
     'MarkerSize', 2 }; ... % tips
    {'Color', varColor} ... % lines
}; 
% PLOT
% open new figure (unless an empty plot/subplot is active)
if ~isempty(get(gca, 'children'))
    figure();
end
axis square
hold on
% set axis
maxload = max(max(abs(loadings)));
[hax, h0] = formataxis(maxload);
hlab = labelaxis();
% plot loadings
htips = plot(loadings(:,1), loadings(:,2), 'o');
set(htips, opts.formatLoadings{1}{:})
hlines = plot([zeros(nvar,1) loadings(:,1)]', [zeros(nvar,1) loadings(:,2)]');
set(hlines, opts.formatLoadings{2}{:})
% plot scores
if ~isempty(scores)
    
    % normalize: scores are scaled to fit in the loadings interval
    % divide each score by the maximum absolute value of all scores and
    % multiply by the maximum length of loadings vectors
    maxlen = max(sqrt(loadings(:,1).^2 + loadings(:,2).^2));
    scores = scores./max(max(abs(scores)))*maxlen;
    
    % Then biplot changes the sign of score coordinates
    % according to the sign convention for the coefs  ... why ???
    
    % plot each group with its format options
    groupID = unique(opts.groups); % can be numbers or cell of strings
    ngroups = length(groupID);
    hscores = NaN(ngroups,1);
    for igroup = 1:ngroups
        if iscell(opts.groups)
            idx = strcmp(groupID(igroup), opts.groups);
        else
            idx = (opts.groups == groupID(igroup));
        end
        hs = plot(scores(idx,1), scores(idx,2), 'o');
        subset=[subset,hs];
        set(hs, opts.format{igroup}{:})
        hscores(igroup) = hs;
    end
end
% ANNOTATE
% observations labels
hobs = labelpoints(scores(:,1), scores(:,2), opts.obsLabels);
% loadings labels
hvars = labelpoints(loadings(:,1), loadings(:,2), opts.varLabels);
% OUTPUTS
if nargout > 0
    h = {hax h0 hlab hscores hlines htips hvars hobs}; 
end
%------------ END OF CODE --------------
end
%----------- SUBFUNCTIONS --------------
function opts = parseopts(input, defaults)
% input:    cell array of name-value pairs
% defaults: struct with default values
% opts:     struct with parsed options
opts = defaults;
validNames = fieldnames(defaults);
% go over input pairs
for pair = reshape(input, 2, []) % pair is {Name;Value}
    
    % find option position (case insensitive, accepts substrings)
    name = pair{1};
    match = strncmpi(name, validNames, length(name));
    
    % replace defaults with supplied inputs
    if any(match)
        opts.(validNames{match}) = pair{2};
   else
      error('%s is not a recognized parameter name', name)
   end
end
end
% ---
function format = parseformat(input, default)
% check if input is cell of cells
% if only one group is given it could be a simple cell e.g. {'Color','r'}
% but the parser expects cell of cells, so fix it
if ~iscell(input{1}) % simple cell
    input = {input};
end
% go over input (if less groups are given in format than in groups, the
% remaining will keep default formatting)
format = default;
for igroup = 1:numel(input)
    for pair = reshape(input{igroup}, 2, []) % pair is {Name;Value}
        % is there a default value?
        idx = find(strcmp(pair{1}, default{igroup}));
        if isempty(idx) % add value
            format{igroup} = {format{igroup}{:} pair{1} pair{2}};
        else % replace default value
            format{igroup}{idx+1} = pair{2};
        end
    end
end
end
% ---
function [hax, h0] = formataxis(l)
% setup axis for biplot
% round limit up (5% margin)
l = l*1.05;
% set boundaries
axis([-l l -l l]) % axis('equal')
hax = gca;
% add origin lines
hx = abline(0,0, 'Color',[.1 .1 .1], 'LineStyle', ':');
hy = vline(0, 'Color',[.1 .1 .1], 'LineStyle', ':');
h0 = [hx hy];
% prettify 
set(hax, ... 
    'FontName'    , 'Helvetica', ... 
    'FontSize'    , 9  , ...
    'Box'         , 'on'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.01 .01] , ...
    'XMinorTick'  , 'off'     , ...
    'YMinorTick'  , 'off'     , ...
    'XColor'      , [.1 .1 .1], ...
    'YColor'      , [.1 .1 .1], ...
    'LineWidth'   , 1         );
%  'YGrid'       , 'on'      , ...
end
% ---
function h = abline(m,b,varargin) 
% plots y=m*x+b line behind other plots 
% example: abline(1,0,'Color',[.8 .8 .8]) % reference y = x line
xlim = get(gca,'Xlim');
hExist = get(gca,'children');
hLine = line(xlim, b+m*xlim, varargin{:});
uistack(hExist,'top');
if (nargout>0), h = hLine; end
end
% ---
function h = vline(x,varargin) 
% plots vertical line behind other plots crossing x-axis at x 
% example: vline(0,'Color',[.8 .8 .8]) % y axis line
ylim = get(gca,'Ylim');
hExist = get(gca,'children');
hLine = line([x x], ylim, varargin{:});
uistack(hExist,'top');
if (nargout>0), h = hLine; end
end
% ---
function h = labelaxis()
% label axis 
hx = xlabel('Component 1');
hy = ylabel('Component 2');
hlab = [hx hy];
set(hlab, ...
    'FontName'   , 'Helvetica', ...
    'FontSize'   , 9  );
if (nargout>0), h = hlab; end
end
% ---
function h = labelpoints(x, y, labels, color) 
% add labels to points in a scatter plot
if nargin < 4 || isempty(color), color = [.1 .1 .1]; end
% if labels = 0 or [] or {} do nothing
if ~ (isempty(labels) || (~iscell(labels) && isequal(labels, 0)))   
    % if labels are numbers convert to cell array of strings
    if isnumeric(labels), labels = cellstr(num2str(labels')); end
    % add labels to plot
    hold on
    htxt = text(x, y, labels);
    set(htxt, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', ...
        'FontSize', 8, 'FontName', 'Helvetica', 'Color', color )
    hold off
else
    htxt = [];
end
if (nargout>0), h = htxt; end
end
