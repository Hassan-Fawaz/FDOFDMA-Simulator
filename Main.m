

global m_max load_inc ID_counter N_sc N_TS N_F N_sim Frame_duration N_mob m_delay Distance S X Y shadowing n;
settings;


for n=1:N_sim

%--------------------------------Define radio conditions for each UE
shadowing=ones(20,10,N_sc);
for i=1:20
   for j=1:10
       for k=1:N_sc
       shadowing(i,j,k)= normrnd (0,10);
       while (shadowing(i,j,k) < 0 || shadowing(i,j,k) > 10)
       shadowing(i,j,k) = normrnd (0,10);
       end
   end
   end
end

X=ones(20,10);
for i=1:20
   for j=1:10
       X(i,j)= raylrnd(1);
   end
end
Y=ones(20,10);
for i=1:20
   for j=1:10
       Y(i,j)= raylrnd(1);
   end
end
%-------------------------------------------------------------------

        ID_counter = 0;
     
         for i=1:2:N_mob
            
            ID_counter = ID_counter + 1;
            Mobile_user(i)= Mobile();
            Mobile_user(i).type = 'Uplink';
            ID_counter = ID_counter + 1;
            Mobile_user(i+1)= Mobile();
            Mobile_user(i+1).type = 'Downlink';
         end

% FDMaxSumRate;%  run this algorithm    
OptimalMaxSumRate;


  
   fname = sprintf('Simulation%d.mat', n);
   save(fname) 
    end
    
   
%end