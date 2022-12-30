clear all;
close all;
clc;

Nbits=12;
MaxVal=2^(Nbits-1)-1
MinVal=-2^(Nbits-1)
uLMSDen=2^(Nbits-1)

%% Variables definitions 4 
% Total samples
N = 2000;

% samples index vector
n = 1:N;

% v = input,  noise 
v = randi([MinVal,  MaxVal],  N,  1); 

% H filter 
bH = [1]; 
aH = [100 -80 50];

% x = H filter output 
x = filter(bH,  aH,  v); 

% y = W adaptive filter output
% since the filtering task is iterative 
% because the coefficients will be updated each time, 
% declare it as a vector of N elements. 
% updated output values will be inserted in it.
y = zeros(N,  1); 
err = zeros(N, 1);

% Filtering related parameters
% temporary buffer / samples size
M = 5; 
m = 1:M;

% Unknown system impulse response
s = randi([MinVal,  MaxVal],  M,  1);

% Reference signal
d = filter(s,  1,  x);

% x samples vector used for filtering
xtmp = zeros(M,  1);

% W time domain vector
wLMS = zeros(M,  1);

% LMS error and output vector.Use it to update y vector of size N
eLMS = ones(M, 1).*MaxVal;
yLMS = 0; 
uLMS = 1./uLMSDen

fig = figure(); 
C = jet(N);
kc = linspace(0.25, 1, N); 

fp = fopen('w.txt','w');

for k = n

    dtmp = d(k); 
    xtmp = [x(k); xtmp(1:M-1)];
    yLMS = transpose(wLMS)*xtmp;
    eLMS = dtmp-yLMS;
    y(k) = yLMS;
    err(k) = eLMS;
    wLMS = floor(wLMS + uLMS .* eLMS .* xtmp);
    
    for kw = 1:length(wLMS)
        if (kw < length(wLMS))
            fprintf(fp, "%d,", wLMS(kw));
        else
            fprintf(fp, "%d\n", wLMS(kw));
        end
    end

    if (isnan(wLMS))
       disp(['Nan at k = ' num2str(k)]);
       break;
    end
    
    plot(m, wLMS, 'LineWidth', 2, 'Color', kc(k).*C(k, :)); grid on; hold on;

 end

fclose(fp);

scatter(m, s, 100, 'MarkerFaceColor', [1 0.95 0.2], 'MarkerEdgeColor',  [1 0 0]);
hold on;
title('w evolution vs s');
print('wLMS_vs_s.png', '-dpng');
waitfor(fig);

fig=figure(); 
subplot(5, 1, 1)
plot(n, v, 'LineWidth', 2, 'Color', [0 0 1]); grid on;
legend('v = Input');
subplot(5, 1, 2)
plot(n, x,  'LineWidth', 2, 'Color',  [1 0.5412 0.2]); grid on;
legend('x = H filter output');
subplot(5, 1, 3)
plot(n, d, 'LineWidth', 2, 'Color', [0 0 0]);grid on;
legend('d = System output,  reference signal');
subplot(5, 1, 4)
plot(n, y, 'LineWidth', 2, 'Color', [0 1 0]); grid on;
legend('y = Adaptive filter output');
subplot(5, 1, 5)
stem(n, err, 'LineWidth', 2, 'Color', [1 0 0]); grid on;
legend('e = d - y = Error');
print('data_plots.png', '-dpng');
waitfor(fig);

disp('s vs wLMS');
disp([s,  wLMS]);

disp(['y bits = ' num2str(ceil(log2(max(abs(y)))))]);
disp(['err bits = ' num2str(ceil(log2(max(abs(err)))))]);
disp(['wLMS bits = ' num2str(ceil(log2(max(abs(wLMS)))))]);

disp(['x(1) = ' num2str(x(1))]);
disp(['d(1) = ' num2str(d(1))]);
disp(['y(1) = ' num2str(y(1))]);
disp(['err(1) = ' num2str(err(1))]);

% fp = fopen('xdye.txt','w'); fprintf(fp, "%d,%d\n", x, d, y, err); fclose(fp);
M = int32([x, d, y, err]);
csvwrite('xdye.txt', M);

fp = fopen('s.txt','w');
fprintf(fp, "%d\n", round(s));
fclose(fp);

