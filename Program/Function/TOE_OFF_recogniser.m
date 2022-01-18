function [end_index,RESULTS] = TOE_OFF_recogniser(signal,start_index,mid_swing_index,taskName,DOM,p)
RESULTS=0;
end_index=NaN;

signal=signal*180/pi;

%faccio in modo che l'asse della velocità angolare sia sempre diretto da
%destra verso sinistra. In modo tale da avere il toe off come un picco
%positivo
if ~DOM
signal=-signal;
end


altezza_min=0.5*180/pi;


if max(signal(start_index:mid_swing_index))>altezza_min
    
    [PKS,LOCS]= findpeaks(signal(start_index:mid_swing_index),...
        'MinPeakHeight',altezza_min,'MinPeakDistance',40);
    end_index=LOCS(1)+start_index-1;
    
      %plot
%     figure
%     plot(signal)
%     hold on
%     plot(start_index,signal(start_index),'o')
%     plot(end_index,PKS(1), '*')
%     if p==7
%          legend('Angular Speed','start','mid-swing')
%     else
%         plot(mid_swing_index,signal(mid_swing_index),'s')
%         legend('Angular Speed','start','toe-off','mid-swing')
%     end
%         legend('Location','northwest')
%         legend('boxoff')
%     title({'Angular Speed' ; taskName})
%     xlabel('samples')
%     ylabel('degree/sec')
  
else
    figure
    plot(signal)
    title(taskName)
    RESULTS=1;
    return
end
end

