function [BinR2s,BinR1,std_c,num]=r1_r2s_relaxivity_bin(Bin,R2s,seg,R1,seg_type)

% This function pools R1 and R2* into bins.
% seg is the segmentation matrix.
% seg_type is a label that determines the ROI on which the binning is done.
% outputs are:
% 1) median values of R2* within each bin
% 2) median values of R1 within each bin
% 3) the STD of R1 within each bin

BinR2s=nan(length(Bin)-1,1);
BinR1=nan(length(Bin)-1,1);
num=zeros(length(Bin)-1,1);
std_c=nan(length(Bin)-1,1);

for ii=1:length(Bin)-1
    clear ind
    ind=find(R2s>=Bin(ii) & R2s<Bin(ii+1) & seg==seg_type);
    num(ii)=length(ind);
    if ~isempty(ind)
       BinR2s(ii)=median(R2s(ind)); % median values of MTV within each bin
       BinR1(ii)=median(R1(ind)); % median values of the qMRI parameter within each bin
       std_c(ii)=mad(R1(ind),1); % the STD of the qMRI parameter within each bin
    end
end
end