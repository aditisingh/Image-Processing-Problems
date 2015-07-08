function [ canvas ] = blend( canvas_size, img_values, img_ranges )
%BLEND Blend the different image values (and ranges) provided to paint
%      a canvas.
%   Basically, we get a whole lot of image inputs. Each of them is valid
%   in a certain region of the canvas. We take them all in and paint the
%   canvas pixel by pixel, using the images that are valid in that region.
    canvas = sum(img_values .* img_ranges, 2) ./ sum(img_ranges, 2);
    
    canvas = reshape(canvas, canvas_size);
end