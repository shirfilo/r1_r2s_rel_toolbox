
function [r1_r2s_relaxivity]=r1_r2s_relaxivity_run(R1_path,R2s_path,Seg_path,save_fig,saveat,flags)

%    r1_r2s_relaxivity is a software package designed to calculate the r1-r2* relaxivities.
%    The software is described in the following manuscript:
%    "Uncovering molecular iron compounds in the living human brain."
%    example= r1_r2s_relaxivity_run(R1_path,R2s_path,Seg_path,1,saveat_path,{'par_max',0.5,'par_min',0.1,'Parameter_str','R1'})
%
%
%    INPUT:
%
%            R1_path:   Path to a Nifti of a R1 map (in units [1/sec]).
%            R2s_path:  Path to a Nifti of a R2* map (in *units [1/sec]*, with *the same resolusion and in the same space* as the R1 map).
%            Seg_path:  Path to a Nifti of a brain segmentation or a ROI
%                       mask (with *the same resolusion* and in the same space as the R1 map).
%                       The software will calculate the r1-r2* relaxivities for
%                       all ROIs (with lables other than zero) in the segmentation
%                       file.
%           save_fig:   1/0 depending on whether or the user would like to save the output (1) or not (0).
%             saveat:   path to a directory where the output will be saved.
%              flags:   every parameter that you would like to be
%                       different from default can be given here. This
%                       input will be expected to come as a cell array
%                       and in pairs. There are 2 parameters that can be
%                       defined here: (1) 'R1_max' and (2) 'R1_min' 
%                       represent the range of values for R1
%                       (to be used in the figures).
%                       for example: {'R1_max',0.5,'R1_min',0.1}
%
%   OUTPUT:
%
%       This function creates and saves the r1_r2s_relaxivity strucure to the 'saveat'
%       directory. In this structure you can find:
%            *  The different inputs to the function will be saved.
%            *  The r1-r2* relaxivities will be saved in the
%               fit matrix. This is an MX2 matrix where M is the number of
%               ROIs in the segmentation and the columns are:
%               1) the slope of the linear relationship between R1 and R2* (the r1-r2* relaxivity)
%               2) the intersection of the linear relationship between R1 and R2*
%            *  For each ROI, the data point used to fit the linear
%               relationship between R1 and R2*, generated by binning over these two
%               parameters, are saved in BinR2s and BinR1 respectively. 
%               The STD of R1 in each bin is saved in STD.   
%
%   SOFTWARE REQUIREMENTS: 
%
%            * MATLAB          - http://www.mathworks.com/products/matlab/
%            * Vistasoft       - https://github.com/vistalab/vistasoft   
%            * boundedline-pkg - https://github.com/kakearney/boundedline-pkg
%            * knkutils        - https://github.com/kendrickkay/knkutils
%
% (C) Mezer lab, the Hebrew University of Jerusalem, Israel, Copyright 2021

%% set the MDM structure

r1_r2s_relaxivity=struct;
r1_r2s_relaxivity.R1_path=R1_path;
r1_r2s_relaxivity.R2s_path=R2s_path;
r1_r2s_relaxivity.Seg_path=Seg_path;
r1_r2s_relaxivity.save_fig=save_fig;

if ~notDefined('saveat')
r1_r2s_relaxivity.saveat=saveat;
% create folder for this analysis in the saveat dir.
mkdir(r1_r2s_relaxivity.saveat);
end



%% set undefined flags

if ~notDefined('flags')
    if ~isempty(flags)
        for ii = 1:2:numel(flags)-1
            % Check to make sure that the argument is formatted properly
            if ischar(flags{ii+1})
            eval([flags{ii},'=','''' (flags{ii+1}) ''';'])
            else
            eval([flags{ii},'=',num2str(flags{ii+1}) ';'])
            end
        end
    end
end

if notDefined('R1_max') || notDefined('R1_min') % The range of values for the  chosen qMRI parameter
    R1=readFileNifti(r1_r2s_relaxivity.R1_path);
    R1=R1.data;
    r1_r2s_relaxivity.range=minmax(R1(:)');
else
    r1_r2s_relaxivity.range=[R1_min R1_max];
end

%% Set files

disp('r1_r2s_relaxivity - setting files...');

% MTV
R2s_s=readFileNifti(r1_r2s_relaxivity.R2s_path);
R2s=double(R2s_s.data);
r1_r2s_relaxivity.R2s_range=[0 80];

% qMRI Parameter
R1=readFileNifti(r1_r2s_relaxivity.R1_path);
R1=double(R1.data);

% Segmentation
seg=readFileNifti(r1_r2s_relaxivity.Seg_path);
seg=seg.data;
 
%% Subcortical regions 

disp('r1_r2s_relaxivity - calculate r1-r2* relaxivity');

% find all labels in the segmentation file:
C=unique(seg); 
C(C==0)=[];

% fit the linear relationship between R1 and R2* (the r1-r2* relaxivity):
[r1_r2s_relaxivity]=r1_r2s_relaxivity_fit(r1_r2s_relaxivity,C,R2s,seg,R1); 

% plot the voxel-by-voxel distribution of R1 relative to R2* for each ROI: 
r1_r2s_relaxivity_dist_fig(r1_r2s_relaxivity,C,R2s,R1,seg,r1_r2s_relaxivity.BinR2s,r1_r2s_relaxivity.BinR1,r1_r2s_relaxivity.STD,r1_r2s_relaxivity.fit);

% plot the linear relationship between R1 and R2* (the r1-r2* relaxivity) for each ROI:
r1_r2s_relaxivity_figure(r1_r2s_relaxivity,C,r1_r2s_relaxivity.BinR2s,r1_r2s_relaxivity.BinR1,r1_r2s_relaxivity.STD,r1_r2s_relaxivity.fit)

%% save r1_r2s_relaxivity structure

if r1_r2s_relaxivity.save_fig==1
    save(fullfile(r1_r2s_relaxivity.saveat,['/r1_r2s_relaxivity.mat']),'r1_r2s_relaxivity')
end

end