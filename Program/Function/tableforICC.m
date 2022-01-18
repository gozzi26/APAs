function tableforICC(S,filename)
%permette di organizzare le tabelle e calcola il valore di  ICC

task = {'task1' 'task2' 'task3' 'task4' 'task5' 'task6' 'task7' ...
     'task8' 'task9' 'task10' 'task11' 'task12' 'task13' 'task14' 'task15'};

 for tab=1:7
    for j=1:15  
        M=S(tab).(task{j});
        M(M == 0) = NaN;
        disp(j)
        disp(M)
        
        for riga=1:size(M,1)
            
            canc1=isnan(M(riga,1)) && isnan(M(riga,2));
            canc2=isnan(M(riga,2)) && isnan(M(riga,3));
            canc3=isnan(M(riga,1)) && isnan(M(riga,3));
            index_canc(riga,1)=canc1 || canc2 || canc3;
            
            
            ave1=isnan(M(riga,1)) && isnan(M(riga,2))==0 && isnan(M(riga,3))==0;
            ave2=isnan(M(riga,1))==0 && isnan(M(riga,2)) && isnan(M(riga,3))==0;
            ave3=isnan(M(riga,1))==0 && isnan(M(riga,2))==0 && isnan(M(riga,3));
            
            if ave1
                M(riga,1)=mean(M(riga,2:3));
            elseif ave2
                M(riga,2)=mean(M(riga,[1 3]));
            elseif ave3
                M(riga,3)=mean(M(riga,1:2));
            end
            
        end
        M(index_canc,:)=[];
        
        [r(tab,j), ~, ~, ~, ~, ~, ~] = ICC(M,'1-1');
        disp(M)
        clear index_canc
        S(tab).(task{j})=M;
        
    end
 end
 
 close all
 icc='ICC';
 for pag=1:7
xlswrite(filename,{icc},pag,'A20')
xlswrite(filename,r(pag,:),pag,'B20')
 end
 
end

