function image = build_image(C)
imagesc(C);
colormap(flipud(gray));

textStrings = num2str(C(:),'%0.2f'); %Stringeja matriisin arvoista
textStrings = strtrim(cellstr(textStrings)); %V‰lit pois

idx = find(strcmp(textStrings(:), '0.00')); %poistetaan turhat 0.0
textStrings(idx) = {'   '};

[x, y] = meshgrid(1:12); %Alustetaan x ja y koordinaatit joiden p‰‰lle arvot(textStringit) laitetaan
hStrings = text(x(:),y(:),textStrings(:),'HorizontalAlignment','center'); %plotataan stringit
midValue = mean(get(gca,'CLim')); %keskiarvotetaan v‰rit, ei sen enemp‰‰ ymm‰rryst‰ mit‰ tuossa tapahtuu :D
textColors = repmat(C(:)>midValue,1,3); %mustaa ja valkoista
set(hStrings,{'Color'},num2cell(textColors,2)); 
set(gca,'XTick',1:12,...                         %x ja y axis 1-12 nimet‰‰n jokanen kolumni ja rivi
        'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'},... 
        'YTick',1:12,...
        'YTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12'},...
        'TickLength',[0 0]);