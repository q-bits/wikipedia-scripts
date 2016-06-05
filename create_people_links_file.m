function create_people_links_file

% Creates the file "links-people.txt"


load params num_pages
load link_param num_links

global titles_sorted  sm_pid
if ~exist('titles_sorted','var')
    load sorted_out2;
end

load sm_people sm_people
sm_are_people=zeros(length(sm_pid),1);
sm_are_people(sm_people)=1;
sm_are_people=logical(sm_are_people);

ssm_people = sort(sm_people);
sm_psm = zeros(length(sm_pid),1);
sm_psm(ssm_people) = 1:length(sm_people);

NL=num_links;
NP=num_pages;
fclose('all');

froms_per_person=cell(length(sm_pid),1);
nfroms_per_person = zeros(length(sm_pid),1);

fid=fopen('links-simple-sorted.txt','r');

fido=fopen('links-people.txt','w');

fido_psm=fopen('links-people-psm.txt','w');

fido_people_titles=fopen('people-sorted.txt','w','n','windows-1252');
tmp=0;
for j=1:length(sm_pid)
    q = sm_psm(j);
    if q>0
        tmp=tmp+1;
        assert(tmp==q);
        fprintf(fido_people_titles,'%s\n',titles_sorted{j});
    end
end
fclose(fido_people_titles);

%froms=zeros(NL,1);
%tos=zeros(NP,1);


nlinks=0;
tic;
line=0;


%count=0;

while(1)
    line=line+1;
    % if line==100000;break;end
    x=fgetl(fid);
    
    
    col=find(x==':');
    if length(col)==1
        from=str2num(x(1:col-1));
        to=str2num(x(col+1:end));
        
        from=from( sm_are_people(from));
        to = to(sm_are_people(to));
        
        num = length(to);
        numfr = length(from);
        
        
        if num>0 && numfr>0
            %fprintf('%s: ',titles_sorted{from});
            %for k=1:num; fprintf('%s, ',titles_sorted{to(k)});end
            %fprintf('\n');
            fprintf(fido,'%d:',from);
            fprintf(fido,' %d',to);
            fprintf(fido,'\n');
            
            fprintf(fido_psm,'%d:',sm_psm(from));
            fprintf(fido_psm,' %d',sm_psm(to));
            fprintf(fido_psm,'\n');
            
            froms_per_person{from} = to;
            nfroms_per_person(from)= num;
            nlinks=nlinks+num;
        end
        %tos(nlinks+1:nlinks+num) = to;
        %froms(nlinks+1:nlinks+num)=from;
      
    end
    
    
    if mod(line,10000)==0;
        fprintf('\n line=%d  nlinks=%d  time=%f',line,nlinks,toc);
    end
    
    if feof(fid);break;end;
    
    %if nlinks>20000000;break;end
    
end
%fprintf('nlinks=%d  NL=%d\n',nlinks,NL);

save person_links froms_per_person nfroms_per_person

return;

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

