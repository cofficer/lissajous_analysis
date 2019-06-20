function output = veith_model_test(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Extract model predictions per self-occlusion
  %based on the active inference framework.
  %TODO: Divide each block into separate sessions.
  %TODO: Figure out how to treat error trials.
  %TODO: Figure out why 13 and 15 contain errors.
  %Created 18/12/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  addpath(genpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/lissajous_code/lissajous_analysis'))

  load('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')

  % select a participants data.
  ipart       = 14;

  % trlTA=trlTA(trlTA.participant==14,:);
  % Error in participants: 13 and 15.
  for ipart = 1:29
    blocklength=length(trlTA.StartTrial) %change to actual
    for iblock = 1:blocklength
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


      Model{1}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lissajous_config1', 'tapas_categorical_config')
      % tapas_fit_plotCorr(Model{1}.subject{1}.session)
      % tapas_hgf_binary_plotTraj(Model{1}.subject{1}.session)

      Model{2}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lissajous_config2', 'tapas_categorical_config')

      Model{3}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Lehky_config', 'tapas_categorical_Wilson_config')

      % Error in Wilson model
      % tried to fix by commenting out infStates(:,1,5) = traj.predicted;
      Model{4}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Wilson_config_full', 'tapas_categorical_Wilson_config')

      % Error in Moreno model - same as in Wilson.
      Model{5}.subject{ipart}.session=tapas_fitModel(y,u,'tapas_hgf_binary_Moreno_config', 'tapas_categorical_Moreno_config')
    end
  end
end



insert_negll=1;
for ipart = 1:29
  if ~isempty(Model{1}.subject{ipart})
    modelfits_null(insert_negll)=Model{1}.subject{ipart}.session.optim.negLl;
    modelfits_alt(insert_negll)=Model{2}.subject{ipart}.session.optim.negLl;
    modelfits_3(insert_negll)=Model{3}.subject{ipart}.session.optim.negLl;
    modelfits_4(insert_negll)=Model{4}.subject{ipart}.session.optim.negLl;
    modelfits_5(insert_negll)=Model{5}.subject{ipart}.session.optim.negLl;
    insert_negll=insert_negll+1;
  end
end

cd('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/behaviour')
save('model_tapas.mat','Model')

figure(1),clf
bar([mean(modelfits_null);mean(modelfits_alt);mean(modelfits_3);mean(modelfits_4);mean(modelfits_5)])
hold on
plot([modelfits_null;modelfits_alt;modelfits_3;modelfits_4;modelfits_5])
xlabel('Model version')
ylabel('Model fits')
saveas(gca,'models_fig.png','png')
