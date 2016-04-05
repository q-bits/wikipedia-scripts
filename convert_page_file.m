
function convert_page_file

% Parse the downloaded file enwiki-20081008-page.sql, and create the
% simpler file page-simple-matlab2.txt containing a list of page titles and
% corresponding wikipedia-assigned page ids.
%
% Henry Haselgrove, January 2009.

feature('DefaultCharacterSet','UTF8')
feature('DefaultCharacterSet')

fclose('all');

f_in=fopen('c:\wikipedia\20160204\enwiki-20160305-page.sql','r','n','windows-1252');
f_out=fopen('page-simple-matlab2.txt','w','n','windows-1252');


dummy_left=char(57344);
dummy_quote=char(57345);
dummy_right=char(57346);
dummy_backslash=char(57347);
dummy_empty=char(57348);


tic;
max_page_id=0;
num_pages=0;
sk=0;
while(1)
    n0=0;n1=1;
    x=fgetl(f_in);
    %fprintf(f_out2,'%s\n',x);
    
    if length(x)<27 || ~strcmp(x(1:11),'INSERT INTO');
        disp(x);
    else
        line=line+1;
        %if line<320;disp('sk');continue;end
        
        
        x=x(27:end);
        y=x;

        
        di=diff(x=='\');
        starts = find(di==1)+1;
        stops = find(di==-1);
        lens = stops-starts+1;
        starts=starts(lens>1);
       % 
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
            
            page_id = v(1);
            namespace_id=v(2);
            %fprintf('%d %d %s\n',v(1),v(2),title);
            
            title(title==dummy_quote)='''';
            title(title==dummy_left)='(';
            title(title==dummy_right)=')';
            title(title==dummy_backslash)='\';
            title=strrep(title,dummy_empty,'');
            
            
            if any(title==char(26))
                fprintf('%d %s\n',page_id,title);
                sk=sk+1;
                continue;
                
            end
            
            if namespace_id==0
                fprintf(f_out,'%d %s\n',page_id,title);
                %fprintf('%d %s\n',page_id,title);
                n0=n0+1;
                
                num_pages=num_pages+1;
                if page_id>max_page_id; max_page_id=page_id;end
                
            else
                n1=n1+1;
            end
            
        end
        
        fprintf('line=%d  n0=%d  n1=%d  time=%f   sk=%d\n',line,n0,n1,toc,sk);
        drawnow;
        
        
        
        %disp(q)
    end
    
    if feof(f_in);break;end
end

fprintf('Number of pages:%d  \nMax page id:%d\n',num_pages,max_page_id);
save params num_pages max_page_id
fclose(f_in);