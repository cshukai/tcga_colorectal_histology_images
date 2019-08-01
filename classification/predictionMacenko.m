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

% configuration
verbose = false;
fid = fopen("predOutcome.txt", 'a');

% normalize then predict by vgg 19
allFolders=dir('/storage/htc/nih-tcga/sc724/tcga_current/coad/exp/tif/')
for i=3:numel(allFolders)
    currFolderName = allFolders(i).name;
    %if currFolderName == '.'
    %   continue
    %end 
    %if currFolderName == '..'
    %   continue
    %end   
    currFolderName=strcat('/storage/htc/nih-tcga/sc724/tcga_current/coad/exp/tif/',currFolderName)
    allMyFiles = dir([currFolderName]);
    
    for j=3:numel(allMyFiles)
      currImageName = allMyFiles(j).name;
      %if currImageName == '.'
      % continue
      %end 
      %if currImageName == '..'
      % continue
      %end
        currImageName=strcat(currFolderName,'/',currImageName)
        currImage = imread(currImageName);
        currImage= currImage(:,:,1:3) % not sure what to do with the 4th channel 
        % normalization
        [ NormMM ] = Norm(currImage, ref_image, 'Macenko', 255, 0.15, 1, verbose);
        NormMM=imresize(NormMM,[224,224])
        % vgg classification
         y=char(classify(myNet,NormMM)) % label as categorical type
         out=strcat(currImageName,',',y,'\n')
         fprintf(fid,out)
    end

end
fclose(fid);




