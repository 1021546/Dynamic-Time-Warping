function [cepDpDD] = my_mfcc(y, fs)

% -----------------------------------------------
% MFCC
% 參考 http://www.ee.columbia.edu/~dpwe/resources/matlab/rastamat/

%{
% Load a speech waveform
[d,sr] = wavread('sm1_cln.wav');

% Look at its regular spectrogram
subplot(411)
specgram(d, 256, sr);

% Calculate basic RASTA-PLP cepstra and spectra and plot them
[cep1, spec1] = rastaplp(d, sr);
subplot(412)
imagesc(10*log10(spec1)); % Power spectrum, so dB is 10log10
axis xy
subplot(413)
imagesc(cep1)
axis xy

% Calculate 12th order PLP features without RASTA and plot them
[cep2, spec2] = rastaplp(d, sr, 0, 12);
subplot(414)
imagesc(10*log10(spec2));
axis xy
%}

% [y,fs] = audioread('w0_0.wav');
[cep2, spec2] = rastaplp(y, fs, 0, 12);

% Append deltas and double-deltas onto the cepstral vectors
del = deltas(cep2);
% Double deltas are deltas applied twice with a shorter window
ddel = deltas(deltas(cep2,5),5);
% Composite, 39-element feature vector, just like we use for speech recognition
cepDpDD = [cep2;del;ddel];
