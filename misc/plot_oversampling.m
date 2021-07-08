clear; clc; close all;

data_eeg1 = readtable('D:\ITESM\EEG\video_experiment\EEG_test_subject_2021-02-25-20_20_08.csv');
data_eeg2 = readtable('D:\ITESM\EEG\video_experiment\EEG_test_subject_2021-02-25-20_43_30.csv');
data_eeg3 = readtable('D:\ITESM\EEG\video_experiment\EEG_test_subject_2021-02-25-21_11_33.csv');
data_eeg4 = readtable('D:\ITESM\EEG\video_experiment\EEG_test_subject_2021-02-25-21_25_51.csv');

data_ppg1 = readtable('D:\ITESM\EEG\video_experiment\PPG_test_subject_2021-02-25-20_20_08.csv');
data_ppg2 = readtable('D:\ITESM\EEG\video_experiment\PPG_test_subject_2021-02-25-20_43_30.csv');
data_ppg3 = readtable('D:\ITESM\EEG\video_experiment\PPG_test_subject_2021-02-25-21_11_33.csv');
data_ppg4 = readtable('D:\ITESM\EEG\video_experiment\PPG_test_subject_2021-02-25-21_25_51.csv');


xeeg1 = data_eeg1.timestamps;
xeeg2 = data_eeg2.timestamps;
xeeg3 = data_eeg3.timestamps;
xeeg4 = data_eeg4.timestamps;

xppg1 = data_ppg1.timestamps;
xppg2 = data_ppg2.timestamps;
xppg3 = data_ppg3.timestamps;
xppg4 = data_ppg4.timestamps;

% Plot EEGs
% Plot subject 1 @ 250
% figure();
% subplot(4,1,1);
% plot(xeeg1, data_eeg1.TP9); title('TP9');
% subplot(4,1,2);
% plot(xeeg1, data_eeg1.AF7); title('AF7');
% subplot(4,1,3);
% plot(xeeg1, data_eeg1.AF8); title('AF8');
% subplot(4,1,4);
% plot(xeeg1, data_eeg1.TP10); title('TP10');
%
% % Plot subject 1
% figure();
n = size(xeeg1);
% m = 20;
% subplot(4,1,1);
% plot(xeeg1(1:m:n), data_eeg1.TP9(1:m:n)); title('TP9');
% subplot(4,1,2);
% plot(xeeg1(1:m:n), data_eeg1.AF7(1:m:n)); title('AF7');
% subplot(4,1,3);
% plot(xeeg1(1:m:n), data_eeg1.AF8(1:m:n)); title('AF8');
% subplot(4,1,4);
% plot(xeeg1(1:m:n), data_eeg1.TP10(1:m:n)); title('TP10');
%
% figure();
% m = 100;
% subplot(4,1,1);
% plot(xeeg1(1:m:n), data_eeg1.TP9(1:m:n)); title('TP9');
% subplot(4,1,2);
% plot(xeeg1(1:m:n), data_eeg1.AF7(1:m:n)); title('AF7');
% subplot(4,1,3);
% plot(xeeg1(1:m:n), data_eeg1.AF8(1:m:n)); title('AF8');
% subplot(4,1,4);
% plot(xeeg1(1:m:n), data_eeg1.TP10(1:m:n)); title('TP10');

figure();
m = 5;
subplot(1,1,1);
hold on;
plot(xeeg1, data_eeg1.AF7); title('AF7');
plot(xeeg1(1:m:n), data_eeg1.AF7(1:m:n)); title('AF7');
hold off;

% Plot subject 2
% figure();
% subplot(4,1,1);
% plot(xeeg2, data_eeg2.TP9); title('TP9');
% subplot(4,1,2);
% plot(xeeg2, data_eeg2.AF7); title('AF7');
% subplot(4,1,3);
% plot(xeeg2, data_eeg2.AF8); title('AF8');
% subplot(4,1,4);
% plot(xeeg2, data_eeg2.TP10); title('TP10');
%
% % Plot Subject 3
% figure();
% subplot(4,1,1);
% plot(xeeg3, data_eeg3.TP9); title('TP9');
% subplot(4,1,2);
% plot(xeeg3, data_eeg3.AF7); title('AF7');
% subplot(4,1,3);
% plot(xeeg3, data_eeg3.AF8); title('AF8');
% subplot(4,1,4);
% plot(xeeg3, data_eeg3.TP10); title('TP10');
%
% % Plot subject 4
% figure();
% subplot(4,1,1);
% plot(xeeg4, data_eeg4.TP9); title('TP9');
% subplot(4,1,2);
% plot(xeeg4, data_eeg4.AF7); title('AF7');
% subplot(4,1,3);
% plot(xeeg4, data_eeg4.AF8); title('AF8');
% subplot(4,1,4);
% plot(xeeg4, data_eeg4.TP10); title('TP10');
%
% % Plot PPGs
% % Plot Subject 1
% figure();
% subplot(3,1,1);
% plot(xppg1, data_ppg1.PPG1); title('PPG1');
% subplot(3,1,2);
% plot(xppg1, data_ppg1.PPG2); title('PPG2');
% subplot(3,1,3);
% plot(xppg1, data_ppg1.PPG3); title('PPG3');
%
% % Plot Subject 2
% figure();
% subplot(3,1,1);
% plot(xppg2, data_ppg2.PPG1); title('PPG1');
% subplot(3,1,2);
% plot(xppg2, data_ppg2.PPG2); title('PPG2');
% subplot(3,1,3);
% plot(xppg2, data_ppg2.PPG3); title('PPG3');
%
% % Plot Subject 3
% figure();
% subplot(3,1,1);
% plot(xppg3, data_ppg3.PPG1); title('PPG1');
% subplot(3,1,2);
% plot(xppg3, data_ppg3.PPG2); title('PPG2');
% subplot(3,1,3);
% plot(xppg3, data_ppg3.PPG3); title('PPG3');
%
% % Plot Subject 1
% figure();
% subplot(3,1,1);
% plot(xppg4, data_ppg4.PPG1); title('PPG1');
% subplot(3,1,2);
% plot(xppg4, data_ppg4.PPG2); title('PPG2');
% subplot(3,1,3);
% plot(xppg4, data_ppg4.PPG3); title('PPG3');
