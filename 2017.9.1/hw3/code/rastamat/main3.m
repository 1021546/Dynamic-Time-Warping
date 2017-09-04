% �P�ˤ��e���ɪ������Z���A�H�Υ������ɩ������Z���A�ñN���G���O�g�Jhw3_check.txt�Bhw3_result.txt��
% �g�o�����A�|�]����[

clear;
clear global;

template_num = 6; %��X�ؤ��e
template_num2 = 4; %���h�ֲ�template
dtw_distance(template_num2, template_num, template_num2, template_num) = 0;
dtw_accuracy(template_num2, template_num) = 0;

for g = 1:template_num2
	for w = 1:template_num

		% ���o���խ��ɪ��S�x�V�q ----------------------------------------------
		fileName = ['wav/w', num2str(g-1), '_', num2str(w-1), '.wav'];
		% fileName = ['fsdd/', num2str(w-1), '_jackson_', num2str(g-1), '.wav'];
		[epd_y, fs, epd_start, epd_end, y] = my_epd(fileName);
		feature_mfcc = my_mfcc(epd_y, fs);
		[feature_size, frame_num] = size(feature_mfcc);

		% �ҪO ----------------------------------------------------------------
		for i2 = 1:template_num2
			for i = 1:template_num

				% ���otemplate���ɪ��S�x�V�q�A_t���template
				fileName_t = ['wav/w', num2str(i2-1), '_', num2str(i-1), '.wav'];
				% fileName_t = ['fsdd/', num2str(i-1), '_jackson_', num2str(i2-1), '.wav'];
				[epd_y_t, fs_t, epd_start_t, epd_end_t, y_t] = my_epd(fileName_t);
				feature_mfcc_t = my_mfcc(epd_y_t, fs_t);
				[feature_size_t, frame_num_t] = size(feature_mfcc_t);

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
				dtw_distance(g, w, i2, i) = dtw_grid_c(dtw_grid, frame_num, frame_num_t);

				clear fileName_t epd_y_t fs_t feature_mfcc_t feature_size_t frame_num_t dtw_grid epd_start_t epd_end_t y_t;

			end
			% �O�U���T�v
			[temp_min, temp_min_index] = min(dtw_distance(g, w, i2, :));
			if temp_min_index == w
				dtw_accuracy(g, w) = dtw_accuracy(g, w) + 1;
			end

		end

		clear fileName epd_y fs feature_mfcc feature_size frame_num epd_start epd_end y;

	end
end

% �g�J���G --------------------------------------------------------------------
% �ˬd��Y�Ӧr�����ɩ��������Z���A�Y�P��L���ɶZ���j��ܥi������n:
% ...
% 
% wX_3:
%     0_3 1_3 2_3 3_3 4_3
% 0_3 
% 1_3 
% 2_3    ... �Z�� ...
% 3_3 
% 4_3 
% 
% wX_4:
% ...
txt_check = fopen('hw3_check.txt','w');
for w = 1:template_num
	fprintf(txt_check, 'wX_%d\n', w-1);
	% fprintf(txt_check, '%d_jackson_X\n', w-1);
	for g = 1:template_num2
		for g2 = 1:template_num2
			fprintf(txt_check, '%5.2f  ', dtw_distance(g, w, g2, w));
		end
		fprintf(txt_check, '\n');
	end
	fprintf(txt_check, '\n');
end
fclose(txt_check);

% �������ɩ������Z��:
% 
%     0_0 0_1 0_2 0_3 0_4 1_0 1_1 1_2 ...
% 0_0 
% 0_1 
% 0_2 
% 0_3 
% 0_4           ... �Z�� ...
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

% �U�ӭ��ɥ��T�v�P�U�ؤ��e���T�v:
%
clear temp_accuracy;
txt_accuracy = fopen('hw3_accuracy.txt','w');
for g = 1:template_num2
	for w = 1:template_num
		fprintf(txt_accuracy, 'w%d_%d: %d/%d(%4.2f%%)\n', g-1, w-1, dtw_accuracy(g, w)-1, template_num2-1, (dtw_accuracy(g, w)-1)/(template_num2-1)*100);
		% fprintf(txt_accuracy, '%d_jackson_%d: %d/%d(%4.2f%%)\n', w-1, g-1, dtw_accuracy(g, w)-1, template_num2-1, (dtw_accuracy(g, w)-1)/(template_num2-1)*100);
	end
end
fprintf(txt_accuracy, '\n\r');
temp_accuracy(template_num) = 0;
for w = 1:template_num
	for g = 1:template_num2
		temp_accuracy(w) = temp_accuracy(w) + dtw_accuracy(g, w)-1;
	end
	fprintf(txt_accuracy, 'wX_%d: %d/%d(%4.2f%%)\n', w-1, temp_accuracy(w), template_num2*(template_num2-1), temp_accuracy(w)/(template_num2*(template_num2-1))*100);
	% fprintf(txt_accuracy, '%d_jackson_X: %d/%d(%4.2f%%)\n', w-1, temp_accuracy(w), template_num2*(template_num2-1), temp_accuracy(w)/(template_num2*(template_num2-1))*100);
end
fclose(txt_accuracy);

