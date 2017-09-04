function hamming_y = my_hamming(hamming_x, hamming_size)
hamming_y = 0.54-0.46*cos(2*pi*hamming_x/(hamming_size-1)); 
