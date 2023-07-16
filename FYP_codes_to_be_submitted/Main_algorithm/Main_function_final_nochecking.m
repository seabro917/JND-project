% Final main algorithm without further bitrate checking.
function [QP_result, searching_level] = Main_function_final_nochecking(mode_flag,N,video_index,SUR_value,Bitrate_condition,pdf_model)
% Main function
% First assume we have encoded the original video with three QP values, then
% we use the bitrate of these three QP values to apply linear least squares
% to do the curve fitting(assume exponential model). Then we use the
% resulting function as the relationship between QP value and bitrate for
% this video.(In this part, I used the points of QP value 10, 15 and 32.)
% Inputs:
%   mode_flag: Flag for choosing either using ground truth bitrate data(for
%   testing) or using three points to do lls to get fitting bitrate data.
%   N: Search iteration, maximum of 3.
%   video_index: index of the video in VideoSet.
%   SUR_value: satisfied user ratio requirement.
%   Bitrate_condition: Bitrate constraint.
%   pdf_model: probability density function used for modeling JND sample
%   data.
% Output:
%   QP_result: Returned QP value.
%   searching_level: The JND level at which the result was found.
% Note that: please add the JND samples data the specified path of your own PC.

% % Data fitting section
% This matrix stores the all the bitrate data for all 220 videos, since we
% had 220 videos in total, with QP values ranging from 0-51, the size of
% the matrix was 52*220.
% This is the path where I saved JND samples data, please change this path
% for individual uses.
bitrate_data_ground_truth = load (['D:\Studying\Matlab_MyScript\' ...
    'Daily learning\test_project_draft\Folder for classification\' ...
    'About_bitrate\curve fitting(without first 8 points)\' ...
    'Reality_bitrate_data\Bitrate_data_for_all_videos.mat']);

% Switch mode for changing bitrate data used, '1' stands for using three
% points to do lls and use fitting bitrate data, '0' stands for using ground
% truth bitrate data (for testing purpose).

% Using fitting bitrate data.
if (mode_flag == 0)
    % In order to do the curve fitting, the matrix should be a column matrix.
    QP = [10;15;32];
    % Since my model for the relationship between bitrate and QP value is a
    % exponential model with function: y = a*exp(b*x). We can take the 'ln' for
    % both sides of the function and get ln(y) = ln(a) + bx, then use the
    % lineaar least squares algorithm to do the curve fitting.
    % Note that during my experiment, I found that the fitting result may vary
    % when I applied different fitting algorithms and number of points used for
    % doing the fitting. And fially I deceided to use 3 points to do the linear
    % least squares, with the exponential model. (Using the relationship mentioned
    % above.) I chose points with QP values 10, 15 and 32.
    bitrate_matrix_temp = [log(bitrate_data_ground_truth.bitrate_data(11,video_index));...
        log(bitrate_data_ground_truth.bitrate_data(16,video_index));log(bitrate_data_ground_truth.bitrate_data(33,video_index))];
    fit_obj = fit(QP,bitrate_matrix_temp,'poly1');
    p1_coefficient = fit_obj.p1;
    p2_coefficient = fit_obj.p2;
    % Calculate the final coefficients. And use these coefficients to build the
    % relationship between QP value and bitrate.
    a_coefficient = exp(p2_coefficient);
    b_coefficient = p1_coefficient;
    % Get all the bitrate data for this video based on the curve fitting result.
    x = 8:47;
    bitrate_matrix_used_for_comparison = a_coefficient * exp(b_coefficient * x);
    
    % Using ground truth bitrate data.
elseif (mode_flag == 1)
    bitrate_matrix_used_for_comparison = bitrate_data_ground_truth.bitrate_data(9:48,video_index);
end

% % Main searching section
% Initialize the finding QP result as -1.
QP_result_final = -1;

% Second find the QP value point corresponding to the SUR condition.(In this
% step we assume that we have already had the pdf of the JND points).
% We should start from the 1st JND point, if no such QP value is found,
% then we should carry on with 2nd and 3rd JND points.
for i = 1:N
    % % SUR model and find QP based on SUR only section.    
    QP_result_temp = find_QP_based_on_different_pdfs(video_index,SUR_value,i,pdf_model);
   
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
    QP_result = 0;
    searching_level = 0;
    disp_str = ['Fail to find a QP value that meets all requirements.'];
    % Case where the bitrate requirement was too large, since I only consider QP value
    % from 8, this case should be dealt with.(Because we had such 'same filesize' issue for 
    % QP ranging from 0 to 7, meaning that first 8 points should be excluded.)
elseif(QP_result_final <= 9)
%     searching_flag = -1;
    QP_result = 9;
    searching_level = i;
    %     QP_based_on_ECDF = NaN;
    %     searching_level = NaN;
    disp_str = ['Requirements are too loose, searching result is too close to QP value 8.'];
else
%     searching_flag = 1;
    QP_result = QP_result_final;
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
% Note thta this piece of code is further improved based on my previous
% work, and this code could use different kinds of PDFs to model the JND
% sample data.
function QP_result = find_QP_based_on_different_pdfs (video_index,SUR_value,level,pdf_model)
% Use the pre-defined functio to read corresponding data into workspace.
sample_data = my_sample_transform(video_index,level);
% Fit the data to the given distribution model.
dist_obj = fitdist(sample_data',pdf_model);
Inverse_QP_result = icdf(dist_obj,1 - SUR_value);
% To check whether the output of icdf is an integer (Because for instance
% if Possion pdf is used, because Possion distribution is discrete
% distribution, then the output is an integer not an double.
if rem(Inverse_QP_result,1) == 0
    % If by chance, the cdf value corresponding to the inverse QP result we
    % calculate is exactly the (1 - required SUR value), then it is the exactly
    % result we want (this is relatively unlikely to happen), else, the result QP value should be substracted by 1.
    if (cdf(dist_obj,Inverse_QP_result) == 1 - SUR_value)
        QP_result = Inverse_QP_result;
    else
        QP_result = Inverse_QP_result - 1;
    end
    % Else, the output is of icdf is not an integer, meaning that the PDF model
    % chosen is a continuous one, then directly use 'floor' function to round
    % it to zero.
else
    QP_result = floor(Inverse_QP_result);
end
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

% Function for comparison.
function flag = Compare_bitrate(bitrate_corrresponding_fitting,bitrate_reality)
if (bitrate_corrresponding_fitting > bitrate_reality)
    flag = -1;
else
    flag = 1;
end
end

