%
% Universidade de Brasilia, PPGEE
% Image Processing, 1/2019
% 
% Detection of the Moire Effect on images
% Author: Leticia Camara van der Ploeg, 19/0005807

clear, clc, close all;
folder = '/Users/leticiacvdploeg/Documents/MATLAB/PDI_T3_MOIRE_DETECTION/result_icons';
resultIcons = imageSet(folder);
isNotMoire = read(resultIcons, 1);
%isNotMoire = imresize(isNotMoire,0.3);
isMoire = read(resultIcons, 2);
%isMoire = imresize(isMoire,0.3);

%% Input from user

prompt = '*** Moire Detection ***\n\nInput image name (with extension): ';
imgFileName = input(prompt,'s');
while (exist(imgFileName, 'file') == 0)
    clc
    fprintf('\nFile %s does not exist. Try again.\n', imgFileName);
    prompt = '\nInput image name (with extension): ';
    imgFileName = input(prompt,'s');
end
img = imread(imgFileName);
img = imresize(img, 0.5);
imgFloat = im2double(img);

%% Image's Fourier Transform

% FFT of the gray-scaled image
grayImg = rgb2gray(imgFloat);
FFTgrayImg = fft2(grayImg);

% Displays FFTs
figure;
subplot(3,3,1); imshow(img); title('Input Image');
amplitudeImage = log(1 + abs(fftshift(FFTgrayImg)));
subplot(3,3,2); imshow(amplitudeImage, []); title('Gray Scaled Image Spectrum');
%set(gcf, 'units','normalized','outerposition',[0 0 1 1]); % Enlarge figure to full-screen


%% Frequency domain filtering

% Finds the location of the central spike
R = size(amplitudeImage, 1);
C = size(amplitudeImage, 2);
axisX = R/2;
axisY = C/2;
[x, y] = meshgrid(-axisX:(axisX-1), -axisY:(axisY-1));
z = sqrt(x.^2 + y.^2);
c = z > 150; % set > 50 if input image = original (due to the size of the image)
hp = amplitudeImage .* c'; % High-pass filter

subplot(3,3,4); imshow(hp, []); title('Spectrum after high-pass filtering');


%% Looks for "big enough" bright spikes (if it exists, we say the image has a Moire pattern)

amplitudeThreshold = 5;
brightSpikes = hp > amplitudeThreshold;
subplot(3,3,5); imshow(brightSpikes); title('Bright spikes'); 


% Until now the bright spikes could be just noise, so we need to check if we
% find bright circles big enough to call it a moire pattern sign  

% Get only the biggest blob
[L, num] = bwlabel(brightSpikes);
counts = sum(bsxfun(@eq, L(:), 1:num));
[~, elements] = size(counts);
if elements >= 1
    [~,ind] = max(counts);
    brightSpikes = (L == ind);
    subplot(3,3,6); imshow(brightSpikes); title('The biggest bright spike');

    % Find the area of the blob
    stats = regionprops(brightSpikes, 'Area');
    area = stats.Area;
    result = find([stats.Area] > 300);
else
    subplot(3,3,6); imshow(brightSpikes); title('The biggest bright spike');
    result = 0;
end

if result == 1
    subplot(3,3,3); imshow(isMoire);
else
    subplot(3,3,3); imshow(isNotMoire);
end

