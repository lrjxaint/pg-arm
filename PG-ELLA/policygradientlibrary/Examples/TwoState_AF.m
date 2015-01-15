% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Discrete Problems Library: Two-State Example
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programmed by Jan Peters. Requires Matlab 5.3.0 and higher. If 
% the results used in any publication, a reference to the paper
% would be highly appreciated.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem settings:
% - Discounted reward formulation
% - Decision border policy
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Encoding the Problem
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global N M p p0 r gamma

% Set problem size
N = 2;  % Set number of states 
M = 2;  % Set number of actions   

% Start state distribution
p0(1) = 0.5;
p0(2) = 0.5;

% Transition table p(x, u, x') -> [0, 1]
p(1,1,1) = 1; p(1,2,1) = 0;
p(1,2,2) = 1; p(1,1,2) = 0;

p(2,1,1) = 1; p(2,2,1) = 0; 
p(2,2,2) = 1; p(2,1,2) = 0; 

% Reward table r(x, u) -> IR
r(1,1) = 2;   r(1,2) = 0; 
r(2,1) = 0;   r(2,2) = 1; 

% Average Reward Formulation
gamma=1.0;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Encoding the Policy
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select an epsilon-greedy Gibbs policy with epsilon = 1
% epsilon = 1;
% policy = initEpsGreedyGibbsPolicy(epsilon);

% Select a decision border policy
policy = initDecisionBorderPolicy;

% Select initial policy
policy.theta = [0.43 0.67];

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Obtaining the Foundations
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transition and resolvent kernels

% i-step Transition Kernels for i=1:7
for i=1:7
   % Compute i-step Transition Kernel
   K_i = transitionKernel(policy, i)
   
   % Show i-step Transition Kernel
   figure(1); subplot(3,3,i); showKernel(K_i, ['K_\pi^' num2str(i)]);
end;

% Compute oo-step Transition Kernel
K_oo = transitionKernel(policy, 10^20)
   
% Show oo-step Transition Kernel
figure(1); subplot(3,3,8); showKernel(K_i, ['K_\pi^\infty']);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stationary and discounted distribution

dstat = stationaryDistribution(policy)

% Show Distributions
figure(2); 
subplot(1,2,1); bar(dstat); title('Stationary Distribution d^\pi(x)'); 
xlabel('State x'); ylabel('d^\pi(x)');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expected Reward

% Calculate the map of average rewards ... 
for i=0:10
   for j=0:10
      % Set policy parameters
      policy.theta = [i/10 j/10];
      J_pi(j+1, i+1) = expectedReturn(policy);                        
   end;
end;   

J_pi

% Show the map of average rewards ... 
figure(44); colormap hot;
contourf(0:0.1:1, 0:0.1:1, J_pi, 6); hold on;
xlabel('Parameter \theta_2');
ylabel('Parameter \theta_1');
title('Expected reward J(\pi_\theta)');

% Determine optimal policy
optimalPolicy = optimalSolution(policy)

% Show optimal policy
plot(optimalPolicy.theta(1), optimalPolicy.theta(2), 'w*');
plot(optimalPolicy.theta(1), optimalPolicy.theta(2), 'ks');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Value & advantage functions

% Select old policy again ...
policy.theta = [0.43 0.67];

% Calculate Value Functions
for x=1:N
    V(x) = VFnc(policy, x);
	for u=1:M
		Q(x,u) = QFnc(policy, x, u);
      A(x,u) = AFnc(policy, x, u); 
   end;   
end;   

V
Q
A

% Plot value functions
figure(3); 
subplot(1,3,1); bar(V); title('Value Function V^\pi(x)'); 
xlabel('State x'); ylabel('V^\pi(x)');
subplot(1,3,2); showFunc(Q, 'Value Function Q^\pi(x, u)');
subplot(1,3,3); showFunc(A, 'Advantage Function A^\pi(x, u)');

dJdtheta = policyGradient(policy);
dJdtheta
w = naturalPolicyGradient(policy);
w

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Obtaining the Gradients
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show the map of average rewards ... reuse old data
figure(5); clf;
subplot(1,2,1); contour(0:0.1:1, 0:0.1:1, J_pi, 6); hold on;
subplot(1,2,2); contour(0:0.1:1, 0:0.1:1, J_pi, 6); hold on;

n_arrows = 15; l_arrows = 1/n_arrows;
for i=0:n_arrows
   for j=0:n_arrows
      % Set admissable policy parameters
      policy.theta = [admissable(i/n_arrows) admissable(j/n_arrows)];
      
      % Calculate Policy Gradient
      dJdtheta = policyGradient(policy);                        
      
      % Show Policy Gradient
      subplot(1,2,1); 
      arrow(policy.theta, l_arrows*dJdtheta/sqrt(sum(dJdtheta.^2)), 'r');
      
      % Calculate Natural Gradient
      w = naturalPolicyGradient(policy); 
      
      % Show Policy Gradient
      subplot(1,2,2); 
      arrow(policy.theta, l_arrows*w/sqrt(sum(w.^2)), 'r');      
      
      stat=stationaryDistribution(policy);
      stat1(i+1,j+1) =stat(1);
      stat2(i+1,j+1) =stat(2);
   end;
end;   









