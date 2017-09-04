function [epd_y, fs, epd_start, epd_end, y] = my_epd(fileName)
% @my_epd: 端點偵測(End Point Detection)
% @fileName: 音檔路徑與檔名
% @epd_y: 端點偵測後的取樣點
% @fs: 取樣頻率
% @epd_start: 起始端點(單位為取樣點)
% @epd_end: 結束端點(單位為取樣點)
% @y: 端點偵測前的取樣點

% -----------------------------------------------
% 取得音檔資訊
[y, fs] = audioread(fileName); 
audioInfo = audioinfo(fileName);

% 變數宣告
frame_size_ms = 32;
frame_shift_ms = 16;
frame_size = frame_size_ms*0.001*audioInfo.SampleRate;
frame_shift = frame_shift_ms*0.001*audioInfo.SampleRate;
frame_num = floor((audioInfo.TotalSamples-(frame_size-frame_shift))/frame_shift);

% -----------------------------------------------
% Energy
energy(frame_num) = 0;
for n = 1:frame_num
	temp = (n-1)*frame_shift;
	for m = 1:frame_size
		energy(n) = energy(n) + (y(temp+m)*my_hamming(n-(temp+m), frame_size))^2;
	end
end

% -----------------------------------------------
% 過零率
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

% -----------------------------------------------
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

% -----------------------------------------------
% 端點偵測

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
		epd_start = 1;
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
		epd_start = 1;
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

epd_start = (epd_start-1)*frame_shift;
epd_end = (epd_end-1)*frame_shift;
epd_y = y(epd_start+1:epd_end-1);
