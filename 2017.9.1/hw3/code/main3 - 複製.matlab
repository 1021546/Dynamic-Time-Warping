% 同樣內容音檔的彼此距離，以及全部音檔彼此的距離，並將結果分別寫入hw3_check.txt、hw3_result.txt中
% 寫得比較爛，會跑比較久

clear;
clear global;

template_num = 6; %唸幾種內容
template_num2 = 5; %有多少組template
dtw_distance(template_num2, template_num, template_num2, template_num) = 0;
dtw_accuracy(template_num2, template_num) = 0;
dtw_distance_c(template_num) = 0; %_c表示累積
dtw_accuracy_c(template_num) = 0; %_c表示累積

for g = 1:template_num2
	for w = 1:template_num

		% 取得測試音檔的特徵向量 ----------------------------------------------
		fileName = ['wav/w', num2str(g-1), '_', num2str(w-1), '.wav'];
		% fileName = ['fsdd/', num2str(w-1), '_jackson_', num2str(g-1), '.wav'];
		[epd_y, fs, epd_start, epd_end, y] = my_epd(fileName);
		feature_mfcc = my_mfcc(epd_y, fs);
		[feature_size, frame_num] = size(feature_mfcc);

		clear dtw_distance_c;
		dtw_distance_c(template_num) = 0; %_c表示累積

		% 模板 ----------------------------------------------------------------
		for i2 = 1:template_num2
			for i = 1:template_num

				% 取得template音檔的特徵向量，_t表示template
				fileName_t = ['wav/w', num2str(i2-1), '_', num2str(i-1), '.wav'];
				% fileName_t = ['fsdd/', num2str(i-1), '_jackson_', num2str(i2-1), '.wav'];
				[epd_y_t, fs_t, epd_start_t, epd_end_t, y_t] = my_epd(fileName_t);
				feature_mfcc_t = my_mfcc(epd_y_t, fs_t);
				[feature_size_t, frame_num_t] = size(feature_mfcc_t);

				% 建立dtw表格
				dtw_grid(frame_num, frame_num_t) = 0;
				for j = 1:frame_num
					for k = 1:frame_num_t
						for l = 1:feature_size
							dtw_grid(j, k) = dtw_grid(j, k) + (feature_mfcc(l, j)-feature_mfcc_t(l, k))^2;
						end
						dtw_grid(j, k) = sqrt(dtw_grid(j, k));
					end
				end

				clear global;
				global dtw_grid2
				dtw_grid2(frame_num, frame_num_t) = 0; %累積的

				% 作法一: 遞迴
				dtw_distance(g, w, i2, i) = dtw_grid_c(dtw_grid, frame_num, frame_num_t);
				dtw_distance_c(i) = dtw_distance_c(i) + dtw_grid_c(dtw_grid, frame_num, frame_num_t);

				clear fileName_t epd_y_t fs_t feature_mfcc_t feature_size_t frame_num_t dtw_grid epd_start_t epd_end_t y_t;

			end
			% 記下正確率
			[temp_min, temp_min_index] = min(dtw_distance(g, w, i2, :));
			if temp_min_index == w
				dtw_accuracy(g, w) = dtw_accuracy(g, w) + 1;
			end
			[temp_min, temp_min_index] = min(dtw_distance_c);
			if temp_min_index == w
				dtw_accuracy_c(w) = dtw_accuracy_c(w) + 1;
			end

		end

		clear fileName epd_y fs feature_mfcc feature_size frame_num epd_start epd_end y;

	end
end

% 寫入結果 --------------------------------------------------------------------
% 檢查唸某個字的音檔彼此間的距離，若與其他音檔距離大表示可能錄不好:
% ...
% 
% wX_3:
%     0_3 1_3 2_3 3_3 4_3
% 0_3 
% 1_3 
% 2_3    ... 距離 ...
% 3_3 
% 4_3 
% 
% wX_4:
% ...
txt_check = fopen('hw3_check.txt','w');
for w = 1:template_num
	fprintf(txt_check, 'wX_%d\n', w-1);
	for g = 1:template_num2
		for g2 = 1:template_num2
			fprintf(txt_check, '%5.2f  ', dtw_distance(g, w, g2, w));
		end
		fprintf(txt_check, '\n');
	end
	fprintf(txt_check, '\n');
end
fclose(txt_check);

% 全部音檔彼此的距離:
% 
%     0_0 0_1 0_2 0_3 0_4 1_0 1_1 1_2 ...
% 0_0 
% 0_1 
% 0_2 
% 0_3 
% 0_4           ... 距離 ...
% 0_5 
% 1_0 
% 1_1 
% 1_2 
% ...
%
txt_result = fopen('hw3_result.txt','w');
for g = 1:template_num2
	for w = 1:template_num
		for g2 = 1:template_num2
			for w2 = 1:template_num
				fprintf(txt_result, '%5.2f  ', dtw_distance(g, w, g2, w2));
			end
		end
		fprintf(txt_result, '\n');
	end
end
fclose(txt_result);

% 各個音檔正確率與各種內容正確率:
% 
%
clear temp_accuracy;
txt_accuracy = fopen('hw3_accuracy.txt','w');
for g = 1:template_num2
	for w = 1:template_num
		fprintf(txt_accuracy, 'w%d_%d: %d/%d(%4.2f%%)\n', g-1, w-1, dtw_accuracy(g, w)-1, template_num2-1, (dtw_accuracy(g, w)-1)/(template_num2-1)*100);
		% fprintf(txt_accuracy, '%d_jackson_%d: %d/%d(%4.2f%%)\n', w-1, g-1, dtw_accuracy(g, w)-1, template_num2-1, (dtw_accuracy(g, w)-1)/(template_num2-1)*100);
	end
end
fprintf(txt_accuracy, '\n');
temp_accuracy(template_num) = 0;
for w = 1:template_num
	for g = 1:template_num2
		temp_accuracy(w) = temp_accuracy(w) + dtw_accuracy(g, w)-1;
	end
	fprintf(txt_accuracy, 'wX_%d: %d/%d(%4.2f%%)\n', w-1, temp_accuracy(w), template_num2*(template_num2-1), temp_accuracy(w)/(template_num2*(template_num2-1))*100);
	% fprintf(txt_accuracy, '%d_jackson_X: %d/%d(%4.2f%%)\n', w-1, temp_accuracy(w), template_num2*(template_num2-1), temp_accuracy(w)/(template_num2*(template_num2-1))*100);
end
fprintf(txt_accuracy, '\n');
for w = 1:template_num
	for g = 1:template_num2
		temp_accuracy(w) = temp_accuracy(w) + dtw_accuracy(g, w)-1;
	end
	fprintf(txt_accuracy, 'wX_%d: %d/%d(%4.2f%%)\n', w-1, dtw_accuracy_c(w), template_num2*(template_num2-1), dtw_accuracy_c(w)/(template_num2*(template_num2-1))*100);
	% fprintf(txt_accuracy, '%d_jackson_X: %d/%d(%4.2f%%)\n', w-1, temp_accuracy(w), template_num2*(template_num2-1), temp_accuracy(w)/(template_num2*(template_num2-1))*100);
end
fclose(txt_accuracy);



dtw_accuracy_c(w)