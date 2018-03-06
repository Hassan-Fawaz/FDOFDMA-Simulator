global m_max load_inc ID_counter N_sc N_TS N_F N_sim Frame_duration N_mob m_delay Distance S t n isc;

MSThroughput_close_users = [];
MSThroughput_far_users = [];
MSBuffer_occupancy_close_users = [];
MSBuffer_occupancy_far_users = [];
MSWaiting_delay_close_users = [];
MSWaiting_delay_far_users = [];
MSPDOR_close_users = [];
MSPDOR_far_users = [];
%---------------------------------
MSThroughput_uplink_users = [];
MSThroughput_downlink_users = [];
MSBuffer_occupancy_uplink_users = [];
MSBuffer_occupancy_downlink_users = [];
MSWaiting_delay_uplink_users = [];
MSWaiting_delay_downlink_users = [];
MSPDOR_uplink_users = [];
MSPDOR_downlink_users = [];
MSusersinr=[];
MSfree_subcarrier=0;
MSfullduplex=0;
MShalfduplex=0;
SumSINR=zeros(10,1);
MSusersinr=[];
%------------------------------------



    for t=1:N_F
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
                if (t >= m_delay)   
                    tx_before_t=0;
                   
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
                    I = [];
                    J = [];
                    q_I = 0;
                    q_J = 0;
                    Max = 0;
                    Sum = 0;
                    sinr_I=0;
                    sinr_j=0;
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
                                    Sum = (log2(1+Mobile_user(j).sinr) + log2(1+Mobile_user(y).sinr));
                                      if Sum > Max
                                      Max=Sum;
                                      I = Mobile_user(j).ID; %Store Uplink mobile ID
                                      J = Mobile_user(y).ID;% Store Downlink mobile ID
                                      q_I = 84*Mobile_user(j).q_k;
                                      q_J = 84*Mobile_user(y).q_k;
                                      sinr_I=Mobile_user(j).sinr;
                                      sinr_J=Mobile_user(y).sinr;
                                      end 
                                end
                              end
                        end
                    end
 %test for full duplex resource blocks            
if (isempty(I)~=1 && isempty(J)~=1)
   MSfullduplex=MSfullduplex+1;
end                   
%------------------------------------------------------                  
                    if isempty(I)==1
                        Sum=0;
                        Max=0;
                        q_I=0;
                        q_j=0;
                        for j=1:N_mob
                           if  strcmp(Mobile_user(j).type,'Uplink')==1  
                              if (Mobile_user(j).uplinkqueue>0)
                                  Mobile_user(j).tag=1;
                                  Mobile_user(j)=nb_bits(Mobile_user(j));
                                  Sum = log(Mobile_user(j).sinr);
                                    if Sum > Max
                                       Max=Sum;
                                       I = Mobile_user(j).ID; %Store Uplink mobile ID
                                       q_I = 84*Mobile_user(j).q_k;
                                       sinr_I=Mobile_user(j).sinr;
                                    end 
                               end
                           end
                           if strcmp(Mobile_user(j).type,'Downlink')==1
                             if (Mobile_user(j).downlinkqueue>0)
                                 Mobile_user(j).tag=1;
                                 Mobile_user(j)=nb_bits(Mobile_user(j));
                                 Sum = log(Mobile_user(j).sinr);
                                   if Sum > Max
                                      Max=Sum;
                                      J = Mobile_user(j).ID; %Store Uplink mobile ID
                                      q_J = 84*Mobile_user(j).q_k;
                                      sinr_I=Mobile_user(j).sinr;
                                   end 
                             end
                          end
                       end 
                    end
%test for half duplex resource blocks
if (isempty(I)~=1 && isempty(J)==1)
   MShalfduplex=MShalfduplex+1;
end    
if (isempty(I)==1 && isempty(J)==1)
   MSfree_subcarrier=MSfree_subcarrier+1;
end    
 
%                      New_Entry=Mobile_user(I).sinr + Mobile_user(J).sinr;
%                      SumSINR(t)=SumSINR(t)+New_Entry;
%                      New_entry=Mobile_user(I).sinr;
%                      MSusersinr= [MSusersinr New_entry];
%                      New_entry=Mobile_user(J).sinr;
%                      MSusersinr= [MSusersinr New_entry];
                    
                    if isempty(I)==1
                        % I is empty no need to schedule 
                    else
                        if q_I>0 
                            Mobile_user(I).tx_bits(t) = Mobile_user(I).tx_bits(t) + min(Mobile_user(I).uplinkqueue,q_I);
                        Mobile_user(I).transmitted_bits = Mobile_user(I).transmitted_bits + min(Mobile_user(I).uplinkqueue,q_I);
                    Mobile_user(I).uplinkqueue = Mobile_user(I).uplinkqueue - min(Mobile_user(I).uplinkqueue,q_I);
                        end
                    end
                    if isempty(J)==1
                        % J is empty no need to schedule 
                    else
                        if q_J>0
                        Mobile_user(J).tx_bits(t) = Mobile_user(J).tx_bits(t) + min(Mobile_user(J).downlinkqueue,q_J);
                        Mobile_user(J).transmitted_bits = Mobile_user(J).transmitted_bits + min(Mobile_user(J).downlinkqueue,q_J);
                    Mobile_user(J).downlinkqueue = Mobile_user(J).downlinkqueue - min(Mobile_user(J).downlinkqueue,q_J);
                        end
                    end
                  New_entry= sinr_I;
                if New_entry~=0 
                    MSusersinr=[MSusersinr New_entry];
                end
                New_entry= sinr_J;
                if New_entry~=0 
                    MSusersinr=[MSusersinr New_entry];
                end
                    
                end
%-------------------------------------------
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


MSN_close_users = 0;
MSTx_bits_close_users = 0;
MSCumulative_buffer_occupancy_close_users = 0;
MSCumulative_waiting_delay_close_users = 0;
MSCumulative_PDOR_close_users = 0;
MSN_far_users = 0;
MSTx_bits_far_users = 0;
MSCumulative_buffer_occupancy_far_users = 0;
MSCumulative_waiting_delay_far_users = 0;
MSCumulative_PDOR_far_users = 0;
%-----------------------------
MSN_downlink_users = 0;
MSTx_bits_downlink_users = 0;
MSCumulative_buffer_occupancy_downlink_users = 0;
MSCumulative_waiting_delay_downlink_users = 0;
MSCumulative_PDOR_downlink_users = 0;
MSN_uplink_users = 0;
MSTx_bits_uplink_users = 0;
MSCumulative_buffer_occupancy_uplink_users = 0;
MSCumulative_waiting_delay_uplink_users = 0;
MSCumulative_PDOR_uplink_users = 0;
MSTransmittedbits = [];
%------------------------------
         
 for i=1:N_mob
     MSTransmittedbits(i) =  Mobile_user(i).transmitted_bits;
 end
 for i=1:N_mob
     if strcmp(Mobile_user(i).type,'Downlink')==1
        MSN_downlink_users = MSN_downlink_users +1;
        MSTx_bits_downlink_users = MSTx_bits_downlink_users + Mobile_user(i).transmitted_bits;
        MSCumulative_buffer_occupancy_downlink_users = MSCumulative_buffer_occupancy_downlink_users + mean(Mobile_user(i).buffer_occupancy);
        MSCumulative_waiting_delay_downlink_users = MSCumulative_waiting_delay_downlink_users + mean(Mobile_user(i).delay);
        MSCumulative_PDOR_downlink_users = MSCumulative_PDOR_downlink_users + mean(Mobile_user(i).PDOR);
   else MSN_uplink_users = MSN_uplink_users +1;
        MSTx_bits_uplink_users = MSTx_bits_uplink_users + Mobile_user(i).transmitted_bits;
        MSCumulative_buffer_occupancy_uplink_users = MSCumulative_buffer_occupancy_uplink_users + mean(Mobile_user(i).buffer_occupancy);
        MSCumulative_waiting_delay_uplink_users = MSCumulative_waiting_delay_uplink_users + mean(Mobile_user(i).delay);
        MSCumulative_PDOR_uplink_users = MSCumulative_PDOR_uplink_users + mean(Mobile_user(i).PDOR);
    end
end
for i=1:N_mob
    if (Mobile_user(i).r_k <= 6)
        MSN_close_users = MSN_close_users +1;
        MSTx_bits_close_users = MSTx_bits_close_users + Mobile_user(i).transmitted_bits;
        MSCumulative_buffer_occupancy_close_users = MSCumulative_buffer_occupancy_close_users + mean(Mobile_user(i).buffer_occupancy);
        MSCumulative_waiting_delay_close_users = MSCumulative_waiting_delay_close_users + mean(Mobile_user(i).delay);
        MSCumulative_PDOR_close_users = MSCumulative_PDOR_close_users + mean(Mobile_user(i).PDOR);
   else MSN_far_users = MSN_far_users +1;
        MSTx_bits_far_users = MSTx_bits_far_users + Mobile_user(i).transmitted_bits;
        MSCumulative_buffer_occupancy_far_users = MSCumulative_buffer_occupancy_far_users + mean(Mobile_user(i).buffer_occupancy);
        MSCumulative_waiting_delay_far_users = MSCumulative_waiting_delay_far_users + mean(Mobile_user(i).delay);
        MSCumulative_PDOR_far_users = MSCumulative_PDOR_far_users + mean(Mobile_user(i).PDOR);
    end
end  
if MSN_close_users ~= 0
   New_entry = (MSTx_bits_close_users*10^-3./MSN_close_users) / (N_F*Frame_duration); % in kb/s
   MSThroughput_close_users = [MSThroughput_close_users New_entry];
   New_entry = (MSCumulative_buffer_occupancy_close_users) / MSN_close_users;
   MSBuffer_occupancy_close_users = [MSBuffer_occupancy_close_users New_entry];
   New_entry = (MSCumulative_waiting_delay_close_users) / MSN_close_users;
   MSWaiting_delay_close_users = [MSWaiting_delay_close_users New_entry];
   New_entry = (MSCumulative_PDOR_close_users)/ MSN_close_users;
   MSPDOR_close_users = [MSPDOR_close_users New_entry];
end
if MSN_far_users ~= 0
   New_entry = (MSTx_bits_far_users*10^-3./MSN_far_users) / (N_F*Frame_duration); % in kb/s
   MSThroughput_far_users = [MSThroughput_far_users New_entry];
   New_entry = (MSCumulative_buffer_occupancy_far_users) / MSN_far_users;
   MSBuffer_occupancy_far_users = [MSBuffer_occupancy_far_users New_entry];
   New_entry = (MSCumulative_waiting_delay_far_users) / MSN_far_users;
   MSWaiting_delay_far_users = [MSWaiting_delay_far_users New_entry];
   New_entry = (MSCumulative_PDOR_far_users)/ MSN_far_users;
   MSPDOR_far_users = [MSPDOR_far_users New_entry];
end
if MSN_uplink_users ~= 0
   New_entry = (MSTx_bits_uplink_users*10^-3./MSN_uplink_users) / (N_F*Frame_duration); % in kb/s
   MSThroughput_uplink_users = [MSThroughput_uplink_users New_entry];
   New_entry = (MSCumulative_buffer_occupancy_uplink_users) / MSN_uplink_users;
   MSBuffer_occupancy_uplink_users = [MSBuffer_occupancy_uplink_users New_entry];
   New_entry = (MSCumulative_waiting_delay_uplink_users) / MSN_uplink_users;
   MSWaiting_delay_uplink_users = [MSWaiting_delay_uplink_users New_entry];
   New_entry = (MSCumulative_PDOR_uplink_users)/ MSN_uplink_users;
   MSPDOR_uplink_users = [MSPDOR_uplink_users New_entry];
end
if MSN_downlink_users ~= 0
   New_entry = (MSTx_bits_downlink_users*10^-3./MSN_downlink_users) / (N_F*Frame_duration); % in kb/s
   MSThroughput_downlink_users = [MSThroughput_downlink_users New_entry];
   New_entry = (MSCumulative_buffer_occupancy_downlink_users) / MSN_downlink_users;
   MSBuffer_occupancy_downlink_users = [MSBuffer_occupancy_downlink_users New_entry];
   New_entry = (MSCumulative_waiting_delay_downlink_users) / MSN_downlink_users;
   MSWaiting_delay_downlink_users = [MSWaiting_delay_downlink_users New_entry];
   New_entry = (MSCumulative_PDOR_downlink_users)/ MSN_downlink_users;
   MSPDOR_downlink_users = [MSPDOR_downlink_users New_entry];
end
FMSThroughput_uplink_users(n)=MSThroughput_uplink_users;
FMSThroughput_downlink_users(n)=MSThroughput_downlink_users;
MSThroughput_all_users(n)= (MSTx_bits_close_users+MSTx_bits_far_users)*10^-3./(MSN_close_users+MSN_far_users) / (N_F*Frame_duration); % in kb/s
MSResource_utilization(n) = 100*(1 - MSfree_subcarrier/ (N_F*N_sc));
MSBuffer_occupancy_all_users(n) = (MSCumulative_buffer_occupancy_close_users+MSCumulative_buffer_occupancy_far_users) / (MSN_close_users+MSN_far_users);
MSWaiting_delay_all_users(n) = (MSCumulative_waiting_delay_close_users+MSCumulative_waiting_delay_far_users)/(MSN_close_users+MSN_far_users);
MSPDOR_all_users(n) = (MSCumulative_PDOR_close_users+MSCumulative_PDOR_far_users)/(MSN_close_users+MSN_far_users);
        