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
[M,N]=size(data);
%% 将缺失值剔除
[row,column]=find(isnan(data)==1);%缺失值所在位置坐标
t=1;
for i=1:M
    if ismember(i,row)==0
        data_delete(t,:)=data(i,:);
        t=t+1;
    end
end
xlswrite('data_deletemissing.xlsx',data_delete);
%% 用最高频率值来填补缺失值
data_mode=data;%对缺失数据置为-1
for column=1:N
    numdata=data(:,column);
    numtab=tabulate(numdata);
    %统计矩阵中元素出现的次数，第一列为元素，第二列为次数，第三列为百分比
    [ma,pos]=max(numtab(:,2));
    for row=1:M
        if isnan(data(row,column))==1
            data_mode(row,column)=numtab(pos,1);
        end
    end
end
xlswrite('data_mode.xlsx',data_mode);
%% 通过属性的相关关系来填补缺失值
corr_test=data;corr_test(:,3)=[];%剔除ID列
data_coor=data;data_coor(:,3)=[];%剔除ID列
r=zeros(27);p=zeros(27);
corr_test(isnan(corr_test)==1)=0;%NAN数据置0以便计算相关性
for i=1:27
    for j=1:27
        feature1=corr_test(:,i);
        feature2=corr_test(:,j);
        [r(i,j),p(i,j)]=corr(feature1,feature2);%r为相关系数,p为置信区间
    end
end
for i=1:27
    p(i,i)=1;
end
sign=zeros(27,4);
%sign用来存储相关和拟合的结果，第一列为Y，第二列为X，第三列为k，第四列为b
for k=1:27
    [pmin,qmin]=min(abs(p(k,:)));%置信区间最小的值
    sign(k,1)=k;%Y所在的列
    sign(k,2)=qmin;%X所在的列
end
for k=1:27
    vector1=corr_test(:,sign(k,1));%Y
    vector2=corr_test(:,sign(k,2));%X
    sign(k,3:4)=polyfit(vector2,vector1,1);%线性拟合系数
end
for column=1:27
    k=sign(column,3);
    b=sign(column,4);
    x=sign(column,2);
    for row=1:M
        if isnan(data_coor(row,column))==1
            data_coor(row,column)=k*data_coor(row,x)+b;
        end
    end
end
data_corr(:,1:2)=data_coor(:,1:2);
data_corr(:,3)=data(:,3);
data_corr(:,4:28)=data_coor(:,3:27);
xlswrite('data_corr.xlsx',data_corr);
%% 通过数据对象之间的相似性来填补缺失值
cos_sim=data;cos_sim(:,3)=[];%剔除ID列
data_cos=data;data_cos(:,3)=[];%剔除ID列
sim=zeros(27);
cos_sim(isnan(cos_sim)==1)=0;%NAN数据置0以便计算相关性
%使用余弦相似性进行相似性度量
for i=1:27
    for j=1:27
        feature1=cos_sim(:,i);
        feature2=cos_sim(:,j);
        sim(i,j)=sum(feature1.*feature2)/...
            (sqrt(sum(feature1.*feature1))*sqrt(sum(feature2.*feature2)));
    end
end
for i=1:27
    sim(i,i)=0;
end
sign_sim=zeros(27,2);
%sign用来存储相关和拟合的结果，第一列为Y，第二列为X
for k=1:27
    [smax,pmax]=max(sim(k,:));%余弦相似性最大值
    sign_sim(k,1)=k;%Y所在的列
    sign_sim(k,2)=pmax;%X所在的列
end
for column=1:27
    x=sign_sim(column,2);
    for row=1:M
        if isnan(data_cos(row,column))==1
            data_cos(row,column)=data_cos(row,x);
        end
    end
end
data_sim(:,1:2)=data_cos(:,1:2);
data_sim(:,3)=data(:,3);
data_sim(:,4:28)=data_cos(:,3:27);
xlswrite('data_sim.xlsx',data_sim);
%% 可视化比较新旧数据集
for column=1:N
    %对标称属性绘制散点图进行比较
    if ismember(column,categorylist)==1
        %
        figure;subplot(221);plot(data(:,column),'r*');hold on;
        plot(data_delete(:,column),'b.');hold off;
        title(strcat(listname(column),'的散点图'));
        legend('pre_data','data_deletemissing');
        %
        subplot(222);plot(data(:,column),'r*');hold on;
        plot(data_mode(:,column),'b.');hold off;
        title(strcat(listname(column),'的散点图'));
        legend('pre_data','data_mode');
        %
        subplot(223);plot(data(:,column),'r*');hold on;
        plot(data_corr(:,column),'b.');hold off;
        title(strcat(listname(column),'的散点图'));
        legend('pre_data','data_corr');
        %
        subplot(224);plot(data(:,column),'r*');hold on;
        plot(data_sim(:,column),'b.');hold off;
        title(strcat(listname(column),'的散点图'));
        legend('pre_data','data_sim');
    elseif ismember(column,valuelist)==1
        %对数值属性比较均值
        %原始数据
        valdata1=data(:,column);
        valdata1(isnan(valdata1)==1)=0;%缺失值置0
        pre_mean=mean(valdata1);%均值
        %剔除缺失值
        valdata1=data_delete(:,column);
        valdata1(isnan(valdata1)==1)=0;%缺失值置0
        delete_mean=mean(valdata1);%均值
        %众数补齐
        valdata1=data_mode(:,column);
        valdata1(isnan(valdata1)==1)=0;%缺失值置0
        mode_mean=mean(valdata1);%均值
        %相关补齐
        valdata1=data_corr(:,column);
        valdata1(isnan(valdata1)==1)=0;%缺失值置0
        corr_mean=mean(valdata1);%均值
        %相似性补齐
        valdata1=data_sim(:,column);
        valdata1(isnan(valdata1)==1)=0;%缺失值置0
        sim_mean=mean(valdata1);%均值
        mean_data=[pre_mean,delete_mean,mode_mean,corr_mean,sim_mean];
        figure;bar(mean_data);
        title(strcat(listname(column),'的均值直方图'));
        set(gca,'XTickLabel',{'pre_mean','delete_mean','mode_mean',...
            'corr_mean','sim_mean'});
    end
end