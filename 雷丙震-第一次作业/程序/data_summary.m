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
%% ����ժҪ
disp('========================����ժҪ===========================');
%������ԣ�����ÿ������ȡֵ��Ƶ��
disp('  �Ա�����ԣ�����ÿ������ȡֵ��Ƶ��');
for i=1:category_num%������Ե�����
    column=categorylist(i);%��ԭʼ�����е�����
    numdata=data(:,column);
    numtab=tabulate(numdata);
    %ͳ�ƾ�����Ԫ�س��ֵĴ�������һ��ΪԪ�أ��ڶ���Ϊ������������Ϊ�ٷֱ�
    disp('  ----------------------------------');
    [m,n]=size(numtab);
    disp(strcat(listname(column),'������:'));
    for j=1:m
        disp(strcat('    ���',num2str(numtab(j,1)),'��Ƶ����',num2str(numtab(j,2))));
    end
end
disp('************************���Ƿָ���***************************');
%��ֵ���ԣ����������С����ֵ����λ�����ķ�λ����ȱʧֵ�ĸ���
disp('  ��ֵ���ԣ����������С����ֵ����λ�����ķ�λ����ȱʧֵ�ĸ���');
result2=zeros(column,7);
for i=1:value_num
    column=valuelist(i);
    valdata1=data(:,column);
    valdata=data(:,column);
    disp('  -------------------------------------------------------');
    disp(strcat('��ֵ����',listname(column),'������������'));
    result2(i,1)=max(valdata);%���ֵ
    disp(strcat('     ���ֵ��',num2str(result2(i,1))));
    result2(i,2)=min(valdata);%��Сֵ
    disp(strcat('     ��Сֵ��',num2str(result2(i,2))));
    valdata1(isnan(valdata1)==1)=0;%ȱʧֵ��0
    result2(i,3)=mean(valdata1);%��ֵ
    disp(strcat('     ��ֵ��',num2str(result2(i,3))));
    result2(i,4)=prctile(valdata,50);%��λ��
    disp(strcat('     ��λ����',num2str(result2(i,4))));
    result2(i,5)=prctile(valdata,25);%��һ���ķ�λ��
    disp(strcat('     Q1ֵ��',num2str(result2(i,5))));
    result2(i,6)=prctile(valdata,75);%��3�ķ�λ��
    disp(strcat('     Q3ֵ��',num2str(result2(i,6))));
    result2(i,7)=sum(isnan(valdata));%ȱʧֵ����
    disp(strcat('     ȱʧֵ����Ϊ',num2str(result2(i,7))));
end
%% ���ݿ��ӻ�
for i=1:value_num
    column=valuelist(i);
    valdata1=data(:,column);
    valdata=data(:,column);
    figure;subplot(221);hist(valdata);
    title(strcat(listname(column),'��ֱ��ͼ'));
    subplot(222);qqplot(valdata);
    title(strcat(listname(column),'��QQͼ'));
    subplot(223);boxplot(valdata);
    title(strcat(listname(column),'�ĺ�ͼ'));
end