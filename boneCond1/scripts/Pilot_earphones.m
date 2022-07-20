function [data] = Pilot_earphones(subjectID, task, tool, order)
% Pilot_earphones('1', 'N', 'E', 'F');
% tool is 'S' or 'E' (speakers, earphones)
% task is 'P' (primed) or 'N' (not primed)
% order is block order - 'F' or 'S' (first, second)


fileName = ['Pilot_earphones_S' num2str(subjectID) '_'  task '_' tool];

try 	
    
    % ----------------------
    % Check input arguments:
    % ----------------------
    

    if ~(tool == 'S' || tool == 'E')     % speakers or earphones
		disp('Tool has to be either ''S'' or ''E''! ');
		data = tool;
		return
    end    
    if ~(task == 'P' || task == 'N' )     % primed or not
		disp('Task has to be ''P'' or ''N''! ');
		data = task;
		return
    end 
    
     if ~(order == 'F' || order == 'S' )     % first or second
		disp('Order has to be ''F'' or ''S''! ');
		data = task;
		return
    end 
   
    
    
    levels = [15 30 45 55 70 85];  % percentage of patient's voice

   
    % ----------------------------------------
    % Randomization of the trial presentation: 
    % ----------------------------------------
    T = repmat(levels, 1, 10); % trial levels
    nt = length(T); % number of trials
    T(1:nt)= T(Shuffle(1:nt));   
  


    %-------------------------------------------------------------
    %                  Start The Experiment:                     
    %-------------------------------------------------------------
    disp('Experiment starts in 3 seconds! ');
    WaitSecs(3); % just so that it is not too sudden
    disp('Experiment started! ');
    [beepSound, beepFreq] = MakeBeep(500,1); % a beep indicates the start
    sound(beepSound, beepFreq);
    WaitSecs(3);  % the voices come 3 seconds after the beep
   
    subject = ones(1, 60)*str2num(subjectID);
    resp = zeros(1, nt); % responses (1 = me; 3 = other)
    rT = zeros(1, nt);   % reaction times
    iti = zeros(1, nt);  % intertrial inteval jitter between 1.0 and 1.5 seconds
    
    for  t=1:nt        
			disp(['Start of trial ' num2str(t) '.']);
            jitter = 1 + 0.5*rand(1);  % intertrial inteval jitter between 1.0 and 1.5 seconds
			
            %-----------------------------
            % Open the corresponding file:
            %-----------------------------			
			folder = 'voice';
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
                %!!!!!!!!!! TODO send the trigger for response here  !!!!!!!!!!!
            end

                
            rT(t) = responseTime;
            buttonsIndex = find(buttons);   % in case the subject presses both
            resp(t) = buttonsIndex(1);
            iti(t) = jitter;
            
            disp(['Level: ' num2str(T(t)) '; Response: ' num2str(resp(t)) '; Time: ' num2str(rT(t)) '.']);

            WaitSecs(jitter);          
            			         

    end
    
    disp('Experiment ended! ');


catch ME
    
    rethrow(ME);

end


% code task
if (task == 'N')
    taskID = 1;
elseif (task == 'P')
    taskID = 2;
else
    taskID = 3;
end

% code tool
if (tool == 'S')
    toolID = 1;
elseif (tool == 'E')
    toolID = 2;
else
    toolID = 3;
end

% code order
if (order == 'F')
    orderID = 1;
elseif (order == 'S')
    orderID = 2;
else
    orderID = 3;
end

taskArr = ones(60, 1)*taskID;
toolArr = ones(60, 1)*toolID;
orderArr = ones(60, 1)*orderID;
%------------------
% Create csv files:
%------------------  
% create output matrix
data = horzcat(subject', T', resp', rT', iti', taskArr, toolArr, orderArr);

csvwrite([ fileName '.csv'], data);
disp(['File:' fileName '.csv saved!']);

end

