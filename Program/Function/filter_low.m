function [filtered_signal] = filter_low(fc,ft,order,signal)
% filtra un segnale con frequenza di campionamento fc con una cutoff
% frequency ft
Wn=ft/(fc/2);
[B,A]=butter(order,Wn);
filtered_signal=filtfilt(B,A,signal);
end

