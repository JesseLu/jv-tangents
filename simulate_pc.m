function [my_solve, my_eigenmode, omega, J] = simulate_pc(cluster_name, num_nodes, omega, epsilon, J_comp)

    dims = size(epsilon{1}); % Simulation size.

    % PML in z-direction only.
    [d_prim, d_dual] = make_scpml(omega, dims, 10);
    for k = 1 : 2
        d_prim{k} = real(d_prim{k});
        d_dual{k} = real(d_dual{k});
    end

    % Create current source
    J = {zeros(dims), zeros(dims), zeros(dims)};
    % J{J_comp}(:,:,round(dims(3)/2)) = reshape(rand(dims(1), dims(2)), [dims(1), dims(2), 1]);
    J{J_comp}(:,:,round(dims(3)/2)) = 1;

    mu = {ones(dims), ones(dims), ones(dims)};
    E = {ones(dims), ones(dims), ones(dims)};

    % Function handle that can be used to solve.
    % [E, H, err, success] = maxwell.solve(cluster_name, num_nodes, omega, d_prim, d_dual, mu, epsilon, E, J, 1e5, 1e-6);
    my_solve = @(omega, J) organized_sim(cluster_name, num_nodes, omega, d_prim, d_dual, mu, epsilon, E, J, 1e5, 1e-6, J_comp);

    % Find the eigenmode.
%     [omega, E, H, err] = eigenmode(sim, omega, E, ...
%                                     d_prim, d_dual, s_prim, s_dual, ...
%                                     mu, epsilon, ...
%                                     max_iters, err_lim);
    my_eigenmode = @(E) eigenmode(my_solve, omega, E, ...
                                    d_prim, d_dual, ...
                                    mu, epsilon, ...
                                    10, 1e-6);


function [E, H, err] = organized_sim(cluster_name, num_nodes, ...
                                    omega, d_prim, d_dual, ...
                                    mu, epsilon, E, J, max_iters, err_thresh, ...
                                    E_index)

    colormap jet; 

    subplot 322;
    [E, H, err] = maxwell.solve(cluster_name, num_nodes, omega, d_prim, d_dual, ...
                    mu, epsilon, E, J, max_iters, err_thresh);

    dims = size(E{1});
    for k = 1 : 3
        subplot(3,3,k-1+4);
        imagesc(squeeze(abs(E{k}(:,:,round(dims(3)/2))))'); axis equal tight;
        subplot(3,3,k-1+7);
        imagesc(squeeze(abs(E{k}(:,round(dims(2)/2),:)))'); axis equal tight;
    end

    subplot 321;
    drawnow
