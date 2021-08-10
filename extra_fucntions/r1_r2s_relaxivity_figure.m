function r1_r2s_relaxivity_figure(r1_r2s_relaxivity,C,BinR2sm,BinR1m,STDm,fit)

color=parula(length(C));
h=figure('Position', get(0, 'Screensize'));
hold on
for i=1:length(C)
    plot([0,0],[0,0],'LineWidth',2,'color',color(i,:));
    legendInfo{i}=strcat('ROI ',num2str(C(i)),' r1-r2* relaxivity=',num2str(fit(i,1)));
    
end
for i=1:length(C)
    v1=BinR2sm{i};
    v2=BinR1m{i};
    plot(v1,v2,'.','color',color(i,:),'MarkerSize',15)
end
for i=1:length(C)
    v1=BinR2sm{i};
    err=STDm{i};
    [hl,hp]=boundedline(v1,v1*fit(i,1)+fit(i,2),err,'alpha','transparency',0.2,'cmap',color(i,:)) ;
end
for i=1:length(C)
    v1=BinR2sm{i};
    plot(r1_r2s_relaxivity.R2s_range,r1_r2s_relaxivity.R2s_range*fit(i,1) +fit(i,2),'--','color',color(i,:),'LineWidth',1);
    plot(v1,v1*fit(i,1) +fit(i,2),'color',color(i,:),'LineWidth',2);
end

hold off
legend(legendInfo)
xlim(r1_r2s_relaxivity.R2s_range)
ylim(r1_r2s_relaxivity.range)
title('R1 Vs. R2*')
xlabel('R2* [1/sec]')
ylabel('R1 [1/sec]')
if r1_r2s_relaxivity.save_fig==1
    F    = getframe(h);
    imwrite(F.cdata, fullfile(r1_r2s_relaxivity.saveat,['/r1_r2s_relaxivity_figre.png']), 'png')
    savefig(h,fullfile(r1_r2s_relaxivity.saveat,['/r1_r2s_relaxivity_figre.fig']))
end
end