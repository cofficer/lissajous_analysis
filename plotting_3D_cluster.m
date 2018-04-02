% plotting_3D_cluster
% this code plots correlation values from matrix 'r' (dimisions:
% subj_events_chan_freq_time) masked by 3D cluster from the 'stats' structure 


THR = 0.05; % threshold for cluster
trap = 1; % 1=cluster will integrated over not-plotted dimentions, 0=average

switch dimord
    case {'trl_chan_freq_time','trl_chan_freq', 'trl_chan_time'}
        for ievent = events
            for isign =1:2
                if replot_clus
                    clus  = 1;
                    cluslabels = ones(size(r,3),size(r,4),size(r,5));
                    pvalues = NaN;
                elseif isign == 1 && min(stats{ievent}.prob(:))<1
                    clus = find(arrayfun(@(x) x.prob<=THR, stats{ievent}.posclusters));
                    cluslabels = stats{ievent}.posclusterslabelmat;
                    pvalues = arrayfun(@(x) x.prob, stats{ievent}.posclusters(clus));
                elseif isign == 2 && min(stats{ievent}.prob(:)) < 1
                    clus = find(arrayfun(@(x) x.prob<=THR, stats{ievent}.negclusters));
                    cluslabels = stats{ievent}.negclusterslabelmat;
                    pvalues = arrayfun(@(x) x.prob, stats{ievent}.negclusters(clus));
                else
                    clus = []; pvalues =  min(stats{ievent}.prob(:));
                end
                
                if ~isempty(clus)
                    for iclus = clus
                        figure
                        
                        % for TFR
                        if ~isempty(strfind(dimord, 'time')) && ~isempty(strfind(dimord, 'freq'))
                            rtemp = squeeze(nanmean(r(:,ievent,:,frind,tind)));
                            if trap;
                                rtemp(cluslabels~=clus(iclus)) = 0;
                                rtemp = squeeze(trapz(rtemp,1));%./numel(find(rtemp~=0));
                            else
                                rtemp(cluslabels~=clus(iclus)) = NaN;
                                rtemp = squeeze(nanmean(rtemp,1));%./numel(find(rtemp~=0));
                                rtemp(isnan(rtemp))=0;
                            end
                        elseif ~isempty(strfind(dimord, 'freq'))
                            rtemp = squeeze(nanmean(r(:,ievent,:,frind,:)));
                            if trap; rtemp(cluslabels~=clus(iclus)) = 0; else; rtemp(cluslabels~=clus(iclus)) = NaN; rtemp(isnan(rtemp))=0; end
                            rtemp(:,:,1) = rtemp;
                        elseif  ~isempty(strfind(dimord, 'time'))
                            rtemp = squeeze(nanmean(r(:,ievent,:,tind)));
                            if trap; rtemp(cluslabels~=clus(iclus)) = 0; else; rtemp(cluslabels~=clus(iclus)) = NaN; rtemp(isnan(rtemp))=0;end
                            rtemp(:,:,1) = rtemp;
                        end
                        scale = [-(max(abs(rtemp(:))))-0.00001, max(abs(rtemp(:)))+0.00001];
                    end
                    cmap = cbrewer('div', 'RdBu',256);
                    cmap = flipud(cmap);
                    subplot(223); colormap(cmap)
                    if avg_over_time == 0 && avg_over_freq == 0
                        ft_plot_matrix(freq.time(tind),freq.freq(frind), rtemp,'clim',scale);%, 'highlight', thrcluster, 'highlightstyle', 'saturation', 'clim', scale) %,taxis,faxis
                        hold on
                        set(gca,'YDir','normal');
                        plot([0,0],foi,'k',[0,0],foi,'k');
                        ylabel('Frequency (Hz)');
                        xlabel(sprintf('Time from %s (s)', trigger));
                        
                        if trap; rtemp_time = squeeze(trapz(rtemp,1)); rtemp_freq = squeeze(trapz(rtemp,2));
                        else rtemp_time = squeeze(nanmean(rtemp,1)); rtemp_freq = squeeze(nanmean(rtemp,2));
                        end
                    elseif avg_over_freq
                        rtemp_time = squeeze(trapz(rtemp,1));%./numel(find(rtemp~=0));
                        rtemp_freq = zeros(1,length(faxis));
                    elseif avg_over_time
                        rtemp_time = zeros(1,length(taxis));
                        rtemp_freq = squeeze(trapz(rtemp,1));%./numel(find(rtemp~=0));
                    end
                    
                    subplot(221);
                    area(freq.time(tind), rtemp_time); hold on;
                    plot([freq.time(1), freq.time(end)], [0 0],'k');
                    xlim([freq.time(tind(1)), freq.time(tind(end))]);
                    ylim([-(ceil(max(abs(rtemp_time)))).*1.2-0.00001, ceil(max(abs(rtemp_time))).*1.2+0.00001]);
                    xlabel(sprintf('Time from %s (s)', trigger));
                    ylabel('Integrated correlation');
                    title(sprintf('%s Corr %s %s-%d\n[%d %d] p=%1.4f', corrfactor{icorr}, event{ievent}, sign{isign}, iclus, (scale(1)), (scale(2)), pvalues(iclus)));
                    
                    
                    subplot(224)
                    area(freq.freq(frind), rtemp_freq'); hold on;
                    plot([freq.freq(frind(1)) freq.freq(frind(end))],[0 0],'k');
                    xlim([freq.freq(frind(1)) freq.freq(frind(end))]);
                    ylim([-((max(abs(rtemp_freq)))).*1.2-0.00001, (max(abs(rtemp_freq))).*1.2+0.00001]);
                    camroll(270)
                    camorbit(0,180)
                    xlabel('Frequency (Hz)');
                    ylabel('Integrated correlation');
                    
                    % for topo
                    % CFG
                    subplot(222); colormap(cmap);
                    cfg = [];
                    cfg.layout = 'CTF275.lay';
                    cfg.comment = 'no';
                    cfg.marker = 'off';
                    cfg.shading = 'flat';
                    cfg.style = 'straight'; %both
                    cfg.interpolation =  'v4'; %'linear','cubic','nearest','v4' (default = 'v4') see GRIDDATA
                    cfg.markersize = 1;
                    
                    if avg_over_freq
                        rtemp = squeeze(nanmean(r(:,ievent,:,tind)));
                    else
                        rtemp = squeeze(nanmean(r(:,ievent,:,frind,tind)));
                    end
                    
                    if trap
                        rtemp(cluslabels~=clus(iclus)) = 0;
                        rtemp = squeeze(trapz(rtemp,2));
                        if avg_over_time == 0 && avg_over_freq == 0
                            rtemp = squeeze(trapz(rtemp,2));
                        end
                        cfg.zlim = [-(max(abs(rtemp(:)))), max(abs(rtemp(:)))];
                    else
                        rtemp(cluslabels~=clus(iclus)) = NaN;
                        rtemp = squeeze(nanmean(rtemp,2));
                        rtemp = squeeze(nanmean(rtemp,2));
                        rtemp(isnan(rtemp))=0;
                        cfg.zlim = [-(max(abs(rtemp(:)))), max(abs(rtemp(:)))];
                    end
                    
                    freq2 = freq;
                    freq2.dimord = 'chan_freq_time';
                    freq2.powspctrm = repmat(rtemp,[1,2,2]);
                    freq2.time = [1 2];
                    freq2.freq = [1 2];
                    warning off;
                    
                    ft_topoplotTFR(cfg,freq2);
                    colorbar
                end
            end
        end
end

