% SGN-16006 Bachelor's Laboratory Course in Signal Processing
% Computational Auditory Scene Recognition: Classification of Environmental Sounds
% 11.3.2016 S.Haikonen & J. Laukkanen

%Assignment II

% 3.1

clc;
close all;
clear all;

%Polkuun .wav tiedostojen kansio
polku = 'C:\Users\Juho\Documents\MATLAB\SGN-16006 Bachelors Laboratory Course in Signal Processing\Proj 1\UEA-Environmental-Noise-Data-Set\Series-2\wav';
cd(polku)

filelist = dir('*.wav');
result = cell(size(filelist));
for index =1:length(filelist)
    fprintf('Processing %s\n',filelist(index).name);
    [y Fs] = audioread(filelist(index).name);
    result{index} = y;
end

% Nyt result sis‰lt‰‰ 12 pitk‰‰ p‰tk‰‰ n‰ytteenottotaajuudella 8kHz.
% Kaikki ovat pituudeltaan joko 2400000 tai 2400001 n‰ytett‰.
% Halutaan, ett‰ kaikki ovat pituudeltaan 2400000 n‰ytett‰, jotta olis
% helpompi jakaa tasan 8000 n‰ytteen p‰tkiin. Siksi otetaan vain 
% 2400000 ensimm‰ist‰ n‰ytett‰ mukaan.
for m = 1:12;
    result{m} = result{m}(1:2400000);
end


% Luodaan matriisi X, jonka sarakkeiksi paloitellaan data 8000 n‰ytteen 
% eli 1 sekunnin p‰tkiksi. %K‰ytet‰‰n samaa buffer-funktiota mutta nyt
% ilman overlappayst‰ (siksi laitetaan kolmanneksi parametriksi nolla).
X=[];
for m=1:length(result);
    X = [X buffer(result{m},8000,0)];
end;
% Nyt meill‰ on kaikki sekunnin (8000 n‰ytteen) p‰tk‰t X:n sarakkeina ja 
% sarakkeita/p‰tki‰ on yhteens‰ 3600.

% Luodaan luokkatiedolle oma vaakavektori, jonka arvot vastaavat matriisin
% X sarakkeina olevia p‰tki‰.
labels=[ones(1,300) 2*ones(1,300) 3*ones(1,300) 4*ones(1,300) 5*ones(1,300) 6*ones(1,300) 7*ones(1,300) 8*ones(1,300) 9*ones(1,300) 10*ones(1,300) 11*ones(1,300) 12*ones(1,300)];


% Satunnaistetaan data opetus- ja testidataan (randperm-funktion avulla)
rp=randperm(3600); 
test_ind = rp(1:720); 
train_ind = rp(721:end);

test_data = X(:,test_ind); 
test_labels=labels(test_ind);

train_data = X(:,train_ind); 
train_labels=labels(train_ind);

% Nyt train_data sis‰lt‰‰ opetusdatan ja train_labels sis‰lt‰‰ luokkatiedon
% Ja vastaavasti test_data ja test_labels.

% Seuraavaksi jokainen training datan‰yte "framewise" Hanning ikkunalla,
% jolla ikkunan pituus 30ms ja overlap 15ms.

% Time frame, ikkunan pituus
Tf = 0.03;
% Frame overlap
Ts = 0.015;
%Fs = 8000, jolloin n‰ytteiden m‰‰r‰ per frame:
frameSize = Fs * Tf;
% N‰ytteiden m‰‰r‰ per overlap
frameStep = Fs*Ts;


% Rakennetaan hanning window
window = hann(frameSize);

% Alustetaan piirre-vektori jonka pit‰isi olla muotoa 4x2880, eli nelj‰
% energia-tasoa jokaista audioklippi‰ kohden

% Lasketaan ensin opetusdatalle sub-band-energiasuhteet sek‰ sub-band
% keskiarvot freimien v‰lill‰.
train_x_ratios = [];
train_x_average = [];
% Silmukka sub-band-energiasuhteiden laskemista varten
for i = 1:size(train_data,2) %k‰yd‰‰n l‰pi 1:2880
    % Otetaan sarake kerrallaan 8000 pituiset p‰tk‰t omaan muuttujaan
    temp_audioClip = train_data(:,i);
    % palotellaan audioklipit overl‰pp‰‰viin sekunnin p‰tkiin (koko 240x67)
    temp_framedSignal = buffer(temp_audioClip,frameSize,frameStep);
    % Alustetaan hanning windowia varten nollamatriisi
    temp_hanningSignal = zeros(size(temp_framedSignal));
    for j = 1:size(temp_framedSignal,2) %k‰yd‰‰n 1:67
            temp_hanningSignal(:,j) = temp_framedSignal(:,j).*window;
            train_x_ratios(:,j) = subBand_energy(temp_hanningSignal(:,j)); 
    end
    train_x_average(:,i) = mean(train_x_ratios,2);
end

% Tehd‰‰n sitten samat esik‰sittelyt testidatalle:
test_x_ratios = [];
test_x_average = [];
% Silmukka sub-band-energiasuhteiden laskemista varten
for i = 1:size(test_data,2) %k‰yd‰‰n l‰pi 1:720
    % Otetaan sarake kerrallaan 8000 pituiset p‰tk‰t omaan muuttujaan
    temp_audioClip = test_data(:,i);
    % palotellaan audioklipit overl‰pp‰‰viin sekunnin p‰tkiin (koko 240x67)
    temp_framedSignal = buffer(temp_audioClip,frameSize,frameStep);
    % Alustetaan hanning windowia varten nollamatriisi
    temp_hanningSignal = zeros(size(temp_framedSignal));
    for j = 1:size(temp_framedSignal,2) %k‰yd‰‰n 1:67
            temp_hanningSignal(:,j) = temp_framedSignal(:,j).*window;
            test_x_ratios(:,j) = subBand_energy(temp_hanningSignal(:,j)); 
    end
    test_x_average(:,i) = mean(test_x_ratios,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LUOKITTELUOSUUS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
one_nearest = knn(train_x_average,test_x_average,test_labels,train_labels,1);
five_nearest = knn(train_x_average,test_x_average,test_labels,train_labels,5);

%%%%%%%%%%%%
% Konfuusiomatriisi

conf_one_nearest = confusionmat(test_labels,one_nearest);
conf_five_nearest = confusionmat(test_labels,five_nearest);

figure;build_image(conf_one_nearest);
figure;build_image(conf_five_nearest);

%     Tarkkuuslaskentaa!!
% % % % % % 1-NN % % % % % %
accuracy = zeros(size(12));
for n=1:12
    class_positive = sum([one_nearest == n & test_labels == n]);
    class_ground_positive = sum(test_labels==n);
    accuracy(1,n) = class_positive/class_ground_positive;
end

mean(accuracy)
% % % % % % 5-NN % % % % % %
accuracy = zeros(size(12));
for n=1:12
    class_positive = sum([five_nearest == n & test_labels == n]);
    class_ground_positive = sum(test_labels==n);
    accuracy(1,n) = class_positive/class_ground_positive;
end

mean(accuracy)














