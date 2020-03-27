S(1).f1 = rand(1,5);
S(2).f1 = rand(1,10);
S(3).f1 = rand(1,15);
A = arrayfun(@(x) mean(x.f1),S);


arr = [ struct('val',0,'id',1), struct('val',0,'id',2), struct('val',0,'id',3) ]

% some attempts
[arr.val]=arr.val; % fine
[arr.val]=arr.val+3; % NOT fine :(

% works !
arr2 = arrayfun(@(s) setfield(s,'val',s.val+3),arr)


arr2 = arrayfun(@(structureVariable) setfield(structureVariable,'colordata',readFrame(vidObj)),structureVariable)
