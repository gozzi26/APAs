function [start_index,RESULTS]=startAPA_recogniser(signal)
% trova il frame nel quale il marker compare. A quell'indice corrisponde lo
% 'start' cue dato dall'esaminatore
j=0;
RESULTS=0;
start_index=NaN;

if length(signal)<1001
   disp(['recond not enough long: ' num2str(length(signal)) ' samples'])
   RESULTS=1;
   return
end

for i=length(signal)-1000:length(signal)
    if isnan(signal(i))==0 && j==0
        start_index=i;
    end
    if isnan(signal(i))==0
        j=j+1;
    else
        j=0;
        start_index=NaN;
    end
    if j>10
        break
    end
end
if isnan(start_index)
    RESULTS=1;
    disp('NO START detected')
end
end

