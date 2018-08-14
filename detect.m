% run('../vlfeat-0.9.20/toolbox/vl_setup')
% If recall rate is low
% and detector still has high precision at its highest recall point,
% we can improve our average precision by reducing the threshold for a
% positive detection.

%% Step: single-scale sliding window face detector
fprintf('\nsingle-scale sliding window face detector running...\n')
load('my_svm');
imageDir = 'test_images';
imageList = dir(sprintf('%s/*.jpg',imageDir));
nImages = length(imageList);

%initialize these as empty and incrementally expand them.
bboxes = zeros(0,4);
confidences = zeros(0,1);
image_names = cell(0,1);
feature_params = struct('template_size', 36, 'hog_cell_size', 6);
cell_size = feature_params.hog_cell_size;
temp_size = feature_params.template_size;
temp_cells = temp_size / cell_size;
D_dimension = (temp_cells)^2 * 31;

threshold = 0.011
% scales = [1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2];
scales = [0.65];
for i = 1:length(imageList)
    img = imread( fullfile( imageDir, imageList(i).name ));
    img = single(img)/255;
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    
    cur_bboxes = zeros(0,4);
    cur_confidences = zeros(0,1);
    cur_image_ids = zeros(0,1);
    
    for scale = scales
        
        img_scaled = imresize(img, scale);
        [height_scaled, width_scaled] = size(img_scaled);

        test_features = vl_hog(img_scaled, cell_size);
        row_img_cell = floor(width_scaled / cell_size);
        cols_img_cell = floor(height_scaled / cell_size);

        num_window_r = row_img_cell - temp_cells + 1;
        num_window_c = cols_img_cell - temp_cells + 1;

        % reshape each features from the test to a row vector
        window_feats = zeros( num_window_r * num_window_c, D_dimension);
        for r = 1:num_window_r
            for c = 1:num_window_c
                test_window = test_features( c:( c+temp_cells-1 ), r:( r+temp_cells-1), :);
                window_feats( (r-1) * num_window_c + c, :) = reshape(test_window, 1, D_dimension);
            end
        end
        scores = window_feats * w + b;
        indices = find(scores > threshold);
        cur_confidences_scaled = scores(indices);

        detected_r = floor( indices ./ num_window_c );
        detected_c = mod( indices, num_window_c ) - 1;
        cur_bboxes_scaled = [  cell_size *  detected_r + 1,            cell_size *  detected_c + 1, ...
                        cell_size * (detected_r + temp_cells),  cell_size * (detected_c + temp_cells)]./ scale;
        cur_image_ids_scaled = repmat( {imageList(i).name}, size(indices,1), 1);
        
        cur_bboxes      = [cur_bboxes;      cur_bboxes_scaled];
        cur_confidences = [cur_confidences; cur_confidences_scaled];
        cur_image_ids   = [cur_image_ids;   cur_image_ids_scaled];
    end
    %non_max_supr_bbox can actually get somewhat slow with thousands of
    %initial detections
   
    [is_maximum] = non_max_supr_bbox(cur_bboxes, cur_confidences, size(img));

    cur_confidences = cur_confidences(is_maximum,:);
    cur_bboxes      = cur_bboxes(     is_maximum,:);
    cur_image_ids   = cur_image_ids(  is_maximum,:);
    
 
    bboxes      = [bboxes;      cur_bboxes];
    confidences = [confidences; cur_confidences];
    image_names   = [image_names;   cur_image_ids];
end


%% Step: Evaluation
label_path = 'test_images_gt.txt';
[gt_ids, gt_bboxes, gt_isclaimed, tp, fp, duplicate_detections] = ...
    evaluate_detections_on_test(bboxes, confidences, image_names, label_path);
  
%% Step: get the most confident predictions, by non-max suppression
  function [is_valid_bbox] = non_max_supr_bbox(bboxes, confidences, img_size, verbose) 
  if(~exist('verbose', 'var'))
    verbose = false;
  end

%Truncate bounding boxes to image dimensions
x_out_of_bounds = bboxes(:,3) > img_size(2); 
y_out_of_bounds = bboxes(:,4) > img_size(1); 

bboxes(x_out_of_bounds,3) = img_size(2);
bboxes(y_out_of_bounds,4) = img_size(1);

num_detections = size(confidences,1);

%higher confidence detections get priority.
[confidences, ind] = sort(confidences, 'descend');
bboxes = bboxes(ind,:);

% indicator for whether each bbox will be accepted or suppressed
is_valid_bbox = logical(zeros(1,num_detections)); 

for i = 1:num_detections
    cur_bb = bboxes(i,:);
    cur_bb_is_valid = true;
    
    for j = find(is_valid_bbox)
        %compute overlap with each previously confirmed bbox.
        
        prev_bb=bboxes(j,:);
        bi=[max(cur_bb(1),prev_bb(1)) ; ... 
            max(cur_bb(2),prev_bb(2)) ; ...
            min(cur_bb(3),prev_bb(3)) ; ...
            min(cur_bb(4),prev_bb(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(cur_bb(3)-cur_bb(1)+1)*(cur_bb(4)-cur_bb(2)+1)+...
               (prev_bb(3)-prev_bb(1)+1)*(prev_bb(4)-prev_bb(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov > 0.3 %If the less confident detection overlaps too much with the previous detection
                cur_bb_is_valid = false;
            end
            
            %special case-- the center coordinate of the current bbox is
            %inside the previous bbox.
            center_coord = [(cur_bb(1) + cur_bb(3))/2, (cur_bb(2) + cur_bb(4))/2];
            if( center_coord(1) > prev_bb(1) && center_coord(1) < prev_bb(3) && ...
                center_coord(2) > prev_bb(2) && center_coord(2) < prev_bb(4))
               
                cur_bb_is_valid = false;
            end
            
            if(verbose)
                fprintf('detection %d, bbox: [%d %d %d %d], %f overlap with %d [%d %d %d %d]\n', ...
                    i, cur_bb(1), cur_bb(2), cur_bb(3), cur_bb(4), ov, j, prev_bb(1), prev_bb(2), prev_bb(3),prev_bb(4))
            end
        end
    end
    
    is_valid_bbox(i) = cur_bb_is_valid;

end

%This statement returns the logical array 'is_valid_bbox' back to the order
%of the input bboxes and confidences
reverse_map(ind) = 1:num_detections;
is_valid_bbox = is_valid_bbox(reverse_map);

fprintf('\n non-max suppression is running please wait.....\n'); 
  end
  
