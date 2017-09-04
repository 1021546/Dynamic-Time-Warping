function [dtw_grid_c_value] = dtw_grid_c(dtw_grid, dtw_x, dtw_y)
% @dtw_grid_c: Dynamic Time Warping的遞迴作法
% @dtw_grid: 歐式距離表格
% @dtw_x: 指定座標x
% @dtw_y: 指定座標y
% @dtw_grid_c_value: 指定座標的累積距離值

% -----------------------------------------------
global dtw_grid2
if dtw_grid2(dtw_x, dtw_y) == 0
	if (dtw_x == 1) && (dtw_y == 1)
		dtw_grid2(dtw_x, dtw_y) = dtw_grid(dtw_x, dtw_y);
	elseif dtw_x == 1
		dtw_grid2(dtw_x, dtw_y) = dtw_grid(dtw_x, dtw_y) + dtw_grid_c(dtw_grid, dtw_x, dtw_y-1);
	elseif dtw_y == 1
		dtw_grid2(dtw_x, dtw_y) = dtw_grid(dtw_x, dtw_y) + dtw_grid_c(dtw_grid, dtw_x-1, dtw_y);
	else
		dtw_grid2(dtw_x, dtw_y) = dtw_grid(dtw_x, dtw_y) + min([dtw_grid_c(dtw_grid, dtw_x-1, dtw_y), dtw_grid_c(dtw_grid, dtw_x, dtw_y-1), dtw_grid_c(dtw_grid, dtw_x-1, dtw_y-1)]);
		% % 走對角則加兩倍距離的話
		% [min_temp, min_temp_index] = min([dtw_grid_c(dtw_grid, dtw_x-1, dtw_y), dtw_grid_c(dtw_grid, dtw_x, dtw_y-1), dtw_grid_c(dtw_grid, dtw_x-1, dtw_y-1)]);
		% if min_temp_index == 2
		% 	dtw_grid2(dtw_x, dtw_y) = 2*dtw_grid(dtw_x, dtw_y) + min_temp;
		% else
		% 	dtw_grid2(dtw_x, dtw_y) = dtw_grid(dtw_x, dtw_y) + min_temp;
		% end
	end
end
dtw_grid_c_value = dtw_grid2(dtw_x, dtw_y);
