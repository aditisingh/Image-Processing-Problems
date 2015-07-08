function [ vals, in_range ] = bilinear_interpolation( img, X, Y )
%BILINEAR_INTERPOLATION Bilinear interpolation of image.
%   Find a value for the given subpixel locations in the image.
    img = padarray(img, [1 1]); % For convenience.
    num_pts = size(X, 1);
    
    X = X + ones(num_pts, 1); % To account for this padding.
    Y = Y + ones(num_pts, 1); % To account for this padding.

    % Locations below and to the right.
    X_int = floor(X);
    X_int_b = floor(X) + ones(num_pts, 1);
    Y_int = floor(Y);
    Y_int_r = floor(Y) + ones(num_pts, 1);
    
    % Account for 1-pixel padding in the range check.
    vert_in_range = and(X_int > 1, X_int < size(img, 1));
    horiz_in_range = and(Y_int > 1, Y_int < size(img, 2));
    in_range = and(vert_in_range, horiz_in_range);    
    
    X_frac = (X - X_int) .* vert_in_range;
    Y_frac = (Y - Y_int) .* horiz_in_range;
    
    % Top-left, bottom-right, etc.
    int_idxs_tl = sub2ind(size(img), X_int(in_range), Y_int(in_range));
    int_idxs_tr = sub2ind(size(img), X_int(in_range), Y_int_r(in_range));
    int_idxs_bl = sub2ind(size(img), X_int_b(in_range), Y_int(in_range));
    int_idxs_br = sub2ind(size(img), X_int_b(in_range), Y_int_r(in_range));
    
    img_tl = zeros(num_pts, 1);
    img_tr = zeros(num_pts, 1);
    img_bl = zeros(num_pts, 1);
    img_br = zeros(num_pts, 1);
    
    img_tl(in_range) = img(int_idxs_tl);
    img_tr(in_range) = img(int_idxs_tr);
    img_bl(in_range) = img(int_idxs_bl);
    img_br(in_range) = img(int_idxs_br);

    vals = X_frac .* Y_frac .* img_br + ...
           (ones(num_pts, 1) - X_frac) .* Y_frac .* img_tr + ...
           X_frac .* (ones(num_pts, 1) - Y_frac) .* img_bl + ...
           (ones(num_pts, 1) - X_frac) .* (ones(num_pts, 1) - Y_frac) .* img_tl;
    
    % vals is a double array. Should normalise to [0,1].
    vals = vals / 255.0;
end