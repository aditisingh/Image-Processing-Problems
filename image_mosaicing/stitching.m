clear
clc

% Homography calculation parameters.
max_trials = 200;
max_error_distance = 2.0;
consensus_threshold = 0.95;


%% ESTIMATING HOMOGRAPHIES.

% 2 to 1.
[c1_12, c2_12] = sift_corresp('img1.pgm', 'img2.pgm');
num_matches_12 = size(c1_12, 1);

% Form homogeneous coordinates.
% What about adjusting for the shift of the origin?
% Doesn't matter I suppose. At most there would be an additional
% shift, which would affect the translation parameter.
c1_12 = [c1_12, ones(num_matches_12, 1)];
c2_12 = [c2_12, ones(num_matches_12, 1)];

[H_21, p_21] = get_homography(c2_12, c1_12, max_trials, max_error_distance, consensus_threshold);
H_21 = H_21 ./ H_21(3,3); % Normalise the last element to one. Scale doesn't matter anyway, right?

% 2 to 3.
[c2_23, c3_23] = sift_corresp('img2.pgm', 'img3.pgm');
num_matches_23 = size(c2_23, 1);

% Form homogeneous coordinates.
c2_23 = [c2_23, ones(num_matches_23, 1)];
c3_23 = [c3_23, ones(num_matches_23, 1)];

[H_23, p_23] = get_homography(c2_23, c3_23, max_trials, max_error_distance, consensus_threshold);
H_23 = H_23 ./ H_23(3,3);


%% PAINTING THE STITCHED CANVAS.
img1 = imread('img1.pgm');
img2 = imread('img2.pgm');
img3 = imread('img3.pgm');
[rows, cols] = size(img1);
canvas_rows = 3 * rows;
canvas_cols = 3 * cols;

[canvas_y, canvas_x] = meshgrid(1:canvas_cols, 1:canvas_rows);
canvas_x = reshape(canvas_x, [canvas_rows * canvas_cols, 1]);
canvas_y = reshape(canvas_y, [canvas_rows * canvas_cols, 1]);

% img2 is taken as the centre of the image.
% So I change my coordinates to that frame of reference.
img2_row_offset = rows;
img2_col_offset = cols;
canvas_x_centred = canvas_x - img2_row_offset * ones(canvas_rows * canvas_cols, 1);
canvas_y_centred = canvas_y - img2_col_offset * ones(canvas_rows * canvas_cols, 1);

% Now that img2 has been placed in the centre, we paint 
[img2_vals, img2_in_range] = bilinear_interpolation(img2, canvas_x_centred, canvas_y_centred);

% Now find where img1 fits in all this...
canvas_img1_coords = H_21 * [canvas_x_centred';...
                             canvas_y_centred';...
                             ones(1, numel(canvas_x_centred))];
% Don't forget to transpose...!
canvas_x_img1 = (canvas_img1_coords(1,:) ./ canvas_img1_coords(3,:))';
canvas_y_img1 = (canvas_img1_coords(2,:) ./ canvas_img1_coords(3,:))';
[img1_vals, img1_in_range] = bilinear_interpolation(img1, canvas_x_img1, canvas_y_img1);

% img3. You know the drill.
canvas_img3_coords = H_23 * [canvas_x_centred';...
                             canvas_y_centred';...
                             ones(1, numel(canvas_x_centred))];
% Don't forget to transpose...!
canvas_x_img3 = (canvas_img3_coords(1,:) ./ canvas_img3_coords(3,:))';
canvas_y_img3 = (canvas_img3_coords(2,:) ./ canvas_img3_coords(3,:))';
[img3_vals, img3_in_range] = bilinear_interpolation(img3, canvas_x_img3, canvas_y_img3);

canvas = blend([canvas_rows, canvas_cols], ...
               [img1_vals, img2_vals, img3_vals],...
               [img1_in_range, img2_in_range, img3_in_range]);
imshow(canvas);