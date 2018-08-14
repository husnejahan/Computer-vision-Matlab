clc
close all
clear
% run('../vlfeat-0.9.21/toolbox/vl_setup')
PD = 0.20 ;
[Train_pos,Train_neg,Test_pos,Test_neg] =split_data(PD);


% % % % creating  training features
fprintf('\n creating  training features is running....wait\n');
training_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/training_images';
training_imageList = dir(sprintf('%s/*.jpg',training_imageDir));
training_pos_nImages = length(Train_pos);
training_neg_nImages = length(Train_neg);

cellSize = 6;
featSize = 31*cellSize^2;

training_pos_feats = zeros(training_pos_nImages,featSize);
for i=1:training_pos_nImages
    im = im2single(imread(sprintf('%s/%s',training_imageDir,Train_pos(i).name)));
    feat = vl_hog(im,cellSize);
    training_pos_feats(i,:) = feat(:);
    fprintf('\ngot feat for training_pos image %d/%d\n',i,Train_pos(i).name);

end

training_neg_feats = zeros(training_neg_nImages,featSize);
for i=1:training_neg_nImages
    im = im2single(imread(sprintf('%s/%s',training_imageDir,Train_neg(i).name)));
    feat = vl_hog(im,cellSize);
    training_neg_feats(i,:) = feat(:);
    fprintf('\ngot feat for training_neg image %d/%d\n',i,Train_neg(i).name);

end
% % % % % creating validation features 
fprintf('\n creating validation features is running....wait\n');
validation_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/Validation_images';
validation_imageList = dir(sprintf('%s/*.jpg',validation_imageDir));
validation_pos_nImages = length(Test_pos);
validation_neg_nImages = length(Test_neg);

validation_pos_feats = zeros(validation_pos_nImages,featSize);
for i=1:validation_pos_nImages
    im = im2single(imread(sprintf('%s/%s',validation_imageDir,Test_pos(i).name)));
    feat = vl_hog(im,cellSize);
    validation_pos_feats(i,:) = feat(:);
    fprintf('\ngot feat for validation_pos image %d/%d\n',i,Test_pos(i).name);

end

validation_neg_feats = zeros(validation_neg_nImages,featSize);
for i=1:validation_neg_nImages
    im = im2single(imread(sprintf('%s/%s',validation_imageDir,Test_neg(i).name)));
    feat = vl_hog(im,cellSize);
    validation_neg_feats(i,:) = feat(:);
    fprintf('\ngot feat for validation_neg image %d/%d\n',i,Test_neg(i).name);

end

save('training_pos_feats','training_neg_feats','training_pos_nImages','training_neg_nImages');
save('validation_pos_feats','validation_neg_feats','validation_pos_nImages','validation_neg_nImages');
fprintf('Generate HOG features for all of the training and validation images done! Press enter to continue...\n\n');
pause;

% --------------------------------------------------------------------------------------------------------------------- % 
% Split cropped images into two sets: a training set, and a validation set.percentage training set=80%,validation set=20% 
%  --------------------------------------------------------------------------------------------------------------------- % 

function [Train_pos,Train_neg,Test_pos,Test_neg] =split_data(PD)
% Let P be your N-by-M input dataset
fprintf('\n Split dataset is running....wait\n')
pos_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_faces';
pos_imageList = dir(sprintf('%s/*.jpg',pos_imageDir));

neg_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_notfaces';
neg_imageList = dir(sprintf('%s/*.jpg',neg_imageDir));

% % training set=80%
cp = cvpartition(size(pos_imageList,1),'HoldOut',PD);
Train_pos = pos_imageList(cp.training,:);
Test_pos = pos_imageList(cp.test,:);

% % validation set=20%
cn = cvpartition(size(neg_imageList,1),'HoldOut',PD);
Train_neg = neg_imageList(cn.training,:);
Test_neg = neg_imageList(cn.test,:);

%%create new directory to transfer all training data
Train_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/training_images';
mkdir(Train_imageDir);

for i = 1:length(Train_pos)
     filename = strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_faces',Train_pos(i).name);
     Train_pos(i).data = imread( fullfile(pos_imageDir,Train_pos(i).name));
     k= Train_pos(i).data;
     Train_imageDir=strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/training_images/',Train_pos(i).name);
     imwrite(k,Train_imageDir,'jpg')

end

for i = 1:length(Train_neg)
     filename = strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_notfaces',Train_neg(i).name);
     Train_neg(i).data = imread( fullfile(neg_imageDir,Train_neg(i).name));
     k= Train_neg(i).data;
     Train_imageDir=strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/training_images/',Train_neg(i).name);
     imwrite(k,Train_imageDir,'jpg')

end

%%create new directory to transfer all validation data
Test_imageDir = 'A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/Validation_images';
mkdir(Test_imageDir);

for i = 1:length(Test_pos)
     filename = strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_faces',Test_pos(i).name);
     Test_pos(i).data = imread( fullfile(pos_imageDir,Test_pos(i).name));
     k= Test_pos(i).data;
     Test_imageDir=strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/Validation_images/',Test_pos(i).name);
     imwrite(k,Test_imageDir,'jpg')

end
for i = 1:length(Test_neg)
     filename = strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/cropped_training_images_notfaces',Test_neg(i).name);
     Test_neg(i).data = imread( fullfile(neg_imageDir,Test_neg(i).name));
     k= Test_neg(i).data;
     Train_imageDir=strcat('A:/COURSE MATERIAL/Winter-2018/computer vision/Assignment-3/Validation_images/',Test_neg(i).name);
     imwrite(k,Train_imageDir,'jpg')
end
fprintf('\n Split dataset done....\n')
end
