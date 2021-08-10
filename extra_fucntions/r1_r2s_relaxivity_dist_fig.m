function r1_r2s_relaxivity_dist_fig(r1_r2s_relaxivity,C,R2s,R1,data,BinR2sm,BinR1m,STDm,fit)


dist=struct;
h=figure('Position', get(0, 'Screensize'));
for i=1:length(C)
    dist(i).R2s=R2s(data==C(i));
    dist(i).R1=R1(data==C(i));
    [p,n]=numSubplots(length(C));
    subplot(p(1),p(2),i)
    plot2Dhist(R2s(data==C(i)),R1(data==C(i)),100,r1_r2s_relaxivity.R2s_range,r1_r2s_relaxivity.range,'R2* [1/sec]','R1 [1/sec]'); 
    dist(i).xbin=BinR2sm{i};
    dist(i).ybin=BinR1m{i};
    dist(i).err=STDm{i};
    vec=[min(BinR2sm{i})-0.1*min(BinR2sm{i}) max(BinR2sm{i})+0.1*max(BinR2sm{i})];
    hold on
    plot(vec,vec*fit(i,1)+fit(i,2),'y');
    plot(dist(i).xbin,dist(i).ybin,'*')
    title(['ROI ' num2str(C(i))])
    hold off
end

if r1_r2s_relaxivity.save_fig==1
    F    = getframe(h);
    imwrite(F.cdata, fullfile(r1_r2s_relaxivity.saveat,'dist.png'), 'png')
    savefig(h,fullfile(r1_r2s_relaxivity.saveat,'/dist.fig'))
end