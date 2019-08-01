% modified version of JN Kather, NCT Heidelberg / RWTH Aachen, 2017-2018
% see separate LICENSE 
%
% This MATLAB script is associated with the following project
% "A deep learning based stroma score is an independent prognostic 
% factor in colorectal cancer"
% Please refer to the article and the supplemntary material for a
% detailed description of the procedures. This is experimental software
% and should be used with caution.
% 
% It requires Matlab R2017b, the neural network toolbox and the pre-trained
% vgg19 model from the Matlab App store. Please observe that different
% licenses may apply to these software packages.
% 

% loading dependecies and network
clear all, close all, format compact, clc
addpath(genpath('./subroutines/'));
addpath(genpath('./subroutines/stain_normalisation_toolbox'));

load('lastNet_TEXTURE_VGG.mat')
ref_image_path = 'Ref.png';
ref_image = imread(ref_image_path);
verbose = true;

% normalize then predict by vgg 19
allFolders=dir('/storage/htc/nih-tcga/sc724/tcga_current/coad/exp/tif/')
for i=1:numel(allFolders)
    currFolderName = allFolders(i).name;
    if currFolderName == '.'
       continue
    end 
    if currFolderName == '..'
       continue
    end   
    currFolderName=strcat('/storage/htc/nih-tcga/sc724/tcga_current/coad/exp/tif/',currFolderName)
    allMyFiles = dir([currFolderName]);
    
    for j=1:numel(allMyFiles)
      currImageName = allMyFiles(j).name;
      if currImageName == '.'
       continue
      end 
      if currImageName == '..'
       continue
      end
        currImageName=strcat(currFolderName,'/',currImageName)
        currImage = imread(currImageName);
        currImage= currImage(:,:,1:3) % not sure what to do with the 4th channel 
        % normalization
        [ NormMM ] = Norm(currImage, ref_image, 'Macenko', 255, 0.15, 1, verbose);
    end

end



% 
testing_inputPath = '/storage/htc/nih-tcga/sc724/tcga_current/whole_slide_patches/images/wholeslide/colorectal/CRC-VAL-HE-7K/'; 

%% READ TESTING IMAGES
disp('loading TESTING images');
testing_set = imageDatastore(testing_inputPath,'IncludeSubfolders',true,'LabelSource','foldernames');
testing_set.ReadFcn = @readPathoImage_224; % read and resize images
testing_tbl = countEachLabel(testing_set) %#ok
testing_categories = testing_tbl.Label; % extract category labels (from folder name)
disp('successfully loaded TESTING images');
figure, imshow(preview(testing_set)); % show preview image
%% DEPLOY
predictedLabels = classify(myNet, testing_set);

%% assess accuracy, show confusion matrix
labels_ground = testing_set.Labels;
labels_pred = predictedLabels;
PerItemAccuracy = mean(labels_pred == labels_ground);
disp(['per image accuracy is ',cnum2str(PerItemAccuracy)]);
allgroups = cellstr(unique(labels_ground));
conf = confusionmat(labels_ground,labels_pred);
figure(),imagesc(conf);
xlabel('predicted'),ylabel('known');
set(gca,'XTickLabel',allgroups);
set(gca,'YTickLabel',allgroups);
axis square
colorbar
set(gcf,'Color','w');
title(['classification with accuracy ',num2str(round(100*PerItemAccuracy)),'%']);

