function [co_variance, skewness] = compute_distmoments(dist_gam)
%Input individual distribution of lissajous during the continuous block
%Important to start each block as a new distribution, to reduce erroneous
%heavy-tailed values if the same perceptual state is at the start and of two
%consequtive block.

%Simulate a gamma distribution
sim = 0;
if sim
  %prob dist of gamma with a=2,b=2
  dist_pdf = gampdf(1,2,1:15);
  %scaled numbers generated
  dist_gam = randg(dist_pdf);


end

co_variance = (std(dist_gam)/mean(dist_gam))

skewns = @(x) (sum((x-mean(x)).^3)./length(x)) ./ (var(x,1).^1.5);

skewness_var = skewns(dist_gam);


end
