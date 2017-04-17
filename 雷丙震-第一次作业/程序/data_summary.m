clear;close all;clc;
%% 读入数据
data=xlsread('horse-colic.xlsx');
%每列数据所对应的属性名称
listname={'surgery','age','hospital number','rectal temperture','pulse',...
    'respiratory rate','temperature of extremities','peripheral pulse',...
    'mucous membranes','capillary refill time','pain','peristalsis',...
    'abdominal distension','nasogastric tube','nasogastric reflux'...
    'nasogastric reflux PH','rectal examination','abdomen',...
    'packed cell volume','total protein','abdominocentesis appearance',...
    'abdomcentesis total protein','outcome','surgical lesion','type of lesion'...
    'type of lesion 26','type of lesion 27','cp_data'};
%标称属性所在列
categorylist=[1,2,7,8,9,10,11,12,13,14,15,17,18,21,23,24,25,26,27,28];
category_num=size(categorylist,2);
%数值属性所在列
valuelist=[4,5,6,16,19,20,22];
%第3列ID号没有统计学意义，不在数据分析之内
value_num=size(valuelist,2);
%% 数据摘要
disp('========================数据摘要===========================');
%标称属性，给出每个可能取值的频数
disp('  对标称属性，给出每个可能取值的频数');
for i=1:category_num%标称属性的列数
    column=categorylist(i);%在原始数据中的列数
    numdata=data(:,column);
    numtab=tabulate(numdata);
    %统计矩阵中元素出现的次数，第一列为元素，第二列为次数，第三列为百分比
    disp('  ----------------------------------');
    [m,n]=size(numtab);
    disp(strcat(listname(column),'特征中:'));
    for j=1:m
        disp(strcat('    标称',num2str(numtab(j,1)),'的频数是',num2str(numtab(j,2))));
    end
end
disp('************************我是分割线***************************');
%数值属性，给出最大、最小、均值、中位数、四分位数及缺失值的个数
disp('  数值属性，给出最大、最小、均值、中位数、四分位数及缺失值的个数');
result2=zeros(column,7);
for i=1:value_num
    column=valuelist(i);
    valdata1=data(:,column);
    valdata=data(:,column);
    disp('  -------------------------------------------------------');
    disp(strcat('数值属性',listname(column),'的特征描述：'));
    result2(i,1)=max(valdata);%最大值
    disp(strcat('     最大值是',num2str(result2(i,1))));
    result2(i,2)=min(valdata);%最小值
    disp(strcat('     最小值是',num2str(result2(i,2))));
    valdata1(isnan(valdata1)==1)=0;%缺失值置0
    result2(i,3)=mean(valdata1);%均值
    disp(strcat('     均值是',num2str(result2(i,3))));
    result2(i,4)=prctile(valdata,50);%中位数
    disp(strcat('     中位数是',num2str(result2(i,4))));
    result2(i,5)=prctile(valdata,25);%第一个四分位数
    disp(strcat('     Q1值是',num2str(result2(i,5))));
    result2(i,6)=prctile(valdata,75);%第3四分位数
    disp(strcat('     Q3值是',num2str(result2(i,6))));
    result2(i,7)=sum(isnan(valdata));%缺失值个数
    disp(strcat('     缺失值个数为',num2str(result2(i,7))));
end
%% 数据可视化
for i=1:value_num
    column=valuelist(i);
    valdata1=data(:,column);
    valdata=data(:,column);
    figure;subplot(221);hist(valdata);
    title(strcat(listname(column),'的直方图'));
    subplot(222);qqplot(valdata);
    title(strcat(listname(column),'的QQ图'));
    subplot(223);boxplot(valdata);
    title(strcat(listname(column),'的盒图'));
end