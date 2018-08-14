clc
close all;
clear all;
fprintf('\n creating cropped_training_images_notfaces is running....wait\n');
% you might want to have as many negative examples as positive examples
n_have = 0;
n_want = numel(dir('cropped_training_images_faces/*.jpg'));

imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/images_notfaces';
imageList = dir(sprintf('%s/*.jpg',imageDir));
nImages = length(imageList);

new_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_notfaces';
mkdir(new_imageDir);

dim = 36;

for i = 1:length(imageList)
   filename = strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/images_notfaces',imageList(i).name);
   imageList(i).data = imread( fullfile(imageDir, imageList(i).name));
   grayImage = rgb2gray(imageList(i).data);
   k=imresize(grayImage,[36,36]);
   new_imageDir=strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_notfaces/',imageList(i).name);
   imwrite(k,new_imageDir,'jpg');
   
end   

