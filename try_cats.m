function try_cats

% Trying to underestand wikipedia category information
%
% Create sm_people.mat, containing an (approximate) list of all people in
% wikipedia

%./20160204/enwiki-20160305-category.sql

% (246606449,'Music_festivals_in_Fiji',1,1,0),(246606450,'1948_in_British_Malaya',1,1,0),(246606451,'Speed_skating_by_continent',4,4,0),(246606452,'1915_in_British_Malaya',1,1,0),(246606453,'1927_in_British_Malaya',1,1,0),(246606454,'Wajj_Club_players',2,0,0),(246606455,'Religious_festivals_in_India\'',1,0,0),(246606456,'Memorials_to_women',0,0,0),(246606457,'Bangladesh_Super_League',2,0,0),(246606458,'Monuments_and_memorials_to_women',33,0,0),(246606459,'Ice_rinks_by_country',3,3,0),(246606460,'Al-Qaisomah_Club_players',1,0,0),(246606461,'Albums_recorded_at_Berry_Street_Studio',1,0,0),(246606462,'2009_in_Champ_Car',0,0,0),(246606463,'Al-Batin_Club_players',4,0,0),(246606464,'United_States_river_stubs',65,0,0),(246606465,'Ice_sports_by_country',1,1,0),(246606466,'Ice_sports',2,2,0)

% CREATE TABLE `category` (
%  `cat_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
%  `cat_title` varbinary(255) NOT NULL DEFAULT '',
%  `cat_pages` int(11) NOT NULL DEFAULT '0',
%  `cat_subcats` int(11) NOT NULL DEFAULT '0',
%  `cat_files` int(11) NOT NULL DEFAULT '0',
%  PRIMARY KEY (`cat_id`),
%  UNIQUE KEY `cat_title` (`cat_title`),
%  KEY `cat_pages` (`cat_pages`)
%) ENGINE=InnoDB AUTO_INCREMENT=246606571 DEFAULT CHARSET=binary;


%./20160204/enwiki-20160305-categorylinks.sql


% (737,'All_articles_containing_potentially_dated_statements','AFGHANISTAN','2014-10-26 01:50:05','','uppercase','page'),(737,'All_articles_with_dead_external_links','AFGHANISTAN','2015-10-31 11:43:51','','uppercase','page'),(737,'All_articles_with_failed_verification','AFGHANISTAN','2015-01-07 00:01:56','','uppercase','page'),(737,'All_articles_with_unsourced_statements','AFGHANISTAN','2015-06-20 10:41:11','','uppercase','page'),(737,'Articles_containing_Arabic-language_text','AFGHANISTAN','2016-02-07 18:13:46','','uppercase','page'),(737,'Articles_containing_Pashto-language_text','AFGHANISTAN','2015-10-27 11:07:18','','uppercase','page'),(737,'Articles_containing_Persian-language_text','AFGHANISTAN','2013-06-19 05:43:13','','uppercase','page'),(737,'Articles_containing_potentially_dated_statements_from_2011','AFGHANISTAN','2014-10-26 01:50:05','','uppercase','page'),(737,'Articles_containing_potentially_dated_statements_from_2012','AFGHANISTAN','2015-11-27 04:00:41','','uppercase','page'),(737,'Articles_containing_potentially_dated_statements_from_2013','AFGHANISTAN','2014-10-26 01:50:05','','uppercase','page'),(737,'Articles_containing_potentially_dated_statements_from_2014','AFGHANISTAN','2015-06-18 02:25:11','','uppercase','page'),(737,'Articles_containing_potentially_dated_statements_from_2015','AFGHANISTAN','2015-09-05 08:11:02','','uppercase','page'),(737,'Articles_including_recorded_pronunciations','AFGHANISTAN','2013-09-03 14:29:30','','uppercase','page'),(737,'Articles_with_DMOZ_links','AFGHANISTAN','2014-04-12 16:53:46','','uppercase','page')

global titles_sorted   pid_sm         sm_pid
if ~exist('titles_sorted','var') || length(titles_sorted)==0
    load sorted_out2;
end

fido=fopen('pout.txt','w');
fidoc=fopen('used_cats.txt','w');

% Later:
%fid=fopen('used_cats.txt','r','n','windows-1252'); fido=fopen('used_cats_utf8.txt','w','n','windows-1252'); while ~feof(fid); x=fgetl(fid); x=unicode2native(x,'windows-1252');x=native2unicode(x,'utf8'); fprintf(fido,'%s\n',x);end


f_in = fopen('./20160204/enwiki-20160305-categorylinks.sql','r','n','windows-1252');

newline = sprintf('\n');

line=0;
dummy_left=char(57344);
dummy_quote=char(57345);
dummy_right=char(57346);
dummy_backslash=char(57347);
dummy_empty=char(57348);

tic;
pt=0;
nlp=0;
last_person=-1;
sm_people=[];
v_people=[];
last_v=-1;
oo=-1;
used_cats={};
while(~feof(f_in))
    
    x=fgetl(f_in);
    %fprintf(f_out2,'%s\n',x);
    
    if length(x)<31 || ~strcmp(x(1:11),'INSERT INTO');
        %disp(x);
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
        x=strrep(x,'\n',newline);
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
            
            v = sscanf(y, '%d,');
            
            
            
            if v==5236
                disp(y);
            end
            q=find(y=='''',4);
            
            c = y(q(1)+1:q(2)-1);
            
            c(c==dummy_quote)='''';
            c(c==dummy_left)='(';
            c(c==dummy_right)=')';
            c(c==dummy_backslash)='\';
            c=strrep(c,dummy_empty,'');
            
            
            sm = pid_sm(v);
            if sm<0
                continue;
            end
            if sm>0
                t = titles_sorted{sm};
            else
                t = y(q(3)+1:q(4)-1);
            end
            
            if ~isempty(strfind(t,'List_of_')) || ~isempty(strfind(t,'_family')) || ~isempty(strfind(t,'_people')) ...
                    || ~isempty(strfind(t,'Individuals')) || ~isempty(strfind(t,'_Family')) || ~isempty(strfind(t,'Lists_of_')) ...
                    || ~isempty(strfind(t,'(band)'))
                continue;
            end
            
            if oo>-1 && oo~=v && oo~=last_person
                fprintf(fido,'%20s  v=%7d  sm=%9d : ',oot,oo,sm);
                for k=1:length(cats);fprintf(fido,'%s, ',cats{k});end;fprintf(fido,'\n');
                oo=-1;
                cats={};
            end
            
            if ( ~isempty(strfind(c,'_people')) || ~isempty(strfind(c,'People_')) ) && isempty(strfind(c,'Fictional'))
                if oo~=v
                    cats={};
                    oo=v;
                    
                end
                cats{end+1}=c;
                oot=t;
                
            end
            
            if last_person==v; continue;end
            
            
            
            %%if strcmp(c,'People')
            %if strcmp(c,'Living_people')
            %if ~isempty(strfind(c,'People_')) ...
            if isempty(strfind(c,'Fictional')) && (...
                    ~isempty(strfind(c,'Living_people')) || ~isempty(strfind(c,'-century_births')) ...
                    || ~isempty(strfind(c,'-century_deaths')) || ~isempty(strfind(c,'-millenium_BC_deaths')) ...
                    || ~isempty(strfind(c,'-millenium_BC_births')) || other(c) ...
                    || ( ~isempty(strfind(c,'-century_')) && ~isempty(strfind(c,'_people')) ) ...
                    || ~isempty(strfind(c,'-century_BC_people')) ...
                    || ~isempty(strfind(c,'People_from_')) ...
                    || ( ~isempty(strfind(c,'People_of_')) && ~isempty(strfind(c,'period')) )...
                    || ~isempty(strfind(c, 'People_of_the_')) ...
                    || ~isempty(strfind(c,'_people_stubs'))  ...
                    || strcmp(c,'Possibly_living_people')   ...
                    || strcmp(v,'Wikipedia_indefinitely_semi-protected_biographies_of_living_people')...
                    )
                %|| ~isempty(strfind(c, 'People_executed_')) ...
                
                %if other(c)
                if ~any(strcmp(used_cats,c))
                    used_cats{end+1}=c;
                    fprintf(fidoc,'%40s : %s\n',c,t);
                end
                
                
                if v~=last_person
                    T=toc;
                    if T-pt>1
                        
                        
                        
                        pt=T;
                        if any(t>127)
                            %oldc=c;
                            t=unicode2native(t,'windows1252');
                            t=native2unicode(t,'utf8');
                            %isp(c);
                            %disp('');
                            
                        end
                        
                        fprintf('%10d: %10d: %s : %s\n',v,nlp,c, t);
                    end
                    sm_people(end+1)=sm;
                    v_people(end+1)=v;
                    last_person=v;
                    oo=-1;cats={};
                    nlp = nlp +1;
                end
            end
        end
    end
    %t=toc;
    %if t-pt>1
    %    fprintf(' -- %d -- \n',v)
    %    pt=t;
    %end
end

save sm_people sm_people


function y=other(x)
y=false;
n=length(x);
%a=' deaths';
%b=' births';
%c='s deaths';
%d='s deaths';

if n<8; return;end
x7 = x(end-6:end);
x8 = x(end-7);
if strcmp(x7,'_deaths') || strcmp(x7,'_births')
    x=x(1:end-7);
    if x(end)=='s'
        x=x(1:end-1);
    end
    if all(x>='0' & x <='9')
        y=true;
    end
    
end


