function contours = get_contour(img, thr)
% get the contour of a given image
if ~exist('thr', 'var') || isempty(thr)
    thr = 0.95; 
end
[d1, d2, d3] = size(img);
contours = cell(d3, 1); 
for z=1:d3
    tmp_img = imfilter(img(:, :, z), fspecial('gaussian', 2,0.2));
    
    % threshold image
    v = sort(img(img>0), 'descend');
    vsum = cumsum(v);
    v_thr = v(find(vsum>vsum(end)*thr, 1));
    
    % cut the image into few components
    W = bwlabel(tmp_img>v_thr);
    nlabels = max(W(:));
    cont = cell(nlabels, 1);
    
    for label=1:nlabels
        img_i = tmp_img.*(W==label);
        
        % crop a small region for computing contours
        [tmp1, tmp2, ~] = find(img_i);
        if isempty(tmp1)
            cont{label} = [];
            continue;
        else
            rmin = max(1, min(tmp1)-3);
            rmax = min(d1, max(tmp1)+3);
            cmin = max(1, min(tmp2)-3);
            cmax = min(d2, max(tmp2)+3);
        end
        img_i = img_i(rmin:rmax, cmin:cmax);
        
        pvpairs = { 'LevelList' , v_thr*0.0001, 'ZData', img_i};
        h = matlab.graphics.chart.primitive.Contour(pvpairs{:});
        temp = h.ContourMatrix;
        if isempty(temp)
            cont{labels} = [];
        else
            temp(:, 1) = temp(:, 2);
            temp = medfilt1(temp')';
            temp(:, 1) = temp(:, end);
            cont{label} = bsxfun(@plus, temp, [cmin-1; rmin-1]);
        end
        
    end
    contours{z} = cont; 
end