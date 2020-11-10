function output = veith_model_test(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Extract model predictions per self-occlusion
  %based on the active inference framework.
  %TODO: Divide each block into separate sessions.
  %TODO: Figure out how to treat error trials.
  %TODO: Figure out why 13 and 15 contain errors.
  %Created 18/12/2018.
  %New version 26/09/2020
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
%   addpath(genpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/lissajous_code/lissajous_analysis'))
%   load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_HGFv6_respUPPT02')
%   load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')
%   load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo_trlnumblock_v2.mat')
% Table_continfo_trlnumblock_v2

  % select a participants data.
  % ipart       = 14;

  % trlTA=trlTA(trlTA.participant==14,:);
  % Error in participants: 13 and 15.
  for ipart = 1:29
%     blocklength=length(trlTA.StartTrial) %change to actual
%     for iblock = 1:blocklength
      disp(ipart)
      index       = trlTA.participant==ipart;
      table_test  = trlTA(index,:);
      resp        = table_test.responseValue;
      
      
      
      % remove nans. Will distort but important to only have the responses.
      % resp_clean=resp(~isnan(resp));
      % resp_clean=resp;
      resp(resp==225)=0;
      resp(resp==232)=1;
      resp(resp==226)=0;
      resp(resp==228)=1;

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

      Model{1}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lissajous_config1', 'tapas_categorical_config')
      % tapas_fit_plotCorr(Model{1}.subject{1}.session)
      % tapas_hgf_binary_plotTraj(Model{1}.subject{1}.session)

      Model{2}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lissajous_config2', 'tapas_categorical_config')

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
%                        (see the configuration file of your chosen observation model for details)
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

insert_negll=1;
for ipart = 1:29
  if ~isempty(Model{1}.subject{ipart})
    modelfits_null(insert_negll)=Model{1}.subject{ipart}.session.optim.negLl;
    modelfits_alt(insert_negll)=Model{2}.subject{ipart}.session.optim.negLl;
%     modelfits_3(insert_negll)=Model{3}.subject{ipart}.session.optim.negLl;
%     modelfits_4(insert_negll)=Model{4}.subject{ipart}.session.optim.negLl;
%     modelfits_5(insert_negll)=Model{5}.subject{ipart}.session.optim.negLl.negLl;
    insert_negll=insert_negll+1;
  end
end

cd('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/')
save('model_tapas_HGFv6_respUPPT02.mat','Model')

figure(1),clf
bar([mean(modelfits_null);mean(modelfits_alt);mean(modelfits_3);mean(modelfits_4);mean(modelfits_5)])
hold on
plot([modelfits_null;modelfits_alt;modelfits_3;modelfits_4;modelfits_5])
xlabel('Model version')
ylabel('Model fits')
saveas(gca,'models_fig.png','png')
