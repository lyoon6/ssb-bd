/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 6: 
						- Sensitivity analysis file 

						* With references to A. Gaskins 2015
************************************************************************************
***********************************************************************************/

libname dat  "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Final"; 
libname results "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08"; 
OPTIONS nofmterr;


/***********************************************************************************
************************************************************************************
					1. 	Import cleaned data
************************************************************************************
***********************************************************************************/

data dietBDperGIRL3; 
	set dat.BDR24_final; 
	run; 


/***********************************************************************************
************************************************************************************
					2. 	Creating underreporting categories
************************************************************************************
***********************************************************************************/

* distrbution of relevant variables; 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\BMIZ_dist.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
proc univariate data = dietBDperGIRL; 
	var antro_baz; 
	histogram;
run; 

proc univariate data = dietBDperGIRL; 
	var AvgSSB; 
	histogram;
run; 
ods excel close; 

* new Avg SSB intake; 
data dietBDperGIRL_sens; 
	set dietBDperGIRL; 

	if antro_baz >= 1 then AvgSSBa_05 = AvgSSB/.95; else AvgSSBa_05 = AvgSSB; 
	if antro_baz >= 1 then AvgSSBa_10 = AvgSSB/.90; else AvgSSBa_10 = AvgSSB; 
	if antro_baz >= 1 then AvgSSBa_15 = AvgSSB/.85; else AvgSSBa_15 = AvgSSB; 
	if antro_baz >= 1 then AvgSSBa_20 = AvgSSB/.80; else AvgSSBa_20 = AvgSSB; 
	if antro_baz >= 2 then AvgSSBb_05 = AvgSSB/.95; else AvgSSBb_05 = AvgSSB; 
	if antro_baz >= 2 then AvgSSBb_10 = AvgSSB/.90; else AvgSSBb_10 = AvgSSB; 
	if antro_baz >= 2 then AvgSSBb_15 = AvgSSB/.85; else AvgSSBb_15 = AvgSSB; 
	if antro_baz >= 2 then AvgSSBb_20 = AvgSSB/.80; else AvgSSBb_20 = AvgSSB; 

	if antro_baz >= 1 then avgCALa_05 = avgCAL/.95; else avgCALa_05 = avgCAL; 
	if antro_baz >= 1 then avgCALa_10 = avgCAL/.90; else avgCALa_10 = avgCAL; 
	if antro_baz >= 1 then avgCALa_15 = avgCAL/.85; else avgCALa_15 = avgCAL; 
	if antro_baz >= 1 then avgCALa_20 = avgCAL/.80; else avgCALa_20 = avgCAL; 
	if antro_baz >= 2 then avgCALb_05 = avgCAL/.95; else avgCALb_05 = avgCAL; 
	if antro_baz >= 2 then avgCALb_10 = avgCAL/.90; else avgCALb_10 = avgCAL; 
	if antro_baz >= 2 then avgCALb_15 = avgCAL/.85; else avgCALb_15 = avgCAL; 
	if antro_baz >= 2 then avgCALb_20 = avgCAL/.80; else avgCALb_20 = avgCAL; 

	run; 




/***********************************************************************************
************************************************************************************
					3. 	Creating underreporting categories
************************************************************************************
***********************************************************************************/

/* Create quartiles of SSB */ 
proc rank data=dietBDperGIRL1 out=DietRank groups=4;                               
     var 
		AvgSSB	
		AvgSSBa_05 
		AvgSSBa_10 
		AvgSSBa_15 
		AvgSSBa_20 

		AvgSSBb_05 
		AvgSSBb_10 
		AvgSSBb_15 
		AvgSSBb_20;
		                                                        
     ranks 	
		AvgSSBQ	
		AvgSSBa_05Q 
		AvgSSBa_10Q 
		AvgSSBa_15Q 
		AvgSSBa_20Q

		AvgSSBb_05Q 
		AvgSSBb_10Q 
		AvgSSBb_15Q
		AvgSSBb_20Q;                                                      
  run;     


ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\Diet_stats.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;

proc means data = dietRank n nmiss min median max mean stddev stackodsoutput; 
	var AvgSSB	avgCAL
		AvgSSBa_05 avgCALa_05
		AvgSSBa_10 avgCALa_10
		AvgSSBa_15 avgCALa_15
		AvgSSBa_20 avgCALa_20

		AvgSSBb_05 avgCALb_05
		AvgSSBb_10 avgCALb_10
		AvgSSBb_15 avgCALb_15
		AvgSSBb_20 avgCALb_20; 
	run; 
 
proc freq data = dietRank; 
	table 		AvgSSBQ	
		AvgSSBa_05Q 
		AvgSSBa_10Q 
		AvgSSBa_15Q 
		AvgSSBa_20Q

		AvgSSBb_05Q 
		AvgSSBb_10Q 
		AvgSSBb_15Q
		AvgSSBb_20Q; 
	run; 

ods excel close; 


data dietBDperGIRL3; 
	set dietRank; 
	run; 


/***********************************************************************************
************************************************************************************
					4. 	rE-DOING ANALYSIS 
	[should update file/folder if re-running]
************************************************************************************
***********************************************************************************/

		/*************************
		**************************
		ANALYSIS 
		*************************
		*************************/

/* ANALYSIS - 5% UNDERREPORT */ 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\Reg_5percent_overweight.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBa_05Q (ref=first); 
model avg_aFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first); 
model avg_perFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first); 
model avg_TotVol= AvgSSBa_05Q antro_baz Age_visit avgCALa_05/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBa_05Q antro_baz Age_visit avgCALa_05 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 


/* ANALYSIS - 10% UNDERREPORT */ 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\Reg_10percent_overweight.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBa_10Q (ref=first); 
model avg_aFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first); 
model avg_perFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first); 
model avg_TotVol= AvgSSBa_10Q antro_baz Age_visit avgCALa_10/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBa_10Q antro_baz Age_visit avgCALa_10 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 


/* ANALYSIS - 20% UNDERREPORT */ 

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\Reg_20percent_overweight.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBa_20Q (ref=first); 
model avg_aFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first); 
model avg_perFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first); 
model avg_TotVol= AvgSSBa_20Q antro_baz Age_visit avgCALa_20/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBa_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBa_20Q antro_baz Age_visit avgCALa_20 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 


/* ANALYSIS - 5% UNDERREPORT AMONG OBESE */ 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\Reg_5percent_obese.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBb_05Q (ref=first); 
model avg_aFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first); 
model avg_perFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first); 
model avg_TotVol= AvgSSBb_05Q antro_baz Age_visit avgCalb_05/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_05Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBb_05Q antro_baz Age_visit avgCalb_05 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 


/* ANALYSIS - 10% UNDERREPORT AMONG OBESE */ 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\Reg_10percent_obese.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBb_10Q (ref=first); 
model avg_aFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first); 
model avg_perFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first); 
model avg_TotVol= AvgSSBb_10Q antro_baz Age_visit avgCalb_10/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_10Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBb_10Q antro_baz Age_visit avgCalb_10 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 


/* ANALYSIS - 20% UNDERREPORT AMONG OBESE */ 

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\Reg_20percent_obese.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBb_20Q (ref=first); 
model avg_aFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first); 
model avg_perFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;


/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first); 
model avg_TotVol= AvgSSBb_20Q antro_baz Age_visit avgCalb_20/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBb_20Q (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBb_20Q antro_baz Age_visit avgCalb_20 educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close;



		/*************************
		**************************
		SSB & BMI/Fat%/Waist 
		*************************
		*************************/

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan08_sens\ssb_anthro.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* BMI Z */ 
Title 'Linear Regression- BMI Z-score ~ SSB quartile: MODEL 1 (adjusted for total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model antro_baz= AvgSSBQ avgCal/dist=normal link=identity;
run;
Title 'Linear Regression- BMI Z-score ~ SSB quartile: MODEL 2 (adjusted for total calories, dairy, meat, age)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model antro_baz= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- BMI Z-score ~ SSB quartile: MODEL 3 (adjusted for total calories, dairy, meat, age , mother education, TV)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model antro_baz= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;

/* Fat percentage */ 
Title 'Linear Regression- Fat % ~ SSB quartile: MODEL 1 (adjusted for total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model fat_p= AvgSSBQ avgCal/dist=normal link=identity;
run;
Title 'Linear Regression- Fat %  ~ SSB quartile: MODEL 2 (adjusted for total calories, dairy, meat, age)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model fat_p= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Fat %  ~ SSB quartile: MODEL 3 (adjusted for total calories, dairy, meat, age , mother education, TV)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model fat_p= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;

/* Waist circumference */ 
Title 'Linear Regression- Waist circumference ~ SSB quartile: MODEL 1 (adjusted for total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model antro_promcint= AvgSSBQ avgCal/dist=normal link=identity;
run;
Title 'Linear Regression- Waist circumference  ~ SSB quartile: MODEL 2 (adjusted for total calories, dairy, meat, age)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model antro_promcint= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Waist circumference  ~ SSB quartile: MODEL 3 (adjusted for total calories, dairy, meat, age , mother education, TV)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model antro_promcint= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;

ods excel close; 
