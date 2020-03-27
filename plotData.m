figure;
x=linspace(0,1,numFrames);
c = linspace(0,1,nreg);
rgb=jet(nreg)
for N = 1:nreg
    c(N)
    rgb(N,:)
    scatter(x, data(:,N,1),25,rgb(N,:));
    grid on
    hold on
end
