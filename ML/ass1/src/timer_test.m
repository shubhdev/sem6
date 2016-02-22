f = fopen('timertest.txt','w');
t = timer('TimerFcn', 'stat=false; fprintf(f,''fuck\n'')',... 
                 'StartDelay',1,'UserData','{a,b}');
start(t)
global wew = 1;
stat=true;
while(stat==true)
  disp('.')
  pause(1)
end