function sortpages

% Read the file "page-simple-matlab2.txt" (created by convert_page_file.m)
% and create the .mat file "sorted_out2.mat", containing a sorted list of page titles
% and a new set of page-ids which replace the page-ids assigned by wikipedia.
%
% Henry Haselgrove, January 2009

load params num_pages max_page_id

tic

fclose('all');
fid=fopen('page-simple-matlab2.txt','r');

% The total number of pages:
np=num_pages;

% The maximum page_id assigned by wikipedia:
max_pid=max_page_id;


page_ids=zeros(np,1,'int32');
titles=cell(np,1);

for j=1:np
    if mod(j,100000)==0; fprintf('%d \n',j);end
    x=fgetl(fid);
    ind=find(x==' ',1,'first');
    page_ids(j)=int32(str2num(x(1:ind-1)));
    titles{j}=x(ind+1:end);
    
end

disp(x)

toc

[titles_sorted,b]=sort(titles);
clear titles
sm_pid=page_ids(b);
clear b
pid_sm=-ones(max_pid,1,'int32');   %The size of this array corresponds to the maximum value of any wikipedia-assigned page id.
pid_sm(sm_pid)=[int32(1):int32(np)];

save sorted_out2 titles_sorted pid_sm sm_pid

fid=fopen('titles-sorted.txt','w'); for j=1:length(titles_sorted); fprintf(fid,'%s\n',titles_sorted{j});end;fclose(fid);


