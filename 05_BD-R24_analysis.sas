/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 5: 
						- Analytic file 

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
					2. 	Looking at correlations
************************************************************************************
***********************************************************************************/

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\dietcorrelations.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/***** AvgCal & SSB *****/ 
ods graphics on;
Title 'Correlation- Total Calories & SSB (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgCal AvgSSB ; 
	label AvgCal="Total energy (kCal)" AvgSSB="Total SSB (ml)"; 
run; 
/***** AvgSSB & Fat *****/ 
Title 'Correlation- SSB & Percent Fat (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPerFat; 
	label AvgSSB="Total SSB (ml)" AvgPerFat="Calories from FAT (%)"; 
run; 
Title 'Correlation- SSB & Percent Fat (average daily intake), adjusting for total calories'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPerFat; 
	partial AvgCal; 
	label AvgSSB="Total SSB (ml)" AvgPerFat="Calories from FAT (%)"; 
run; 
Title 'Correlation- SSB & Fat (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgFat; 
	label AvgSSB="Total SSB (ml)" AvgFat="Total FAT (g)"; 
run; 
Title 'Correlation- SSB & Fat (average daily intake), adjusting for total calories'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgFat; 
	partial AvgCal; 
	label AvgSSB="Total SSB (ml)" AvgFat="Total Fat (g)"; 
run; 
/***** AvgSSB & Protein *****/ 
Title 'Correlation- SSB & Percent Protein (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPerPro; 
	label AvgSSB="Total SSB (ml)" AvgPerPro="Calories from PROTEIN (%)"; 
run; 
Title 'Correlation- SSB & Percent Protein (average daily intake), adjusting for total calories'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPerPro; 
	partial AvgCal; 
	label AvgSSB="Total SSB (ml)" AvgPerPro="Calories from PROTEIN (%)"; 
run; 
Title 'Correlation- SSB &  Protein (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPro; 
	label AvgSSB="Total SSB (ml)" AvgPro="Total PROTEIN (g)"; 
run; 
Title 'Correlation- SSB &  Protein (average daily intake), adjusting for total calories'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPro; 
	partial AvgCal; 
	label AvgSSB="Total SSB (ml)" AvgPro="Total PROTEIN (g)"; 
run; 
/***** AvgSSB & Carb *****/ 
Title 'Correlation- SSB & Percent Carb (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPerCarb; 
	label AvgSSB="Total SSB (ml)" AvgPerCarb="Calories from Carb (%)"; 
run; 
Title 'Correlation- SSB & Percent Carb (average daily intake), adjusting for total calories'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgPerCarb; 
	partial AvgCal; 
	label AvgSSB="Total SSB (ml)" AvgPerCarb="Calories from Carb (%)"; 
run; 
Title 'Correlation- SSB &  Carb (average daily intake)'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgCarb; 
	label AvgSSB="Total SSB (ml)" AvgCarb="Total Carb (g)"; 
run; 
Title 'Correlation- SSB &  Carb (average daily intake), adjusting for total calories'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB AvgCarb; 
	partial AvgCal; 
	label AvgSSB="Total SSB (ml)" AvgCarb="Total Carb (g)"; 
run;
ods excel close;



ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\diet_anthro_correlations.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/***** AvgCal & anthro *****/ 
Title 'Correlation- Total Calories (daily)  & BMI Z-score'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgCal antro_baz; 
	label AvgCal="Total Calories (kCal/day)" antro_baz="BMI Z-score"; 
run; 
Title 'Correlation- Total Calories (daily)  & Fat %'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgCal fat_p; 
	label AvgCal="Total Calories (kCal/day)" fat_p="Body fat percent"; 
run;
/***** AvgSSB & anthro *****/ 
Title 'Correlation- SSB (daily)  & BMI Z-score'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB antro_baz; 
	label AvgSSB="Total SSB (ml)" antro_baz="BMI Z-score"; 
run; 
Title 'Correlation- SSB (daily)  & Fat %'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB fat_p; 
	label AvgSSB="Total SSB (ml)" fat_p="Body fat percent"; 
run;
/***** AvgSSB & anthro, adjust for totcal *****/ 
Title 'Correlation- SSB (daily)  & BMI Z-score, adjusting for total caloric intake'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB antro_baz; 
	partial AvgCal;
	label AvgSSB="Total SSB (ml)" antro_baz="BMI Z-score"; 
run; 
Title 'Correlation- SSB (daily)  & Fat %,  adjusting for total caloric intake'; 
proc corr data = dietBDperGIRL3 plots=scatter(nvar=2 alpha=.05 .10); 
	var AvgSSB fat_p; 
	partial AvgCal;
	label AvgSSB="Total SSB (ml)" fat_p="Body fat percent"; 
run;
ods excel close;


ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\BD_anthro_correlations.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/***** SSB (ml/day) and Fat (g/day) correlation *****/ 
Title 'Correlation of aFGV and BMI-Z'; 
proc corr data = dietBDperGIRL3 plots = scatter; 
	var avg_aFGV antro_baz ; 
run; 
Title 'Correlation of aFGV and BMI-Z, adjusting for fat percentage'; 
proc corr data = dietBDperGIRL3 plots = scatter; 
	var avg_aFGV antro_baz ;
	partial fat_p;  
run; 

Title 'Correlation of avg_perFGV and BMI-Z'; 
proc corr data = dietBDperGIRL3 plots = scatter; 
	var avg_perFGV antro_baz ; 
run; 
Title 'Correlation of avg_perFGV and BMI-Z, adjusting for fat percentage'; 
proc corr data = dietBDperGIRL3 plots = scatter; 
	var avg_perFGV antro_baz ;
	partial fat_p;  
run; 
ods excel close;


/***********************************************************************************
************************************************************************************
					3. 	Are my covariates equal across SSB groups?
************************************************************************************
***********************************************************************************/ 

/*** QUARTILES ***/ 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\Covariates by SSB quartile - ChiSq and Wilcoxon.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;

Title 'Categories of Intake';
proc freq data = dietBDperGIRL3; 
	table AvgSSBQ AvgDairyQ num_recall_cat; 
run; 

/* chi sq */ 
proc freq data = dietBDperGIRL3; 
	table AvgSSBQ*(educ_M dailyTV num_recall_cat menarche)/chisq; 
run; 
* chi sq: educ_M p=0.3466, dailyTV p=.0969, num_recall_cat p=.0002; 

/* Wilcoxon */ 
proc sort data = dietBDperGIRL3; 
by AvgSSBQ; 
proc means data = dietBDperGIRL3;
by AvgSSBQ; 
var age_visit antro_baz BMImo AvgCal AvgMeat AvgDairy fat_p antro_promcint; 
run; 

proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var age_visit; run; 
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var antro_baz; run;  
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var BMImo; run; 
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var AvgCal; run; 
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var AvgMeat; run; 
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var AvgDairy; run; 
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var AvgPerFat; run;
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var fat_p; run;
proc npar1way data=dietBDperGIRL3 wilcoxon; class AvgSSBQ; var antro_promcint; run;

ods excel close; 

* Looking at contribution of individual beverages; 
data SSBcontribution; 
	set dietBDperGIRL3; 
	AvgSSB2 = AvgSugWater + AvgSportBev + AvgSugCoff + AvgSugSoda + AvgSugJuice 
				+ AvgSugTea + AvgSwMilkSub + AvgSwMilk + AvgFlvPow + AvgSwYogG; 

	if AvgSSB = AvgSSB2 then CHECK = 1; 
	else if 0 < AvgSSB < AvgSSB2 then CHECK = 2; 
	else if AvgSSB > AvgSSB2 then CHECK = 3; 

	/* SSB contribution */ 
	AvgPerSugWat = (AvgSugWater/AvgSSB)*100; 
	AvgPerSportBev = (AvgSportBev/AvgSSB)*100; 
	AvgPerSugSoda = (AvgSugSoda/AvgSSB)*100; 
	AvgPerCoffTea = ((AvgSugCoff+AvgSugTea)/AvgSSB)*100; 
	AvePerSugJuice = (AvgSugJuice/AvgSSB)*100; 
	AvgPerMixedDairy = ((AvgSwMilkSub+AvgSwMilk+AvgSwYogG)/AvgSSB)*100;
	AvgPerSugPow = (AvgFlvPow/AvgSSB)*100; 
	AvgPerSSB = (AvgSSB/AvgSSB)*100; 

run; 

proc freq data = SSBcontribution; 
	table check; 
	run; 

proc print data = SSBcontribution; 
	where check in(2,3); 
	var child_id AvgSSB AvgSSB2 AvgWater AvgSugWater AvgSportBev AvgCoff AvgSugCoff AvgSoda AvgSugSoda AvgDietSoda AvgJuice AvgFJuice AvgSugJuice
AvgTea AvgSugTea AvgSwMilkSub AvgMilkSub AvgSwMilk AvgFlvPow AvgSwYogG; 
run; 

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\SSB components by percent.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
proc means data = SSBcontribution stackodsoutput; 
	var AvgPerSugWat AvgPerSportBev AvgPerSugSoda AvgPerCoffTea AvePerSugJuice AvgPerMixedDairy 
		AvgPerSugPow AvgPerSSB; 
run; 
proc means data = SSBcontribution stackodsoutput; 
	class AvgSSBQ; 
	var AvgPerSugWat AvgPerSportBev AvgPerSugSoda AvgPerCoffTea AvePerSugJuice AvgPerMixedDairy 
		AvgPerSugPow AvgPerSSB; 
run; 
ods excel close; 

/***********************************************************************************
************************************************************************************
					4. 	Table 1
************************************************************************************
***********************************************************************************/ 

	/** QUARTILES **/ 
proc sort data = dietBDperGIRL3; by AvgSSBq; 

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\Table1_QUART.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
Title 'Characteristics without SSB categorization- continuous'; 
proc means data = dietBDperGIRL3 n mean stddev min max q1 median q3 stackodsoutput; 
var AvgSSB age_visit avg_aFGV avg_perFGV avg_TotVol avg_TotArea 
		antro_baz BMImo AvgCal AvgPerFat AvgPerPro AvgPerCarb AvgMeat AvgDairy AvgSug fat_p antro_promcint
	; 
run; 
Title 'Characteristics without SSB categorization- categorica'; 
proc freq data = dietBDperGIRL3; 
table educ_M dailytv num_recall_cat menarche/list; 
run; 
Title 'Characteristics without SSB categorization- continuous'; 
proc means data = dietBDperGIRL3 n mean stddev min max q1 median q3 stackodsoutput; 
by AvgSSBq;
var AvgSSB age_visit avg_aFGV avg_perFGV avg_TotVol avg_TotArea 
		antro_baz BMImo AvgCal AvgPerFat AvgPerPro AvgPerCarb AvgMeat AvgDairy AvgSug fat_p antro_promcint
	; 
run; 
Title 'Characteristics without SSB categorization- categorica'; 
proc freq data = dietBDperGIRL3; 
table AvgSSBq*(educ_M dailytv num_recall_cat menarche)/list; 
run; 
proc means data = SSBcontribution stackodsoutput; 
by AvgSSBq; 
	var AvgPerSugWat AvgPerSportBev AvgPerSugSoda AvgPerCoffTea AvePerSugJuice AvgPerMixedDairy 
		AvgPerSugPow; 
run; 
ods excel close; 


/***********************************************************************************
************************************************************************************
					5. 	Regression analysis: FGV ~ SSB
************************************************************************************
***********************************************************************************/

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\Regression_QUART.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* absolute FGV */ 
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
class AvgSSBQ (ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Test- absolute FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist circumference)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_aFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

/* %FGV */
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Test- percent FGV ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_perFGV= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

/* Total breast volume */
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first) ; 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Linear Regression- Total breast volume ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 1 (adjusted for BMI, age, and total calories)'; 
proc genmod data=dietBDperGIRL3 ;
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 2 (adjusted for BMI, age,total calories, mother education, TV)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV /dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 3 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Test- Total breast volume ~ SSB quartile: MODEL 4 (adjusted for BMI, age,total calories, mother education, TV, dairy, meat, waist)'; 
proc genmod data=dietBDperGIRL3 ;
class educ_M (ref=first) dailyTV(ref=first); 
model avg_TotVol= medQ_AvgSSBQ antro_baz Age_visit AvgCal educ_M dailyTV AvgDairy AvgMeat antro_promcint/dist=normal link=identity;
run;

ods excel close; 


/***********************************************************************************
************************************************************************************
					6. 	Regression analysis: FGV ~ anthropometric
************************************************************************************
***********************************************************************************/

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\Regression_anthro_bd.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;
/* BMI Z score */ 
Title 'Linear Regression- absolute FGV ~ BMI Z score: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_aFGV= antro_baz /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ BMI Z score: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_aFGV= antro_baz Age_visit AvgCal/dist=normal link=identity;
run;

Title 'Linear Regression- percent FGV ~ BMI Z score: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_perFGV= antro_baz /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ BMI Z score: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_perFGV= antro_baz Age_visit AvgCal/dist=normal link=identity;
run;

Title 'Linear Regression- total BV ~ BMI Z score: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_TotVol= antro_baz /dist=normal link=identity;
run;
Title 'Linear Regression- total FGV ~ BMI Z score: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_TotVol= antro_baz Age_visit AvgCal/dist=normal link=identity;
run;
	
/* Fat Percentage */ 
Title 'Linear Regression- absolute FGV ~ Fat %: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_aFGV= fat_p /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ Fat %: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_aFGV= fat_p Age_visit AvgCal/dist=normal link=identity;
run;

Title 'Linear Regression- percent FGV ~ Fat %: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_perFGV= fat_p /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ Fat %: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_perFGV= fat_p Age_visit AvgCal/dist=normal link=identity;
run;

Title 'Linear Regression- total BV ~ Fat %: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_TotVol= fat_p /dist=normal link=identity;
run;
Title 'Linear Regression- total FGV ~ Fat %: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_TotVol= fat_p Age_visit AvgCal/dist=normal link=identity;
run;

/* Waist circumference */ 
Title 'Linear Regression- absolute FGV ~ Waist circumference: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_aFGV= antro_promcint /dist=normal link=identity;
run;
Title 'Linear Regression- absolute FGV ~ Waist circumference: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_aFGV= antro_promcint Age_visit AvgCal/dist=normal link=identity;
run;

Title 'Linear Regression- percent FGV ~ Waist circumference: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_perFGV= antro_promcint /dist=normal link=identity;
run;
Title 'Linear Regression- percent FGV ~ Waist circumference: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_perFGV= antro_promcint Age_visit AvgCal/dist=normal link=identity;
run;

Title 'Linear Regression- total BV ~ Waist circumference: MODEL 1 '; 
proc genmod data=dietBDperGIRL3  ; 
model avg_TotVol= antro_promcint /dist=normal link=identity;
run;
Title 'Linear Regression- total FGV ~ Waist circumference: MODEL 2 (age and total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model avg_TotVol= antro_promcint Age_visit AvgCal/dist=normal link=identity;
run;
ods excel close; 



/***********************************************************************************
************************************************************************************
					7. 	[Supplemental] Regression analysis: anthro ~ SSB
************************************************************************************
***********************************************************************************/

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\ssb_anthro.xlsx"
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
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
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
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
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
class AvgSSBQ (ref=first) educ_M (ref=first) dailyTV(ref=first); 
model antro_promcint= AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;

/* Tests for trend */ 
Title 'Trend Linear Regression- BMI Z-score ~ SSB quartile: MODEL 1 (adjusted for total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model antro_baz= MedQ_AvgSSBQ avgCal/dist=normal link=identity;
run;
Title 'Trend Linear Regression- BMI Z-score ~ SSB quartile: MODEL 2 (adjusted for total calories, dairy, meat, age)'; 
proc genmod data=dietBDperGIRL3  ; 
model antro_baz= MedQ_AvgSSBQ Age_visit avgCal AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Linear Regression- BMI Z-score ~ SSB quartile: MODEL 3 (adjusted for total calories, dairy, meat, age , mother education, TV)'; 
proc genmod data=dietBDperGIRL3  ; 
class  educ_M (ref=first) dailyTV(ref=first); 
model antro_baz= MedQ_AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;
Title 'Trend Linear Regression- Fat % ~ SSB quartile: MODEL 1 (adjusted for total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model fat_p= MedQ_AvgSSBQ avgCal/dist=normal link=identity;
run;
Title 'Trend Linear Regression- Fat %  ~ SSB quartile: MODEL 2 (adjusted for total calories, dairy, meat, age)'; 
proc genmod data=dietBDperGIRL3  ; 
model fat_p= MedQ_AvgSSBQ Age_visit avgCal AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Linear Regression- Fat %  ~ SSB quartile: MODEL 3 (adjusted for total calories, dairy, meat, age , mother education, TV)'; 
proc genmod data=dietBDperGIRL3  ; 
class  educ_M (ref=first) dailyTV(ref=first); 
model fat_p= MedQ_AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;
Title 'Trend Linear Regression- Waist circumference ~ SSB quartile: MODEL 1 (adjusted for total calories)'; 
proc genmod data=dietBDperGIRL3  ; 
model antro_promcint= MedQ_AvgSSBQ avgCal/dist=normal link=identity;
run;
Title 'Trend Linear Regression- Waist circumference  ~ SSB quartile: MODEL 2 (adjusted for total calories, dairy, meat, age)'; 
proc genmod data=dietBDperGIRL3  ; 
model antro_promcint= MedQ_AvgSSBQ Age_visit avgCal AvgDairy AvgMeat/dist=normal link=identity;
run;
Title 'Trend Linear Regression- Waist circumference  ~ SSB quartile: MODEL 3 (adjusted for total calories, dairy, meat, age , mother education, TV)'; 
proc genmod data=dietBDperGIRL3  ; 
class  educ_M (ref=first) dailyTV(ref=first); 
model antro_promcint= MedQ_AvgSSBQ Age_visit avgCal AvgDairy AvgMeat educ_M dailyTV/dist=normal link=identity;
run;

ods excel close; 
