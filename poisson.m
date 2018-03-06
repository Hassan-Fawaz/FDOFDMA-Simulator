function [a,T] = poisson(lambda, Tmax)

if lambda <0
    error('The arrival rate you have entered is %d. It must be positive',lambda)

elseif Tmax <=0
        error('The simulation maximum time you have entered is %d. It must be positive', Tmax)
    else

% Start of Poisson process simulation      
clear T;
i=1;
T(1)=0; %T(1)= Start time

%T(2)= First arrival instant
%T(n) = (n-1)th arrival instant

while T(i) < Tmax,
    T(i+1)=T(i)+random('Exponential',1/lambda);
    i=i+1;
end

a=i-2; 

T(i)=Tmax;   %draws a stairstep graph of the number of arrivals as a
%function of time
% stairs(T(1:i), 0:(i-1));
    end