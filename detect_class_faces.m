
% run('../vlfeat-0.9.20/toolbox/vl_setup')
%  If recall rate is low
% and detector still has high precision at its highest recall point,
% we can improve our average precision by reducing the threshold for a
% positive detection.


load('my_svm');
imageDir = 'class_image';
imageList = dir(sprintf('%s/*.jpg',imageDir));
nImages = length(imageList);

%initialize these as empty and incrementally expand them.
bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);
feature_params = struct('template_size', 36, 'hog_cell_size', 6);
cell_size = feature_params.hog_cell_size;
temp_size = feature_params.template_size;
temp_cells = temp_size / cell_size;
D_temp_dimension = (temp_cells)^2 * 31;

threshold = 2.5;
scales = [0.68,0.64,0.61,0.49,0.48,0.47,0.46,0.45,0.44,0.43,0.42,0.41,0.39,0.36,0.32,0.31,0.29,0.27,0.25,0.21,0.19,0.17];

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
        x_img_cell = floor(width_scaled / cell_size);
        y_img_cell = floor(height_scaled / cell_size);

        num_window_x = x_img_cell - temp_cells + 1;
        num_window_y = y_img_cell - temp_cells + 1;

        % reshape each features from the test to a row vector
        window_feats = zeros( num_window_x * num_window_y, D_temp_dimension);
        for x = 1:num_window_x
            for y = 1:num_window_y
                test_window = test_features( y:( y+temp_cells-1 ), x:( x+temp_cells-1), :);
                window_feats( (x-1) * num_window_y + y, :) = reshape(test_window, 1, D_temp_dimension);
            end
        end
        scores = window_feats * w + b;
        indices = find(scores > threshold);
        cur_confidences_scaled = scores(indices);

        detected_x = floor( indices ./ num_window_y );
        detected_y = mod( indices, num_window_y ) - 1;
        cur_bboxes_scaled = [  cell_size *  detected_x + 1,            cell_size *  detected_y + 1, ...
                        cell_size * (detected_x + temp_cells),  cell_size * (detected_y + temp_cells)]./ scale;
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
    image_ids   = [image_ids;   cur_image_ids];
end
%% Step 3.non-max suppression
visualize_detections(bboxes, confidences, image_ids, imageDir);
%% Step 4.non-max suppression
function [is_valid_bbox] = non_max_supr_bbox(bboxes, confidences, img_size, verbose) 
  if(~exist('verbose', 'var'))
    verbose = false;
  end

%Truncate bounding boxes to image dimensions
x_out_of_bounds = bboxes(:,3) > img_size(2); %xmax is greater than x dimension
y_out_of_bounds = bboxes(:,4) > img_size(1); %ymax is greater than y dimension

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

fprintf(' non-max suppression: %d detections to %d final bounding boxes\n', num_detections, sum(is_valid_bbox));
   
end
  
%% Step 5.Use your face detector on class.jpg, and plot the bounding boxes on the image
function visualize_detections(bboxes, confidences, image_ids, imageDir)
% 'bboxes' is Nx4, N is the number of non-overlapping detections, and each
% row is [x_min, y_min, x_max, y_max]
% 'confidences' is the Nx1 (final cascade node) confidence of each
% detection.
% 'image_ids' is the Nx1 image names for each detection.

test_files = dir(fullfile(imageDir, '*.jpg'));
test_images = length(test_files);

for i=1:test_images
   cur_test_image = imread( fullfile( imageDir, test_files(i).name));
      
   cur_detections = strcmp(test_files(i).name, image_ids);
   cur_bboxes = bboxes(cur_detections,:);
   cur_confidences = confidences(cur_detections);
   
   figure(15)
   imshow(cur_test_image);
   hold on;
   
   num_detections = sum(cur_detections);
   
   for j = 1:num_detections
       bb = cur_bboxes(j,:);
       plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g','linewidth',1);
   end
 
   hold off;
   axis image;
   axis off;
   title(sprintf('image: "%s" green=detection', test_files(i).name),'interpreter','none');
    
   set(15, 'Color', [.988, .988, .988])
   pause(0.1) 
   detection_image = frame2im(getframe(15));
  
   imwrite(detection_image, sprintf('class_image/detections_%s.png', test_files(i).name))
   
end

end

