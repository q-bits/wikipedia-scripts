function analyse_links_file

% Creates the file "links-simple-sorted.txt", using the file
% "links-simple-matlab.txt" created by convert_links_file.m
%
% Henry Haselgrove, January 2009.

load params num_pages 
load link_param num_links

global titles_sorted 
if ~exist('titles_sorted','var')
    load sorted_out2;
end


NL=num_links;
NP=num_pages;
fclose('all');


fid=fopen('links-simple-matlab.txt','r');


froms=zeros(NL,1);
tos=zeros(NP,1);


nlinks=0;
tic;
line=0;


count=0;

while(1)
    line=line+1;
   % if line==100000;break;end
    x=fgetl(fid);
   
    
    col=find(x==':');
    if length(col)==1
        to=str2num(x(1:col-1));
        from=str2num(x(col+1:end));

        num = length(from);
        tos(nlinks+1:nlinks+num) = to;
        froms(nlinks+1:nlinks+num)=from;
        nlinks=nlinks+num;
    end
    
    
    if mod(line,10000)==0;
        fprintf('\n line=%d  nlinks=%d  time=%f',line,nlinks,toc);
    end
    
    if feof(fid);break;end;
    
    %if nlinks>20000000;break;end
    
end
fprintf('nlinks=%d  NL=%d\n',nlinks,NL);


S=sparse(tos(1:nlinks),froms(1:nlinks), ones(nlinks,1), NP,NP);

if 0
    fot = fopen('links-text.txt','w');
    for from=1:NP
        to = find(S(:,from));
        nto =length(to);
        %if nto>0 && rand < .0001
        fprintf(fot,'%s:',titles_sorted{from});
        for k=1:nto
            fprintf(fot,' %s',titles_sorted{to(k)});
        end
        fprintf(fot,'\n');
        %end
    end
end

%return


fo=fopen('links-simple-sorted.txt','w');
for from=1:NP
    to = find(S(:,from));
    if length(to)>0
        fprintf(fo,'%d:',from);
        fprintf(fo,' %d',to);
        fprintf(fo,'\n');
    end
end
fclose(fo);

return


for j=1:NP
    if mod(j,100000)==0; fprintf('\n   write   line=%d  time  = %f',j,toc);end
    nout=nouts(j);
    if nout>0
        fprintf(fo,'%d:',j);
        for kk=1:nout
            fprintf(fo,' %d',outs(starts(j)+kk-1));
        end
        fprintf(fo,'\n');
    end
end

%save alout2 outs

