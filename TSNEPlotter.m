classdef TSNEPlotter < handle
    % TSNEPlotter  Sets up a t-SNE scatter plot with additional functionality
    %
    % t = TSNEPlotter(ax, h, reduced, imds) returns a TSNEPlotter
    % associated with the axes ax, the collection of t-SNE scatter plot
    % handles h, the 2-D reduced representation of the data reduced, and
    % the imageDatastore imds.
    % 
    % Use this after you have created the t-SNE plot, e.g. with gscatter.
    % It will handle setting up on-click functions for the lines in the
    % plot, so clicking them displays the image corresponding to the t-SNE
    % datapoint.
    %
    % Example:
    %   reduced = tsne(acts);
    %   colors = lines(numClasses);
    %
    %   % t-SNE scatter plot
    %   h = gscatter(ax, reduced(:,1), reduced(:,2), g, ...
    %       colors, [], 8);
    %
    %   plotter = TSNEPlotter(ax, h, reduced, imds, predClass);
    %   plotter.setUpOnClickBehavior();
    
    %   Copyright 2020 The MathWorks, Inc.
    
    properties
       % ImageDisplayAxes  (empty, or axes handle)
       % If this is empty, each new image will be plotted in a new figure.
       % If it is an axes handle, the image will be plotted there.
       ImageDisplayAxes 
    end
    
    properties(Access = private)
        % Axes  (axes)
        % Handle to the axes containing the scatter plot
        Axes
        
        % ScatterHandles  (array of graphics handles)
        % Points to which the ButtonDownFcn will be applied to. For a t-SNE
        % scatter plot made with gscatter, this is the vector of line
        % handles which is the output of gscatter.
        ScatterHandles
        
        % ReducedData  (Nx2 numeric array)
        % Array of x-y points in the reduced representation
        ReducedData
        
        % ImageDatastore  (imageDatastore with N observations)
        % Datastore holding the original data from which ReducedData was
        % extracted.
        ImageDatastore
        
        % PredictedClass 
        % Predicted class labels for images in image datastore
        PredictedClass
    end
    
    methods
        function this = TSNEPlotter(ax, scatterHandles, reducedData, imds, predResults)
            this.Axes = ax;
            
            this.ScatterHandles = scatterHandles;
            this.ReducedData = reducedData;
            this.ImageDatastore = imds;
            this.PredictedClass = predResults;

        end
        
        function setUpOnClickBehavior(this)
            
            % Separately apply a ButtonDownFcn to each graphics handle that
            % needs it.
            h = this.ScatterHandles;
            for i=1:length(h)
                h(i).ButtonDownFcn = @this.handleLineClicked;
            end
        end
    end
    
    methods(Access = private)
        function  handleLineClicked(this, ~, evt)
            % Fired when a line is clicked in ax.
            
            % Find which point in the reduced representation this
            % corresponds to, i.e. the index of the observation being
            % clicked.
            idx = iFindNearestPoint(evt.IntersectionPoint(1:2), this.ReducedData);
            
            imgFilename = this.ImageDatastore.Files{idx};
            trueClass = this.ImageDatastore.Labels(idx);
            predClass = this.PredictedClass(idx);
            
            this.displayImage(imgFilename, trueClass, predClass);
        end
        
        function displayImage(this, imgFilename, trueClass, predClass)
            
            % Display in a new figure and axes, unless an axes is provided.
            if isempty(this.ImageDisplayAxes)
                ax = axes(figure);
            else
                ax = this.ImageDisplayAxes;
            end           
            
            img = imread(imgFilename);
            imgTitle = iImageTitle(imgFilename, trueClass, predClass);
            
            imshow(img, "Parent", ax);
            title(ax, imgTitle, "Interpreter", "none")
            ax.ActivePositionProperty = 'outerposition';

        end
    end
end

function idx = iFindNearestPoint(xy, reducedData)
% Find the index in the data of the nearest actual point to the user's
% click.

% L2 distance between every reduced datapoint and the user click.
d = reducedData - xy;
distances = sqrt(sum(d.^2, 2));

[~, idx] = min(distances);
end

function imgTitle = iImageTitle(imgFilename, trueClass, predClass)
% Create a title for the image.
[~, name, ext] = fileparts(imgFilename);

imageName = strcat(name, ext);
imgTitle = {strcat("True class: ", string(trueClass), "    Predicted class: ", ...
string(predClass)), strcat("File name: ", imageName)};
end

% Copyright 2020 The MathWorks, Inc.