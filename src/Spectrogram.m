%% reads file into matlab This reads an array of audio samples into y,
%%%assuming the file is in the current folder
[y,Fs] = audioread('../audio/CutRoaringThunder.wav');
%y = y(1:Fs*10);
window=hamming(512); %%window with size of 512 points
noverlap=256; %%the number of points for repeating the window
nfft=1024; %%size of the fit
[S,F,T] = spectrogram(y(:,1),window,noverlap,nfft,Fs);
pcolor(T,F,log10(abs(S))),shading flat,colorbar
%spectrogram(y,window,noverlap,1024,Fs,'yaxis'); % no outputs specified will create a convenience plot
%colormap(hot) % for black and white