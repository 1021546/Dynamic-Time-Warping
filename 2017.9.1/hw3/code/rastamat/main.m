% ���w�@�ӭ��ɡA�P�@��template���ɺ�Z���A�õe��

clear;
clear global;

template_num = 6;

% ���o���խ��ɪ��S�x�V�q ----------------------------------------------
fileName = 'wav/w0_0.wav';
[epd_y, fs, epd_start, epd_end, y] = my_epd(fileName);
feature_mfcc = my_mfcc(epd_y, fs);
[feature_size, frame_num] = size(feature_mfcc);

% �e�� ----------------------------------------------------------------
suptitle('Wave Form & MFCC');
subplot(template_num+1, 2, 1);
x = 1:length(y);
plot(x, y, 'k');
[size_y_1, size_y_2] = size(y);
axis([0, size_y_1, -inf, inf]);
title(fileName); 
line([epd_start epd_start], [min(y) max(y)], 'color', 'r');
line([epd_end epd_end], [min(y) max(y)], 'color', 'r');
clear x;
subplot(template_num+1, 2, 2);
imagesc(feature_mfcc);
axis xy

% �ҪO ----------------------------------------------------------------
dtw_distance(template_num) = 0;

for i = 1:template_num

	% ���otemplate���ɪ��S�x�V�q�A_t���template
	fileName_t = ['wav/w1_', num2str(i-1), '.wav'];
	[epd_y_t, fs_t, epd_start_t, epd_end_t, y_t] = my_epd(fileName_t);
	feature_mfcc_t = my_mfcc(epd_y_t, fs_t);
	[feature_size_t, frame_num_t] = size(feature_mfcc_t);

	% �e��
	subplot(template_num+1, 2, i*2+1);
	x = 1:length(y_t);
	plot(x, y_t, 'b');
	[size_y_t_1, size_y_t_2] = size(y_t);
	axis([0, size_y_t_1, -inf, inf]);
	title(fileName_t,'Color', 'b'); 
	line([epd_start_t epd_start_t], [min(y_t) max(y_t)], 'color', 'r');
	line([epd_end_t epd_end_t], [min(y_t) max(y_t)], 'color', 'r');
	clear x;
	subplot(template_num+1, 2, i*2+2);
	imagesc(feature_mfcc_t);
	axis xy

	% �إ�dtw���
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
	dtw_grid2(frame_num, frame_num_t) = 0; %�ֿn��

	% �@�k�@: ���j
	dtw_distance(i) = dtw_grid_c(dtw_grid, frame_num, frame_num_t);

	% �@�k�G: �j��
	% dtw_grid2(frame_num,frame_num_t) = 0;
	% for j = 1:frame_num
	% 	for k = 1:frame_num_t
	% 		if (j==1) && (k==1)
	% 			dtw_grid2(j,k) = dtw_grid(j,k);
	% 			continue;
	% 		end
	% 		if (j>1) && (k>1)
	% 			temp1 = dtw_grid2(j-1,k-1);
	% 		else
	% 			temp1 = realmax;
	% 		end
	% 		if j>1
	% 			temp2 = dtw_grid2(j-1,k);
	% 		else
	% 			temp2 = realmax;
	% 		end
	% 		if k>1 
	% 			temp3 = dtw_grid2(j,k-1);
	% 		else
	% 			temp3 = realmax;
	% 		end
	% 		dtw_grid2(j,k) = dtw_grid(j,k) + min([temp1,temp2,temp3]);
	% 	end
	% end
	% dtw_distance(i) = dtw_grid2(frame_num,frame_num_t);

	title(['�Z��:', num2str(dtw_distance(i))],'Color', 'b'); 
	clear fileName_t epd_y_t fs_t feature_mfcc_t feature_size_t frame_num_t dtw_grid epd_start_t epd_end_t y_t;

end

% ��ܵ��G
dtw_distance
[min_distance, min_distance_index] = min(dtw_distance);
disp(['�̱���:wav/w0_', num2str(min_distance_index-1), '.wav �Z����:', num2str(min_distance)]);
