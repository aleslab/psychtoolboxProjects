% %the slow speed accelerating lateral upper and lower speed bounds
% section1lowerSpeeds = [18.0 15.8 13.5 11.3 9.01 6.76 4.50];
% section1upperSpeeds = [21.9 18.7 15.6 12.7 9.91 7.26 4.72];
% section2lowerSpeeds = [21.9 24.0 26.0 27.9 29.7 31.4 33.1];
% section2upperSpeeds = [27.2 30.6 34.0 37.4 40.8 44.2 47.6];

%the mid speed speed bounds
section1lowerSpeeds = [30.1 26.4 22.6 18.8 15.1 11.3 7.53];
section1upperSpeeds = [43.8 36.4 29.7 23.6 18.0 12.9 8.22];
section2lowerSpeeds = [43.9 46.9 49.6 52.0 54.1 55.9 57.6];
section2upperSpeeds = [69.5 78.1 86.8 95.5 104.1 112.8 121.4];

for i = 1:length(section1lowerSpeeds)

s1lowerspeeds(i) = 97*tand(section1lowerSpeeds(i)/60);

end

for i = 1:length(section1upperSpeeds)

s1upperspeeds(i) = 97*tand(section1upperSpeeds(i)/60);

end

for i = 1:length(section2lowerSpeeds)

s2lowerspeeds(i) = 97*tand(section2lowerSpeeds(i)/60);

end

for i = 1:length(section2upperSpeeds)

s2upperspeeds(i) = 97*tand(section2upperSpeeds(i)/60);

end

cmspeedranges = horzcat(s1lowerspeeds', s1upperspeeds', s2lowerspeeds', s2upperspeeds');