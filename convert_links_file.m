function convert_links_file

% Parse the links database file "enwiki-20081008-pagelinks.sql", and produce
% the file "links-simple-matlab.txt". Requires the .mat file
% "sorted_out2.mat" created by sortpages.m
%
% Henry Haselgrove, January 2009

global titles_sorted sm_pid pid_sm

if ~exist('sm_pid','var') ||  length(sm_pid)==0
   load sorted_out2;
end

npages=length(sm_pid);

w=zeros(1,npages+2); for j=1:npages; w(j+1)=double(titles_sorted{j}(1));end;
w(1)=-1; w(end)=999999;
Hstarts=-ones(256,1);
Hstops=-ones(256,1);
hash=find(diff(w)>0);
Hstarts( w(  hash(1:end-1)+1)  )=hash(1:end-1);
Hstops( w(   hash(1:end-1)+1)  )=hash(2:end)-1;

fclose('all');
f_in= fopen('h:\wikipedia\enwiki-20081008-pagelinks.sql','r','n','');
f_out=fopen('links-simple-matlab.txt','w','n','');
%f_out2=fopen('e:\wikipedia\tmp.txt','w','n','utf-8');

%u=[];
line=0;
%dummy='??';
%dummy2='??';
dummy=char([1132,1136]);
dummy2=char([1132,1139]);
tic;
last_page_id=-10;
num_links=0;
while(1)
    n0=0;n1=1;
    x=fgetl(f_in);
    %fprintf(f_out2,'%s\n',x);

    if length(x)<31 || ~strcmp(x(1:11),'INSERT INTO');
        disp(x);
    else
        
        line=line+1;
        % if line<300;continue;end
        x=[x(32:end),'  '];y=x;
        di=diff(x=='\');
        starts = find(di==1)+1;
        stops = find(di==-1);
        lens = stops-starts+1;
        starts=starts(lens>1);
        %stops=stops(lens>1);
        lens=lens(lens>1);
        nrep = fix(lens/2);
        for j=1:length(nrep)
            for k=1:nrep(j)
                x(starts(j)+(k-1)*2:starts(j)+(k-1)*2+1)=dummy;
            end
        end
        
        
        x=strrep(x,'\''', dummy2);
        x=strrep(x,'(','{');
        x=strrep(x,')','}');
        x=strrep(x,dummy,'\\');
        x=strrep(x,['''',dummy2,''''],'''''''''');
        x=strrep(x,['''',dummy2],'''''''');
        x=strrep(x,[dummy2,''''],'''''''');
        x=strrep(x,dummy2,'''''');
        jjj=strfind(x,dummy2);
        if length(jjj)>0; error('help!');end
        jjj=strfind(x,dummy);
        if length(jjj)>0; error('help!');end
      
       if 1
            q={};
            eval(['q={',x,'};']);
            
            nq=length(q);
            for j=1:nq
                qj=q{j};
                if length(qj)>2
                    page_id=qj{1};
                    namespace_id=qj{2};
                    title=qj{3};
                    title=strrep(title,'{','(');
                    title=strrep(title,'}',')');
                    title=strrep(title,dummy2,'''');
                    
                    if namespace_id~=0 || page_id==0 || isempty(title); continue;end
                    
                    if pid_sm(page_id)==-1
                       % fprintf('\nNo such pid:  %d %s',page_id,title);
                    
                    elseif namespace_id==0 && page_id>0
                        %fprintf(f_out,'%d %s\n',page_id,title);
                        %fprintf('%d %s\n',page_id,title);
                        n0=n0+1;
                       % if any(title==char(26))
                       %     fprintf('%d %s\n',page_id,title);
                       % end
                        
                       % if page_id==93739 || page_id==95166
                       %     %fprintf('%d %s\n',page_id,title);
                       % end
                       
                       % Find sm_id
                       found=0;sm_id=-1;
                       LO = Hstarts(title(1));
                       HI = Hstops(title(1));
                       if LO==-1 || HI==-1; LO=1; HI=npages;end
                       
                       if strcmp(title,titles_sorted{LO})==1
                           sm_id=LO;found=1;
                       elseif strcmp(title,titles_sorted{HI})==1
                           sm_id=HI;found=1;
                       else
                       
                           lower=1;
                           upper=npages;
                           
                           while(1)
                                middle=fix( 0.5*(lower+upper));
                                if middle==lower;break;end
                                mt = titles_sorted{middle};
                                if length(mt)==length(title) && strcmp(title,mt)
                                    found=1;sm_id=middle;break;
                                else
                                    if strcmp_henry(mt,title)   %if mt>title
                                        upper=middle;
                                    else
                                        lower=middle;
                                    end
                                end
                           end
                           
                      
                           if found
                               if page_id~=last_page_id
                                   last_page_id=page_id;
                                   fprintf(f_out,'\n%d: ',pid_sm(page_id));
                               end
                               
                               
                               fprintf(f_out,' %d',sm_id);
                               num_links = num_links + 1;
                           end
                           
                           %if ~found
                           %    fprintf('NF: %d %s\n',page_id,title); 
                           %else
                           %    fprintf('%d (%d) %s -> %d (%d) %s\n',page_id,pid_sm(page_id),titles_sorted{pid_sm(page_id)},sm_id,sm_pid(sm_id),title); 
                           %end
                           
                       end
                           
                       
                       
                        
                    else
                        n1=n1+1;
                    end
                    
                end
                
            end
        end
        fprintf('line=%d  n0=%d  n1=%d  num_links=%d time=%f\n',line,n0,n1,num_links,toc);
        %fprintf(f_out,'%% line=%d\n',line);
        %disp(q)
    end
    
    if feof(f_in);break;end
end

save link_param num_links
fclose(f_in);


function y=strcmp_henry(a,b)

na=length(a);
nb=length(b);
n=na; if nb<na; n=nb;end;%min([na,nb]);

%ind = find(a(1:n)~=b(1:n),1,'first');
for ind=1:n
    if a(ind)==b(ind); continue;end
    if a(ind)>b(ind); y=1;return;end
    y=0;return;
end
if na>nb;y=1;return;end

y=0;return;

%if isempty(ind)
%    if na>nb;
%        y=1;return;
%    else
%        y=0;return;
%    end
%end
%
%if a(ind)>b(ind); y=1;return;else y=0;return;end



