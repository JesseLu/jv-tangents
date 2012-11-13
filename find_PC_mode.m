function [omega, E, H, err] = find_PC_mode(cname, num_nodes, epsilon, omega, pol)

[my_sim, my_eig, omega, J] = simulate_pc(cname, num_nodes, omega, epsilon, pol);
[E, H, err] = my_sim(omega, J);  
[omega, E, H, err] = my_eig(E);
[my_sim, my_eig, omega, J] = simulate_pc(cname, num_nodes, real(omega), epsilon, pol);
[omega, E, H, err] = my_eig(E);


