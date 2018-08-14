% I have used the below data set:
% http://fei.edu.br/~cet/facedatabase.html
% The FEI face database is a Brazilian face database that contains a set of
% face images taken between June 2005 and March 2006 at the Artificial 
% Intelligence Laboratory of FEI in São Bernardo do Campo, São Paulo, Brazil.
% There are 14 images for each of 200 individuals, a total of 2800 images. 
% All images are colourful and taken against a white homogenous background 
% in an upright frontal position with profile rotation of up to about 180 degrees.

fprintf('\n\n1.By changing regularization coefficient, I got best accuracy on\n') 
fprintf('train data which was 1 and on validation data was 0.997\n')
fprintf('2.I had added 2800 more images with the training and validation set\n')
fprintf('which helped to increase the training and test accuracy\n')
fprintf('3.Then by changing threshold and using multiscale detector,I had\n')
fprintf('found best average precision on test data\n')
fprintf('4.By adjusting the threshold and scale values, I had found best\n')
fprintf('performance on class.jpg,which detect 15 faces without any\n')
fprintf('wrong detection.\n\n')


