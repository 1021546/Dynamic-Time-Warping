function [dtw_grid_c_value] = dtw_grid_c(dtw_grid, dtw_x, dtw_y)

if (dtw_x == 1) && (dtw_y == 1)
	dtw_grid_c_value = dtw_grid(dtw_x, dtw_y);
elseif dtw_x == 1
	dtw_grid_c_value = dtw_grid(dtw_x, dtw_y) + dtw_grid_c(dtw_grid, dtw_x, dtw_y-1);
elseif dtw_y == 1
	dtw_grid_c_value = dtw_grid(dtw_x, dtw_y) + dtw_grid_c(dtw_grid, dtw_x-1, dtw_y);
else
	% temp_min = dtw_grid_c(dtw_grid, dtw_x-1, dtw_y);
	% if(dtw_grid_c(dtw_grid, dtw_x, dtw_y-1) < temp_min)
	% 	temp_min = dtw_grid_c(dtw_grid, dtw_x, dtw_y-1);
	% end
	% if(dtw_grid_c(dtw_grid, dtw_x-1, dtw_y-1) < temp_min)
	% 	temp_min = dtw_grid_c(dtw_grid, dtw_x-1, dtw_y-1);
	% end
	% dtw_grid_c_value = dtw_grid(dtw_x, dtw_y) + temp_min;
	dtw_grid_c_value = dtw_grid(dtw_x, dtw_y) + min(dtw_grid_c(dtw_grid, dtw_x-1, dtw_y), min(dtw_grid_c(dtw_grid, dtw_x, dtw_y-1), dtw_grid_c(dtw_grid, dtw_x-1, dtw_y-1)));
end
