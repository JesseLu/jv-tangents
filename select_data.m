function [sel_data] = select_data(t, r, pol, data, sel)

    params = {t, r, pol};
    ind = 1 : numel(t);
    for k = 1 : 3
        if ~isnan(sel(k))
            ind = intersect(ind, find(params{k} == sel(k)));
        end
    end
    
    sel_data = data(ind);

