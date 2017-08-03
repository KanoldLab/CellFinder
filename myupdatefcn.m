function txt = myupdatefcn(empt,event_obj)
% Customizes text of data tips

pos = get(event_obj,'Position');
%txt = {['X: ',num2str(pos(1))],['Y: ',num2str(pos(2))]};
txt = {''};