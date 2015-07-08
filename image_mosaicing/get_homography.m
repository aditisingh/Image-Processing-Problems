function [ H, consensus_factor ] = get_homography( corr_pts_1, corr_pts_2, ...
                                 max_trials, max_error, ...
                                 consensus_threshold)
%GET_HOMOGRAPHY Get a homography connecting two images. 
%   Uses the Direct Linear Transform method to estimate the homography.
%   RANSAC is used to mitigate the effect of false correspondences.
    num_pts = size(corr_pts_1, 1); % Also 2. Should I check?
    max_num_consensus = num_pts - 4; % 4 to estimate the homography.
    
    for trials = 1:max_trials,
        % Randomly sample 4 points to estimate the homography from.
        points_to_sample = randperm(num_pts, 4);
        pts_1 = corr_pts_1(points_to_sample, :);
        pts_2 = corr_pts_2(points_to_sample, :);

        % Collect the other points on which we will verify the computed
        % homography.
        unsampled_pts = setdiff(1:num_pts, points_to_sample);
        other_pts_1 = corr_pts_1(unsampled_pts, :);
        other_pts_2 = corr_pts_2(unsampled_pts, :);
        
        H = homography(pts_1, pts_2);
        % Transpose and re-transpose to make it work in this layout.
        expected_other_pts_2 = (H * other_pts_1')';
        % Normalise this output.
        expected_other_pts_2(:,1) = ...
            expected_other_pts_2(:,1) ./ expected_other_pts_2(:,3);
        expected_other_pts_2(:,2) = ...
            expected_other_pts_2(:,2) ./ expected_other_pts_2(:,3);
        
        % See how far we landed...
        delta = expected_other_pts_2 - other_pts_2;
        abs_delta = sqrt(sum(delta .^ 2, 2));        
        consensus_flags = abs_delta < max_error;
        
        % See how many points agree with the homography.
        consensus_factor = sum(consensus_flags) / max_num_consensus;        
        if consensus_factor > consensus_threshold,
            break
        end
    end
    
%     consensus_pts_1 = [pts_1; other_pts_1(consensus_flags,:)];
%     consensus_pts_2 = [pts_2; other_pts_2(consensus_flags,:)];
%     H = homography(consensus_pts_1, consensus_pts_2);
end