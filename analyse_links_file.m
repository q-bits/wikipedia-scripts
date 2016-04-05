function analyse_links_file

% Creates the file "links-simple-sorted.txt", using the file
% "links-simple-matlab.txt" created by convert_links_file.m
%
% Henry Haselgrove, January 2009.

load params num_pages 
load link_param num_links

NL=num_links;%130160392;
NP=num_pages;
fclose('all');

fid=fopen('links-simple-matlab.txt','r');

%nouts = zeros(5716808,1);
%outs=cell(5716808,1);
outs=-ones(NL,1,'int32');
starts=-ones(NP,1,'int32');
nouts=-ones(NL,1,'int32');

nlinks=0;
tic;
line=0;

%for i=1:3740000;
%    x=fgetl(fid); line=line+1;
%if mod(line,10000)==0; disp(line);end
%end

count=0;
while(1)
    line=line+1;
   % if line==100000;break;end
    x=fgetl(fid);
    %disp(x);
    perc=find(x=='%');
    eq=find(x=='=');
    
    np=length(perc); ne=length(eq);
    if np~=ne
        disp(x)
        error('Okay');
    end
    
    if np==1
        for jjj=1:np
            x(perc(jjj):eq(jjj))=[];
            %disp(x);
        end
    end
    
    col=find(x==':');
    if length(col)==1
        from=str2num(x(1:col-1));
        to=str2num(x(col+1:end));
        nouts(from)=length(to);
        %outs{from}=to;
        outs(count+1:count+length(to))=to;
        starts(from)=count+1;
        count=count+length(to);
        nlinks=nlinks+length(to);
        if ~all(from==sort(from));disp(x);end
    end
    
    
    if mod(line,10000)==0;
        fprintf('\n line=%d  nlinks=%d  time=%f',line,nlinks,toc);
    end
    
    if feof(fid);break;end;
    
    
end

fo=fopen('links-simple-sorted.txt','w');
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

