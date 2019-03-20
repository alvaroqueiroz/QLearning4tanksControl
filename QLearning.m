%% Simulation of the 4-tank plant - control with learning by reinforcement - Q-Learning
% Author: Álvaro Queiroz
% Simulink model Adolfo Bauchspiess - University of Brasília

% Process Parameters
d=6;      % reservoirs depth
A1=d*9.9; % cm2   - transversal section of the reservoirs
A2=d*10;  % cm2
A3=d*10;  % cm2
A4=d*10;  % cm2


% valve positions 4-3-3 - Refer to Readme to understand this;

k1=0; 
k3= 0;
k2=4.313;
k4=4.9667;

k12=12.18;
k23=11.89;
k34=10.09;

% initial conditions, empty reservoirs
h1=0;
h2=0;
h3=0;
h4=0;

hmax=1;  % reservoirs heigth 50 cm
qmax=60;
qmin=0;

% Sampling rate 
T = 0.5;  % seconds

% To avoid the use of dynamic lengh vectors, we declare them here with
% zeros, to avoid performance issues
H4       = zeros(100,1);                                         
entrada = zeros(10201,1);
saida = zeros(10201,1); 
%% DEFINE Q-LEARNING PARAMS
% Reward function
rewardFunc = @(x,xdot)(-abs(x-xdot).^2);
% Learning rate
learnRate = 0.99; % How is new value estimate weighted against the old (0-1). 1 means all new and is ok for no noise situations.

%%% Exploration vs. exploitation
% Probability of picking random action vs estimated best action
epsilon = 0.1; % Initial value
epsilonDecay = 0.95; % Decay factor per iteration.

%%% Future vs present value
discount = 0.98; % When assessing the value of a state & action, how important is the value of the future states?

actions = linspace(0.2,1,20); % actions the controller may take
 
%% INITIALIZE REF, REWARDS, STATES AND Q MATRIX

%references are the values the actor will try to follow - they are the
%reservoirs height the actor should try to get
ref(1:2100) = 0.2;
ref(2101:4100) = 0.2;
ref(4101:6100) = 0.2;
ref(6101:8201) = 0.2;
ref(8101:10201) = 0.2;
ref = ref';

% State1 is H4,
x1 = 0.0:0.01:1;
x2 = 0.0:0.01:1;

%Generate a state list
states=zeros(length(x1)*length(x2),2); % 2 Column matrix of all possible combinations of the discretized state.
index=1;
for j=1:length(x1)
    for k = 1:length(x2)
        states(index,1)=x1(j);
        states(index,2)=x2(k);
        index=index+1;
    end
end

R = rewardFunc(states(:,1),ref); % cost function
Q = repmat(R,[1,length(actions)]); % Q is length(x1) x length(x2) x length(actions)
% We should save Q to reset Q table in case of new ref
Q0 = Q;

U = 1;
H4(1) = 0;

for k=2:10201
  
    %% CHOOSE ACTION, OBSERVE STATE
    if abs(ref(k)-ref(k-1))>0
        Q = Q0;
    end
        
        % Interpolate the state within our discretization (ONLY for choosing
        % the action. We do not actually change the state by doing this!)
    [~,sIdx] = min(sum((states - repmat([H4(1),h3(end)],[size(states,1),1])).^2,2));
        
        % Choose an action:
        % EITHER 1) pick the best action according the Q matrix (EXPLOITATION). OR
        % 2) Pick a random action (EXPLORATION)
    if (rand() > epsilon) % Pick according to the Q-matrix it's the last episode or we succeed with the rand()>epsilon check. Fail the check if our action doesn't succeed (i.e. simulating noise)
        [~,aIdx] = max(Q(sIdx,:)); % Pick the action the Q matrix thinks is best!
    else
        aIdx = randi(length(actions),1); % Random action!
    end
        
    U = actions(aIdx);
    %take action, observe output        
    sim('modelo_simulink'); % simulate system, "modelo_simulink" must be in the current folder
    H4(1) = h4(end); % get h4 height
    
    ERRO = H4(1)-ref(k);
 %% UPDATE Q-MATRIX
        
    % As the system get close to ref, it's actions receive bonus ever
    % increasing
    if abs(ERRO) < 0.01  
        bonus = 0.01;
    else
    if abs(ERRO) < 0.008  
        bonus = 0.02;
    else
    if abs(ERRO) < 0.005  
        bonus = 0.04;
    else
        bonus = -0.01;
    end
    end
    end

    [~,snewIdx] = min(sum((states - repmat([H4(1),h3(end)],[size(states,1),1])).^2,2)); % Interpolate again to find the new state the system is closest to.   
    
    if k < 10201 % On the last iteration, stop learning and just execute. Otherwise...
        % Update Q
        %Q(sIdx,aIdx) = Q(sIdx,aIdx) + learnRate * ( R(snewIdx) + discount*max(Q(snewIdx,:)) - Q(sIdx,aIdx) + bonus );
        Q(sIdx,aIdx) = Q(sIdx,aIdx) + learnRate * (R(snewIdx) + discount*max(Q(snewIdx,:)) - Q(sIdx,aIdx) + bonus*20 );

    end

    % Decay the odds of picking a random action vs picking the
    % estimated "best" action. I.e. we're becoming more confident in
    % our learned Q.
    epsilon = epsilon*epsilonDecay;                                             

    %save states of simulation for the next
    
    h1=h1(end);
    h2=h2(end);
    h3=h3(end);
    h4=h4(end);

    %save input output
  
    entrada(k)= U;
    saida(k)= H4(1);
    
    %display in command windows ref H4 U   
    [ref(k); H4(1); U]
    
end
RMSE = sqrt(mean((ref - saida).^2));
