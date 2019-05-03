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
voxel_em = reshape(options.voxel_em, 1,[]);    % em resolution during the voxelization
dims_2p = options.dims_2p;      % dimension of the 2p space
range_2p = options.range_2p;    % spatial range of the 2p space
voxels_2p = reshape(range_2p./dims_2p, 1, []);    %2p resolution
res_factor = 3;         % use a higher resolution before doing downsampling
A = options.A;          % transformation matrix between EM space and 2p space . y_2p = A*y_em + offset;
offset = options.offset;
scale_factor = options.scale_factor;  % scaling the EM coordinates.
if isfield(options, 'use_parallel')     % do parallel processing or not
    use_parallel = options.use_parallel;
else
    use_parallel = true;
end
if isempty(faces)       % empty input. return.
    subs_2p = zeros(0, 3);
    V = 0;
    return;
end

%% voxelize mesh surfaces
if iscell(vertices)   % vertices is saved as multiple small fragments.
    nz_voxels = cell(length(vertices), 1);
    if use_parallel
        parfor seg_id = 1:length(vertices)
            % convert the coordinates from EM space to 2p space
            tmp_vert = bsxfun(@plus, vertices{seg_id} * scale_factor * A, offset);
            
            % voxelize these coordinates at the resolution of voxel_em
            tmp_vert = bsxfun(@times, tmp_vert, reshape(1./voxel_em, 1, []));
            
            % translate the volume and determine the volume range
            vert_0 = min(tmp_vert);
            tmp_vert = bsxfun(@minus, tmp_vert, vert_0);
            vert_range = ceil(max(tmp_vert))+1;
            
            % voxelize the mesh
            FV = struct('vertices', tmp_vert, 'faces', faces{seg_id} + 1);
            tmp_V = polygon2voxel(FV, vert_range, 'none', false);
            
            %% determine the xyz locations of nonzero voxels
            ind = find(tmp_V);
            if isempty(ind)  % the segment is too small.
                nz_voxels{seg_id} = single([]);
            else
                [x, y, z] = ind2sub(size(tmp_V), ind);
                
                % upsample the results
                temp = bsxfun(@plus, [x, y, z]-1, vert_0);
                nz_voxels{seg_id} = round(bsxfun(@times, temp, (voxel_em./voxels_2p)*res_factor)) + 1;
            end
        end
    else
        for seg_id = 1:length(vertices)
            % convert the coordinates from EM space to 2p space
            tmp_vert = bsxfun(@plus, vertices{seg_id} * scale_factor * A, offset);
            
            % voxelize these coordinates at the resolution of voxel_em
            tmp_vert = bsxfun(@times, tmp_vert, reshape(1./voxel_em, 1, []));
            
            % translate the volume and determine the volume range
            vert_0 = min(tmp_vert);
            tmp_vert = bsxfun(@minus, tmp_vert, vert_0);
            vert_range = ceil(max(tmp_vert))+1;
            
            % voxelize the mesh
            FV = struct('vertices', tmp_vert, 'faces', faces{seg_id} + 1);
            tmp_V = polygon2voxel(FV, vert_range, 'none', false);
            
            %% determine the xyz locations of nonzero voxels
            ind = find(tmp_V);
            if isempty(ind)  % the segment is too small.
                nz_voxels{seg_id} = single([]);
            else
                [x, y, z] = ind2sub(size(tmp_V), ind);
                
                % upsample the results
                temp = bsxfun(@plus, [x, y, z]-1, vert_0);
                nz_voxels{seg_id} = round(bsxfun(@times, temp, (voxel_em./voxels_2p)*res_factor)) + 1;
            end
        end
    end
    % xyz positions of all nonzero voxels
    subs = cell2mat(nz_voxels);
    
    if isempty(subs)
        subs_2p = zeros(0, 3);
        V = [];
        return;
    end
else
    % convert the coordinates from EM space to 2p space
    tmp_vert = bsxfun(@plus, vertices * scale_factor * A, offset);
    
    % voxelize these coordinates at the resolution of voxel_em
    tmp_vert = bsxfun(@times, tmp_vert, reshape(1./voxel_em, 1, []));
    
    % translate the volume and determine the volume range
    vert_0 = min(tmp_vert);
    tmp_vert = bsxfun(@minus, tmp_vert, vert_0);
    vert_range = ceil(max(tmp_vert))+1;
    
    % voxelize the mesh
    FV = struct('vertices', tmp_vert, 'faces', faces + 1);
    tmp_V = polygon2voxel(FV, vert_range, 'none', false);
    
    %% determine the xyz locations of nonzero voxels
    ind = find(tmp_V);
    if isempty(ind)  % the segment is too small.
        subs_2p = zeros(0, 3);
        V = [];
        return;
    end
    [x, y, z] = ind2sub(size(tmp_V), ind);
    
    % upsample the results
    temp = bsxfun(@plus, [x, y, z]-1, vert_0);
    subs = round(bsxfun(@times, temp, (voxel_em./voxels_2p)*res_factor)) + 1;
end
%% create a small volume for filling the empty holes

volume_size = range(subs, 1)+1;
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