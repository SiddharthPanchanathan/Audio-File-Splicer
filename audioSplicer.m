function audioSplicer()
% Builds and plays a soundtrack with fade transitions.
% The constituent soundfiles...
C = {'testAudio4.wav' , 'testAudio2.wav' , 'testAudio3.wav' , 'testAudio1.wav'};

for k=1:length(C)
    [s,r] = wavread(C{k});
    SA(k) = MakeSound(s,r);
end
fadeTime = 6;
T = MakeSoundTrack(SA,fadeTime); 
sound(T.data,T.rate)
% Dear Mr. Spielberg, Attached please find a copy of...
% wavwrite(T.data,T.rate,'Trailer.wav')  

%%%%%%%%%% Given Subfunctions %%%%%%%%%%%%%%%

function S = MakeSound(s,r)
% s is a real column n-vector with components in the interval [-1,+1].
% r is a sampling rate.
S = struct('data',s,'rate',r);

function S = MakeSoundTrack(SA,fadeTime)
% SA is a length N structure array of sounds, each of which has duration greater
% than fadeTime and each of which has sampling rate = 8000.
% S is a sound obtained by playing SA(1),...,SA(N) in order with fade
% transitions lasting fadeTime seconds. S has sample rate 8000.
for k=1:length(SA)
    SA(k) = convert(SA(k));
end
S = SA(1);
for k=2:length(SA)
    S = splice(S,SA(k),fadeTime);
end

%%%%%%%%%% Your Subfunctions %%%%%%%%%%%%%%%%%


function P = convert(Q)
% Q is a sound with sample rate >=8000.
% P is a sound with the property that sound(P.data,8000) is acoustically
% close to sound(Q.data,Q.rate).

% T = duration of Q...
T = length(Q.data)/Q.rate;
% Initialize the new sound vector...
nP = ceil(T*8000);
s = zeros(nP,1);
% The two sampling intervals...
delP = 1/8000;
delQ = 1/Q.rate;
for i=1:nP
    % the time associated with the P's ith sample...
    t = i*delP;
    % the nearest sample point in Q is in component k of its data vector...
    k = round(t/delQ);
    s(i) = Q.data(k);
end
P = MakeSound(s,8000);

function S = splice(P,Q,tau)
% tau is a positive real number.
% P and Q are sounds, each with duration > tau and each with the same
% sampling rate.
% S is the splice of P and Q with overlap equal to tau seconds.

% m is the number of components associated with tau seconds
m = round(tau*P.rate);
% Do a weighted interpolation of the last m components of of P.data and
% the first m components of Q.data...
nP = length(P.data);
nQ = length(Q.data);
c = wAve(P.data(nP-m+1:nP),Q.data(1:m));
% Concatenate the first part of P.data, c, and the second part of Q.data...
s = [P.data(1:nP-m); c ; Q.data(m+1:nQ)];
S = MakeSound(s,P.rate);

function c = wAve(a,b)
% a and b are column n-vectors.
% c is their weighted average.
n = length(a);
c = zeros(n,1);
for i=1:n
    w = i/(n+1);
    c(i) = (1-w)*a(i)  + w*b(i);
end
% Vectorized solution: w = (1:n)'/(n+1); c = (1-w).*a + w.*b;


