/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 3: 	
						- Covariate data
						Last Updated: 08/09/2021

						* With references to A. Gaskins 2015
************************************************************************************
***********************************************************************************/


libname dat  "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Final"; 
libname results "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08"; 


/***********************************************************************************
************************************************************************************
					1. 	Import data: Covariates
************************************************************************************
***********************************************************************************/

*breast density data for visit at which girls first reached tanner 4 (or tanner 5 if skipped tanner 4); 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Lara_08082018.dta"
			out= work.t45visit replace ;
run;

*list of prior visits to clinic (merge with tanita and anthro); 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Visitas previas Lara Yoon_13082018.dta"
			out= work.priorvisit replace;
run;
*tanita data from prior visits; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Tanita.dta"
			out= work.pv_tanita replace ;
run;
*anthropometric data from prior visits; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Antropometría.dta"
			out= work.pv_antro replace ;
run;

*girls birthdays; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Datos personales_27082018.dta"
			out = work.birthday replace ; 
run; 
*mothers age at menarche; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\EDAD MENARQUIA DERCAM.xlsx"
		out= work.mothers 
		dbms = xlsx replace;
		sheet = "Hoja1"; 
		getnames = yes; 
run;
*mothers birthday; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\BirthDateMothers_28082018.dta"
			out = work.mothersbday replace ; 
run; 
*mothers education; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Education_mom_27082018.dta"
			out = work.motheredu replace ; 
run; 
* mothers height and weight + tv watching; ; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\DERCAM_27082018.xlsx"
		out= work.motherssizeandtv
		dbms = xlsx replace;
		sheet = "DERCAM_2007"; 
		getnames = yes; 
run;
*mothers dxa; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\ReBase_DERCAM_basedemamografia_Data.xls"
		out= work.mothersdxa
		dbms = xls replace;
		getnames = yes; 
run;

/***********************************************************************************
************************************************************************************
					2.	Merging: Covariates 
************************************************************************************
***********************************************************************************/

* Get date of T4/5 visit; 
proc contents data = t45visit; run; 
data t45date; 
	set t45visit; 
	keep cod_child date; 
	rename cod_child=child_id; 
run; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from t45date;
quit; *467; 

* Get birthday; 
data birth2; 
	set birthday; 
	rename cod_child = child_id; 
	keep cod_child date_birth; 
run; 

* Merge birthday with t45 visit; 
proc sort data = t45date; by child_id; 
proc sort data = birth2; by child_id; 
run; 
data t45date2; 
	merge t45date(in=a) birth2; 
	by child_id; 
	if a; 
run; 

* Get tanner staging and anthropometric vars; 
proc sort data = priorvisit; by cod_child redcap_event_name;  
proc sort data = pv_tanita; by cod_child redcap_event_name; 
proc sort data = pv_antro; by cod_child redcap_event_name; 
run; 
data priorvisit2; 
	merge pv_tanita pv_antro priorvisit(in=a); 
	by cod_child redcap_event_name; 
	if a; 
	rename cod_child=child_id;
run; 

* Select Age, BMI-Z, Fat%, waist circumference for visits; 
data priorvisit3; 
	set priorvisit2; 
	keep child_id redcap_event_name date tanita_age tanita_complete antro_baz fat_p antro_promcint; 
run; 

* Merge prior visits with t45 date;
proc sort data = t45date2; by child_id date; 
proc sort data = priorvisit3; by child_id date; 
run;  
data covar1; 
	merge t45date2(in=a) priorvisit3; 
	by child_id date; 
	if a; 
run; 

* Maternal menarche; 
data mothers2; 
	set mothers; 
	rename cod_child = child_id n20=age_men_mo; 
run; 
proc sort data = mothers; by child_id; 
data mothers3; 
	set mothers2; 
	by child_id; 
	if first.child_id; 
run; 

* Maternal education; 
proc sort data = motheredu; by cod_child descending educacion_madre ; run;
data motheredu2; 
	set motheredu; 
	rename cod_child = child_id date=date_edu; 
run; 
data motheredu3; 
	set motheredu2; 
	by child_id; 
	if first.child_id; 
run; 

* Maternal DXA; 
data mothersdxa1; 
	set mothersdxa; 
	rename cod_child = child_id date_mother = date_motherdxa; 
run; 
proc sort data = mothersdxa1; by child_id; 
data mothersdxa2; 
	set mothersdxa1; 
	by child_id; 
	if first.child_id; 
run; 

* TV watching; 
data motherssizeandtv1; 
	set motherssizeandtv; 
	rename cod_child = child_id date_encuesta=date_tv; 
run; 

* Merging together; 
proc sort data = mothers3; by child_id; 
proc sort data = motheredu3; by child_id; 
proc sort data = motherssizeandtv1; by child_id; 
proc sort data = mothersdxa2; by child_id; 
run; 
data mothersall; 
	merge mothers3 motheredu3 (in=a) motherssizeandtv1 mothersdxa2; 
	by child_id;
	if a; 
run; 

data mothersall2; 
	set mothersall; 
	keep child_id educacion_madre age_men_mo n69__peso_ n68__talla_ tiempo_tvd__horas_
	bv_cc_left dt_cc_left bd_cc_left 
	bv_mlo_left dt_mlo_left bd_mlo_left 
	bv_cc_right dt_cc_right bd_cc_right 
	bv_mlo_right dt_mlo_right bd_mlo_right ; 
run; 

* Merge with prior visits for the child ; 
proc sort data = covar1; by child_id; 
proc sort data = mothersall2; by child_id; 
run; 
data covars2; 
	merge covar1(in=a) mothersall2; 
	by child_id; 
	if a; 
run; 

/***********************************************************************************
************************************************************************************
					3.	Cleaning: Covar data  
************************************************************************************
***********************************************************************************/

proc contents data = covars2 order=varnum; run; 

* renaming variables, creating grouped vars; 
data covars3; 
	set covars2; 

	/* age at visit */ 
	age_visit = (date-date_birth)/365.25; 

	/* BMI (Z-score) */ 
	if  antro_baz>1 and antro_baz<=2  then overweight=1; else overweight=0;
	if  antro_baz>2  then obese=1; else obese=0;

	/* Mothers BMI */ 
	BMImo = (n69__peso_)/((n68__talla_/100)*(n68__talla_/100)); 
	if BMImo>=25 and BMImo<30 then overweight_m=1; else overweight_m=0;
	if BMImo>=30 then obese_m=1; else obese_m=0;

	/* Mothers education */ 
	if educacion_madre>=0 and educacion_madre<=8 then educ_M=1;
	else if educacion_madre>8 and educacion_madre<16 then educ_M=2;
	else if educacion_madre in (16,17) then educ_M=3;
	else if educacion_madre in (29,99,.) then educ_M=99;

	/* TV hours */ 
	if tiempo_tvd__horas_ >= 0 and tiempo_tvd__horas_<=2 then dailyTV = 1; 
	else if tiempo_tvd__horas_>2 and tiempo_tvd__horas_<=4 then dailyTV = 2; 
	else if tiempo_tvd__horas_>4 then dailyTV = 3;

	/* age at menarche */ 
	* in breast density dataset; 
run; 


/***********************************************************************************
************************************************************************************
					3.	Save: final covariate data 
************************************************************************************
***********************************************************************************/

proc contents data = covars3 order=varnum; run; 

* keep relevant vars; 
data covarfinal; 
	set covars3;
	keep child_id date date_birth tanita_age fat_p antro_baz antro_promcint age_men_mo educacion_madre 
			age_visit overweight obese BMImo overweight_m obese_m educ_M dailyTV; 
run;  

* save; 
data dat.COVARperGIRL; 
	set covarfinal; 
	run; 
