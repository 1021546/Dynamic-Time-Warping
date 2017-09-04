% ���w�@�ӭ��ɡA�P�h��template���ɺ�Z���A�õe��

clear;
clear global;

template_num = 6; %��X�ؤ��e
template_num2 = 4; %���h�ֲ�template

% ���o���խ��ɪ��S�x�V�q ----------------------------------------------
fileName = 'wav/w0_0.wav'; %��0�հ������աA��1~4�է@��template
% fileName = 'fsdd/0_jackson_0.wav';
[epd_y, fs, epd_start, epd_end, y] = my_epd(fileName);
feature_mfcc = my_mfcc(epd_y, fs);
[feature_size, frame_num] = size(feature_mfcc);

% �e�� ----------------------------------------------------------------
suptitle('Wave Form & MFCC');
subplot(template_num+1, 2*template_num2, template_num2);
x = 1:length(y);
plot(x, y, 'k');
[size_y_1, size_y_2] = size(y);
axis([0, size_y_1, -inf, inf]);
title(fileName); 
line([epd_start epd_start], [min(y) max(y)], 'color', 'r');
line([epd_end epd_end], [min(y) max(y)], 'color', 'r');
clear x;
subplot(template_num+1, 2*template_num2, template_num2+1);
imagesc(feature_mfcc);
axis xy

% �ҪO ----------------------------------------------------------------
dtw_distance(template_num) = 0;

for i2 = 1:template_num2
	for i = 1:template_num

		% ���otemplate���ɪ��S�x�V�q�A_t���template
		fileName_t = ['wav/w', num2str(i2), '_', num2str(i-1), '.wav'];
		% fileName_t = ['fsdd/', num2str(i-1), '_jackson_', num2str(i2), '.wav'];
		[epd_y_t, fs_t, epd_start_t, epd_end_t, y_t] = my_epd(fileName_t);
		feature_mfcc_t = my_mfcc(epd_y_t, fs_t);
		[feature_size_t, frame_num_t] = size(feature_mfcc_t);

		% �e��
		subplot(template_num+1, 2*template_num2, (i2-1)*2+i*2*template_num2+1);
		x = 1:length(y_t);
		plot(x, y_t, 'b');
		[size_y_t_1, size_y_t_2] = size(y_t);
		axis([0, size_y_t_1, -inf, inf]);
		title(fileName_t,'Color', 'b'); 
		line([epd_start_t epd_start_t], [min(y_t) max(y_t)], 'color', 'r');
		line([epd_end_t epd_end_t], [min(y_t) max(y_t)], 'color', 'r');
		clear x;
		subplot(template_num+1, 2*template_num2, (i2-1)*2+i*2*template_num2+2);
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
		dtw_distance(i) = dtw_distance(i) + dtw_grid_c(dtw_grid, frame_num, frame_num_t);

		% �@�k�G: �j��
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
		% dtw_distance(i) = dtw_distance(i) + dtw_grid2(frame_num,frame_num_t);

		% dtw�B��
		% count_step = 0;
		% temp_x = frame_num;
		% temp_y = frame_num_t;
		% for j = 1:(frame_num+frame_num_t)
		% 	if (temp_x == 1) && (temp_y == 1)
		% 		break;
		% 	elseif temp_x == 1
		% 		temp_y = temp_y-1;
		% 	elseif temp_y == 1
		% 		temp_x = temp_x-1;
		% 	else
		% 		[min_temp, min_temp_index] = min([dtw_grid2(temp_x-1,temp_y),dtw_grid2(temp_x,temp_y-1),dtw_grid2(temp_x-1,temp_y-1)]);
		% 		if min_temp_index == 1
		% 			temp_x = temp_x-1;
		% 		elseif min_temp_index == 2
		% 			temp_y = temp_y-1;
		% 		else
		% 			temp_x = temp_x-1;
		% 			temp_y = temp_y-1;
		% 		end
		% 	end
		% 	count_step = count_step + 1;
		% end
		% count_step

		title(['�Z��:', num2str(dtw_grid_c(dtw_grid, frame_num, frame_num_t))],'Color', 'b'); 
		clear fileName_t epd_y_t fs_t feature_mfcc_t feature_size_t frame_num_t dtw_grid epd_start_t epd_end_t y_t;

	end
end

% ��ܵ��G
dtw_distance
[min_distance, min_distance_index] = min(dtw_distance);
disp(['�̱���:wav/wX_', num2str(min_distance_index-1), '.wav �`�Z����:', num2str(min_distance)]);
