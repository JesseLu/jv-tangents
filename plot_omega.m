function plot_omega(t, r, pol, omega, E0)

    t_uniq = unique(t);
    r_uniq = unique(r);
    p_uniq = unique(pol);

    for k = 1 : length(t_uniq)
        for l = 1 : length(r_uniq)
            w = reshape(select_data(t, r, pol, omega, [t_uniq(k), r_uniq(l), nan]), [5 2]); 
            E = reshape(select_data(t, r, pol, E0, [t_uniq(k), r_uniq(l), nan]), [5 2]); 
           
            subplot(3, 1, 1); plot(real(w), '.-')
            title(['t: ', num2str(t_uniq(k)), ', r: ', num2str(r_uniq(l))]);

            for m = 1:5
                for n = 1:2
                    subplot(3, 5, n*5 + m); imagesc(real(E{m, n}{n+1}(:,:,20))'); axis equal tight;
                    title(sprintf('%1.2e + i %1.2e', real(w(m,n)), imag(w(m,n))));
                end
            end
            pause
        end
    end

