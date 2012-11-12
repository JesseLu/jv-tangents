function [epsilon] = shifted_L3_structure (grid_size, t_slab, eps_slab, radius)
% Makes a slab with a single hole in the center.

eps_air = 1.0;
edge_len = 2.0;

% Make the slab and the hole
s = {[1 0 0 1e9 1e9 eps_slab], [0 0 0 radius eps_air]};

% Obtain the 2D epsilon arrays.
e = draw_structure(grid_size(1:2), s, edge_len);

% === Now, make the 2D structure into a 3D structure. ===
center = round(grid_size(3)/2);

% Create the slab. Be careful of offsets in the Yee grid, and smoothing.
offsets = [0 0 0.5];
for k = 1 : 3
    z = offsets(k) + [1 : grid_size(3)];

    % Make the weighting function.
    w = (t_slab/2 - abs(z - center)) / edge_len;
    w = 1 * (w > 0.5) + (w+0.5) .* ((w>-0.5) & (w <= 0.5));
    % plot(w, '.-'); pause;

    % Apply the weighting function.
    epsilon{k} = zeros(grid_size);
    for m = 1 : grid_size(3)
        epsilon{k}(:,:,m) = (1-w(m)) * eps_air + w(m) * e{k};
    end
end


% % Use this to step through the slices of the structure, for verification.
% for k = 1 : grid_size(3)
%     for cnt = 1 : 3
%         subplot (1, 3, cnt)
%         imagesc (epsilon{cnt}(:,:,k)', [1, 12.25]);
%         colormap('gray');
%         title(num2str(k));
%         set (gca, 'YDir', 'normal');
%         axis equal tight;
%     end
%     pause
% end
