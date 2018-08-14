clc;
clear all; 
close all ;

% read images and convert to single format
I1 = im2single(imread('Einstein.jpg'));
I2 = im2single(imread('marilyn.jpg'));
I1 = imresize(I1,[500 640]);
I2 = imresize(I2,[500 640]);

cutoff_low = 5;
cutoff_high = 5; 
im = hybridImage(I1, I2, cutoff_low, cutoff_high);
%adjust the lowpass and highpass cutoff frequencies 
cutoff_low = 10;
cutoff_high = 8; 
im = hybridImage(I1, I2, cutoff_low, cutoff_high);

function [imghybrid] = hybridImage(im1, im2, cutoff_low, cutoff_high)

% apply low pass filter on im1
im1_lowpass = imgaussfilt(im1, cutoff_low);

% apply high pass filter on im2
im2_highpass = im2 - imgaussfilt(im2, cutoff_high);

% merge two images
imghybrid = im1_lowpass + im2_highpass;
imshow(rgb2gray(imghybrid)),figure,imshow(imghybrid);
figure,
subplot(2,2,1), imshow(im1_lowpass), title('low frequency');
subplot(2,2,2), imshow(im2_highpass), title('high frequency');
subplot(2,2,3), imshow(imghybrid), title('hybrid optical illusion colour');
subplot(2,2,4), imshow(rgb2gray(imghybrid)), title('hybrid optical illusion grayscale');
end

