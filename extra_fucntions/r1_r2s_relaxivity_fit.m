function [r1_r2s_relaxivity]=r1_r2s_relaxivity_fit(r1_r2s_relaxivity,C,R2s,data,R1)

% fit the linear relationship between R1 and R2* (the r1-r2* relaxivity)
% for the different ROIs in the segmentation

Bin=linspace(0,50,36); % Create bins for R2* values

BinR2sm=[];
BinR1m=[];
NUMm=zeros(length(Bin)-1,length(C));
STDm=[];
fit=nan(length(C),2);

for i=1:length(C) % for each ROI
    BinR2s=[]; BinR1=[]; std_c=[]; num=[];
    % divide to bins
    [BinR2s,BinR1,std_c,num]=r1_r2s_relaxivity_bin(Bin,R2s,data,R1,C(i));
    NUMm(:,i)=num;
    
    % take only bins with enough voxels
    y=BinR1;
    y(isnan(BinR1) | isnan(BinR2s) | num<0.04*sum(num) ) = [];
    x=BinR2s;
    x(isnan(BinR1) | isnan(BinR2s) | num<0.04*sum(num) ) = [];
    BinR2sm{i}=x;
    BinR1m{i}=y;
    std_c(isnan(BinR1) | isnan(BinR2s) | num<0.04*sum(num) ) = [];
    STDm{i}=std_c;
    
    % linear fit
    if ~isempty(x)
        mdl=fitlm(x,y);
        fit(i,1)=mdl.Coefficients{2,1};
        fit(i,2)=mdl.Coefficients{1,1};
    end
end

r1_r2s_relaxivity.fit=fit; % slope and intersection of the linear relationship between a qMRI parameter and MTV
r1_r2s_relaxivity.BinR2s=BinR2sm; %  median values of MTV within each bin
r1_r2s_relaxivity.BinR1=BinR1m; % median values of the qMRI parameter within each bin
r1_r2s_relaxivity.STD=STDm; % STD of the qMRI parameter within each bin
end