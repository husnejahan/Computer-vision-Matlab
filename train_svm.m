
% run('../vlfeat-0.9.20/toolbox/vl_setup')
fprintf('training SVM is running, please wait...\n\n');

load('training_pos_feats','training_neg_feats','training_pos_nImages','training_neg_nImages')
load('validation_pos_feats','validation_neg_feats','validation_pos_nImages','validation_neg_nImages')

feats = cat(1,training_pos_feats,training_neg_feats);
labels_train = cat(1,ones(training_pos_nImages,1),-1*ones(training_neg_nImages,1));
testing_data=cat(1,validation_pos_feats,validation_neg_feats);
labels_validation = cat(1,ones(validation_pos_nImages,1),-1*ones(validation_neg_nImages,1));

% % % % train with regularization coefficient lambda = 0.0001
lambda1 = 0.001;
[w1,b1] = vl_svmtrain(feats',labels_train',lambda1);

fprintf('Classifier performance on train data,lambda = 0.001:\n')
confidences_train = [training_pos_feats;training_neg_feats]*w1 + b1;
[tp_rate, fp_rate, tn_rate, fn_rate] =  report_accuracy(confidences_train, labels_train);

fprintf('Classifier performance on validation data,lambda = 0.001:\n')
confidences_validation=[validation_pos_feats;validation_neg_feats]*w1 + b1;
[tp_rate, fp_rate, tn_rate, fn_rate] =  report_accuracy(confidences_validation, labels_validation);

% % % % train with regularization coefficient lambda = 0.00001
lambda2 = 0.0001;
[w,b] = vl_svmtrain(feats',labels_train',lambda2);

fprintf('Classifier performance on train data,lambda = 0.0001:\n')
confidences_train = [training_pos_feats;training_neg_feats]*w + b;
[tp_rate, fp_rate, tn_rate, fn_rate] =  report_accuracy(confidences_train, labels_train);

fprintf('Classifier performance on validation data,lambda = 0.0001:\n')
confidences_validation=[validation_pos_feats;validation_neg_feats]*w + b;
[tp_rate, fp_rate, tn_rate, fn_rate] =  report_accuracy(confidences_validation, labels_validation);

% % % % saving weight and bias at lambda=0.0001

my_svm=[w;b];
save('my_svm');