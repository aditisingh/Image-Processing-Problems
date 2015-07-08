function [ H ] = homography( pts_1, pts_2 )
%HOMOGRAPHY Computes a homography between 2 sets of points.
%   Workhorse of the get_homography function.
%   Form an equation Ah = 0, where A is formed out of the point
%   correspondences, and h is a vector of the elements of the
%   homography matrix.
    num_pts = size(pts_1, 1);
    
    A = zeros(2 * num_pts, 9);
    for i = 1:num_pts,
        x_row = 2 * i - 1;
        y_row = 2 * i;

        x = pts_1(i,1) / pts_1(i,3);
        y = pts_1(i,2) / pts_1(i,3);
        x_p = pts_2(i,1) / pts_2(i,3);
        y_p = pts_2(i,2) / pts_2(i,3);

        A(x_row,:) = [x y 1 0 0 0 -x_p*x -x_p*y -x_p];
        A(y_row,:) = [0 0 0 x y 1 -y_p*x -y_p*y -y_p];        
    end
    
    if num_pts == 4,
        H = null(A);
        H = H(:,1); % Take the first nullspace vector. Maybe the points
                    % were really defective...
        H = reshape(H, [3 3])'; % Transpose because reshape is column-major.
    else
        % Use fmincon? Normalise H to have sum of squares of entries = 1...
    end
end

