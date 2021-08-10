/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 7: 
						- Sensitivity file #2 

						* With references to A. Gaskins 2015

Anita's comments: 
1) The distribution of the numbers of 24HR is very different across quantiles of SSB. 
	50% of girls that belong to SSB Q1 have only 1 24HR. 
	Could this be a reason for the no association of SSB to obesity or the null results? 
	It would be reasonable to carry out a sensitivity analysis without girls with only 1 24HR. 	
	This means you should do the quantiles again. It is only an idea. 
2) The models are not adjusted by menarche yes or no at the time of DXA. I think you should add this. 
3) Inline to point 1, we observe that obese girls report less SSB than normal girls. 
	We assume they are sub reporting. What happens if we perform the analysis 
	(only to know what may happen) if we exclude the obese girls? 
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
					2. 	Create 2 datasets by recalls
************************************************************************************
***********************************************************************************/

* subset girls by 24H recall----------------; 
proc freq data = dietBDperGIRL3; table num_recall_cat; run; 
proc freq data = dietBDperGIRL3; table AvgSSBQ*num_recall_cat; run; 
data dietBDperGIRLbyRECALLA; 
	set dietBDperGIRL3; 
	where num_recall_cat=1; * with only 1; 
	run; * 143 obs; 
data dietBDperGIRLbyRECALLB; 
	set dietBDperGIRL3; 
	where num_recall_cat~=1; * exclude only 1; 
	run; * 231; 

* re-do quartiles -------------------; 
proc rank data=dietBDperGIRLbyRECALLA out=DietRankA groups=4;                               
     var 
		/* diet */
		AvgDairy AvgSSB AvgMeat AvgCal 
		/* BD */ 
		avg_aFGV avg_perFGV avg_TotVol avg_TotArea;                                                          
     ranks 	AvgDairyQ AvgSSBQ AvgMeatQ AvgCalQ  avg_aFGVQ avg_perFGVQ avg_TotVolQ avg_TotAreaQ;                                                      
  run; 
proc means data=DietRankA n nmiss min median max mean stddev;
	class AvgSSBQ;
	var AvgSSB;
	run;
proc rank data=dietBDperGIRLbyRECALLB out=DietRankB groups=4;                               
     var 
		/* diet */
		AvgDairy AvgSSB AvgMeat AvgCal 
		/* BD */ 
		avg_aFGV avg_perFGV avg_TotVol avg_TotArea;                                                          
     ranks 	AvgDairyQ AvgSSBQ AvgMeatQ AvgCalQ  avg_aFGVQ avg_perFGVQ avg_TotVolQ avg_TotAreaQ;                                                      
  run; 
proc means data=DietRankB n nmiss min median max mean stddev;
	class AvgSSBQ;
	var AvgSSB;
	run;



* categorizing covars -------------------; 
data dietBDperGIRLbyRECALL2;
	set DietRankA;
	AvgPerFat=((AvgFAT*9)/AvgCal)*100;*1g fat = 9 calories; 
	AvgPerPro=((AvgPRO*4)/AvgCal)*100;*1g protein = 4 cal; 
	AvgPerCarb=((AvgCARB*4)/AvgCal)*100;*1g carb = 4 cal;

	/* Creating median continuous vars for trend test (quartiles) */ 
	if AvgSSBq = 0 then medQ_AvgSSBQ = 10; 
	else if AvgSSBq = 1 then medQ_AvgSSBQ = 200; 
	else if AvgSSBq = 2 then medQ_AvgSSBQ = 338; 
	else if AvgSSBq = 3 then medQ_AvgSSBQ = 614; 
run;
data dietBDperGIRLbyRECALL3;
	set DietRankB;
	AvgPerFat=((AvgFAT*9)/AvgCal)*100;*1g fat = 9 calories; 
	AvgPerPro=((AvgPRO*4)/AvgCal)*100;*1g protein = 4 cal; 
	AvgPerCarb=((AvgCARB*4)/AvgCal)*100;*1g carb = 4 cal;

	/* Creating median continuous vars for trend test (quartiles) */ 
	if AvgSSBq = 0 then medQ_AvgSSBQ = 170; 
	else if AvgSSBq = 1 then medQ_AvgSSBQ = 290; 
	else if AvgSSBq = 2 then medQ_AvgSSBQ = 375; 
	else if AvgSSBq = 3 then medQ_AvgSSBQ = 616; 
run;


/***********************************************************************************
************************************************************************************
					3. 	Re-running analysis
[update file/folder if re-running]
************************************************************************************
***********************************************************************************/

* re-running analysis ------------------------ ;
proc sort data = dietBDperGIRLbyRECALL3; by AvgSSBq; run; 
proc sort data = dietBDperGIRL3; by AvgSSBq; run; 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan19\REDO_2FREQ.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;

Title 'Distribution of 24H recalls by SSQ Quartile'; 
proc freq data = dietBDperGIRL3; 
	table AvgSSBQ*num_recall_cat/list missing; 
	run; 
proc means data=dietBDperGIRL3 n nmiss min max mean stddev;
	class AvgSSBQ;
	var AvgSSB;
	run;

Title 'Distribution of 24H recalls by SSQ Quartile- Sensitivity Analysis (girls with only 1 24H recall)'; 
proc freq data = dietBDperGIRLbyRECALL3; 
	table AvgSSBQ*num_recall_cat/list missing;  
	run; 
proc means data=dietBDperGIRLbyRECALL3 n nmiss min max mean stddev;
	class AvgSSBQ;
	var AvgSSB;
	run;

Title 'TABLE 1: Characteristics without SSB categorization- continuous'; 
proc means data = dietBDperGIRLbyRECALL3 n mean stddev min max q1 median q3 stackodsoutput; 
var AvgSSB age_visit avg_aFGV avg_perFGV avg_TotVol avg_TotArea 
		antro_baz BMImo AvgCal AvgPerFat AvgPerPro AvgPerCarb AvgMeat AvgDairy AvgSug fat_p antro_promcint; 
run; 
Title 'TABLE 1: Characteristics without SSB categorization- categorical'; 
proc freq data = dietBDperGIRLbyRECALL3; 
table educ_M dailytv num_recall_cat menarq/list; 
run; 
Title 'TABLE 1:Characteristics with SSB categorization- continuous'; 
proc means data = dietBDperGIRLbyRECALL3 n mean stddev min max q1 median q3 stackodsoutput; 
by AvgSSBq;
var AvgSSB age_visit avg_aFGV avg_perFGV avg_TotVol avg_TotArea 
		antro_baz BMImo AvgCal AvgPerFat AvgPerPro AvgPerCarb AvgMeat AvgDairy AvgSug fat_p antro_promcint; 
run; 
Title 'TABLE 1: Characteristics with SSB categorization- categorica'; 
proc freq data = dietBDperGIRLbyRECALL3; 
table AvgSSBq*(educ_M dailytv num_recall_cat menarq)/list; 
run; 


/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRLbyRECALL3 ; 
class AvgSSBQ (ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRLbyRECALL3;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 







* INCLUDING MENARCHE ------------------------ ;


ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Jan19\regression_wmenarche.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal menarq/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV menarq/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat menarq/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint menarq/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal menarq/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV menarq/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat menarq/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint menarq/dist=normal link=identity;
run;

/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal menarq/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV menarq/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat menarq/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint menarq/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal menarq/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV menarq/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat menarq/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint menarq/dist=normal link=identity;
run;

/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal menarq/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV menarq/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat menarq/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint menarq/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal menarq/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV menarq/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat menarq/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint menarq/dist=normal link=identity;
run;

ods excel close; 


