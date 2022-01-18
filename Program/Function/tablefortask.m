function tablefortask(S)
%costruisce la tabella per ciascuna task
filename='analisitask.xlsx';
task = {'task1' 'task2' 'task3' 'task4' 'task5' 'task6' 'task7' ...
    'task8' 'task9' 'task10' 'task11' 'task12' 'task13' 'task14' 'task15'};
column={'B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'};

Nome_partecipanti={'P1','P2','P3','P4','P5'};

for sheet=1:length(task)
    A={task{sheet},'copML peak value', 'AccML peak value', 'copAP peak value', 'AccAP peak value',...
        'Duration','time to peak ML', 'time to peak AP'};
    xlswrite(filename,A,sheet,'A1')
    for part=1:length(Nome_partecipanti)
        NOME=Nome_partecipanti{part};
        xlswrite(filename,{NOME},sheet,['A',num2str(2+3*(part-1))] )
        %disp(strcat('A',num2str(2+3*(part-1))))
    end
end

for j=1:15
    for i=1:7
        M=S(i).(task{j});
        M(M == 0) = NaN;
        disp(M)
        num_soggetti=size(M,1);
        K=M';
        
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
        [r, ~, ~, ~, ~, ~, ~] = ICC(M,'1-1');
        
        icc='ICC';
        xlswrite(filename,{icc},j,'A20')
        xlswrite(filename,r,j,[column{i} '20'])
        clear index_canc
        
        for coord=1:num_soggetti*3
            %disp(K(coord))
            xlswrite(filename,K(coord),j,[column{i} num2str(coord+1)])
        end
        
    end
end
end

