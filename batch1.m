
t = 8:2:12;
r = 4:3:13;
w = 0.08 : 0.04 : 0.24;
pol = 2:3;
[t, r, w, pol] = ndgrid(t, r, w, pol);

for k = 1 : numel(t)
    epsilon{k} = PC_structure([32 32 40], t(k), 12, r(k)); 
    [omega{k}, E{k}, H{k}, err{k}] = find_PC_mode('a', 1, epsilon{k}, w(k), pol(k))
end

