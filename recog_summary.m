%% best accuracy on the validation set, and what you did to improve performance
fprintf('\n1.I have splitted cropped images into two sets: a training set,')
fprintf('and a validation set.Where percentage training set=80,\n')
fprintf( 'validation set=20')
fprintf('\n2.Then trained model with regularization coefficient lambda = 0.001 and ')
fprintf('regularization coefficient lambda = 0.0001.\n')
fprintf('3.I got accuracy on train data 0.997 and  1.000 respectively. And accuracy on validation data')
fprintf(' 0.995 and 0.997 respectively.\n')
fprintf('By changing regularization coefficient, I got best accuracy on train data which is 1 and on validation data is 0.997. \n\n')

% Classifier performance on train data,lambda = 0.001:
%   accuracy:   0.997
%   true  positive rate: 0.972
%   false positive rate: 0.003
%   true  negative rate: 0.025
%   false negative rate: 0.000
% Classifier performance on validation data,lambda = 0.001:
%   accuracy:   0.995
%   true  positive rate: 0.972
%   false positive rate: 0.005
%   true  negative rate: 0.023
%   false negative rate: 0.000
% Classifier performance on train data,lambda = 0.0001:
%   accuracy:   1.000
%   true  positive rate: 0.972
%   false positive rate: 0.000
%   true  negative rate: 0.028
%   false negative rate: 0.000
% Classifier performance on validation data,lambda = 0.0001:
%   accuracy:   0.997
%   true  positive rate: 0.971
%   false positive rate: 0.002
%   true  negative rate: 0.026
%   false negative rate: 0.002