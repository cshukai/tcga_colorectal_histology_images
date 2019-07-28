deploy_dataPath = '/storage/htc/nih-tcga/sc724/tcga_current/coad/exp/slide';
allFiles = dir([deploy_dataPath,'*.svs']);

for i = 1:numel(allFiles)
  currFilePath = [deploy_dataPath,allFiles(i).name];
  disp(currFilePath)
  I=imread(curFilePath,'Index',1)
  
  
