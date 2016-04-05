function convert_page_file

% Parse the downloaded file enwiki-20081008-page.sql, and create the
% simpler file page-simple-matlab2.txt containing a list of page titles and
% corresponding wikipedia-assigned page ids.
%
% Henry Haselgrove, January 2009.

fclose('all');
f_in= fopen('h:\wikipedia\enwiki-20081008-page.sql','r','n','');
f_out=fopen('page-simple-matlab2.txt','w','n','');
%f_out2=fopen('e:\wikipedia\tmp.txt','w','n','utf-8');

u=[];
line=0;
%dummy='??';
%dummy2='??';
dummy=char([1132,1136]);
dummy2=char([1132,1139]);
tic;
max_page_id=0;
num_pages=0;

while(1)
    n0=0;n1=1;
    x=fgetl(f_in);
    %fprintf(f_out2,'%s\n',x);
    if length(x)<27 || ~strcmp(x(1:11),'INSERT INTO');
        disp(x);
    else
        line=line+1;
        % if line<300;continue;end
        x=[x(27:end),'  '];y=x;
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
                
                if namespace_id==0
                    fprintf(f_out,'%d %s\n',page_id,title);
                    %fprintf('%d %s\n',page_id,title);
                    n0=n0+1;
                    if any(title==char(26))
                        fprintf('%d %s\n',page_id,title);
                        
                        
                    end
                    num_pages=num_pages+1;
                    if page_id>max_page_id; max_page_id=page_id;end
                    
                else
                    n1=n1+1;
                end
                
            end
            
        end
        fprintf('line=%d  n0=%d  n1=%d  time=%f\n',line,n0,n1,toc);
        
        %disp(q)
    end
    
    if feof(f_in);break;end
end

fprintf('Number of pages:%d  \nMax page id:%d\n',num_pages,max_page_id);
save params num_pages max_page_id
fclose(f_in);