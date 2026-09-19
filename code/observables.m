%observables.m data returns the matrix Y containing the data on which the model is estimated. Output is saved in read_data.m
%note: Dy is in percent per quarter and r and Dff are in percent per year. The division makes  all observables  be expressed in per one per quarter, as in the model.  
tend = 2018.25;
[Dy,Dpai,Dff, y, pai,ff,date, readme_data] = read_data(tend)
r = ff-pai;
Y1 = (Dy-mean(Dy))/100;
Y2 = (r-mean(r))/400;
Y3 = (Dff-mean(Dff))/400;
Y = [Y1 Y2 Y3];
meanY = mean(Y)';
stdY = std(Y)';
varY = var(Y)';
T = size(Y,1);

save observables.mat