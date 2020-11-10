function output = veith_model_withfreqresp(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Extract model predictions per self-occlusion
  %based on the active inference framework.
  %TODO: Divide each block into separate sessions.
  %Created 18/12/2018.
  %New version 26/09/2020
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
%   addpath(genpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/lissajous_code/lissajous_analysis'))
% 
%   load('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')

  % select a participants data.
  % ipart       = 14;

  % trlTA=trlTA(trlTA.participant==14,:);
  % Error in participants: 13 and 15.
  % TODO: Fix Errors in these  
  %   find all participant id.
  % 
  % load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_HGFv6.mat')
  
%   addpath('/home/chris/Documents/lissajous/code/lissajous_analysis/veith_model/TAPAS modifications/Old Scripts')
  addpath('/home/chris/Documents/lissajous/code/tapas')
  tapas_init('hgf')
  
  participants = dir('/home/chris/Documents/lissajous/data/continous_self_freq/*freq_low_selfocclBlock2.mat');
  
  for ipart = 1:29
%     blocklength=length(trlTA.StartTrial) %change to actual
%     for iblock = 1:blocklength
      disp(ipart)
      
      
      files = dir(sprintf('/home/chris/Documents/lissajous/data/continous_self_freq/%sfreq_low_selfocclBlock*.mat',participants(ipart).name(1:2)));
      
      cd(files(1).folder)
      
      %   load(sprintf('/home/chris/Documents/lissajous/data/contin
      freqAll = [];
      
      for ifile = 1:length(files)
          cfg = [];
          
          load(files(ifile).name);
          
          if ifile>1
              [freqAll] = append_trialfreq([],freqAll,freq);
          else
              freqAll=freq;
          end
          
      end
      
      resp = freqAll.trialinfo(:,5);
      resp(resp == 0)=NaN; 
      % remove nans. Will distort but important to only have the responses.
      % resp_clean=resp(~isnan(resp));
      % resp_clean=resp;
      resp(resp==225)=0;
      resp(resp==232)=1;
      resp(resp==226)=0;
      resp(resp==228)=1;
      %there is a 233 , 236 values...
      resp(resp==233)=1;
      resp(resp==236)=1;

      % perception at each overlap
      y=resp;
      clear u
      u(:,1)=y;
      u(:,2)=repmat(0.5,length(resp),1);
      u(:,3)=repmat(0.5,length(resp),1);

      u(:,4)=[1:length(resp)]'*4.5;

      % When assessing our model, Model 1 to 4 are important. Here, we
      % systematically remove parts of the model, regarding the parameter InitPi
      % (the inital precision of a percept) and StereoPi (the precision of the
      % stereo-disparity). Since you don't have stereodisparity, the most
      % appropriate model should be Model 2. You could compare it to Model 1 (the
      % null model) using Bayesian model comparison; Model 3 and 4 don't make
      % sense in your case, since you do not have a stereodisparity condition.

      % Model 5 - 7 include alternative models of bistable perception to compare
      % the model to. Model 8 changes an additional parameter of the model (zeta).
      
      Model{1}.subject{ipart}.session = tapas_fitModel(y,...
          u,...
          'tapas_hgf_binary_Lissajous_config1',...
          'tapas_categorical_config');
      
      Model{2}.subject{ipart}.session = tapas_fitModel(y,...
          u,...
          'tapas_hgf_binary_Lissajous_config2',...
          'tapas_bayes_optimal_binary_config',...
          'tapas_quasinewton_optim_config');
      
      
                     
%       Model{1}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lissajous_config1', 'tapas_categorical_config')
%       % tapas_fit_plotCorr(Model{1}.subject{1}.session)
%       % tapas_hgf_binary_plotTraj(Model{1}.subject{1}.session)
% 
%       Model{2}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lissajous_config2', 'tapas_categorical_config')
% 
%       Model{3}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lehky_config', 'tapas_categorical_Wilson_config')
% 
%       % Error in Wilson model
%       % tried to fix by commenting out infStates(:,1,5) = traj.predicted;
%       Model{4}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Wilson_config_full', 'tapas_categorical_Wilson_config')
% 
%       % Error in Moreno model - same as in Wilson.
%       Model{5}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Moreno_config', 'tapas_categorical_Moreno_config')
%     end
  end


%
%What is the meaning of all the output?
% OUTPUT:
%     est.u              Input to agent (i.e., the inputs array from the arguments)
%     est.y              Observed responses (i.e., the responses array from the arguments)
%     est.irr            Index numbers of irregular trials
%     est.ign            Index numbers of ignored trials
%     est.c_prc          Configuration settings for the chosen perceptual model
%                        (see the configuration file of that model for details)
%     est.c_obs          Configuration settings for the chosen observation model
%                        (see the configuration file of that model for details)
%     est.c_opt          Configuration settings for the chosen optimization algorithm
%                        (see the configuration file of that algorithm for details)
%     est.optim          A place where information on the optimization results is stored
%                        (e.g., measures of model quality like LME, AIC, BIC, and posterior
%                        parameter correlation)
%     est.p_prc          Maximum-a-posteriori estimates of perceptual parameters
%                        (see the configuration file of your chosen perceptual model for details)
%     est.p_obs          Maximum-a-posteriori estimates of observation parameters
%                        (see ttapas_hgf_binary_plotTrajhe configuration file of your chosen observation model for details)
%     est.traj:          Trajectories of the environmental states tracked by the perceptual model
%                        (see the configuration file of that model for details)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The HGF configuration consists of the priors of parameters and initial values. All priors are
% Gaussian in the space where the quantity they refer to is estimated. They are specified by their
% sufficient statistics: mean and variance (NOT standard deviation).
% 
% Quantities are estimated in their native space if they are unbounded (e.g., the omegas). They are
% estimated in log-space if they have a natural lower bound at zero (e.g., the sigmas).
% 
% Parameters can be fixed (i.e., set to a fixed value) by setting the variance of their prior to
% zero. Aside from being useful for model comparison, the need for this arises whenever the scale
% and origin at the j-th level are arbitrary. This is the case if the observation model does not
% contain the representations mu_j and sigma_j. A choice of scale and origin is then implied by
% fixing the initial value mu_j_0 of mu_j and either kappa_j-1 or omega_j-1.
%
% Fitted trajectories can be plotted by using the command
%
% >> tapas_hgf_binary_plotTraj(est)
% 
% where est is the stucture returned by tapas_fitModel. This structure contains the estimated
% perceptual parameters in est.p_prc and the estimated trajectories of the agent's
% representations (cf. Mathys et al., 2011). Their meanings are:
%              
%         est.p_prc.mu_0       row vector of initial values of mu (in ascending order of levels)
%         est.p_prc.sa_0       row vector of initial values of sigma (in ascending order of levels)
%         est.p_prc.rho        row vector of rhos (representing drift; in ascending order of levels)
%         est.p_prc.ka         row vector of kappas (in ascending order of levels)
%         est.p_prc.om         row vector of omegas (in ascending order of levels)
%
% Note that the first entry in all of the row vectors will be NaN because, at the first level,
% these parameters are either determined by the second level (mu_0 and sa_0) or undefined (rho,
% kappa, and omega).
%
%         est.traj.mu          mu (rows: trials, columns: levels)
%         est.traj.sa          sigma (rows: trials, columns: levels)
%         est.traj.muhat       prediction of mu (rows: trials, columns: levels)
%         est.traj.sahat       precisions of predictions (rows: trials, columns: levels)
%         est.traj.v           inferred variance of random walk (rows: trials, columns: levels)
%         est.traj.w           weighting factors (rows: trials, columns: levels)
%         est.traj.da          volatility prediction errors  (rows: trials, columns: levels)
%         est.traj.ud          updates with respect to prediction  (rows: trials, columns: levels)
%         est.traj.psi         precision weights on prediction errors  (rows: trials, columns: levels)
%         est.traj.epsi        precision-weighted prediction errors  (rows: trials, columns: levels)
%         est.traj.wt          full weights on prediction errors (at the first level,
%                                  this is the learning rate) (rows: trials, columns: levels)

%remove three outlier participants 
Model{1}.subject{8}=[];
Model{1}.subject{19}=[];
Model{1}.subject{22}=[];


insert_negll=1;
for ipart = 1:29
  if ~isempty(Model{1}.subject{ipart})
    modelfits_null(insert_negll)=Model{1}.subject{ipart}.session.optim.LME;
    modelfits_alt(insert_negll)=Model{2}.subject{ipart}.session.optim.LME;
%     modelfits_3(insert_negll)=Model{3}.subject{ipart}.session.optim.negLl;
%     modelfits_4(insert_negll)=Model{4}.subject{ipart}.session.optim.negLl;
%     modelfits_5(insert_negll)=6.negLl;
    insert_negll=insert_negll+1;
  end
end

%%
%

%plot the results of model fitting. 
addpath('/home/chris/Documents/lissajous/code/cbrewer')
addpath('/home/chris/Documents/lissajous/code/RainCloudPlots/tutorial_matlab')


[cb] = cbrewer('qual', 'Set3', 12, 'pchip');

close all;
figure('Position', [10 10 1300 900])

load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_HGFv6.mat')

subplot(1,2,1)

h1 = raincloud_plot(modelfits_null, 'box_on', 1, 'color', cb(1,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .15,...
     'box_col_match', 0);
 
h2 = raincloud_plot(modelfits_alt, 'box_on', 1, 'color', cb(4,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .35, 'dot_dodge_amount', .35, 'box_col_match', 0);
 
legend([h1{1} h2{1}], {'Null model', 'PE Model'});
% ylim([-700 -330])
% yl = get(gca, 'YLim');
set(gca, 'XLim', [-620 -350]);
set(gca, 'YLim', [-0.01 0.02]);
xlabel(['Log likelihood (more - better)'])

set(gca,'ytick',[])
set(gca,'yticklabel',[])
title('LME - new model comparison')


%%
%plot the old model fits to compare. 
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas.mat')

insert_negll=1;
for ipart = 1:29
  if ~isempty(Model{1}.subject{ipart})
    modelfits_null2(insert_negll)=Model{1}.subject{ipart}.session.optim.LME;
    modelfits_alt2(insert_negll)=Model{2}.subject{ipart}.session.optim.LME;
%     modelfits_3(insert_negll)=Model{3}.subject{ipart}.session.optim.negLl;
%     modelfits_4(insert_negll)=Model{4}.subject{ipart}.session.optim.negLl;
%     modelfits_5(insert_negll)=6.negLl;
    insert_negll=insert_negll+1;
  end
end

subplot(1,2,2)

h1 = raincloud_plot(modelfits_null2, 'box_on', 1, 'color', cb(1,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .15,...
     'box_col_match', 0);
 
h2 = raincloud_plot(modelfits_alt2, 'box_on', 1, 'color', cb(4,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .35, 'dot_dodge_amount', .35, 'box_col_match', 0);
 

legend([h1{1} h2{1}], {'Null model', 'PE Model'});
set(gca, 'XLim', [-620 -350]);
set(gca, 'YLim', [-0.007 0.012]);

set(gca,'ytick',[])
set(gca,'yticklabel',[])
xlabel(['Log likelihood (more - better)'])


title('LME - old model comparison')


%%
%Save figure

cd('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/compmodelling')

%New naming file standard. Apply to all projects.
namefigure = 'model_fits_old_new_raincloud_v2';
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
figurefreqname = sprintf('%s_%s.png',todaystr,namefigure);
saveas(gca,figurefreqname,'png')

%%
h3 = raincloud_plot(mnull, 'box_on', 1, 'color', cb(7,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .55, 'dot_dodge_amount', .55, 'box_col_match', 0);
 
h4 = raincloud_plot(malt, 'box_on', 1, 'color', cb(10,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .75, 'dot_dodge_amount', .75, 'box_col_match', 0);
 
 
legend([h1{1} h2{1}], {'Group 1', 'Group 2'});
title(['Figure M7' newline 'A) Dodge Options Example 1']);
set(gca,'XLim', [0 40], 'YLim', [-.075 .15]);
box off

fits{1}=modelfits_null;
fits{2}=modelfits_alt;

cd('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour')
save('model_tapas_HGFv6.mat','Model')


%%
figure(1),clf
bar([mean(modelfits_null);mean(modelfits_alt);mean(modelfits_3);mean(modelfits_4);mean(modelfits_5)])
hold on
plot([modelfits_null;modelfits_alt;modelfits_3;modelfits_4;modelfits_5])
xlabel('Model version')
ylabel('Model fits')
saveas(gca,'models_fig.png','png')
