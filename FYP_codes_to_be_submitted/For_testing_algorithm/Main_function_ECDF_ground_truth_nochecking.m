% Testing algorithm without further bitrate checking, where empirical CDF and ground truth
% bitrate data were used for finding the ground truth QP.
function [QP_based_on_ECDF, searching_level] = Main_function_ECDF_ground_truth_nochecking(N,video_index,SUR_value,Bitrate_condition)
% Main function
% First assume we have encoded the original video with three QP values, then
% we use the bitrate of these three QP values to apply linear least squares
% to do the curve fitting(assume exponential model). Then we use the
% resulting function as the relationship between QP value and bitrate for
% this video.(In this part, I used the points of QP value 10, 15 and 32.)
% Inputs:
%   N: Search iteration, maximum of 3.
%   video_index: index of the video in VideoSet.
%   SUR_value: satisfied user ratio requirement.
%   Bitrate_condition: Bitrate constraint.
%   pdf_model: probability density function used for modeling JND sample
%   data.
% Output:
%   Returned QP value and its corresponding JND level.

% % Data fitting section
% This matrix stores the all the bitrate data for all 220 videos, since we
% had 220 videos in total, with QP values ranging from 0-51, the size of
% the matrix was 52*220.
bitrate_data_ground_truth = load (['D:\Studying\Matlab_MyScript\' ...
    'Daily learning\test_project_draft\Folder for classification\' ...
    'About_bitrate\curve fitting(without first 8 points)\' ...
    'Reality_bitrate_data\Bitrate_data_for_all_videos.mat']);
bitrate_matrix_used_for_comparison = bitrate_data_ground_truth.bitrate_data(9:48,video_index);

% % Main searching section
% Initialize the finding QP result as -1.
QP_result_final = -1;

% Second find the QP value point corresponding to the SUR condition.(In this
% step we assume that we have already had the pdf of the JND points).
% We should start from the 1st JND point, if no such QP value is found,
% then we should carry on with 2nd and 3rd JND points.
for i = 1:N
    % % SUR model and find QP based on SUR only section.    
    QP_result_temp = Find_QP_based_on_SUR_ECDF(video_index,i, SUR_value);
   
    % Third compare the bitrate of the QP value calculated above to the
    % requirement.
    % % Searching section.
    flag_outter = Compare_bitrate(bitrate_matrix_used_for_comparison(QP_result_temp-7),Bitrate_condition);
    if (flag_outter == -1)
        continue;
    else
        % Else, we find the QP value, then withouting search for a smaller QP
        % value, we directly return this QP value and stop the searching
        % iteration.
        QP_result_final = QP_result_temp;
        break;
    end
    
end

if (QP_result_final == -1)
%     searching_flag = 0;
    QP_based_on_ECDF = 0;
    searching_level = 0;
    disp_str = ['Fail to find a QP value that meets all requirements.'];
    % Case where the bitrate requirement was too large, since I only consider QP value
    % from 7, this should be dealt with.
elseif(QP_result_final <= 9)
%     searching_flag = -1;
    QP_based_on_ECDF = 9;
    searching_level = i;
%     QP_based_on_ECDF = NaN;
%     searching_level = NaN;
    disp_str = ['Requirements are too loose, searching result is too close to QP value 8.'];
else
%     searching_flag = 1;
    QP_based_on_ECDF = QP_result_final;
    searching_level = i;
    switch i
        case 1
            num_str = '1st';
        case 2
            num_str = '2nd';
        otherwise
            num_str = '3rd';
    end
    disp_str = ['The found QP value is in the SUR vurve corresponding to ' num_str ' JND points.'...
        'The found QP value is ' int2str(QP_result_final)];
end
% disp(disp_str);
end

% Find the QP value corresponding to the given video clip under given SUR
% requirement.
% Note that here I am using the empirical CDF to find the ground truth QP.
function QP_based_on_ECDF = Find_QP_based_on_SUR_ECDF(video_index, JND_level, SUR_value)
data_under_consideration = my_sample_transform(video_index, JND_level);
% y is the empirical CDF value of x.
[y,x] = ecdf(data_under_consideration);
QP = x';
SUR = 1 - y';
index = find(SUR >= SUR_value);
QP_based_on_ECDF = QP(index(end));
end


% To get the Nth JND sample values of given video index and transform the
% data from cell type to the matrix type which is easier for following
% processing and analysing.
function [QP_sample_matrix] = my_sample_transform(video_index,level)
switch level
    case 1
        filename_str = 'D:\Studying\Matlab_MyScript\Daily learning\test_project_draft\1280x720_1st.csv';
    case 2
        filename_str = 'D:\Studying\Matlab_MyScript\Daily learning\test_project_draft\1280x720_2nd.csv';
    case 3
        filename_str = 'D:\Studying\Matlab_MyScript\Daily learning\test_project_draft\1280x720_3rd.csv';
    otherwise
        error("Please input a correct level of JND");
end
sample_index = ['E' int2str(video_index + 1) ':' 'E' int2str(video_index + 1) ];
% The second term of the output of 'xlsread' function includes the contents that are
% not data, and converts it into a cell matrix.
[num, QP_sample_cell] = xlsread(filename_str,sample_index);
% Convert the cell matrix to the char matrix.
QP_sample_char = cell2mat(QP_sample_cell);
% Convert the char matrix to the double matrix.
QP_sample_matrix = str2num(QP_sample_char);
end


function flag = Compare_bitrate(bitrate_corrresponding_fitting,bitrate_reality)
if (bitrate_corrresponding_fitting > bitrate_reality)
    flag = -1;
else
    flag = 1;
end
end

