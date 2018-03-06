

classdef Mobile
    %% Mobile properties    
    properties
        ID; % Mobile ID
        type;%
        tag;
        throughput = 2*10^6; % Source bit rate (bit/s)
        coordinates; % Mobile's coordinates in a plane
        a_k; % Number of bit arrivals during frame "i-1"
        r_k; % Distance from AP 1
        q_k; % q_k(i) = maximum number of bits that can be transmitted on subcarrier "i"
        sinr;
        queue;%used for halfduplex simulations
        uplinkqueue; % Nbr of bits waiting for transmission
        downlinkqueue;
        buffer_occupancy; % Tracking of queue length: buffer_occupancy(i) is the queue length at the beginning 
        % of frame "i"
        transmitted_bits; % Nbr of already transmitted bits
        tx_bits; % Tracking of transmitted bits: Nbr of transmitted bits during frame "i"
        delay; % delay(i) = average waiting packet(bit) delay at the beginning of frame "i"
        late_tx_bits; % Nbr of bits/packets, whose delay have exceeded the threshold, transmitted during frame "i"
        PDOR; % Percentage of packets that do not meet the delay threshold in the total number of packets 
        % transmitted up to frame "i"
    end
    
    %% Mobile methods
    methods
        
        % Constructor
        function s = Mobile()
            global ID_counter AP_coordinates N_F S X t Y;
            s.ID = ID_counter;
           % M=[1 2];
           % k=M(randi(numel(M)));
           % if k == 1
              %  s.type = 'Uplink';
           % elseif k == 2
             %   s.type = 'Downlink';
           % end
            % % -8.5 <= i <= +8.5
            % i = 17*rand(1,1)-8.5;
            % % -8.5 <= j <= +8.5
            % j = 17*rand(1,1)-8.5;
            % Randomly generate a point inside a circle of radius 12 km
            [i j]=cirrdnPJ(0,0,0.12);
            s.coordinates = [i j];
            s.r_k = sqrt((i-AP_coordinates(1))^2+(j-AP_coordinates(2))^2);
            % max(r_k) = 12 km, given our radio model parameters, mobile "s" will have an average SNR of
            % -3.16 dB ==> will benefit from QPSK 1/8 (MCS with the lowest spectral efficiency)
            s.uplinkqueue = 0;
            s.downlinkqueue = 0;
            s.transmitted_bits = 0;
            s.queue = 0;
            s.tx_bits= zeros(1,N_F);
        end
        
        % Determine the maximum number of bits that mobile "s" can transmit on each subcarrier
        function s = nb_bits(s)
            if s.tag==0
            if strcmp(s.type,'Uplink')==1
               
            global  Distance N_sc P_emitted A betta sigma_2 S SIC X t Y isc;
             S = Distance;
             P_mobile = 0.005; %Value in watts
             %epsilon represents the value of the RSI considered small in
             %this simulation 
          
                
                A= 10^((Cost231extendedHataPassLossModel(s.r_k*10^3, 'urban',s.ID,t,isc))/10);
               % B = 1./(s.r_k^betta);
                BS_antenna_gain= 10^1.5;
                UE_antenna_gain= 10^0.1;
                SIC = 10^11;
                SNR= 10*log10((P_mobile*BS_antenna_gain*UE_antenna_gain*X(s.ID,t)./(A*(sigma_2+(P_emitted/SIC))))); % I_intra = 0 (OFDMA)
                s.sinr=(P_mobile*BS_antenna_gain*UE_antenna_gain*X(s.ID,t))./(A*(sigma_2+(P_emitted/SIC)));
                %SNR= 10*log10(P_emitted*A*X./(sigma_2*s.r_k^betta));
                % No other AP is considered in our network ==> I_inter = 0
                if (SNR<-5.1)
                    s.q_k =0;
                elseif (SNR<-2.9)
                    s.q_k = 0.25; % QPSK 1/8
                elseif (SNR < -1.7)
                    s.q_k = 0.4; % QPSK 1/5
                elseif (SNR < -1)
                    s.q_k = 0.5; % QPSK 1/4
                elseif (SNR < 2)
                    s.q_k = 0.66; % QPSK 1/3
                elseif (SNR < 4.3)
                    s.q_k = 1; % QPSK 1/2
                elseif (SNR < 5.5)
                    s.q_k = 1.33; % QPSK 2/3
                elseif (SNR < 6.2)
                    s.q_k = 1.5; % QPSK 3/4
                elseif (SNR < 7.9)
                    s.q_k = 1.6; % QPSK 4/5
                elseif (SNR < 11.3)
                    s.q_k = 2; % 16-QAM 1/2
                elseif (SNR < 12.2)
                    s.q_k = 2.66; % 16-QAM 2/3
                elseif (SNR < 12.8)
                    s.q_k = 3; % 16-QAM 3/4
                elseif (SNR < 15.3)
                    s.q_k = 3.2; % 16-QAM 4/5
                elseif (SNR < 17.5)
                    s.q_k = 4; % 64-QAM 2/3
                elseif (SNR < 18.6)
                    s.q_k = 4.5; % 64-QAM 3/4
                else
                    s.q_k = 4.8; % 64-QAM 4/5
                end
           
            end
            if strcmp(s.type,'Downlink')==1
                    
            global N_sc P_emitted A betta sigma_2 S Distance X t Y isc;
           
                S = Distance; 
                %B = 1./(s.r_k^betta); 
                P_mobile = 0.005;
                C= 10^((Cost231extendedHataPassLossModel(s.r_k*10^3, 'urban',s.ID,t,isc))/10);
                D = 10^((Cost231extendedHataPassLossModel(S*10^3, 'urban',s.ID,t,isc))/10);
                BS_antenna_gain= 10^1.5;
                UE_antenna_gain= 10^0.1;
                SNR= 10*log10((P_emitted*BS_antenna_gain*UE_antenna_gain*X(s.ID,t)./C)./(sigma_2+ (P_mobile*UE_antenna_gain*UE_antenna_gain*Y(s.ID,t)./D)));
                s.sinr=(P_emitted*BS_antenna_gain*UE_antenna_gain*X(s.ID,t)./C)./(sigma_2+ (P_mobile*UE_antenna_gain*UE_antenna_gain*Y(s.ID,t)./D));
               % SNR= 10*log10(P_emitted*A*X./(sigma_2*s.r_k^betta));
                % No other AP is considered in our network ==> I_inter = 0
               if (SNR<-5.1)
                    s.q_k =0;
                elseif (SNR<-2.9)
                    s.q_k = 0.25; % QPSK 1/8
                elseif (SNR < -1.7)
                    s.q_k = 0.4; % QPSK 1/5
                elseif (SNR < -1)
                    s.q_k = 0.5; % QPSK 1/4
                elseif (SNR < 2)
                    s.q_k = 0.66; % QPSK 1/3
                elseif (SNR < 4.3)
                    s.q_k = 1; % QPSK 1/2
                elseif (SNR < 5.5)
                    s.q_k = 1.33; % QPSK 2/3
                elseif (SNR < 6.2)
                    s.q_k = 1.5; % QPSK 3/4
                elseif (SNR < 7.9)
                    s.q_k = 1.6; % QPSK 4/5
                elseif (SNR < 11.3)
                    s.q_k = 2; % 16-QAM 1/2
                elseif (SNR < 12.2)
                    s.q_k = 2.66; % 16-QAM 2/3
                elseif (SNR < 12.8)
                    s.q_k = 3; % 16-QAM 3/4
                elseif (SNR < 15.3)
                    s.q_k = 3.2; % 16-QAM 4/5
                elseif (SNR < 17.5)
                    s.q_k = 4; % 64-QAM 2/3
                elseif (SNR < 18.6)
                    s.q_k = 4.5; % 64-QAM 3/4
                else
                    s.q_k = 4.8; % 64-QAM 4/5
                end
            
            end
            end
       %-----------------------------------
        global N_sc P_emitted A betta sigma_2 S Distance X t Y isc;
       if s.tag==1
            if strcmp(s.type,'Downlink')==1
            
                A= 10^((Cost231extendedHataPassLossModel(s.r_k*10^3, 'urban',s.ID,t,isc))/10);
                
                BS_antenna_gain= 10^1.5;
                UE_antenna_gain= 10^0.1;
                
                SNR= 10*log10(P_emitted*BS_antenna_gain*UE_antenna_gain*X(s.ID,t)./(sigma_2*A)); % I_intra = 0 (OFDMA)
                s.sinr=(P_emitted*BS_antenna_gain*UE_antenna_gain*X(s.ID,t))./(sigma_2*A);
                % No other AP is considered in our network ==> I_inter = 0
                if (SNR<-5.1)
                    s.q_k =0;
                elseif (SNR<-2.9)
                    s.q_k = 0.25; % QPSK 1/8
                elseif (SNR < -1.7)
                    s.q_k = 0.4; % QPSK 1/5
                elseif (SNR < -1)
                    s.q_k = 0.5; % QPSK 1/4
                elseif (SNR < 2)
                    s.q_k = 0.66; % QPSK 1/3
                elseif (SNR < 4.3)
                    s.q_k = 1; % QPSK 1/2
                elseif (SNR < 5.5)
                    s.q_k = 1.33; % QPSK 2/3
                elseif (SNR < 6.2)
                    s.q_k = 1.5; % QPSK 3/4
                elseif (SNR < 7.9)
                    s.q_k = 1.6; % QPSK 4/5
                elseif (SNR < 11.3)
                    s.q_k = 2; % 16-QAM 1/2
                elseif (SNR < 12.2)
                    s.q_k = 2.66; % 16-QAM 2/3
                elseif (SNR < 12.8)
                    s.q_k = 3; % 16-QAM 3/4
                elseif (SNR < 15.3)
                    s.q_k = 3.2; % 16-QAM 4/5
                elseif (SNR < 17.5)
                    s.q_k = 4; % 64-QAM 2/3
                elseif (SNR < 18.6)
                    s.q_k = 4.5; % 64-QAM 3/4
                else
                    s.q_k = 4.8; % 64-QAM 4/5
                end
            
            end
       if strcmp(s.type,'Uplink')==1
            
                A= 10^((Cost231extendedHataPassLossModel(s.r_k*10^3, 'urban',s.ID,t,isc))/10);
                
                BS_antenna_gain= 10^1.5;
                UE_antenna_gain= 10^0.1;
                
                SNR= 10*log10(0.005*BS_antenna_gain*UE_antenna_gain*X(s.ID,t)./(sigma_2*A))+7;% I_intra = 0 (OFDMA)
                s.sinr=(0.005*BS_antenna_gain*UE_antenna_gain*X(s.ID,t))./(sigma_2*A)+7;
                % No other AP is considered in our network ==> I_inter = 0
                if (SNR<-5.1)
                    s.q_k =0;
                elseif (SNR<-2.9)
                    s.q_k = 0.25; % QPSK 1/8
                elseif (SNR < -1.7)
                    s.q_k = 0.4; % QPSK 1/5
                elseif (SNR < -1)
                    s.q_k = 0.5; % QPSK 1/4
                elseif (SNR < 2)
                    s.q_k = 0.66; % QPSK 1/3
                elseif (SNR < 4.3)
                    s.q_k = 1; % QPSK 1/2
                elseif (SNR < 5.5)
                    s.q_k = 1.33; % QPSK 2/3
                elseif (SNR < 6.2)
                    s.q_k = 1.5; % QPSK 3/4
                elseif (SNR < 7.9)
                    s.q_k = 1.6; % QPSK 4/5
                elseif (SNR < 11.3)
                    s.q_k = 2; % 16-QAM 1/2
                elseif (SNR < 12.2)
                    s.q_k = 2.66; % 16-QAM 2/3
                elseif (SNR < 12.8)
                    s.q_k = 3; % 16-QAM 3/4
                elseif (SNR < 15.3)
                    s.q_k = 3.2; % 16-QAM 4/5
                elseif (SNR < 17.5)
                    s.q_k = 4; % 64-QAM 2/3
                elseif (SNR < 18.6)
                    s.q_k = 4.5; % 64-QAM 3/4
                else
                    s.q_k = 4.8; % 64-QAM 4/5
                end
             
       end
       end
        end         
        % Destructor
        function Delete(s)  
        end     
    end
   
end
