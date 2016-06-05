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

title_sm_map = containers.Map(titles_sorted, 1:npages)


fclose('all');
% Note: the encoding is not really windows-1252, but the effect will be
% to preserve the actual encoding (utf-8) in the final file.
f_in= fopen('c:\wikipedia\20160204\enwiki-20160305-pagelinks.sql','r','n','windows-1252');

f_out=fopen('links-simple-matlab.txt','w','n','windows-1252');

line=0;
dummy_left=char(57344);
dummy_quote=char(57345);
dummy_right=char(57346);
dummy_backslash=char(57347);
dummy_empty=char(57348);

tic;
last_page_id=-10;
num_links=0;
last_title='---dumy---';
last_not_found='';
last_sm_id=-1;
num_not_found=0;
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
                x(starts(j)+(k-1)*2:starts(j)+(k-1)*2+1)=[dummy_backslash, dummy_empty];
            end
        end
        
        
        x=strrep(x,'\''', dummy_quote);
        x=strrep(x,'\"','"');
        x=strrep(x,'''''', '');
        x=strrep(x,'''wikitext''','');
        
        if any(x=='\')
            tmp=strrep(x,'\"','"');
            for j=find(tmp=='\'); disp(tmp(j-10:j+40));end
        end
        
        
        qu = find(x=='''');
        nqu = length(qu);
        assert(mod(nqu,2)==0);
        for j=1:nqu/2
            k1=qu(2*j-1);
            k2=qu(2*j);
            if k2>k1+1
                y=x(k1+1:k2-1);
                j1 = find(y=='(');
                j2 = find(y==')');
                if ~isempty(j1) || ~isempty(j2)
                    x(k1+j1)=dummy_left;
                    x(k1+j2)=dummy_right;
                end
            end
        end
        L=find(x=='(');
        R=find(x==')');
        assert(length(L)==length(R));
        N=length(L);
        for j=1:N
            
            y=x(L(j)+1:R(j)-1);
            %disp(x(L(j):R(j)));
            v = sscanf(y, '%d,%d,');
            q=find(y=='''',2);
            title=y(q(1)+1:q(2)-1);
            
            page_id=v(1);
            namespace_id=v(2);
            title(title==dummy_quote)='''';
            title(title==dummy_left)='(';
            title(title==dummy_right)=')';
            title(title==dummy_backslash)='\';
            title=strrep(title,dummy_empty,'');
            
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
                sm_id=-1;
                
                if strcmp(last_title, title)
                    sm_id=last_sm_id;
                    
                else
                    try
                        sm_id = title_sm_map(title);
                        
                        
                    catch
                    end
                    
                end
                
                % Changed from pid_sm(page_id):  sm_id
                % to  sm_id:  pid_sm(page_id)
                
                if sm_id>-1
                    %if page_id~=last_page_id
                    %    last_page_id=page_id;
                    %    fprintf(f_out,'\n%d: ',pid_sm(page_id));
                    %end
                    %fprintf(f_out,' %d',sm_id);
                    if sm_id~=last_sm_id
                        
                        fprintf(f_out,'\n%d: ',sm_id);
                    end
                    fprintf(f_out,' %d',pid_sm(page_id));
                    num_links = num_links + 1;
                else
                    num_not_found = num_not_found + 1;
                    last_not_found=title;
                    last_not_found_from = titles_sorted{pid_sm(page_id)};
                end
                
                last_title=title;
                last_sm_id=sm_id;
                
                
                
                
            else
                n1=n1+1;
            end
            
        end
        
        
        
        fprintf('line=%d  n0=%d  n1=%d  num_links=%d time=%f  num_not_found=%d   last not found=%s  (from) %s\n',line,n0,n1,num_links,toc,num_not_found,last_not_found,last_not_found_from);
        %fprintf(f_out,'%% line=%d\n',line);
        %disp(q)
    end
    
    if feof(f_in);break;end
end

save link_param num_links
fclose(f_in);



