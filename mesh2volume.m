function [subs_2p, V] = mesh2volume(vertices, faces, options)
%% function goal
%{
	details
%}

%% inputs
%{
    vertices: M*3 matrix, locations of vertices (x, y, z)
    faces: N*3 matrix, indices of vertices formulating a triangle
    options: struct variable with the following fields
        voxel_em: em resolution for voxelization
        dims_2p: dimension of 2p imaging (d1, d2, d3)
        range_2p: spatial range of 2p imaging (l1, l2, l3)
        A, offset: 3*3 matrix & 1*3 vector, transform em coordinates to 2p
            coordinates Y_em*A + offset
        scale_factor: double, scale the EM coordinates because of some
            error in the preprocessing step
%}

%% outputs
%{
    subs_2p:  k*3 matrix, the indices for the voxels in 2p space
    V:        3D matrix of the voxelized component
%}

%% Author
%{
	Pengcheng Zhou
	Columbia Unviersity, 2019
	zhoupc2018@gmail.com
	XXX License
%}

%% parameters
voxel_em = options.voxel_em;    %em resolution
dims_2p = options.dims_2p;
range_2p = options.range_2p;
voxels_2p = range_2p./dims_2p;    %2p resolution
res_factor = 3;     % use a higher resolution before downsampling
A = options.A;
offset = options.offset;
scale_factor = options.scale_factor;
if isfield(options, 'use_parallel')
    use_parallel = options.use_parallel;
else
    use_parallel = true;
end
if isempty(faces)
    subs_2p = zeros(0, 3);
    V = 0;
    return;
end

%% voxelize mesh surfaces
if iscell(vertices)
    nz_voxels = cell(1, length(vertices));
    if use_parallel
        parfor seg_id = 1:length(vertices)
            % convert the coordinates from EM space to 2p space
            tmp_vert = bsxfun(@plus, vertices{seg_id} * scale_factor * A, offset);
            
            % the starting point
            vert_0 = min(tmp_vert);
            vert_range = max(tmp_vert)-vert_0+1;
            
            % voxelize
            FV = struct('vertices', bsxfun(@minus, tmp_vert, vert_0), ...
                'faces', faces{seg_id} + 1);
            tmp_V = polygon2voxel(FV, round(vert_range./voxel_em), 'auto', false);
            
            %% determine the xyz locations of nonzero voxels
            ind = find(tmp_V);
            [x, y, z] = ind2sub(size(tmp_V), ind);
            temp = bsxfun(@times, [x, y, z]-1, voxel_em);
            nz_voxels{seg_id} = bsxfun(@plus, temp', vert_0');
        end
    else
        for seg_id = 1:length(vertices)
            % convert the coordinates from EM space to 2p space
            tmp_vert = bsxfun(@plus, vertices{seg_id} * scale_factor * A, offset);
            
            % the starting point
            vert_0 = min(tmp_vert);
            vert_range = max(tmp_vert)-vert_0+1;
            
            % voxelize
            FV = struct('vertices', bsxfun(@minus, tmp_vert, vert_0), ...
                'faces', faces{seg_id} + 1);
            tmp_V = polygon2voxel(FV, round(vert_range./voxel_em), 'auto', false);
            
            %% determine the xyz locations of nonzero voxels
            ind = find(tmp_V);
            [x, y, z] = ind2sub(size(tmp_V), ind);
            temp = bsxfun(@times, [x, y, z]-1, voxel_em);
            nz_voxels{seg_id} = bsxfun(@plus, temp', vert_0');
        end
    end
    % xyz positions of all nonzero voxels
    subs = round(bsxfun(@times, cell2mat(nz_voxels), res_factor./voxels_2p')') + 1;
else
    % convert the coordinates from EM space to 2p space
    tmp_vert = bsxfun(@plus, vertices * scale_factor * A, offset);
    
    % the starting point
    vert_0 = min(tmp_vert);
    vert_range = max(tmp_vert)-vert_0+1;
    
    % voxelize
    FV = struct('vertices', bsxfun(@minus, tmp_vert, vert_0), ...
        'faces', faces + 1);
    tmp_V = polygon2voxel(FV, round(vert_range./voxel_em), 'auto', false);
    
    %% determine the xyz locations of nonzero voxels
    ind = find(tmp_V);
    [x, y, z] = ind2sub(size(tmp_V), ind);
    temp = bsxfun(@times, [x, y, z]-1, voxel_em);
    % xyz positions of all nonzero voxels
    subs = round(bsxfun(@times, bsxfun(@plus, temp', vert_0'), ...
        res_factor./voxels_2p')') + 1;
end

%% create a small volume for filling the empty holes

volume_size = range(subs)+1;
subs_0 = min(subs, [],1);
idx_new = bsxfun(@minus, subs, subs_0)+1;

% get the indices of all nonzero voxels in the zoom-in space
ind_new = unique(sub2ind(volume_size, idx_new(:,1), idx_new(:,2), ...
    idx_new(:,3)));
V = false(volume_size);
V(ind_new) = true;

% dilate and fill
se = strel('sphere',1);
V_dilate = imdilate(V,se);
% V_dilate = V;

% find the axes with fewer planes and fill holes in those planes
[n, idx] = min(size(V));
for m=1:n
    if idx==1
        V(m,:, :) = imfill(squeeze(V_dilate(m, :, :)), 'hole');
    elseif idx==2
        V(:, m,:) = imfill(squeeze(V_dilate(:,m, :)), 'hole');
    else
        V(:, :, m) = imfill(squeeze(V_dilate(:, :, m)), 'hole');
    end
end

%% convert voxel locations to 2p locations
ind = find(V(:));
[x, y, z] = ind2sub(volume_size, ind);
temp = unique(floor(([x, y, z] + subs_0 -1)/res_factor)+1, 'rows');
subs_2p= zeros(size(temp));
subs_2p(:,1) = dims_2p(2) - temp(:,2) + 1;    % the first dimension is y
subs_2p(:,2) = temp(:,1);                   % second dimension is x
subs_2p(:,3) = dims_2p(3) - temp(:,3) +1 ;  % the third dimension is z