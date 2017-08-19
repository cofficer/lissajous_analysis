function lissajous_datacheck( numP )
%This funcion checks the data quality of MEG recordings, starting with MEG.

%%
%Change to numP directory of raw data

directoryMEG = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s',numP);

cd(directoryMEG)

namesData=dir('*lissajous*');

for idata = 1:length(namesData)
%ft_qualitycheck creates an plot of a quick overview. 
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/diagnostics/')
cfg                         = [];
cfg.visualize               = 'yes';
cfg.dataset                 =sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/%s',numP,namesData(idata).name) ;
ft_qualitycheck(cfg)
end
%%

%Check the existence of eyelink data in MEG. 

directoryMEG = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s',numP);

cd(directoryMEG)

namesData=dir('*lissajous*');

cfg.dataset                 =sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/%s',numP,namesData(1).name) ;

cd(directoryMEG)

%Get the header information for label indexing.
hdr=ft_read_header(cfg.dataset);
dat=ft_read_data(cfg.dataset);



indx = strcmp(hdr.label,'UADC003');


a=squeeze(dat(indx,:,:));

a=reshape(a,1,1200*length(a));

close all
plot(a(400*1200:600*1200))


end

