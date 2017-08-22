function [co_variance, skewness] = compute_distmoments(dist_gam)
%Input individual distribution of lissajous during the continuous block
%Important to start each block as a new distribution, to reduce erroneous
%heavy-tailed values if the same perceptual state is at the start and of two
%consequtive block.

clear
%Simulate a gamma distribution
sim = 1;
if sim
  %prob dist of gamma with a=2,b=2
  dist_pdf = gampdf(1,2,1:15);
  %scaled numbers generated
  dist_gam = randg(dist_pdf);


end

co_variance = (std(dist_gam)/mean(dist_gam))

skewness = skewness(dist_gam)

%plot
figure(1),clf
plot(dist_pdf)
saveas(gca,'gamm.png','png')

end
