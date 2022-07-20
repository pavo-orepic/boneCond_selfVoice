function [data] = finalBehavior100(subjectID, task, tool, order)
% finalBehavior100('1', 'S', 'E', 1);
% task is always 'S'
% tool is 'B' or 'E' (bone-conduction, earphones)
% order is block order (1, 2)

% configure arduino connection for triggers
% ard = arduino('COM9', 'Micro');
% configurePin(ard,'D2', 'DigitalOutput');      % trial start
% configurePin(ard,'D3', 'DigitalOutput');      % sounds
% configurePin(ard,'D4', 'DigitalOutput');      % response

fileName = ['Control_100_S' num2str(subjectID) '_'  task '_' tool '_' num2str(order)];

try 	
    
    % ----------------------
    % Check input arguments:
    % ----------------------
    

    if ~(tool == 'B' || tool == 'E')     % speakers or earphones
		disp('Tool has to be either ''B'' or ''E''! ');
		data = tool;
		return
    end    
    
    if ~(task == 'S'  )  
		disp('Task has to be ''S''! ');
		data = task;
		return
    end 
    
    
    levels = [1 2 3];  % 1 = self, 2 = familiar, 3 = other
    
    folder = '100';

    % ----------------------------------------
    % Randomization of the trial presentation: 
    % ----------------------------------------
    T = repmat(levels, 1, 10); % trial levels
    nt = length(T); % number of trials
    T(1:nt)= T(Shuffle(1:nt));   
  

    % -------------------------------------------------
    % Perform basic initialization of the sound driver:
    % -------------------------------------------------

	% TODO this won't work on Windows
	% 
    % InitializePsychSound(1);
	% frequency = 44100;
	% nrChannels = 1;
    % phandle = PsychPortAudio('Open', [], [], 1,frequency, nrChannels);
    
    
    %-------------------------------------------------------------
    %                  Start The Experiment:                     
    %-------------------------------------------------------------
    disp('Experiment starts in 3 seconds! ');
    WaitSecs(3); % just so that it is not too sudden
    disp('Experiment started! ');
    [beepSound, beepFreq] = MakeBeep(500,1); % a beep indicates the start
    sound(beepSound, beepFreq);
    WaitSecs(3);  % the voices come 3 seconds after the beep
   
    subject = ones(1, 30)*str2num(subjectID);
    resp = zeros(1, nt); % responses (1 = me; 3 = other)
    rT = zeros(1, nt);   % reaction times
    iti = zeros(1, nt);  % intertrial inteval jitter between 1.0 and 1.5 seconds
    
    for  t=1:nt        
			disp(['Start of trial ' num2str(t) '.']);
            jitter = 1 + 0.5*rand(1);  % intertrial inteval jitter between 1.0 and 1.5 seconds
			
            %-----------------------------
            % Open the corresponding file:
            %-----------------------------			
			
            path = [ folder filesep num2str(T(t)) '.wav'];
            
            [soundData, soundFreq] = audioread(path);
			soundData = soundData';			

			%-------------------
            % Play the Sounds:
            %-------------------	

        	sound(soundData, soundFreq);
            
            %!!!!!!!!!! TODO send the trigger here  !!!!!!!!!!!
% 			writeDigitalPin(ard, 'D3', 1);   % the sound trigger goes up after the first sound
%             WaitSecs(0.05); 
%             writeDigitalPin(ard, 'D3', 0);
			
            %------------------
			% Get the response:
			%------------------
             
			responseTime = 0;
			buttons = 0;
			startTime = GetSecs;
            while ~buttons	
                [~, ~, buttons] = GetMouse();
                responseTime = GetSecs - startTime; 
            end

                
            rT(t) = responseTime;
            buttonsIndex = find(buttons);   % in case the subject presses both
            resp(t) = buttonsIndex(1);
            iti(t) = jitter;
            
            disp(['Level: ' num2str(T(t)) '; Response: ' num2str(resp(t)) '; Time: ' num2str(rT(t)) '.']);

            WaitSecs(jitter);          
            			         

    end
    
    disp('Experiment ended! ');
    %save(fileName, 'subject', 'T', 'resp', 'rT', 'iti');
	disp(['File: ' fileName '.mat saved!']);

    % PsychPortAudio('Close' , pamaster);


catch ME
    
    rethrow(ME);

end


% code task
if (task == 'S')
    taskID = 1;
elseif (task == 'F') % should never appear
    taskID = 2;
else
    taskID = 3; % should never appear
end

% code tool
if (tool == 'B')
    toolID = 1;
elseif (tool == 'E')
    toolID = 2;
else
    toolID = 3;  % should never appear
end




taskArr = ones(30, 1)*taskID;
toolArr = ones(30, 1)*toolID;
orderArr = ones(30, 1)*order;
%------------------
% Create csv files:
%------------------  
% create output matrix
data = horzcat(subject', T', resp', rT', iti', taskArr, toolArr, orderArr);

csvwrite([ fileName '.csv'], data);
disp(['File:' fileName '.csv saved!']);

end

