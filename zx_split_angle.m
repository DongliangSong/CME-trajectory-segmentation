clc; clear

load('zx_split_angle.mat');
% data: Includes stages 1-3, corresponding to time/displacement/azimuth angle/polar angle
t = data(:,1);
traj = data(:,2:4);

disp_all = traj(:,1);
azi_all  = traj(:,2);
pol_all  = traj(:,3);
N = length(disp_all);

% stage1
stage1_idx = 1:740;     %% The starting and ending indices of stage 1, not the time
d_azi = abs(diff(azi_all));
d_pol = abs(diff(pol_all));
X = [d_azi, d_pol];

X1 = X(stage1_idx(1:end-1), :);
mu1 = mean(X1,1);
Sigma1 = cov(X1);
Sigma1 = Sigma1 + 1e-6*eye(size(Sigma1));

% Search for the segmentation point
best_t = [];
best_scores = [];
for m = 0:0.01:1
    search_start = stage1_idx(end) + 20;
    search_end   = size(X,1) - 20;
    scores = [];
    split_points = [];
    for k = search_start:search_end
        % stage2
        X2 = X(stage1_idx(end)+1:k,:);
        
        % stage3
        X3 = X(k+1:end,:);
        
        if size(X3,1) < 10
            continue;
        end
        
        % stage3
        mu3 = mean(X3,1);
        Sigma3 = cov(X3);
        Sigma3 = Sigma3 + 1e-6*eye(size(Sigma3));
        %
        %     % Mahalanobis
        %     d_mu = (mu3 - mu1);
        %     Dm = d_mu / Sigma1 * d_mu';
        %     Dc = norm(Sigma3 - Sigma1,'fro');
        %
        %     % KL divergence
        p = size(X,2);
        %     KL = 0.5 * (trace(Sigma1 \ Sigma3) +d_mu / Sigma1 * d_mu' -p + log(det(Sigma1)/det(Sigma3)) );
        %
        %     % BIC penalty
        %     n3 = size(X3,1);
        %     bic_penalty = log(n3);
        %
        %     % final score
        %     score = KL + 0.1*Dc + 0.01*bic_penalty;
        
        % stage2
        mu2 = mean(X2,1);
        Sigma2 = cov(X2) + 1e-6*eye(size(X,2));
        
        % KL(stage2 || stage1)
        KL2 = 0.5 * (trace(Sigma1 \ Sigma2) + (mu2-mu1)/Sigma1*(mu2-mu1)' - p + log(det(Sigma1)/det(Sigma2)));
        
        % KL(stage3 || stage1)
        KL3 = 0.5 * (trace(Sigma1 \ Sigma3) + (mu3-mu1)/Sigma1*(mu3-mu1)' - p + log(det(Sigma1)/det(Sigma3)));
        
        % new score
        lambda = m;
        
        score = KL3 - lambda*KL2;
        scores(end+1) = score;
        split_points(end+1) = k;
    end
    
    % Optimal change point
    [min_score,idx_best] = min(scores);
    best_split = split_points(idx_best);
    fprintf('lamda = %f, Best split point = %d, best time = %f\n', m, best_split, t(best_split));
    best_t(end+1) = t(best_split);
    best_scores(end + 1,:) = scores;
end

figure
imagesc(best_scores);
xlabel('Candidate change point');
ylabel('Score');

% Plot
figure;
subplot(4,1,1)
% plot(disp,'k');
% hold on;
% xline(stage1_idx(end),'b','LineWidth',2);
% xline(best_split,'r','LineWidth',2);
% ylabel('\Deltar');

subplot(4,1,2)
plot(d_azi,'k');
hold on;
xline(stage1_idx(end),'b','LineWidth',2,'DisplayName','Stage 2');
xline(best_split,'r','LineWidth',2,'DisplayName','Stage 3');
ylabel('\Delta azimuth');
legend('Location', 'best');

subplot(4,1,3)
plot(d_pol,'k');
hold on;
xline(stage1_idx(end),'b','LineWidth',2,'DisplayName','Stage 2');
xline(best_split,'r','LineWidth',2,'DisplayName','Stage 3');
ylabel('\Delta polar');
legend('Location', 'best');

subplot(4,1,4)
plot(split_points,scores,'LineWidth',2);
xlabel('Candidate split');
ylabel('Score');
sgtitle('Stage2 / Stage3 segmentation');



% Plot
figure;
subplot(4,1,1)
plot(disp_all,'k');
hold on;
xline(stage1_idx(end),'b','LineWidth',2,'DisplayName','Stage 2');
xline(best_split,'r','LineWidth',2,'DisplayName','Stage 3');
ylabel('Displacement');
legend('Location', 'best');

subplot(4,1,2)
plot(azi_all,'k');
hold on;
xline(stage1_idx(end),'b','LineWidth',2,'DisplayName','Stage 2');
xline(best_split,'r','LineWidth',2,'DisplayName','Stage 3');
ylabel('Azimuth');
legend('Location', 'best');

subplot(4,1,3)
plot(pol_all,'k');
hold on;
xline(stage1_idx(end),'b','LineWidth',2,'DisplayName','Stage 2');
xline(best_split,'r','LineWidth',2,'DisplayName','Stage 3');
ylabel('Polar');
legend('Location', 'best');

subplot(4,1,4)
plot(split_points,scores,'LineWidth',2);
xlabel('Candidate change point');
ylabel('Score');
sgtitle('Stage2 / Stage3 segmentation');

