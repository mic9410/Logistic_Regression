/* ----------------------------------------
Kod wyeksportowany z SAS Enterprise Guide
DATA: niedziela, 26 maja 2019     GODZINA: 23:38:07
PROJEKT: Regresja_Logistyczna_2
ŒCIE¯KA PROJEKTU: D:\Michal\Dokumenty\STUDIA - SGH\II\Regresja logistyczna\Projekt\Regresja_Logistyczna_2.egp
---------------------------------------- */

/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=ACTIVEX;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HtmlBlue
    STYLESHEET=(URL="file:///D:/Program%20Files/SASHome/SASEnterpriseGuide/7.1/Styles/HtmlBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   POCZ¥TEK WÊZ£A: Filtruj i sortuj   */
LIBNAME TMP00001 "D:\Michal\Dokumenty\STUDIA - SGH\II\Regresja logistyczna\Projekt\ESS8DE.sas";



GOPTIONS ACCESSIBLE;
%_eg_conditional_dropds(WORK.FILTER_FOR_ESS8DE_SAS7BDAT_0000);

PROC SQL;
   CREATE TABLE WORK.FILTER_FOR_ESS8DE_SAS7BDAT_0000 AS 
   SELECT t1.dvrcdeva, 
          t1.agea, 
          t1.anctry1, 
          t1.hhmmb, 
          t1.rlgatnd, 
          t1.sclmeet, 
          t1.rlgdgr, 
          t1.nwspol, 
          t1.eduyrs, 
          t1.hlthhmp, 
          t1.stflife, 
          t1.edctn, 
          t1.jbspv, 
          t1.uemp3m, 
          t1.chldhhe, 
          t1.emplrel, 
          t1.bennent, 
          t1.icwhct, 
          t1.imptrad, 
          t1.pplfair, 
          t1.imprich, 
          t1.impfree, 
          t1.hincfel, 
          t1.region, 
          t1.lnghom1
      FROM TMP00001.ess8de t1
      WHERE t1.dvrcdeva NOT = 7;
QUIT;

GOPTIONS NOACCESSIBLE;


%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   POCZ¥TEK WÊZ£A: Kategoryzacja   */
%LET SYSLAST=WORK.FILTER_FOR_ESS8DE_SAS7BDAT_0000;
%LET _CLIENTTASKLABEL='Kategoryzacja';
%LET _CLIENTPROCESSFLOWNAME='Przebieg procesu';
%LET _CLIENTPROJECTPATH='D:\Michal\Dokumenty\STUDIA - SGH\II\Regresja logistyczna\Projekt\Regresja_Logistyczna_2.egp';
%LET _CLIENTPROJECTPATHHOST='DESKTOP-2DBNNOD';
%LET _CLIENTPROJECTNAME='Regresja_Logistyczna_2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
PROC SQL;
	CREATE TABLE WORK.SORTED_AND_CATEGORIZED AS
		SELECT t1.dvrcdeva, 
          t1.agea, 
          t1.anctry1, 
          t1.hhmmb,
		  t1.Imptrad,
		  t1.Nwspol, 
          t1.rlgatnd, 
          t1.sclmeet, 
          t1.rlgdgr, 
          t1.eduyrs, 
          t1.hlthhmp, 
          t1.stflife, 
          t1.edctn, 
          t1.jbspv, 
          t1.uemp3m, 
          t1.chldhhe, 
          t1.emplrel, 
          t1.bennent, 
          t1.icwhct,
          t1.pplfair, 
          t1.imprich, 
          t1.impfree, 
          t1.hincfel, 
          t1.region, 
          t1.lnghom1
	FROM WORK.FILTER_FOR_ESS8DE_SAS7BDAT_0000 as T1	
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized1 AS
select *, case when 0<= agea <= 45 then "young"
			   when 46<= agea <= 66 then "middle"
			   else "old" end as ageacat	   
	from WORK.SORTED_AND_CATEGORIZED;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized2 AS
select *, case when lnghom1 = 'GER' then "GER"
			   else "OTH" end as lnghom1cat	   
	from WORK.SORTTempTableCategorized1;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized3 AS
select *, case when region = 'DE4' or 
					region = 'DE3' or
					region = 'DE8' or 
					region = 'DE3' or 
					region = 'DED' or 
					region = 'DEE' or 
					region = 'DEG' then "NRD"
			   else "RFN" end as regioncat	   
	from WORK.SORTTempTableCategorized2;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized4 AS
select *, case when anctry1 = 11070 or
					anctry1 = 11077 or 
					anctry1 = 11078 or 
					anctry1 = 11079 then "GER"
			   else "OTH" end as anctry1cat	   
	from WORK.SORTTempTableCategorized3;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized5 AS
select *, CASE when 1 <= hhmmb <= 3 then 'low'
			   else 'high' end as hhmmbcat
	from WORK.SORTTempTableCategorized4
	where hhmmb le 6 ;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized6 AS
select * 
from WORK.SORTTempTableCategorized5
where Rlgatnd lt 77 ;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized7 AS
select *, case when 0 < eduyrs <= 10 then "basic"
			   when 10 < eduyrs <= 18 then "medium"
			   else "higher" end as eduyrscat	   	   
	from WORK.SORTTempTableCategorized6 
    where eduyrs ne 99 and eduyrs ne 88;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized8 AS
select * 	   	   
	from WORK.SORTTempTableCategorized7 
	where Hlthhmp NE 7;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized9 AS
select *, case when 0 < stflife <= 6 then "no"
			   else "yes" end as stflifecat 	   	   
	from WORK.SORTTempTableCategorized8 
	where stflife NE 77	 and stflife NE 88;
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized10 AS
select *, case when Jbspv = 1 then 1
			   else 2 end as Jbspvcat 	   	   
	from WORK.SORTTempTableCategorized9
	where Jbspv NE 7 and Jbspv NE 8 
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized11 AS
select * from WORK.SORTTempTableCategorized10 
where Uemp3m NE 7 and Uemp3m NE 8
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized12 AS
select * from WORK.SORTTempTableCategorized11 
where chldhhe NE 8
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized13 AS
select *, case when 0 < Bennent <= 2 then "Extreme"
		       when Bennent = 5 then "Extreme"
			   else "Middle" end as Bennentcat 
from WORK.SORTTempTableCategorized12 
where Bennent NE 8 and Bennent NE 7 
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized14 AS
select *, case when Emplrel = 6 then "Not_applicable"
	when Emplrel = 1 then "Position"
	else "Business" end as Emplrelcat 
from WORK.SORTTempTableCategorized13 
where Emplrel NE 8 and Emplrel NE 7 
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized15 AS
select *,case when Icwhct = 2 then 'no answer'
		else 'answer' end as Icwhctcat
from WORK.SORTTempTableCategorized14 
;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized16 AS
select *,case when 1 <= Sclmeet <= 2 then 'low'
		when 3 <= Sclmeet <= 5 then "medium"
else 'high' end as Sclmeetcat
from WORK.SORTTempTableCategorized15
where Sclmeet ne 77;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized17 AS
select *,case when Rlgdgr = 0 then 'no'
		when 1 <= Rlgdgr <= 5 then "medium"
else 'high' end as Rlgdgrcat
from WORK.SORTTempTableCategorized16
where Rlgdgr ne 77 and Rlgdgr ne 88; 
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized18 AS
select *,case when 0 <= Pplfair <= 2 then 'cagey'
else 'trustful' end as Pplfaircat
from WORK.SORTTempTableCategorized17
where Pplfair ne 88; 
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized19 AS
select *,case when 0 <= Imprich <= 3 then 'yes'
else 'no' end as Imprichcat
from WORK.SORTTempTableCategorized18
where Imprich ne 7 and Imprich ne 8; 
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized20 AS
select *,case when Impfree = 1 then 'high'
when 2 <= Impfree <= 4 then 'medium'
else 'low' end as Impfreecat
from WORK.SORTTempTableCategorized19
where Impfree ne 7 and Impfree ne 8 and Impfree ne 6;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized21 AS
select *,case when 0 <= Nwspol <= 30 then 'rarely'
when 31 <= Nwspol <= 60 then 'medium'
else 'often' end as Nwspolcat
from WORK.SORTTempTableCategorized20;
proc sql;
CREATE VIEW WORK.SORTTempTableCategorized22 AS
select * from WORK.SORTTempTableCategorized21 
where Imptrad LT 7;
proc sql;
CREATE TABLE WORK.FINALSortedAndCategorizedTable AS
select *, case when 1 <= Hincfel <= 2 then 'yes'
else 'no' end as  Hincfelcat 
from WORK.SORTTempTableCategorized22
where Hincfel ne 8 and Hincfel ne 7; 

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   POCZ¥TEK WÊZ£A: enviroment_filtered   */

GOPTIONS ACCESSIBLE;
/* -------------------------------------------------------------------
   Kod wygenerowany przez zadanie SAS-a

   Wygenerowany dnia: niedziela, 26 maja 2019 o godz. 23:37:41
   Przez zadanie: enviroment_filtered

   Dane wejœciowe: Local:WORK.FINALSORTEDANDCATEGORIZEDTABLE
   Serwer:  Local
   ------------------------------------------------------------------- */
ODS GRAPHICS ON;

%_eg_conditional_dropds(WORK.SORTTempTableSorted);
/* -------------------------------------------------------------------
   Sortowanie zbioru Local:WORK.FINALSORTEDANDCATEGORIZEDTABLE
   ------------------------------------------------------------------- */

PROC SQL;
	CREATE VIEW WORK.SORTTempTableSorted AS
		SELECT T.dvrcdeva, T.imptrad, T.rlgatnd, T.hlthhmp, T.chldhhe, T.lnghom1cat, T.regioncat, T.anctry1cat, T.eduyrscat, T.Emplrelcat, T.Rlgdgrcat
	FROM WORK.FINALSORTEDANDCATEGORIZEDTABLE as T
;
QUIT;
TITLE;
TITLE1 "Rezultaty regresji logistycznej";
FOOTNOTE;
FOOTNOTE1 "Wygenerowane przez System SAS (&_SASSERVERNAME, &SYSSCPL) dnia %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) o godz. %TRIM(%SYSFUNC(TIME(), NLTIMAP20.))";
PROC LOGISTIC DATA=WORK.SORTTempTableSorted
		PLOTS(ONLY)=ALL
	;
	CLASS imptrad 	(PARAM=EFFECT) rlgatnd 	(PARAM=EFFECT) hlthhmp 	(PARAM=EFFECT) chldhhe 	(PARAM=EFFECT) lnghom1cat 	(PARAM=EFFECT) regioncat 	(PARAM=EFFECT) anctry1cat 	(PARAM=EFFECT) eduyrscat 	(PARAM=EFFECT) Emplrelcat 	(PARAM=EFFECT)
	  Rlgdgrcat 	(PARAM=REF);
	MODEL dvrcdeva (Event = '1')=imptrad rlgatnd hlthhmp chldhhe lnghom1cat regioncat anctry1cat eduyrscat Emplrelcat Rlgdgrcat		/
		SELECTION=STEPWISE
		SLE=0.05
		SLS=0.05
		INCLUDE=0
		INFLUENCE
		LACKFIT
		AGGREGATE SCALE=NONE
		RSQUARE
		CTABLE
		LINK=LOGIT
		CLPARM=WALD
		CLODDS=WALD
		ALPHA=0.05
	;
RUN;
QUIT;

/* -------------------------------------------------------------------
   Koniec kodu zadania
   ------------------------------------------------------------------- */
RUN; QUIT;
%_eg_conditional_dropds(WORK.SORTTempTableSorted);
TITLE; FOOTNOTE;
ODS GRAPHICS OFF;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   POCZ¥TEK WÊZ£A: opinions_filtered   */

GOPTIONS ACCESSIBLE;
/* -------------------------------------------------------------------
   Kod wygenerowany przez zadanie SAS-a

   Wygenerowany dnia: niedziela, 26 maja 2019 o godz. 23:37:41
   Przez zadanie: opinions_filtered

   Dane wejœciowe: Local:WORK.FINALSORTEDANDCATEGORIZEDTABLE
   Serwer:  Local
   ------------------------------------------------------------------- */
ODS GRAPHICS ON;

%_eg_conditional_dropds(WORK.SORTTempTableSorted);
/* -------------------------------------------------------------------
   Sortowanie zbioru Local:WORK.FINALSORTEDANDCATEGORIZEDTABLE
   ------------------------------------------------------------------- */

PROC SQL;
	CREATE VIEW WORK.SORTTempTableSorted AS
		SELECT T.dvrcdeva, T.rlgatnd, T.chldhhe, T.hhmmbcat, T.eduyrscat, T.stflifecat, T.Jbspvcat, T.Bennentcat, T.Emplrelcat, T.Icwhctcat, T.Sclmeetcat, T.Rlgdgrcat, T.Pplfaircat, T.Imprichcat, T.Impfreecat, T.Nwspolcat
	FROM WORK.FINALSORTEDANDCATEGORIZEDTABLE as T
;
QUIT;
TITLE;
TITLE1 "opinions_filtered";
FOOTNOTE;
FOOTNOTE1 "Wygenerowane przez System SAS (&_SASSERVERNAME, &SYSSCPL) dnia %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) o godz. %TRIM(%SYSFUNC(TIME(), NLTIMAP20.))";
PROC LOGISTIC DATA=WORK.SORTTempTableSorted
		PLOTS(ONLY)=ALL
	;
	CLASS rlgatnd 	(PARAM=REF) chldhhe 	(PARAM=REF) hhmmbcat 	(PARAM=REF) eduyrscat 	(PARAM=REF) stflifecat 	(PARAM=REF) Jbspvcat 	(PARAM=REF) Bennentcat 	(PARAM=REF) Emplrelcat 	(PARAM=REF) Icwhctcat 	(PARAM=REF) Sclmeetcat 	(PARAM=REF)
	  Rlgdgrcat 	(PARAM=REF) Pplfaircat 	(PARAM=REF) Imprichcat 	(PARAM=REF) Impfreecat 	(PARAM=REF) Nwspolcat 	(PARAM=REF);
	MODEL dvrcdeva (Event = '1')=rlgatnd chldhhe hhmmbcat eduyrscat stflifecat Jbspvcat Bennentcat Emplrelcat Icwhctcat Sclmeetcat Rlgdgrcat Pplfaircat Imprichcat Impfreecat Nwspolcat		/
		SELECTION=FORWARD
		SLE=0.05
		INCLUDE=0
		INFLUENCE
		LACKFIT
		AGGREGATE SCALE=NONE
		RSQUARE
		CTABLE
		LINK=LOGIT
		CLPARM=WALD
		CLODDS=WALD
		ALPHA=0.05
	;
RUN;
QUIT;

/* -------------------------------------------------------------------
   Koniec kodu zadania
   ------------------------------------------------------------------- */
RUN; QUIT;
%_eg_conditional_dropds(WORK.SORTTempTableSorted);
TITLE; FOOTNOTE;
ODS GRAPHICS OFF;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
