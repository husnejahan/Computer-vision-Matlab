close all;
clear all;
clc;
data_path = 'A:/COURSE MATERIAL/Winter-2018/computer vision/assignment-A3/test-ass3/Q_3/images_notfaces';
image_files = dir( fullfile( data_path, '*.jpg' ));
mkdir('A:/COURSE MATERIAL/Winter-2018/computer vision/assignment-A3/test-ass3/Q_3/cropped_training_images_notfaces')
for i = 1:length(image_files)
   filename = strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/assignment-A3/test-ass3/Q_3/images_notfaces',image_files(i).name);
   image_files(i).data = imread( fullfile(data_path, image_files(i).name));
   k=imresize(image_files(i).data,[36,36]);
   newfilename=strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/assignment-A3/test-ass3/Q_3/cropped_training_images_notfaces/',image_files(i).name);
   imwrite(k,newfilename,'jpg');
   
end   