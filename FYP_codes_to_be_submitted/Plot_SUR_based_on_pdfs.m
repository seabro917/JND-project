% This function is used for ploting the SUR curve of given video, with
% given PDF model used.
function Plot_SUR_based_on_pdfs(video_index,level,pdf_model)
sample_data = my_sample_transform(video_index,level);
% Fit the data to the given distribution model.
dist_obj = fitdist(sample_data',pdf_model);
% The range of QP value.
QP_value = 0:51;
% The cdf of the resulting model.
obj_cdf = cdf(dist_obj,QP_value);
% SUR curve.
SUR = 1 - obj_cdf;
plot(QP_value,SUR,'-o')
hold on;
grid on;
xlabel('QP value');
ylabel('SUR value');
end

