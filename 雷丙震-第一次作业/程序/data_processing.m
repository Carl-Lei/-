clear;close all;clc;
%% ��������
data=xlsread('horse-colic.xlsx');
%ÿ����������Ӧ����������
listname={'surgery','age','hospital number','rectal temperture','pulse',...
    'respiratory rate','temperature of extremities','peripheral pulse',...
    'mucous membranes','capillary refill time','pain','peristalsis',...
    'abdominal distension','nasogastric tube','nasogastric reflux'...
    'nasogastric reflux PH','rectal examination','abdomen',...
    'packed cell volume','total protein','abdominocentesis appearance',...
    'abdomcentesis total protein','outcome','surgical lesion','type of lesion'...
    'type of lesion 26','type of lesion 27','cp_data'};
%�������������
categorylist=[1,2,7,8,9,10,11,12,13,14,15,17,18,21,23,24,25,26,27,28];
category_num=size(categorylist,2);
%��ֵ����������
valuelist=[4,5,6,16,19,20,22];
%��3��ID��û��ͳ��ѧ���壬�������ݷ���֮��
value_num=size(valuelist,2);
[M,N]=size(data);
%% ��ȱʧֵ�޳�
[row,column]=find(isnan(data)==1);%ȱʧֵ����λ������
t=1;
for i=1:M
    if ismember(i,row)==0
        data_delete(t,:)=data(i,:);
        t=t+1;
    end
end
xlswrite('data_deletemissing.xlsx',data_delete);
%% �����Ƶ��ֵ���ȱʧֵ
data_mode=data;%��ȱʧ������Ϊ-1
for column=1:N
    numdata=data(:,column);
    numtab=tabulate(numdata);
    %ͳ�ƾ�����Ԫ�س��ֵĴ�������һ��ΪԪ�أ��ڶ���Ϊ������������Ϊ�ٷֱ�
    [ma,pos]=max(numtab(:,2));
    for row=1:M
        if isnan(data(row,column))==1
            data_mode(row,column)=numtab(pos,1);
        end
    end
end
xlswrite('data_mode.xlsx',data_mode);
%% ͨ�����Ե���ع�ϵ���ȱʧֵ
corr_test=data;corr_test(:,3)=[];%�޳�ID��
data_coor=data;data_coor(:,3)=[];%�޳�ID��
r=zeros(27);p=zeros(27);
corr_test(isnan(corr_test)==1)=0;%NAN������0�Ա���������
for i=1:27
    for j=1:27
        feature1=corr_test(:,i);
        feature2=corr_test(:,j);
        [r(i,j),p(i,j)]=corr(feature1,feature2);%rΪ���ϵ��,pΪ��������
    end
end
for i=1:27
    p(i,i)=1;
end
sign=zeros(27,4);
%sign�����洢��غ���ϵĽ������һ��ΪY���ڶ���ΪX��������Ϊk��������Ϊb
for k=1:27
    [pmin,qmin]=min(abs(p(k,:)));%����������С��ֵ
    sign(k,1)=k;%Y���ڵ���
    sign(k,2)=qmin;%X���ڵ���
end
for k=1:27
    vector1=corr_test(:,sign(k,1));%Y
    vector2=corr_test(:,sign(k,2));%X
    sign(k,3:4)=polyfit(vector2,vector1,1);%�������ϵ��
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
%% ͨ�����ݶ���֮������������ȱʧֵ
cos_sim=data;cos_sim(:,3)=[];%�޳�ID��
data_cos=data;data_cos(:,3)=[];%�޳�ID��
sim=zeros(27);
cos_sim(isnan(cos_sim)==1)=0;%NAN������0�Ա���������
%ʹ�����������Խ��������Զ���
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
%sign�����洢��غ���ϵĽ������һ��ΪY���ڶ���ΪX
for k=1:27
    [smax,pmax]=max(sim(k,:));%�������������ֵ
    sign_sim(k,1)=k;%Y���ڵ���
    sign_sim(k,2)=pmax;%X���ڵ���
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
%% ���ӻ��Ƚ��¾����ݼ�
for column=1:N
    %�Ա�����Ի���ɢ��ͼ���бȽ�
    if ismember(column,categorylist)==1
        %
        figure;subplot(221);plot(data(:,column),'r*');hold on;
        plot(data_delete(:,column),'b.');hold off;
        title(strcat(listname(column),'��ɢ��ͼ'));
        legend('pre_data','data_deletemissing');
        %
        subplot(222);plot(data(:,column),'r*');hold on;
        plot(data_mode(:,column),'b.');hold off;
        title(strcat(listname(column),'��ɢ��ͼ'));
        legend('pre_data','data_mode');
        %
        subplot(223);plot(data(:,column),'r*');hold on;
        plot(data_corr(:,column),'b.');hold off;
        title(strcat(listname(column),'��ɢ��ͼ'));
        legend('pre_data','data_corr');
        %
        subplot(224);plot(data(:,column),'r*');hold on;
        plot(data_sim(:,column),'b.');hold off;
        title(strcat(listname(column),'��ɢ��ͼ'));
        legend('pre_data','data_sim');
    elseif ismember(column,valuelist)==1
        %����ֵ���ԱȽϾ�ֵ
        %ԭʼ����
        valdata1=data(:,column);
        valdata1(isnan(valdata1)==1)=0;%ȱʧֵ��0
        pre_mean=mean(valdata1);%��ֵ
        %�޳�ȱʧֵ
        valdata1=data_delete(:,column);
        valdata1(isnan(valdata1)==1)=0;%ȱʧֵ��0
        delete_mean=mean(valdata1);%��ֵ
        %��������
        valdata1=data_mode(:,column);
        valdata1(isnan(valdata1)==1)=0;%ȱʧֵ��0
        mode_mean=mean(valdata1);%��ֵ
        %��ز���
        valdata1=data_corr(:,column);
        valdata1(isnan(valdata1)==1)=0;%ȱʧֵ��0
        corr_mean=mean(valdata1);%��ֵ
        %�����Բ���
        valdata1=data_sim(:,column);
        valdata1(isnan(valdata1)==1)=0;%ȱʧֵ��0
        sim_mean=mean(valdata1);%��ֵ
        mean_data=[pre_mean,delete_mean,mode_mean,corr_mean,sim_mean];
        figure;bar(mean_data);
        title(strcat(listname(column),'�ľ�ֱֵ��ͼ'));
        set(gca,'XTickLabel',{'pre_mean','delete_mean','mode_mean',...
            'corr_mean','sim_mean'});
    end
end