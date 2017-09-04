
%{
Recording: "語音訊號處理"
Sample Rate: 16k Hz
Resolution: 16bits
Windowing: Hamming window
Frame Size: 32ms
Frame Shift: 16ms
Channel: Mono
%}
% -----------------------------------------------

clear;

% get audio inform
fileName='a1.wav';
[y, fs] = audioread(fileName); 
audioInfo = audioinfo(fileName);

% variable declaration
frame_size_ms = 32;
frame_shift_ms = 16;
frame_size = frame_size_ms*0.001*audioInfo.SampleRate;
frame_shift = frame_shift_ms*0.001*audioInfo.SampleRate;
frame_num = floor((audioInfo.TotalSamples-(frame_size-frame_shift))/frame_shift);

% -----------------------------------------------
% Wave Form
subplot(6, 1, 1);
x = (1:length(y))/(audioInfo.TotalSamples/frame_num);
plot(x, y);
axis([0, frame_num, -inf, inf]); % 限制顯示x軸0到frame_num的範圍
title('Wave Form'); 

% -----------------------------------------------
% Energy
energy(frame_num) = 0;
for n = 1:frame_num
	temp = (n-1)*frame_shift;
	for m = 1:frame_size
		energy(n) = energy(n) + (y(temp+m)*my_hamming(n-(temp+m), frame_size))^2;
	end
end
subplot(6, 1, 2);
clear x;
x = 1:frame_num;
plot(x, energy);
axis([0, frame_num, -inf, inf]);
title('Energy'); 

% -----------------------------------------------
% Zero Crossing Rate
zero_crossing_rate(frame_num) = 0;
for i = 1:frame_num
	temp = (i-1)*frame_shift;
	for j = 1:frame_size
		if temp+j-1 == 0
			continue;
		end
		zero_crossing_rate(i) = zero_crossing_rate(i) + abs(sign(y(temp+j))-sign(y(temp+j-1)))*my_hamming(i-(temp+j), frame_size);
	end
	zero_crossing_rate(i) = zero_crossing_rate(i) / frame_size;
end
subplot(6, 1, 3);
clear x;
x = 1:frame_num;
plot(x, zero_crossing_rate);
axis([0, frame_num, 0, 1]);
title('Zero Crossing Rate'); 

% -----------------------------------------------
% Autocorrelation on Frame XXX

frame_autocorrelation_no = 113;
autocorrelation(frame_size) = 0;
temp_seq(frame_size) = 0;
autocorrelation_all(frame_num, frame_size) = 0;

for n = 1:frame_num
	temp = (n-1)*frame_shift;
	for m = 1:frame_size
		temp_seq(m) = y(temp+m)*my_hamming(n-(temp+m), frame_size);
	end
	for k = 1:frame_size
		autocorrelation_all(n, k) = sum(temp_seq(1:frame_size-k+1).*temp_seq(k:frame_size));
	end
end

% 平滑
mean_range = 3;
for n = 1:frame_num
	% 歸零
	for i = 1:frame_size
		autocorrelation_mean(i) = 0;
	end
	% 首尾以外
	for i = 1:frame_size
		if (i < mean_range+1) || (i > frame_size-mean_range)
			continue;
		end
		for j = 1:mean_range
			autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, i-j);
			autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, i+j);
		end
		autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, i);
		autocorrelation_all(n, i) = autocorrelation_mean(i)/(mean_range*2+1);
	end
	% 首尾
	for i = 1:mean_range
		for j = 1:mean_range
			if i-j >= 1
				autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, i-j);
			else
				autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, 1);
			end
			if i+j <= frame_size
				autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, i+j);
			else
				autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, frame_size);
			end
		end
		autocorrelation_mean(i) = autocorrelation_mean(i) + autocorrelation_all(n, i);
		autocorrelation_all(n, i) = autocorrelation_mean(i)/(mean_range*2+1);
	end
end

autocorrelation = autocorrelation_all(frame_autocorrelation_no,:);
% autocorrelation = sgolayfilt(autocorrelation, 13, 17);

subplot(6, 1, 4);
clear x;
x = 1:frame_size;
plot(x, autocorrelation, 'r');
axis([0, frame_size, -inf, inf]);
title(strcat('Autocorrelation on Frame ', num2str(frame_autocorrelation_no))); 

% -----------------------------------------------
% Pitch

% energy門檻
itl_count = 10;
itl = 0;
itl_mean = 0;
itl_sigma = 0;
for n = 1:itl_count
	itl_mean = itl_mean + energy(n);
end
itl_mean = itl_mean/itl_count;
for n = 1:itl_count
	itl_sigma = itl_sigma + (energy(n)-itl_mean)^2;
end
itl_sigma = sqrt(itl_sigma/itl_count);
itl = itl_mean + 5*itl_sigma;
itu = 4*itl;

% 從autocorrelation算頻率，共peak_count個週期
pitch(frame_num) = 0;
peak_end = 1;
peak_end_edge = 35;
for n = 1:frame_num
	temp = (n-1)*frame_shift;
	flag_first_peak = true;
	peak_end = 1;
	if energy(n) < itu
		pitch(n) = 0;
		continue;
	end
	for m = peak_end_edge:frame_size-1
		if (autocorrelation_all(n,m) > autocorrelation_all(n,m-1)) && (autocorrelation_all(n,m) > autocorrelation_all(n,m+1))
			if(flag_first_peak)
				peak_end = m;
				flag_first_peak = false;
			else
				if autocorrelation_all(n,m) > autocorrelation_all(n,peak_end)
					peak_end = m;
				end
			end
		end
	end
	pitch(n) = audioInfo.SampleRate/(peak_end - 1);
end

subplot(6, 1, 5);
clear x;
x = 1:frame_num;
plot(x, pitch);
axis([0, frame_num, -inf, inf]);
title('Pitch'); 

% -----------------------------------------------
% End Point Detection

% 過零率門檻
izct_count = 10;
izct = 0;
izct_mean = 0;
izct_sigma = 0;
for n = 1:izct_count
	izct_mean = izct_mean + zero_crossing_rate(n);
end
izct_mean = izct_mean/izct_count;
for n = 1:izct_count
	izct_sigma = izct_sigma + (zero_crossing_rate(n)-izct_mean)^2;
end
izct_sigma = sqrt(izct_sigma/izct_count);
izct = izct_mean + 5*izct_sigma;

% 依序以itl、itu、izct為標準，找出起始與結束端點
epd_start = 1;
epd_end = frame_num;
% itu
for i = 1:frame_num
	if energy(i) > itu
		epd_start = i;
		break;
	end
end
for i = 1:frame_num
	if energy(frame_num+1-i) > itu
		epd_end = frame_num+1-i;
		break;
	end
end
% itl
for i = 1:epd_start-1
	if energy(epd_start-i) < itl
		epd_start = epd_start-i+1;
		break;
	end
	if i==epd_start-1
		epd_start = 0;
		break;
	end
end
for i = 1:frame_num-epd_end
	if energy(epd_end+i) < itl
		epd_end = epd_end+i-1;
		break;
	end
	if i==frame_num-epd_end
		epd_end = frame_num;
		break;
	end
end
% izct
for i = 1:epd_start-1
	if zero_crossing_rate(epd_start-i) < izct
		epd_start = epd_start-i+1;
		break;
	end
	if i==epd_start-1
		epd_start = 0;
		break;
	end
end
for i = 1:frame_num-epd_end
	if zero_crossing_rate(epd_end+i) < izct
		epd_end = epd_end+i-1;
		break;
	end
	if i==frame_num-epd_end
		epd_end = frame_num;
		break;
	end
end

subplot(6, 1, 6);
x = (1:length(y))/(audioInfo.TotalSamples/frame_num);
plot(x, y);
axis([0, frame_num, -inf, inf]); % 限制顯示x軸0到frame_num的範圍
title('End Point Detection'); 
line([epd_start epd_start], [min(y) max(y)], 'color', 'r');
line([epd_end epd_end], [min(y) max(y)], 'color', 'g');
