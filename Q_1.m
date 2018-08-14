
clc;
clear all;
close all;

%% Q1_1 % convolution in the spatial domain
%% Q1_2 % convolution in the frequency domain
fprintf('\nQuestion Q1_1 and Q1_2 are running,please wait...\n\n');
I = imread('image1.jpg');

conv(I);

%% Q_1_3
fprintf('\nQ1_3- \n');
fprintf('\nDescription of the plots- \n');
fprintf('\nIn a spatially filtered image, the value of each output pixel is the weighted sum of neighboring input pixels.\n')
fprintf('Spatial based convolution is good in case of smaller kernels.\n')
fprintf('While frequency based convolution is better after bigger sized kernels,\n')
fprintf('it finishes filtering under similar runtime speed.\n')
fprintf('Filtering in the frequency domain is often faster than filtering in the spatial domain.\n\n')

function conv(I)
subplot(2,2,1), imshow(I), title('Original Image');
I = im2double(I);
if size(I,3) == 3
    I = rgb2gray(I);
end
% Conv2 on spatial domain
tic;
filter3 = fspecial('gaussian', 3, 2);
convim3 = conv2(double(I),double(filter3), 'same');
t3 = toc;
tic;
filter5 = fspecial('gaussian', 5, 2);
convim5 = conv2(im2double(I),im2double(filter5), 'same');
t5 = toc;
tic;
filter7 = fspecial('gaussian', 7, 2);
convim7 = conv2(im2double(I),im2double(filter7), 'same');
t7 = toc;
tic;
filter13 = fspecial('gaussian', 13, 2);
convim13 = conv2(im2double(I),im2double(filter13), 'same');
t13 = toc;
tic;
filter21 = fspecial('gaussian', 21, 2);
convim21 = conv2(im2double(I),im2double(filter21), 'same');
t21 = toc;
tic;
filter31 = fspecial('gaussian', 31, 2);
convim31 = conv2(im2double(I),im2double(filter31), 'same');
t31 = toc;
tic;
filter41 = fspecial('gaussian', 41, 2);
convim41 = conv2(im2double(I),im2double(filter41), 'same');
t41 = toc;
subplot(2,2,2), imshow(convim41), title('conv Image');
tic;
filter51 = fspecial('gaussian', 51, 2);
convim51 = conv2(im2double(I),im2double(filter51), 'same');
t51 = toc;
subplot(2,2,3), imshow(convim51), title('conv Image');
tic;
filter71 = fspecial('gaussian', 71, 2);
convim71 = conv2(im2double(I),im2double(filter71), 'same');
t71 = toc;
subplot(2,2,4), imshow(convim71), title('conv Image');

kernel_size = [3 5 7 13 21 31 41 51 71];
execution_time = [t3 t5 t7 t13 t21 t31 t41 t51 t71];

figure, plot(kernel_size,execution_time), ...
    title('Plot of execution time over kernel size'), ...
    ylabel('Execution time'), xlabel('Kernel size'), ...
    set(gca,'XTick',[3 5 7 13 21 31 41 51 71])

%% Q1_2 % convolution in the frequency domain
fprintf('\nImage size......\n');
[Height Width] = size(I)
tic;
f = circshift(padarray(filter3, [Height Width]-3, 'post'), -[1 1]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf1 = toc;
tic;
f = circshift(padarray(filter5, [Height Width]-5, 'post'), -[2 2]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf2 = toc;
tic;
f = circshift(padarray(filter7, [Height Width]-7, 'post'), -[3 3]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf3 = toc;
tic;
f = circshift(padarray(filter13, [Height Width]-13, 'post'), -[6 6]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf4 = toc;
tic;
f = circshift(padarray(filter21, [Height Width]-21, 'post'), -[10 10]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf5 = toc;
tic;
f = circshift(padarray(filter31, [Height Width]-31, 'post'), -[15 15]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf6 = toc;
tic;
f = circshift(padarray(filter41, [Height Width]-41, 'post'), -[20 20]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf7 = toc;
tic;
f = circshift(padarray(filter51, [Height Width]-51, 'post'), -[25 25]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf8 = toc;
tic;
f = circshift(padarray(filter71, [Height Width]-71, 'post'), -[35 35]);
im_DFT = fft2(I, Height, Width); 
f_DFT = fft2(f, Height, Width); 
im_f_dft = im_DFT .* f_DFT; 
im_f = ifft2(im_f_dft); 
tf9 = toc;
execution_time = [tf1,tf2,tf3,tf4,tf5,tf6,tf7,tf8,tf9];
hold on;
plot(kernel_size,execution_time,'r'), legend('spatial domain','frequency domain')
hold off;
end



