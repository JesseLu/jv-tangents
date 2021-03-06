function [omega, E, H, err] = pc_eig(eps, E_init, omega_guess)


    % Constants for the eigenmode solve routine.
    max_iters = 10;
    err_lim = 1e-6;

    % Do the initial simulation, to guess the eigenvector.
    [omega, d_prim, d_dual, s_prim, s_dual, mu, epsilon, E, J, sim] = ...
        initial_sim(omega_guess, epsilon, E_init);

    % Find the eigenmode.
    [omega, E, H, err] = eigenmode(sim, omega, E, ...
                                    d_prim, d_dual, s_prim, s_dual, ...
                                    mu, epsilon, ...
                                    max_iters, err_lim);

    % Print out final result.
    fprintf('Omega: %1.3e + i%1.3e\nErrors: %e (actual), %e (E), %e (H)\n', ...
            real(omega), imag(omega), err.actual, err.E, err.H);

function [omega, d_prim, d_dual, s_prim, s_dual, mu, epsilon, E, J, sim2] = ...
            initial_sim(base_omega, epsilon, J)

    dims = size(epsilon{1}); % Simulation size.
    
    % Create the grid.
    d = {ones(dims(1), 1), ones(dims(2), 1), ones(dims(3), 1)};
    d_prim = d;
    d_dual = d;
    [s_prim, s_dual] = make_scpml(omega, dims, 10/ds);
    % PML in z-direction only.
    for k = 1 : 2
        s_prim{k} = real(s_prim{k});
        s_prim{k} = real(s_prim{k});
    end

    mu = {ones(dims), ones(dims), ones(dims)}; 


    % Current source.
    % Excite the upper-left cavity.
    J = {zeros(dims), zeros(dims), zeros(dims)}; 
    c = ceil(dims/2);
    spr = unique(round([-4/ds:4/ds]));
    shift = -round([50, 15, 0] ./ ds);
    J{2}(c(1)+shift(1)+spr, c(2)+shift(2)+spr, c(3)+shift(3)+spr) = 1;


    % Run the initial simulation
    E = {zeros(dims), zeros(dims), zeros(dims)}; 
    sim = @(omega, J, E) my_sim(omega, d_prim, d_dual, s_prim, s_dual, ...
                        mu, epsilon, E, J, ...
                        1e6, 1e-6, 'plot', ...
                        2, round(dims(3)/2), 'armand_coupled_cavities');
    % TODO: Change viewoption to 'plot'.

    % Function handle for the eigenvalue finding function.
    sim2 = @(omega, J) sim(omega, J, E);
    subplot 321;
    % imagesc(epsilon{3}(:,:,round(dims(3)/2))'); axis equal tight;
    epj = epsilon{2} + J{2};
    imagesc(epj(:,:,round(dims(3)/2))'); axis equal tight;
    
    % Run the initial simulation.
    title('Initial simulation');
    [E, H, err] = sim2(omega, J);
    
    
    
%% Calculates s_prim and s_dual for a regularly spaced grid of dimension DIMS.
% Grid spacing assumed to be 1.
function [s_prim, s_dual] = make_scpml(omega, dims, t_pml)
    % Helper functions.
    pos = @(z) (z > 0) .* z; % Only take positive values.
    l = @(u, n) pos(t_pml - u) + pos(u - (n - t_pml)); % Distance to nearest pml boundary.

    % Compute the stretched-coordinate grid spacing values.
    for k = 1 : 3
        s_prim{k} = 1 - i * (4 / omega) * (l(0:dims(k)-1, dims(k)) / t_pml).^4;
        s_dual{k} = 1 - i * (4 / omega) * (l(0.5:dims(k)-0.5, dims(k)) / t_pml).^4;
    end


function [E, H, err] = my_sim(omega, d_prim, d_dual, s_prim, s_dual, ...
                                mu, epsilon, E0, J, ...
                                fds_max_iters, fds_err_lim, view_option, ...
                                E_index, E_loc, name)
    subplot 322;
    [E, H, err] = fds(omega, d_prim, d_dual, s_prim, s_dual, mu, epsilon, E0, J, ...
                        fds_max_iters, fds_err_lim, view_option);

    subplot(3,1,2:3);
    imagesc(imag(E{E_index}(:,:,E_loc)')); axis equal tight;

    subplot 321;
    drawnow
    saveas(gcf, [name, ' ', datestr(now, 'mm-dd-HH:MM:SS')], 'png')
