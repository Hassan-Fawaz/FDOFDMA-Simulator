global m_max load_inc N_sc N_TS N_F N_sim Frame_duration N_mob A betta AP_coordinates P_emitted sigma_2 m_delay mer;


N_mob = 20; % Nbr of active users m = 1*load_inc, 2*load_inc,... m_max*load_inc
N_sc = 50; % Nbr of resource blocks
% N_F = 1000; % Nbr of frames
N_F = 10; % Nbr of frames (TTI)
N_sim = 300; % Nbr of iterations
Frame_duration = 0.001; % The TTI duration is fixed to a value much smaller than the coherence time
P_emitted = 0.005; % Power emitted per RB by the BS (in W)
epsilon = 10^(-20.4);
sigma_2 = epsilon*180000; % Background noise
AP_coordinates = [0 0];
max_delay = 8*Frame_duration; % Packet delay constraint,
m_delay=floor(max_delay/Frame_duration);
