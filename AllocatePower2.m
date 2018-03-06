global isc P_emitted N_sc t m_max load_inc ID_counter  N_TS N_F N_sim Frame_duration N_mob m_delay Distance S X Y shadowing n;
nbreSub=N_sc;
BS_antenna_gain= 10^1.5;
UE_antenna_gain= 10^0.1;
SIC=10^14;
nbreUL=5;
nbreDL=5;
pDL=P_emitted;
cvx_begin gp
cvx_solver sedumi
variable pUL(nbreUL,N_sc);
expression SINR_UL(nbreUL,nbreDL,N_sc)
expression SINR_DL(nbreUL,nbreDL,N_sc)
expression objective

for i=1:nbreUL
    for j=1:nbreDL
        for sc=1:N_sc
      %remplir la matrice du sinr (formule du sinr)
          if round(W(i,j,sc))==1
              IDReplace2;
              coor1 = Mobile_user(I).coordinates;
              coor2 = Mobile_user(J).coordinates;
              S=sqrt((coor1(1)-coor2(1))^2+(coor1(2)-coor2(2))^2);
              A= 10^((Cost231extendedHataPassLossModel(Mobile_user(I).r_k*10^3, 'urban',Mobile_user(I).ID,t,sc))/10);
              C= 10^((Cost231extendedHataPassLossModel(Mobile_user(J).r_k*10^3, 'urban',Mobile_user(J).ID,t,sc))/10);
              D = 10^((Cost231extendedHataPassLossModel(S*10^3, 'urban',Mobile_user(J).ID,t,sc))/10);
              SINR_UL(i,j,sc)=(10/log(10))*log(pUL(i,sc)*BS_antenna_gain*UE_antenna_gain*X(Mobile_user(I).ID,t)./(A*(sigma_2+(pDL/SIC))))+7;
              SINR_DL(i,j,sc)=(10/log(10))*log((pDL*BS_antenna_gain*UE_antenna_gain*X(Mobile_user(J).ID,t)./C)./(sigma_2+ (pUL(i,sc)*UE_antenna_gain*UE_antenna_gain*Y(Mobile_user(J).ID,t)./D)));
          else
              SINR_UL(i,j,sc)=0;
              SINR_DL(i,j,sc)=0;
              
          end;
        end
    end
end

%fonction objective
objective=sum(sum(sum(SINR_UL+SINR_DL)));
maximize(objective)
subject to
% constraints are power limits for each BS
% 
% for i=1:5
%     for j=1:5
%         for sc=1:N_sc
%         SINR_UL(i,j,sc)>=0;
%         end
%     end
% end
% 
% for i=1:5
%     for j=1:5
%         for sc=1:N_sc
%         SINR_DL(i,j,sc)>=0;
%         end
%     end
% end

for i=1:nbreUL
    sum(pUL(i,:))<=0.2;
end 

for i=1:nbreUL
    for sc=1:N_sc
        if sum(W(i,:,sc))==1
pUL(i,sc)>=0.001;
        end

    end
end
% for i=1:nbreUL
%     for j=1:nbreDL
%     for sc=1:N_sc
%         if W(i,j,sc)==1
% pUL(i,sc)<=0.05;
%         end
%     end
%     end
% end
cvx_end

