function a=psignifit_custom(data)
    %This function uses psiginit 4 with custom settings to calculate temporal order thresholds (TOTs).
    %Therefore it requires psignifit 4 to be added to the path of Matlab.
    %
    %It takes data as an argument in a form of structure containg fields "stim_seq_diff" with ISIs 
    %and "trial_status" field collecting information about correctness of trials, with values ''CORRECT'' for correct responses. 

    %take a vector with all ISIs
    ISIs=[data.stim_seq_diff];

    %create vector with all durations of ISI, sorted ascending
    X=unique(ISIs);

    %total number of ISI durations
    N = numel(X);

    %count occurences of each ISI duration
    count = zeros(1,N);
    for k = 1:N
        count(k) = sum(ISIs==X(k));
    end


    %count only correct trials for each duration of ISI
    correct=zeros(1,N);
     for kk=1:N
         for ii=1:length(data)
              if X(kk)==data(ii).stim_seq_diff && data(ii).trial_status=='''CORRECT'''
                 correct(kk)=correct(kk)+1;
             end
         end
     end


     % configuration of psignifit 4

    mini=1; %minimal duration of interval 
    maxi=150; %maximal duration of interval 

    data_fit=[X' correct' count'];
    options             = struct;
    options.sigmoidName = 'logistic';   % choose a logistic curve as the sigmoid  
    options.expType     = '2AFC';  % set 2 alternatives forced choice as the type of experiment

    options.threshPC = 0.71; % select the threshold for the unscaled sigmoid, here 0.71 was used as the overall correctness converged to this value  
    options.stimulusRange =[mini,maxi]; % set the stimulus range for the priors


    options.nblocks        = 0;   % number of blocks required to start pooling
    options.poolMaxGap     = inf;  % maximal number of trials with other stimulus levels between pooled trials 
    options.poolMaxLength  = inf;  % maximal number of trials per block 
    options.poolxTol       = 2; % max difference between durations to pool the data 

    result = psignifit(data_fit,options);

    a=getThreshold(result,0.75); % get the temporal order threshold

end

