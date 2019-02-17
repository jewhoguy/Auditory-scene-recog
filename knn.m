function class = knn(train_data,test_data,test_labels,train_labels,k)
class = 20*ones(size(test_labels));
for m=1:size(test_data,2) % k‰yd‰‰n 1:720 eli testidata
    % Alustetaan distance_temp ekan opetusn‰ytteen et‰isyytt‰ vastaavaksi:
    distance_temp = sqrt(sum((test_data(:,m)-train_data(:,1)).^2));
    
    for n=1:size(train_data,2) %1:2880
        distance_temp = sqrt(sum((test_data(:,m)-train_data(:,n)).^2));
        distances(n) = distance_temp; 
    end
        
    [dist,ind] = sort(distances);
    ind_closest = ind(1:k);
    
    k_closest = train_labels(ind_closest);
    
    %mode-funktio palauttaa matriisin/vektorin eniten esiintyneen arvon
    class(m) = mode(k_closest);
end
