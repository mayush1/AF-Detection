clear all;
close all;
clc ;
 
% Load Data Here%
load('BEN_iPPG.mat')
ppg = Sessiondata(4:end,2);
ppg = cell2mat(ppg);
% load('patient2_pre.mat')
% ppg = patient2_pre(1:end,2);
THrmssd = 0.115;
THshe = 0.5;
sample_rate = 32;
ppg = ppg/abs((max(ppg))-(min(ppg)));
ppg = smooth(ppg);
findpeaks(ppg,'MinPeakProminence',0.35)
[pks,locs] = findpeaks(ppg,'MinPeakProminence',0.35);
x = 0;
g = 0;
afpos = 0;
d = [];
sSum = 0;
sqSum = 0;
she = 0;
 for i = 1:67
     a = locs(i+1);
     b = locs(i);
     d = a-b;
     x = x + d;
     g = g+1;
 end
result = x/g;
Heart_Rate = sample_rate * 60 / result

while(length(locs) > 30)
% RMSSD Code for AF Detection %
if(length(locs) > 16)
    for i = 1:16
        a = locs(i+1);
        b = locs(i);
        c = a - b;
        d = [d, c];
    end
    
    rrSum = sum(d);
    rrMean = rrSum / length(d);
    
    for i = 1:length(d)-1
        sSum = (d(i+1) - d(i)).^2;
        sqSum = sqSum + sSum;
    end
    sqrtSum = sqrt(sqSum / (length(d) - 1));
    rmSSD = sqrtSum / rrMean;
end

% Shannon Entropy for AF Detection %
 
    minNo = min(d);
    maxNo = max(d);
    delta = (maxNo - minNo) / 16;
    bin_size = 16;
    
    h = hist(d,bin_size);
    probabilities = zeros (bin_size, 1);
    
    for n = 1:bin_size
   	probabilities (n) = h (n)/(sample_rate-16);
    end

    for n = 1:16
   	if probabilities (n) ~= 0
            se = probabilities (n) * (log (probabilities (n)) / log (1 / 16));
            she = abs(she + se);
    end
    end
    
% AF Detection %
      if (rmSSD > THrmssd && she > THshe)
%           disp("Root Mean Square Succesive Difference = ")
%           disp(rmSSD)
%           disp("Shannon Entropy =")
%           disp(she)
           disp("Irregular Heart Rhythm")
          afpos = afpos + 1;
      else
%           disp("Root Mean Square Succesive Difference = ")
%           disp(rmSSD)
%           disp("Shannon Entropy =")
%           disp(she)
          disp("Regular Heart Rhythm")
      end
      
      for n = 1:16
          locs(1) = [];
      end
      d = [];
      sqSum = 0;
      she = 0;
end

if(afpos > 0)
    disp("AF found on the subject")
else
    disp("Subject is normal")
end