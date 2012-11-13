function w = batch1_plot_omegas(omega)

    % Get rid of cells of omega.
    dims = size(omega); 
    for k = 1 : numel(omega)
        w(k) = omega{k};
    end

    plot(real(w(:)))
