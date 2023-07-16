% To get the JND sample of the corresponding image from 
function [QP_sample_matrix] = JND_sample_transform_MCL_JCI(image_index)
filename_str = ['D:\Studying\Matlab_MyScript\JND_project_summer\About_distribution\'...
    'distribution_for_MCL_JCI\MCL-JCI_JND_samples.xlsx'];
sample_index = ['B' int2str(image_index) ':' 'B' int2str(image_index) ];

[num, QP_sample_cell] = xlsread(filename_str,sample_index);
% Convert the cell matrix to the char matrix.
QP_sample_char = cell2mat(QP_sample_cell);
% Convert the char matrix to the double matrix.
QP_sample_matrix = str2num(QP_sample_char);
end







