

global m_max load_inc ID_counter N_sc N_TS N_F N_sim Frame_duration N_mob m_delay Distance S t n isc ulid pUL1;

PCThroughput_close_users = [];
    PCThroughput_far_users = [];
    PCBuffer_occupancy_close_users = [];
    PCBuffer_occupancy_far_users = [];
    PCWaiting_delay_close_users = [];
    PCWaiting_delay_far_users = [];
    PCPDOR_close_users = [];
    PCPDOR_far_users = [];
    %---------------------------------
    PCThroughput_uplink_users = [];
    PCThroughput_downlink_users = [];
    PCBuffer_occupancy_uplink_users = [];
    PCBuffer_occupancy_downlink_users = [];
    PCWaiting_delay_uplink_users = [];
    PCWaiting_delay_downlink_users = [];
    PCPDOR_uplink_users = [];
    PCPDOR_downlink_users = [];
    PCtester=0;
    PCfree_subcarrier=0;
    MatchPriority=zeros(10,1);
    qi=0;
    qj=0;
    PCusersinr=[];
    PCnumbsubcarrier=0;
    NOPCusersinrUL=[];
   NOPCusersinrDL=[];
   PCusersinrUL=[];
   PCusersinrDL=[];
    %--------------------------------
        for t=1:N_F
             testsinr=0;
            pUL1=0.02*ones(5,30);
           z1=1;
          ArrPriority=[];  
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
               if t==1
                    AvBitsPerSymb(i)=1; % When scheduling the first frame transmissions, PF is equivalent to MaxSNR
                else AvBitsPerSymb(i)=Mobile_user(i).transmitted_bits/(N_TS*N_sc*(t-1));
                    if AvBitsPerSymb(i)==0;
                        AvBitsPerSymb(i)=1;
                    end
                end
            end
            
            % Repeat for each time slot
            for k=1:N_TS
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
                          if  strcmp(Mobile_user(j).type,'Uplink')==1 && strcmp(Mobile_user(y).type,'Downlink')==1
                              if (Mobile_user(j).uplinkqueue>0) && (Mobile_user(y).downlinkqueue>0) % Mobile_user(j) compete for subcarrier "i", if in need
                                  I1=Mobile_user(j).ID;
                                  J1=Mobile_user(y).ID;
                                  IDReplaceop;
                                  coor1 = Mobile_user(j).coordinates;
                                  coor2 = Mobile_user(y).coordinates;
                                  Distance = sqrt((coor1(1)-coor2(1))^2+(coor1(2)-coor2(2))^2);
                                  Mobile_user(j).tag=0;
                                  Mobile_user(y).tag=0;
                                  Mobile_user(j)=nb_bits(Mobile_user(j));
                                  Mobile_user(y)=nb_bits(Mobile_user(y));
                                  Sum = Mobile_user(j).q_k/AvBitsPerSymb(j)+ Mobile_user(y).q_k/AvBitsPerSymb(y);
                                  ArrPriority(z1)=Sum;
                                  TUm(z1)=84*Mobile_user(j).q_k;  %Uplink users capability vector
                                  TDm(z1)=84*Mobile_user(y).q_k; %Downlimk users capability vector
                                  z1=z1+1;
                              end
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
            Priority(ib,ic,ia)=ArrPriority(z2);
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
cvx_solver_settings('MSK_DPAR_MIO_MAX_TIME', 10)
variable z(N_mob/2,N_mob/2,N_sc) binary
expression objective
objective=sum(sum(sum(z.*Priority)));
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
W=z;
AllocatePower2;
% PowAll3;
if  (strcmp(cvx_status,'Failed')~=1 && strcmp(cvx_status,'Inaccurate/Infeasible')~=1 && strcmp(cvx_status,'Infeasible')~=1)

%test------------------
New_entry=cvx_optval;
withpctest=[withpctest New_entry];

%-----------------------------------
New_Entry=pUL;
PowerMatrix(:,:,t,n)=pUL;
for i=1:5
    for j=1:5
        for isc=1:N_sc
            if round(W(i,j,isc))==1
                ulid=i;
                dlid=j;
%----------------------------------- for test--------------------
% I=[];
% J=[];
% I1=[];
% J1=[];
% q_I=0;
% q_J=0;
% IDReplace2;
% Mobile_user(I).tag=0;
% Mobile_user(J).tag=0;
% coor1 = Mobile_user(I).coordinates;
% coor2 = Mobile_user(J).coordinates;
% Distance = sqrt((coor1(1)-coor2(1))^2+(coor1(2)-coor2(2))^2);    
% I1=I;
% J1=J;
%  Mobile_user(I)=nb_bits(Mobile_user(I));
%  Mobile_user(J)=nb_bits(Mobile_user(J));
% testsinr=testsinr+Mobile_user(I).sinr+Mobile_user(J).sinr;
% sumsinrnopc(t,n)=testsinr;
% New_entry=Mobile_user(I).sinr;
% NOPCusersinrUL= [NOPCusersinrUL New_entry];
%  New_entry=Mobile_user(J).sinr;
% NOPCusersinrDL= [NOPCusersinrDL New_entry];

%---------------------------------------------------------------------
                pUL1(i,isc)=pUL(i,isc);
                I=[];
                J=[];
                I1=[];
                J1=[];
                q_I=0;
                q_J=0;

  IDReplace2;              
                Mobile_user(I).tag=0;
Mobile_user(J).tag=0;
coor1 = Mobile_user(I).coordinates;
coor2 = Mobile_user(J).coordinates;
Distance = sqrt((coor1(1)-coor2(1))^2+(coor1(2)-coor2(2))^2);    
I1=I;
J1=J;
 Mobile_user(I)=nb_bits(Mobile_user(I));
 Mobile_user(J)=nb_bits(Mobile_user(J));
 F(port,1)=pUL(i,isc);
 F(port,2)=Mobile_user(I).sinr;
 F1(port,1)=pUL(i,isc);
 F1(port,2)=Mobile_user(J).sinr;
  port=port+1;
 New_entry=Mobile_user(I).sinr;
PCusersinrUL= [PCusersinrUL New_entry];
 New_entry=Mobile_user(J).sinr;
PCusersinrDL= [PCusersinrDL New_entry];
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

 
end
        % The cell is decomposed into two rings: ring 1 contains users that are relatively close to the AP 
        % (their r_k <= 0.5*(maximum distance), and ring 2 contains users that are at a distance r_k > 0.5 *
        % (maximum distance).
        % We take maximum distance = 12 km
        
        % Stats for iteration "n"
        PCN_close_users = 0;
        PCTx_bits_close_users = 0;
        PCCumulative_buffer_occupancy_close_users = 0;
        PCCumulative_waiting_delay_close_users = 0;
        PCCumulative_PDOR_close_users = 0;
        PCN_far_users = 0;
        PCTx_bits_far_users = 0;
        PCCumulative_buffer_occupancy_far_users = 0;
        PCCumulative_waiting_delay_far_users = 0;
        PCCumulative_PDOR_far_users = 0;
        %-----------------------------
         PCN_downlink_users = 0;
        PCTx_bits_downlink_users = 0;
        PCCumulative_buffer_occupancy_downlink_users = 0;
        PCCumulative_waiting_delay_downlink_users = 0;
        PCCumulative_PDOR_downlink_users = 0;
        PCN_uplink_users = 0;
        PCTx_bits_uplink_users = 0;
        PCCumulative_buffer_occupancy_uplink_users = 0;
        PCCumulative_waiting_delay_uplink_users = 0;
        PCCumulative_PDOR_uplink_users = 0;
        PCTransmittedbits = [];
        Fwithpc1=[];
        Fnopc=[];
        %------------------------------
         
       for i=1:N_mob
           PCTransmittedbits(i) =  Mobile_user(i).transmitted_bits;
       end
       for i=1:N_mob
             if strcmp(Mobile_user(i).type,'Downlink')==1
                 PCN_downlink_users = PCN_downlink_users +1;
                 PCTx_bits_downlink_users = PCTx_bits_downlink_users + Mobile_user(i).transmitted_bits;
                 PCCumulative_buffer_occupancy_downlink_users = PCCumulative_buffer_occupancy_downlink_users + mean(Mobile_user(i).buffer_occupancy);
                 PCCumulative_waiting_delay_downlink_users = PCCumulative_waiting_delay_downlink_users + mean(Mobile_user(i).delay);
                 PCCumulative_PDOR_downlink_users = PCCumulative_PDOR_downlink_users + mean(Mobile_user(i).PDOR);
             else PCN_uplink_users = PCN_uplink_users +1;
                 PCTx_bits_uplink_users = PCTx_bits_uplink_users + Mobile_user(i).transmitted_bits;
                 PCCumulative_buffer_occupancy_uplink_users = PCCumulative_buffer_occupancy_uplink_users + mean(Mobile_user(i).buffer_occupancy);
                 PCCumulative_waiting_delay_uplink_users = PCCumulative_waiting_delay_uplink_users + mean(Mobile_user(i).delay);
                 PCCumulative_PDOR_uplink_users = PCCumulative_PDOR_uplink_users + mean(Mobile_user(i).PDOR);
             end
        end
        for i=1:N_mob
            if (Mobile_user(i).r_k <= 6)
                PCN_close_users = PCN_close_users +1;
                PCTx_bits_close_users = PCTx_bits_close_users + Mobile_user(i).transmitted_bits;
                PCCumulative_buffer_occupancy_close_users = PCCumulative_buffer_occupancy_close_users + mean(Mobile_user(i).buffer_occupancy);
                PCCumulative_waiting_delay_close_users = PCCumulative_waiting_delay_close_users + mean(Mobile_user(i).delay);
                PCCumulative_PDOR_close_users = PCCumulative_PDOR_close_users + mean(Mobile_user(i).PDOR);
            else PCN_far_users = PCN_far_users +1;
                PCTx_bits_far_users = PCTx_bits_far_users + Mobile_user(i).transmitted_bits;
                PCCumulative_buffer_occupancy_far_users = PCCumulative_buffer_occupancy_far_users + mean(Mobile_user(i).buffer_occupancy);
                PCCumulative_waiting_delay_far_users = PCCumulative_waiting_delay_far_users + mean(Mobile_user(i).delay);
                PCCumulative_PDOR_far_users = PCCumulative_PDOR_far_users + mean(Mobile_user(i).PDOR);
            end
        end
        
        if PCN_close_users ~= 0
            New_entry = (PCTx_bits_close_users*10^-3./PCN_close_users) / (N_F*Frame_duration); % in kb/s
            PCThroughput_close_users = [PCThroughput_close_users New_entry];
            New_entry = (PCCumulative_buffer_occupancy_close_users) / PCN_close_users;
            PCBuffer_occupancy_close_users = [PCBuffer_occupancy_close_users New_entry];
            New_entry = (PCCumulative_waiting_delay_close_users) / PCN_close_users;
            PCWaiting_delay_close_users = [PCWaiting_delay_close_users New_entry];
            New_entry = (PCCumulative_PDOR_close_users)/ PCN_close_users;
            PCPDOR_close_users = [PCPDOR_close_users New_entry];
        end
        if PCN_far_users ~= 0
            New_entry = (PCTx_bits_far_users*10^-3./PCN_far_users) / (N_F*Frame_duration); % in kb/s
            PCThroughput_far_users = [PCThroughput_far_users New_entry];
            New_entry = (PCCumulative_buffer_occupancy_far_users) / PCN_far_users;
            PCBuffer_occupancy_far_users = [PCBuffer_occupancy_far_users New_entry];
            New_entry = (PCCumulative_waiting_delay_far_users) / PCN_far_users;
            PCWaiting_delay_far_users = [PCWaiting_delay_far_users New_entry];
            New_entry = (PCCumulative_PDOR_far_users)/ PCN_far_users;
            PCPDOR_far_users = [PCPDOR_far_users New_entry];
        end
        
        if PCN_uplink_users ~= 0
            New_entry = (PCTx_bits_uplink_users*10^-3./PCN_uplink_users) / (N_F*Frame_duration); % in kb/s
            PCThroughput_uplink_users = [PCThroughput_uplink_users New_entry];
            New_entry = (PCCumulative_buffer_occupancy_uplink_users) / PCN_uplink_users;
            PCBuffer_occupancy_uplink_users = [PCBuffer_occupancy_uplink_users New_entry];
            New_entry = (PCCumulative_waiting_delay_uplink_users) / PCN_uplink_users;
            PCWaiting_delay_uplink_users = [PCWaiting_delay_uplink_users New_entry];
            New_entry = (PCCumulative_PDOR_uplink_users)/ PCN_uplink_users;
            PCPDOR_uplink_users = [PCPDOR_uplink_users New_entry];
        end
        if PCN_downlink_users ~= 0
            New_entry = (PCTx_bits_downlink_users*10^-3./PCN_downlink_users) / (N_F*Frame_duration); % in kb/s
            PCThroughput_downlink_users = [PCThroughput_downlink_users New_entry];
            New_entry = (PCCumulative_buffer_occupancy_downlink_users) / PCN_downlink_users;
            PCBuffer_occupancy_downlink_users = [PCBuffer_occupancy_downlink_users New_entry];
            New_entry = (PCCumulative_waiting_delay_downlink_users) / PCN_downlink_users;
            PCWaiting_delay_downlink_users = [PCWaiting_delay_downlink_users New_entry];
            New_entry = (PCCumulative_PDOR_downlink_users)/ PCN_downlink_users;
            PCPDOR_downlink_users = [PCPDOR_downlink_users New_entry];
        end
        PCFThroughput_downlink_users(n)=PCThroughput_downlink_users;
        PCFThroughput_uplink_users(n)=PCThroughput_uplink_users;
        PCThroughput_all_users(n)= (PCTx_bits_close_users+PCTx_bits_far_users)*10^-3./(PCN_close_users+PCN_far_users) / (N_F*Frame_duration); % in kb/s
        PCResource_utilization(n) = 100*(1 - PCfree_subcarrier/ (N_F*N_TS*N_sc));
        PCBuffer_occupancy_all_users(n) = (PCCumulative_buffer_occupancy_close_users+PCCumulative_buffer_occupancy_far_users) / (PCN_close_users+PCN_far_users);
        PCWaiting_delay_all_users(n) = (PCCumulative_waiting_delay_close_users+PCCumulative_waiting_delay_far_users)/(PCN_close_users+PCN_far_users);
        PCPDOR_all_users(n) = (PCCumulative_PDOR_close_users+PCCumulative_PDOR_far_users)/(PCN_close_users+PCN_far_users);
        
     