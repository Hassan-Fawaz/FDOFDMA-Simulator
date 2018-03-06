 
global m_max load_inc ID_counter N_sc N_TS N_F N_sim Frame_duration N_mob m_delay Distance S;
settings;
%This function empties temporary variables
for t=1:N_F
 for i=1:N_mob
      Mobile_user(i).a_k(t)=0;
      Mobile_user(i).transmitted_bits=0;
      Mobile_user(i).tx_bits(t)=0;
      Mobile_user(i).late_tx_bits(t)=0;
      Mobile_user(i).uplinkqueue=0;
      Mobile_user(i).downlinkqueue=0;
      Mobile_user(i).buffer_occupancy(t)=0;
      Mobile_user(i).delay(t)=0;
      isc=0;
 
 end
   end