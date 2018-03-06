

global m_max load_inc ID_counter N_sc N_TS N_F N_sim Frame_duration N_mob m_delay Distance S t n isc;

Throughput_close_users = [];
    Throughput_far_users = [];
    Buffer_occupancy_close_users = [];
    Buffer_occupancy_far_users = [];
    Waiting_delay_close_users = [];
    Waiting_delay_far_users = [];
    PDOR_close_users = [];
    PDOR_far_users = [];
    %---------------------------------
    Throughput_uplink_users = [];
    Throughput_downlink_users = [];
    Buffer_occupancy_uplink_users = [];
    Buffer_occupancy_downlink_users = [];
    Waiting_delay_uplink_users = [];
    Waiting_delay_downlink_users = [];
    PDOR_uplink_users = [];
    PDOR_downlink_users = [];
    tester=0;
    free_subcarrier=0;
    MatchSinr=zeros(10,1);
    qi=0;
    qj=0;
    usersinr=[];
    numbsubcarrier=0;
    %--------------------------------
        for t=1:N_F
           z1=1;
          ArrSINR=[];  
            for i=1:N_mob
                % Determine, for each mobile, the current number of bits waiting for transmission
                Mobile_user(i).a_k(t)= poisson(Mobile_user(i).throughput, Frame_duration);
                if  strcmp(Mobile_user(i).type,'Uplink')==1
                Mobile_user(i).uplinkqueue = Mobile_user(i).uplinkqueue + Mobile_user(i).a_k(t);
                Mobile_user(i).buffer_occupancy(t)= Mobile_user(i).uplinkqueue;
                Mobile_user(i).delay(t)= Mobile_user(i).buffer_occupancy(t)/Mobile_user(i).throughput;
                end
                if  strcmp(Mobile_user(i).type,'Downlink')==1
                Mobile_user(i).downlinkqueue = Mobile_user(i).downlinkqueue + Mobile_user(i).a_k(t);
                Mobile_user(i).buffer_occupancy(t)= Mobile_user(i).downlinkqueue;
                Mobile_user(i).delay(t)= Mobile_user(i).buffer_occupancy(t)/Mobile_user(i).throughput;
                end
              
                  % Little's formula: Average delay = Average queue length / packet arrival rate
                % Although it looks intuitively reasonable, it is quite a remarkable result, as the relationship
                % is not influenced by the arrival process distribution, the service distribution, the service 
                % order, or practically anything else.  
                % Marking late bits/packets:
                % Before proceeding with the allocation algorithm, check whether some packets/bits have missed 
                % their deadline.
                % When less than max_delay (m_delay frames) have elapsed, no packet/bit has missed their 
                % deadlines ==> late_bits = 0;
                % Otherwise, compute the number of packets/bits that should have been transmitted before the
                % start of frame "i" to avoid missing their deadline, and compare it with the number of packets/
                % bits that have actually been transmitted before the start of frame "i".
                % We can deduce the number of late packets/bits (that have missed their deadline)
                % This reasoning is valid as long as packets are served according to a FIFO-based policy
                
                if (t >= m_delay)   
                    tx_before_t=0;
                    % tx_before_t = number of packets/bits mobile_user(i) should have transmitted before the 
                    % start of frame "t"
                    % Normally, tx_before_t is the sum of packet/bit arrivals from 0 till the start of frame 
                    % "t-m_delay+1"
                    for j=1:t-m_delay+1
                        tx_before_t = tx_before_t + Mobile_user(i).a_k(j);
                    end                   

                    % Compute the number of bits/packets waiting for transmission, but whose delay have exceeded
                    % the threshold
                    late_bits(i)= max(0,tx_before_t - Mobile_user(i).transmitted_bits);
                    % These are the first bits(paquets) to be transmitted for mobile_user(i)
                    % No packet/bit dropping ==> even late_bits(i) need to be transmitted
                else late_bits(i)=0;
                end
                
                % Determine, for each mobile, the maximum number of bits it can transmit on each subcarrier
                % Radio conditions vary each frame
               
            end
            
            % Repeat for each time slot
            
                %Repeat for all subcarriers
                for isc=1:N_sc
                    bitsPerSymbU = [];
                    bitsPerSymbD = [];
                    UserID1 = [];
                    UserID2 = [];
                    Sum = 0;
                    
                    
                    % Select the user that will benefit from subcarrier "i": the one with the highest SNR
                    for j=1:2:N_mob
                        for y=2:2:N_mob
                           
                      if  (strcmp(Mobile_user(j).type,'Uplink')==1 && strcmp(Mobile_user(y).type,'Downlink')==1)
                        if ((Mobile_user(j).uplinkqueue>0) && (Mobile_user(y).downlinkqueue>0)) % Mobile_user(j) compete for subcarrier "i", if in need
                           Mobile_user(j).tag=0;
                           Mobile_user(y).tag=0;
                            coor1 = Mobile_user(j).coordinates;
                            coor2 = Mobile_user(y).coordinates;
                            Distance = sqrt((coor1(1)-coor2(1))^2+(coor1(2)-coor2(2))^2);
                            Mobile_user(j)=nb_bits(Mobile_user(j));
                            Mobile_user(y)=nb_bits(Mobile_user(y));
                            ArrSINR(z1)=log2(1+Mobile_user(j).sinr)+log2(1+Mobile_user(y).sinr);
                            TUm(z1)=84*Mobile_user(j).q_k;  %Uplink users capability vector
                            TDm(z1)=84*Mobile_user(y).q_k; %Downlimk users capability vector
                            z1=z1+1;
                           
                        end
                      end
                     
                     
                     
                        end
                    end
           
           
                 
                  
                end  
               
            
%---------------------------------------Set of demands for uplink  and downlink users----------------------------
for i7=1:2:N_mob
    Dut(i7)=Mobile_user(i7).uplinkqueue;
end
count=1;
for ir=1:N_mob-1
    if Dut(ir)~=0
        Du(count)=Dut(ir);
        count=count+1;
        if ir==N_mob
            break;
        end
    end
end
for i8=2:2:N_mob
    Ddt(i8)=Mobile_user(i8).downlinkqueue;
end
count=1;
for ir=1:N_mob
    if Ddt(ir)~=0
        Dd(count)=Ddt(ir);
        count=count+1;
        if ir==N_mob-1
            break;
        end
    end
end
%---------------------------------------------------FILL SINR Array-------------------------------------------------
z2=1;
for ia=1:N_sc
    for ib=1:N_mob/2
        for ic=1:N_mob/2
            SINR(ib,ic,ia)=ArrSINR(z2);
            z2=z2+1;
        end
    end
end
%-------------------------FILL TU and TD---------------------
z3=1;
for ia=1:N_sc
    for ib=1:N_mob/2
        for ic=1:N_mob/2
            TU(ib,ic,ia)=TUm(z3);
            z3=z3+1;
        end
    end
end

z4=1;
for ia=1:N_sc
    for ib=1:N_mob/2
        for ic=1:N_mob/2
            TD(ib,ic,ia)=TDm(z4);
            z4=z4+1;
        end
    end
end

%------------------------------------------------------
xp=1;
cvx_begin
cvx_solver mosek
variable z(N_mob/2,N_mob/2,N_sc) binary
expression objective
objective=sum(sum(sum(z.*SINR)));
maximize (objective)
subject to
for n1=1:N_sc
    sum(sum(z(:,:,n1)))<=1; 
end
for ib=1:N_mob/2
    xp*sum(sum(z(ib,:,:).*TU(ib,:,:)))<=Du(ib);
end
for ic=1:N_mob/2
    xp*sum(sum(z(:,ic,:).*TD(:,ic,:)))<=Dd(ic);
end
cvx_end
I = 0;
J = 0;
q_I = 0;
q_J = 0;

for isc=1:N_sc
   for ib=1:N_mob/2
       for ic=1:N_mob/2
         if round(z(ib,ic,isc))==1
             numbsubcarrier=numbsubcarrier+1;
            if ib==1
                I=1;
            elseif ib==2
                I=3;
            elseif ib==3
                I=5;
            elseif ib==4
                I=7;
            elseif ib==5
                I=9;
            end
            if ic==1
                J=2;
            elseif ic==2
                J=4;
            elseif ic==3
                J=6;
            elseif ic==4
                J=8;
            elseif ic==5
                J=10;
            end

 
Mobile_user(I).tag=0;
Mobile_user(J).tag=0;
coor1 = Mobile_user(I).coordinates;
coor2 = Mobile_user(J).coordinates;
Distance = sqrt((coor1(1)-coor2(1))^2+(coor1(2)-coor2(2))^2);                    
 Mobile_user(I)=nb_bits(Mobile_user(I));
 Mobile_user(J)=nb_bits(Mobile_user(J));
 MatchSinr(t)=MatchSinr(t)+Mobile_user(I).sinr+Mobile_user(J).sinr;
 New_entry=Mobile_user(I).sinr;
 usersinr= [usersinr New_entry];
 New_entry=Mobile_user(J).sinr;
 usersinr= [usersinr New_entry];
 q_I = 84*Mobile_user(I).q_k;
 q_J = 84*Mobile_user(J).q_k;
 
if q_I>0                         
Mobile_user(I).tx_bits(t) = Mobile_user(I).tx_bits(t) + min(Mobile_user(I).uplinkqueue,q_I);
Mobile_user(I).transmitted_bits = Mobile_user(I).transmitted_bits + min(Mobile_user(I).uplinkqueue,q_I);
Mobile_user(I).uplinkqueue = Mobile_user(I).uplinkqueue - min(Mobile_user(I).uplinkqueue,q_I);
qi=qi+1;
end

if q_J>0
Mobile_user(J).tx_bits(t) = Mobile_user(J).tx_bits(t) + min(Mobile_user(J).downlinkqueue,q_J);
Mobile_user(J).transmitted_bits = Mobile_user(J).transmitted_bits + min(Mobile_user(J).downlinkqueue,q_J);
Mobile_user(J).downlinkqueue = Mobile_user(J).downlinkqueue - min(Mobile_user(J).downlinkqueue,q_J);
tester=tester+1;
qj=qj+1;
end
end
       end
   end
end
        
            for i=1:N_mob
                % Determine the number of packets/bits that have been transmitted during frame "i" althrough they
                % have missed their deadline
                Mobile_user(i).late_tx_bits(t)= min(late_bits(i),Mobile_user(i).tx_bits(t));
                % Compute PDOR, defined as the percentage of packets that do not meet the delay requirement in the
                % total number of packets transmitted up to frame "i"
                if Mobile_user(i).transmitted_bits ~= 0
                    Mobile_user(i).PDOR(t)=sum(Mobile_user(i).late_tx_bits)/Mobile_user(i).transmitted_bits;
                else Mobile_user(i).PDOR(t)=0;
                end
            end
        end    

        % The cell is decomposed into two rings: ring 1 contains users that are relatively close to the AP 
        % (their r_k <= 0.5*(maximum distance), and ring 2 contains users that are at a distance r_k > 0.5 *
        % (maximum distance).
        % We take maximum distance = 12 km
        
        % Stats for iteration "n"
        N_close_users = 0;
        Tx_bits_close_users = 0;
        Cumulative_buffer_occupancy_close_users = 0;
        Cumulative_waiting_delay_close_users = 0;
        Cumulative_PDOR_close_users = 0;
        N_far_users = 0;
        Tx_bits_far_users = 0;
        Cumulative_buffer_occupancy_far_users = 0;
        Cumulative_waiting_delay_far_users = 0;
        Cumulative_PDOR_far_users = 0;
        %-----------------------------
         N_downlink_users = 0;
        Tx_bits_downlink_users = 0;
        Cumulative_buffer_occupancy_downlink_users = 0;
        Cumulative_waiting_delay_downlink_users = 0;
        Cumulative_PDOR_downlink_users = 0;
        N_uplink_users = 0;
        Tx_bits_uplink_users = 0;
        Cumulative_buffer_occupancy_uplink_users = 0;
        Cumulative_waiting_delay_uplink_users = 0;
        Cumulative_PDOR_uplink_users = 0;
        Transmittedbits = [];
        %------------------------------
         
       for i=1:N_mob
           Transmittedbits(i) =  Mobile_user(i).transmitted_bits;
       end
       for i=1:N_mob
             if strcmp(Mobile_user(i).type,'Downlink')==1
                 N_downlink_users = N_downlink_users +1;
                 Tx_bits_downlink_users = Tx_bits_downlink_users + Mobile_user(i).transmitted_bits;
                 Cumulative_buffer_occupancy_downlink_users = Cumulative_buffer_occupancy_downlink_users + mean(Mobile_user(i).buffer_occupancy);
                 Cumulative_waiting_delay_downlink_users = Cumulative_waiting_delay_downlink_users + mean(Mobile_user(i).delay);
                 Cumulative_PDOR_downlink_users = Cumulative_PDOR_downlink_users + mean(Mobile_user(i).PDOR);
             else N_uplink_users = N_uplink_users +1;
                 Tx_bits_uplink_users = Tx_bits_uplink_users + Mobile_user(i).transmitted_bits;
                 Cumulative_buffer_occupancy_uplink_users = Cumulative_buffer_occupancy_uplink_users + mean(Mobile_user(i).buffer_occupancy);
                 Cumulative_waiting_delay_uplink_users = Cumulative_waiting_delay_uplink_users + mean(Mobile_user(i).delay);
                 Cumulative_PDOR_uplink_users = Cumulative_PDOR_uplink_users + mean(Mobile_user(i).PDOR);
             end
        end
        for i=1:N_mob
            if (Mobile_user(i).r_k <= 6)
                N_close_users = N_close_users +1;
                Tx_bits_close_users = Tx_bits_close_users + Mobile_user(i).transmitted_bits;
                Cumulative_buffer_occupancy_close_users = Cumulative_buffer_occupancy_close_users + mean(Mobile_user(i).buffer_occupancy);
                Cumulative_waiting_delay_close_users = Cumulative_waiting_delay_close_users + mean(Mobile_user(i).delay);
                Cumulative_PDOR_close_users = Cumulative_PDOR_close_users + mean(Mobile_user(i).PDOR);
            else N_far_users = N_far_users +1;
                Tx_bits_far_users = Tx_bits_far_users + Mobile_user(i).transmitted_bits;
                Cumulative_buffer_occupancy_far_users = Cumulative_buffer_occupancy_far_users + mean(Mobile_user(i).buffer_occupancy);
                Cumulative_waiting_delay_far_users = Cumulative_waiting_delay_far_users + mean(Mobile_user(i).delay);
                Cumulative_PDOR_far_users = Cumulative_PDOR_far_users + mean(Mobile_user(i).PDOR);
            end
        end
        
        if N_close_users ~= 0
            New_entry = (Tx_bits_close_users*10^-3./N_close_users) / (N_F*Frame_duration); % in kb/s
            Throughput_close_users = [Throughput_close_users New_entry];
            New_entry = (Cumulative_buffer_occupancy_close_users) / N_close_users;
            Buffer_occupancy_close_users = [Buffer_occupancy_close_users New_entry];
            New_entry = (Cumulative_waiting_delay_close_users) / N_close_users;
            Waiting_delay_close_users = [Waiting_delay_close_users New_entry];
            New_entry = (Cumulative_PDOR_close_users)/ N_close_users;
            PDOR_close_users = [PDOR_close_users New_entry];
        end
        if N_far_users ~= 0
            New_entry = (Tx_bits_far_users*10^-3./N_far_users) / (N_F*Frame_duration); % in kb/s
            Throughput_far_users = [Throughput_far_users New_entry];
            New_entry = (Cumulative_buffer_occupancy_far_users) / N_far_users;
            Buffer_occupancy_far_users = [Buffer_occupancy_far_users New_entry];
            New_entry = (Cumulative_waiting_delay_far_users) / N_far_users;
            Waiting_delay_far_users = [Waiting_delay_far_users New_entry];
            New_entry = (Cumulative_PDOR_far_users)/ N_far_users;
            PDOR_far_users = [PDOR_far_users New_entry];
        end
        
        if N_uplink_users ~= 0
            New_entry = (Tx_bits_uplink_users*10^-3./N_uplink_users) / (N_F*Frame_duration); % in kb/s
            Throughput_uplink_users = [Throughput_uplink_users New_entry];
            New_entry = (Cumulative_buffer_occupancy_uplink_users) / N_uplink_users;
            Buffer_occupancy_uplink_users = [Buffer_occupancy_uplink_users New_entry];
            New_entry = (Cumulative_waiting_delay_uplink_users) / N_uplink_users;
            Waiting_delay_uplink_users = [Waiting_delay_uplink_users New_entry];
            New_entry = (Cumulative_PDOR_uplink_users)/ N_uplink_users;
            PDOR_uplink_users = [PDOR_uplink_users New_entry];
        end
        if N_downlink_users ~= 0
            New_entry = (Tx_bits_downlink_users*10^-3./N_downlink_users) / (N_F*Frame_duration); % in kb/s
            Throughput_downlink_users = [Throughput_downlink_users New_entry];
            New_entry = (Cumulative_buffer_occupancy_downlink_users) / N_downlink_users;
            Buffer_occupancy_downlink_users = [Buffer_occupancy_downlink_users New_entry];
            New_entry = (Cumulative_waiting_delay_downlink_users) / N_downlink_users;
            Waiting_delay_downlink_users = [Waiting_delay_downlink_users New_entry];
            New_entry = (Cumulative_PDOR_downlink_users)/ N_downlink_users;
            PDOR_downlink_users = [PDOR_downlink_users New_entry];
        end
        FThroughput_downlink_users(n)=Throughput_downlink_users;
        FThroughput_uplink_users(n)=Throughput_uplink_users;
        Throughput_all_users(n)= (Tx_bits_close_users+Tx_bits_far_users)*10^-3./(N_close_users+N_far_users) / (N_F*Frame_duration); % in kb/s
        Resource_utilization(n) = 100*(1 - free_subcarrier/ (N_F*N_TS*N_sc));
        Buffer_occupancy_all_users(n) = (Cumulative_buffer_occupancy_close_users+Cumulative_buffer_occupancy_far_users) / (N_close_users+N_far_users);
        Waiting_delay_all_users(n) = (Cumulative_waiting_delay_close_users+Cumulative_waiting_delay_far_users)/(N_close_users+N_far_users);
        PDOR_all_users(n) = (Cumulative_PDOR_close_users+Cumulative_PDOR_far_users)/(N_close_users+N_far_users);
 
