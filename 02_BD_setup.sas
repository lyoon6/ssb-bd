/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 2: 	
						- Breast Density data
						Last Updated: 08/09/2021

						* With references to A. Gaskins 2015
************************************************************************************
***********************************************************************************/

libname dat  "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Final"; 
libname results "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08"; 


/***********************************************************************************
************************************************************************************
					1. 	Import data: Breast outcomes
************************************************************************************
***********************************************************************************/

* Breast density data for visit at which girls first reached tanner 4 (or tanner 5 if skipped tanner 4); 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Lara_08082018.dta"
			out= work.t45visit replace ;
run;

proc contents data = t45visit; run; 

* Birthdays, to create age variable; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Datos personales_27082018.dta"
			out = work.birthday replace ; 
run; 


/***********************************************************************************
************************************************************************************
					2.	Cleaning: breast outcomes 
************************************************************************************
***********************************************************************************/

* Rename; 
data bd; 
	set t45visit; 
	rename cod_child = child_id date=date_t45; 
run; 

* Get distribution of Tanner stage; 
proc freq data = bd; 
	table tanner; 
run; 

* Get number of girls with breast data; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from bd;
quit;

* Review years of data; 
proc freq data = bd; 
	table date_t45; 
run; 
proc sql; 
	create table t45daterange as
		select min(date_t45) as min_date format= MMDDYY10.,
			   max(date_t45) as max_date format= MMDDYY10.
		from bd; 
quit; 
proc print data= t45daterange; 
title 'Date range';
run; *08/20/2012 - 06/04/2016 ; 

* Get year of Tanner visit; 
data bd; 
	set bd; 
	t45year = year(date_t45); 
run; 

* Getting birthdays; 
data birthday2; 
	set birthday; 
	rename cod_child = child_id;
run;  
proc sort data = bd; by child_id; 
proc sort data = birthday2; by child_id; 
run; 
data bd2; 
	merge bd (in=a) birthday2; 
	by child_id; 
	if a; 
run; 

proc contents data = bd2; run; 

* Keep only relevant vars; 
data bd2a; 
	set bd2; 
	keep child_id redcap_event_name date_t45 
		dxa_m_lle_bd 	dxa_m_lle_bv 	dxa_m_lle_db 	dxa_m_lle_ba 
		dxa_m_lrle_bd	dxa_m_lrle_bv 	dxa_m_lrle_db 	dxa_m_lrle_ba 
		dxa_m_rle_bd 	dxa_m_rle_bv 	dxa_m_rle_db 	dxa_m_rle_ba 
		tanner tcuerpo_aprobado
		date_menarq_final t45year sex date_birth ; 
run; 

* Get missing information; 
data bd3;
	set bd2a;
	* breast density (%FGV); 
	if dxa_m_lle_bd=. and dxa_m_lrle_bd=. and dxa_m_rle_bd=. then missingBD=1; else missingBD=0; 
	if dxa_m_lle_bd=. and dxa_m_lrle_bd=. and dxa_m_rle_bd=. then BD=.; else BD=1;
	* breast volume (cm3); 
	if dxa_m_lle_bv=. and dxa_m_lrle_bv=. and dxa_m_rle_bv=. then missingBV=1; else missingBV=0; 
	if dxa_m_lle_bv=. and dxa_m_lrle_bv=. and dxa_m_rle_bv=. then BV=.; else BV=1;
	* density volume (absolute FGV, cm3); 
	if dxa_m_lle_db=. and dxa_m_lrle_db=. and dxa_m_rle_db=. then missingDB=1; else missingDB=0; * ; 
	if dxa_m_lle_db=. and dxa_m_lrle_db=. and dxa_m_rle_db=. then DB=.; else DB=1;
	* determine months of follow-up for menarche ; 
	if date_menarq_final ne . then followup=(date_menarq_final-date_birth)/365.25; else followup=(date_t45-date_birth)/365.25;
	if date_menarq_final ne . then followup_mo=(date_menarq_final-date_birth)/30.5; else followup_mo=(date_t45-date_birth)/30.5;
	* get menarche; 
	if date_menarq_final > date_t45 then menarche = 0; else if 0 < date_menarq_final <= date_t45 then menarche = 1; else menarche = .; 
run; 

proc freq data = bd3; 
	table missingBD BD missingBV BV missingDB DB sex tcuerpo_aprobado*menarche ; 
	run; 

* No one missing breast outcomes; 


* Creating final breast variables; 
data bd4; 
	set bd3; 

	/* creating mean absolute breast density volume (aFGV) */
	if dxa_m_lle_db=. and dxa_m_lrle_db=. and dxa_m_rle_db=. then delete;
	dxa_m_lle_db=ABS(dxa_m_lle_db); dxa_m_rle_db=ABS(dxa_m_rle_db); dxa_m_lrle_db=ABS(dxa_m_lrle_db);
	avg_aFGV=mean(dxa_m_lle_db,dxa_m_rle_db); /* take the average of the R and L */ 
	if avg_aFGV=. then avg_aFGV=mean(dxa_m_lrle_db,dxa_m_rle_db);  /* if one of the left is missing, use 2nd left */ 

	/* creating mean % FGV (%FGV) */ 
	dxa_m_lle_bd=ABS(dxa_m_lle_bd); dxa_m_rle_bd=ABS(dxa_m_rle_bd); dxa_m_lrle_bd=ABS(dxa_m_lrle_bd);
	avg_perFGV=mean(dxa_m_lle_bd,dxa_m_rle_bd);
	if avg_perFGV=. then avg_perFGV=mean(dxa_m_lrle_bd,dxa_m_rle_bd);

	/* creating mean Total breast volume) */ 
	dxa_m_lle_bv=ABS(dxa_m_lle_bv); dxa_m_rle_bv=ABS(dxa_m_rle_bv); dxa_m_lrle_bv=ABS(dxa_m_lrle_bv);
	avg_TotVol=mean(dxa_m_lle_bv,dxa_m_rle_bv);
	if avg_TotVol=. then avg_TotVol=mean(dxa_m_lrle_bv,dxa_m_rle_bv);

	/* creating mean Total breast area) */ 
	dxa_m_lle_ba=ABS(dxa_m_lle_ba); dxa_m_rle_ba=ABS(dxa_m_rle_ba); dxa_m_lrle_ba=ABS(dxa_m_lrle_ba);
	avg_TotArea=mean(dxa_m_lle_ba,dxa_m_rle_ba);
	if avg_TotArea=. then avg_TotArea=mean(dxa_m_lrle_ba,dxa_m_rle_ba);

run;


proc means data = bd4 n nmiss min mean median max; 
var avg_aFGV avg_perFGV avg_TotVol avg_TotArea; 
run; 

/***********************************************************************************
************************************************************************************
					3.	Save: final breast outcomes 
************************************************************************************
***********************************************************************************/
proc contents data = bd4; run; 

* keeping relevant vars; 
data bdfinal; 
	set bd4; 
	keep child_id date_birth date_menarq_final date_t45 t45year redcap_event_name tcuerpo_aprobado
	missingBD missingBV missingDB menarche BD BV DB avg_aFGV avg_perFGV avg_TotVol; 
	run; 


* save; 
data dat.avgBREASTperGIRL; 
	set bdfinal; 
	run; 
