% Autor: Angel Cumbe

clear,clc,close all

%___________________________________________________________
% Initialization of the audio file:
%___________________________________________________________
frameLength = 512*3;  % Samples per simulation step

[nameFile,pathAudio] = uigetfile('*.mp3;*.wav','Select an mp3 or wav file','');

if nameFile == 0
    msgbox('you have not selected any audio','Error');
    return
end

audioFile = [pathAudio,nameFile];

% create audio-read object:
fileReader = dsp.AudioFileReader(audioFile,'SamplesPerFrame',frameLength);

% Create an audio-playback object:
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate,'BitDepth','16-bit integer');

% Optimize the start of playback:
fileInfo = audioinfo(audioFile);
setup(deviceWriter,zeros(fileReader.SamplesPerFrame,fileInfo.NumChannels))       

fs = fileReader.SampleRate;              % Sampling frequency.
Tss = frameLength * (1 / fs);            % Simulation step time.
L = frameLength;                         % Sample size per simulation step.
NFFT = 2 ^ nextpow2 (L + 1);             % Number of FFT points.
NFFT = 2 ^ nextpow2 (NFFT + 1);          % Number of FFT points.
NFFT = 2 ^ nextpow2 (NFFT + 1);          % Number of FFT points.
NFFT = 2 ^ nextpow2 (NFFT + 1);          % Number of FFT points.
f = linspace (0,1, NFFT / 2) * 0.5 * fs; % Frequency vector initialization.
h = hamming(L);                          % Hammming window.
FFT_y = dsp.FFT('FFTLengthSource','Property','FFTLength',NFFT); % FFT DSP.

% ___________________________________________________________
% Graphics
% ___________________________________________________________
% ___________________________________
% Figure configuration:
% ___________________________________
fig_act = figure('Visible','off');
set(fig_act,'Visible','off')
set(fig_act,'Name','DSP - grafica de señal y espectro')
set(fig_act,'ToolBar','none')
set(fig_act,'Color',[0.10,0.10,0.10])
set(fig_act,'Position',[676,41,685,670])

% ___________________________________
% Configuration of Axes 1:
% ___________________________________
figure(fig_act)
ax_act_1 = subplot(2,1,1,'Parent',fig_act);
set(ax_act_1,'Selected','off')
set(ax_act_1,'SelectionHighlight','off')
title(ax_act_1,...
'\fontsize{9}Audio signal: {\color[rgb]{0.0863,0.6275,0.5216} --- Channel 1  \color[rgb]{0.9451,0.7686,0.0588} --- Channel 2} ','FontName','Century Gothic')
ylabel(ax_act_1,'Amplitude','FontWeight','bold')
xlabel(ax_act_1,'time [s]','FontWeight','bold')
grid(ax_act_1,'minor')
set(ax_act_1,'Color',[0.28,0.28,0.28])
set(ax_act_1,'XColor',[1,1,1])
set(ax_act_1,'YColor',[1,1,1])
set(ax_act_1,'YLim',[-1, 1])
set(ax_act_1,'GridAlpha',0.3)
set(ax_act_1,'GridLineStyle','-.')
set(ax_act_1,'XGrid','on')
set(ax_act_1,'YGrid','on')
set(ax_act_1,'MinorGridColor',[0.94,0.94,0.94])
set(ax_act_1,'GridColor',[1,1,1])
set(ax_act_1,'Box','on')
set(ax_act_1,'FontName','Century Gothic')
set(ax_act_1,'FontSize',10)
title(ax_act_1,...
'\fontsize{9} {\color[rgb]{1,1,1} Audio signal: \color[rgb]{0.0863,0.6275,0.5216} --- Channel 1  \color[rgb]{0.9451,0.7686,0.0588} --- Channel 2} ','FontName','Century Gothic')

% ___________________________________
% Configuration of Axes 2:
% ___________________________________
figure(fig_act)
ax_act_2 = subplot(2,1,2,'Parent',fig_act);
set(ax_act_2,'Selected','off')
set(ax_act_2,'SelectionHighlight','off')
title(ax_act_2,...
'\fontsize{9} {\color[rgb]{1,1,1} Spectrum: \color[rgb]{0.0863,0.6275,0.5216} --- Channel 1  \color[rgb]{0.9451,0.7686,0.0588} --- Channel 2} ','FontName','Century Gothic')
ylabel(ax_act_2,'|FFT|','FontWeight','bold')
xlabel(ax_act_2,'frequency [Hz]','FontWeight','bold')
grid(ax_act_2,'minor')
set(ax_act_2,'XLim',[0,3000])
set(ax_act_2,'YLim',[-0.05, 0.2])
set(ax_act_2,'Color',[0.28,0.28,0.28])
set(ax_act_2,'XColor',[1,1,1])
set(ax_act_2,'YColor',[1,1,1])
set(ax_act_2,'GridAlpha',0.3)
set(ax_act_2,'GridLineStyle','-.')
set(ax_act_2,'XGrid','on')
set(ax_act_2,'YGrid','on')
set(ax_act_2,'MinorGridColor',[0.94,0.94,0.94])
set(ax_act_2,'GridColor',[1,1,1])
set(ax_act_2,'Box','on')
set(ax_act_2,'FontName','Century Gothic')
set(ax_act_2,'FontSize',10)   
set(fig_act,'Visible','on')


% ___________________________________________________________
% Simulation parameters:
% ___________________________________________________________
bufferSize = 2;
updPlot = bufferSize+1;
tvs = 2;
cont = tvs;
contTmp = 1;
cla_ax = 1;
t = 0;
buffer_y = zeros(frameLength*bufferSize,2);
grafs = 1;

% ___________________________________________________________
% Start simulation:
% ___________________________________________________________
while ~isDone(fileReader)
    
    t = t + Tss;        % audio time elapsed.
    y = fileReader ();  % signal frame
    deviceWriter (y);   % plays the frame
    
    %__________________________________________
    % Verify the update of the graphs:
    %__________________________________________
    if updPlot >= bufferSize
       updPlot = 1;
       buffer_y(1:frameLength,:) = y;
    else
        updPlot = updPlot + 1;
        buffer_y(frameLength*(updPlot-1)+1:frameLength*updPlot,:) = y;
    end
    
    %___________________________________
    % update graph time:
    %___________________________________
    if t>cont
        cont = cont + tvs;  % updates the maximum scale in time
        cla_ax = 1;         % Clears the time axes
    end
    
    
    if isempty(findobj(fig_act)), return, end % check the figure
    if updPlot == bufferSize
        %________________________________________
        % Fourier transform
        %________________________________________
        Y = FFT_y(y.*h);
        Ymag = sqrt(real(Y).^2 + imag(Y).^2);
        Ymag = Ymag./norm(Ymag);
        Ymag = Ymag(1:NFFT/2,:);
        
        switch grafs
        
        case 1

            % update the limits of the graph:
            if cla_ax == 1
                cla_ax = 0;
                if isempty(findobj(fig_act)), return, end % check the figure
                cla(ax_act_1)
                set(ax_act_1,'XLim',[cont-tvs,cont])
            end
            
            %________________________________________
            % Plot Signal:
            %________________________________________
            [len_y,~] = size(buffer_y);
            t_audio = linspace(t-Tss*bufferSize,t,len_y);
            if isempty(findobj(fig_act)), return, end % check the figure
            channels = line(ax_act_1,t_audio,buffer_y,'Linewidth',0.5,'LineStyle','-','Marker','none','Color',[0.9451,0.7686,0.0588],'HitTest','Off');     
            set(channels(1),'Color',[0.0863,0.6275,0.5216])
            drawnow

            %________________________________________
            % Plot Spectrum:
            %________________________________________
            if isempty(findobj(fig_act)), return, end % check the figure
            cla(ax_act_2)
            if isempty(findobj(fig_act)), return, end % check the figure
            channels = line(ax_act_2,f,Ymag,'Linewidth',0.5,'Marker','.','Color',[0.9451,0.7686,0.0588],'HitTest','Off');     
            set(channels(1),'Color',[0.0863,0.6275,0.5216])
            drawnow
        end
    end
end 
% Close the input file and the audio output device.
release(fileReader)
release(deviceWriter)