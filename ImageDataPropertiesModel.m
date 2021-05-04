classdef ImageDataPropertiesModel
% ImageDataProperties  Access properties and random images of image datastore
%
% ImageDataPropertiesModel Properties: 
%
% ImageDatastore            - The input image datastore object 
% TotalObservations         - Total number of observations in the datastore
% Classes                   - Unique classes in image datastore 
% NumClasses                - Number of unique classes in image datastore
% NumObservationsByClass    - Number observations per unique class
% NumObsToShow              - Number of observations to show when accessing 
%                             image datastore
%
% ImageDataPropertiesModel Methods:
% 
% getRandomData             - Extract random images from datastore
% getRandomDataByLabel      - Extract random images from datastore by class
%                             label
% 
% Copyright 2020 The MathWorks, Inc.
        
    properties(SetAccess = private)
        % Properties of the image data
        ImageDatastore
        Classes
        NumObservationsByClass        
        TotalObservations
    end
    
    properties(Dependent)
        NumClasses
    end
    
    properties
        % Default number of observations to show when accessing image
        % datastore
        NumObsToShow = 16;
    end
       
    methods
        % ImageDataPropertiesModel is constructed with an image datastore 
        % argument
        function imageData = ImageDataPropertiesModel(imds)
            % Extract the properties of the image data
            imageData.ImageDatastore = imds;            
            imageData.TotalObservations = length(imds.Labels);            
            imageData.Classes = unique(imds.Labels);           
            imageData.NumObservationsByClass = arrayfun(...
                @(x)sum(x == imds.Labels), imageData.Classes);
        end
        
        % Select numImages random images from the image data
        function [data, labels] = getRandomData(imageData, numImages)
            idx = randperm(imageData.TotalObservations, imageData.NumObsToShow);
            
            subImds = imageData.ImageDatastore.subset(idx);
            cellData = subImds.readall();
            
            if nargin > 1
                data = cellfun(@(x)imresize(x, numImages), cellData, ...
                    "UniformOutput", false);
            else
                data = cellData;
            end          
            labels = imageData.ImageDatastore.Labels(idx);
        end
        
        % Select numImages random images from the image data with class
        % chosenClass
        function [data, labels] = getRandomDataByLabel(imageData, chosenClass, numImages)
           
            isIncluded = ismember(imageData.ImageDatastore.Labels, categorical(chosenClass));
            subImds = imageData.ImageDatastore.subset(isIncluded);
            
            numObsToShow = min(imageData.NumObsToShow, length(subImds.Labels)); 
            
            idx = randperm(length(subImds.Labels), numObsToShow);
            subImds = subImds.subset(idx);
            
            cellData = subImds.readall();
            
            if nargin > 2
                data = cellfun(@(x)imresize(x, numImages), cellData, ...
                    "UniformOutput", false);
            else
                data = cellData;
            end           
            labels = subImds.Labels;
        end        
    end    
end

