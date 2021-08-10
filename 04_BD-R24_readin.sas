/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 4: 
						- Merging 24H, BD, Covar ReadIn file

						* With references to A. Gaskins 2015
************************************************************************************
***********************************************************************************/

libname dat  "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Final"; 
libname results "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08"; 


/***********************************************************************************
************************************************************************************
					1. 	Import cleaned data
************************************************************************************
***********************************************************************************/

* Diet; 
data DIET; 
	set dat.avgDIETperDAY; 
run; 

* Breast; 
data BD; 
	set dat.avgBREASTperGIRL; 
run; 

* Covariate; 
data COVAR; 
	set dat.COVARperGIRL; 
run; 

* Review all; 
proc contents data = diet order=varnum; run; 
proc contents data = bd order=varnum; run; 
proc contents data = covar order=varnum; run; 

Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from diet;
quit;
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from bd;
quit;
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from covar;
quit;


/***********************************************************************************
************************************************************************************
					2. 	Merging
************************************************************************************
***********************************************************************************/

* Giving indicators for each dataset; 
data diet2; 
	set diet; 
	dietN = 1; 
run; 
data bd2; 
	set bd; 
	bdN = 1; 
run; 
data covar2; 
	set covar; 
	covarN = 1; 
run; 


* Merge datasets; 
proc sort data = diet2; by child_id; 
proc sort data = bd2; by child_id; 
proc sort data = covar2; by child_id; 
data dietBD; 
	merge diet2 bd2 covar2; 
	by child_id; 
run; 


/***********************************************************************************
************************************************************************************
					3. 	Keep prospective diet only
************************************************************************************
***********************************************************************************/

proc contents data = dietBD order=varnum; run; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from dietBD;
quit; * 523; 


* Who is missing diet data? ; 
data dietBD1;
	set dietBD;
	if TotCal=. then missingdiet=1; else missingdiet=0;
	if r24_date>date_t45 then notprospectiveBD=1; else notprospectiveBD=0;
	year_diet=year(r24_date);
run;

Title 'Girls Missing Diet and BD';
proc freq data=dietBD1;
table missingBD*missingdiet/missing ;
run;

Title 'Observations without prospective BD'; 
proc freq data = dietBD1; 
table notprospectiveBD; 
run; 

proc freq data=dietBD1;
where missingBD=0 and missingdiet=0;
table notprospectiveBD*year_diet;
run;


/***********************
Consort diagram
**********************/

* Total number of GOCS girls with diet or BD information; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from dietbd1;
quit; * 523 girls; 

* Drop OBSERVATIONS with missing diet; 
data notmissingdiet; 
	set dietbd1; 
	if missingdiet=1 then delete; 
run; * 1613 observations; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from notmissingdiet;
quit; * 516 girls ; 

* Drop GIRLS with missing breast density; 
data notmissingbd; 
	set notmissingdiet; 
	if missingBD=1 or missingBD=. then delete;
	if missingDB=1 or missingDB=. then delete;
run; * 1457 observations; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from notmissingbd;
quit; * 460 girls; 

* Drop OBSERVATIONS that are not prospective; 
data noprospectivediet; 
	set notmissingbd; 
	if notprospectiveBD=1 then delete;
run; * 881 observations; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from noprospectivediet;
quit; * 374 girls; 


* Save final LONG diet dataset; 
data dat.dietBDcomplete;
	set noprospectivediet; 
run; * 881 obs, 374 girls; 


* Save final non-diet dataset; 
proc sort data = noprospectivediet; by child_id; run; 
data bdcovars; 
	set noprospectivediet; 
	keep child_id date_t45 tcuerpo_aprobado date_menarq_final t45year date_birth 
	missingBD BD missingBV BV missingDB DB 
	menarche avg_aFGV avg_perFGV avg_TotVol 
	date tanita_age fat_p antro_baz antro_promcint age_men_mo 
	educacion_madre age_visit overweight obese BMImo overweight_m obese_m educ_M dailyTV ; 
run; 
proc sort data = bdcovars 
	OUT=bdcovars_nodup	
	NODUPKEYS  ;  
	BY child_id;
run; 
data dat.BDCOVARcomplete;
	set bdcovars_nodup; 
run;


/**********************************************************************************
Consider the temporality of drinking SSB and 
	the outcome in the study design and analysis

Can you standardize the timing of exposure to outcome 
	based on when you hypothesize SSB to affect density? 

Focus on the timing as a source of bias. For the girls with only 1 recall , 
	was this recall at an earlier age than girls with >1 recall? 

Use long diet data: dietBDcomplete
**********************************************************************************/

* Calculating time betweeen recall and BD outcome measurement; 
data timing; 
	set dat.dietBDcomplete; 
	followupR24yr = (date_t45-r24_date)/365.25; 
	followupR24mo = (date_t45-r24_date)/30.5;
run; 

proc means data = timing noprint;
by child_id; 
var followupR24yr followupR24mo; 
output out = avgFOLLOWUPperGIRL 
mean(followupR24yr)=avgFUyr min(followupR24yr)=minFUyr max(followupR24yr)=maxFUyr
mean(followupR24mo)=avgFUmo min(followupR24mo)=minFUmo max(followupR24mo)=maxFUmo; 
run; 

data avgFOLLOWUPperGIRL2; 
	set avgFOLLOWUPperGIRL; 
	rename _FREQ_=num_recalls; 
	run; 

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\timing_months.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;

Title 'Average'; 
proc means data = timing n min mean max;
var followupR24mo; 
run; 

Title 'Average of averages'; 
proc means data = avgFOLLOWUPperGIRL2 n min mean max; 
var num_recalls avgFUmo minFUmo maxFUmo; 
run; 
ods excel close; 




/**********************************************************************************
How did the analytical cohort of 374 differ from the 515 by 
key sample characteristics such as those listed in Table 1?
**********************************************************************************/

* Use notmissingdiet dataset; 
proc sort data = notmissingdiet; by child_id; run; 
data oc; 
	set notmissingdiet; 
	keep child_id tcuerpo_aprobado age_visit tanita_age menarche
		fat_p antro_baz antro_promcint overweight obese BMImo educ_M dailytv; 
	run; 
proc sort data = oc 
	OUT=oc_nodup	
	NODUPKEYS  ;  
	BY child_id;
run; 

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\TABLE1_fullcohort.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;

Title 'Characteristics without SSB categorization- continuous'; 
proc means data = oc_nodup n mean stddev min max q1 median q3 stackodsoutput; 
	var age_visit antro_baz BMImo fat_p antro_promcint; 
run; 
Title 'Characteristics without SSB categorization- categorical'; 
proc freq data = oc_nodup; 
table overweight obese educ_M dailytv menarche/list; 
run; 

ods excel close; 


/***********************************************************************************
************************************************************************************
					4. 	Average food intake and quartiles
************************************************************************************
***********************************************************************************/
data dietBDcomplete;
	set dat.dietBDcomplete; 
run; 
data bdcovarcomplete;
	set dat.BDCOVARcomplete; 
run; 

* Get day and month of survey; 
data dietbdcomplete2; 
	set dietbdcomplete; 
	R24month= put(r24_date, monname3.);
run;  

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\day_month_R24.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;
proc freq data = dietbdcomplete2; 
	table R24month; 
run; 
proc freq data = dietbdcomplete2; 
	table R24day; 
run; 
ods excel close; 


* Calculating average food intake per girl, over X# 24hr recalls; 
data dietbdcomplete2; 
	set dietbdcomplete2; 
		/* creating new variable for all sweetened dairy or dairy-sub drinks */ 
	TotSwMilkAndSub = TotSwMilkSubG + TotSwMilkG + TotSwYogG; 
run; 
proc  means data=dietbdcomplete2 noprint;
by child_id;
var TotCAL 
/* nutrients */
TotPRO TotFAT TotCARB TotSFA TotMUFA TotPUFA TotFIB TotSUG TotCa TotIron TotMg SUMPh TotK TotaNa TotZn TotCu 
TotMn TotSe TotVitC TotVitB1 TotVitB2 TotVitB3 TotVitB5 TotVitB6 TotFol TotFolic TotFFol TotDFE TotChol TotVitB12 TotVitA
TotRAE TotRet TotACar TotBCar TotBCrypt TotLyc TotLutZe TotVitE TotVitD TotVitDIU TotVitK TotCholes 
/* Dairy */ 
TotDairyG TotDairySUG TotLFDairyG TotHFDairyG TotMilkG TotHFMilkG TotLFMilkG TotYogG TotCheeseG TotCreamG TotDairyBevG TotDessertG
/* meat */ 
TotMEATG TotUPMeatG TotPMeatG TotWMeatG TotRMeatG
/* SSB */ 
TotSSB TotWaterG TotSugWaterG TotSportBevG TotCoffG TotSCoffG TotSodaG TotSSodaG TotDSodaG TotJuiceG TotFJuiceG TotSJuiceG
TotTea TotSTea TotSwMilkSubG TotMilkSubG TotSwMilkG TotFlvPowG TotSwMilkAndSub TotSwYogG;
output out=avgDIETperGIRL 
/* Nutrients */ 
MEAN(TotCAL)=AvgCAL MEAN(TotPRO)=AvgPRO MEAN(TotFAT)=AvgFAT MEAN(TotCARB)=AvgCARB
MEAN(TotSFA)=AvgSFA MEAN(TotMUFA)=AvgMUFA MEAN(TotPUFA)=AvgPUFA MEAN(TotFIB)=AvgFIB MEAN(TotSUG)=AvgSUG MEAN(TotCa)=AvgCa
MEAN(TotIron)=AvgIron MEAN(TotMg)=AvgMg MEAN(SUMPh)=AvgPh MEAN(TotK)=AvgK MEAN(TotaNa)=AvgNa MEAN(TotZn)=AvgZn MEAN(TotCu)=AvgCu 
MEAN(TotMn)=AvgMn MEAN(TotSe)=AvgSe MEAN(TotVitC)=AvgVitC MEAN(TotVitB1)=AvgVitB1 MEAN(TotVitB2)=AvgVitB2 MEAN(TotVitB3)=AvgVitB3
MEAN(TotVitB5)=AvgVitB5 MEAN(TotVitB6)=AvgVitB6 MEAN(TotFol)=AvgFol MEAN(TotFolic)=AvgFolic MEAN(TotFFol)=AvgFFol 
MEAN(TotDFE)=AvgDFE MEAN(TotChol)=AvgChol MEAN(TotVitB12)=AvgVitB12 MEAN(TotVitA)=AvgVitA MEAN(TotRAE)=AvgRAE 
MEAN(TotRet)=AvgRet MEAN(TotACar)=AvgACar MEAN(TotBCar)=AvgBCar MEAN(TotBCrypt)=AvgBCrypt MEAN(TotLyc)=AvgLyc 
MEAN(TotLutZe)=AvgLutZe MEAN(TotVitE)=AvgVitE MEAN(TotVitD)=AvgVitD MEAN(TotVitDIU)=AvgVitDIU MEAN(TotVitK)=AvgVitK
MEAN(TotCholes)=AvgCholes
/* Dairy */ 
MEAN(TotDairyG)=AvgDairy MEAN(TotDairySUG)=AvgDairySug MEAN(TotLFDairyG)=AvgLFDairy MEAN(TotHFDairyG)=AvgHFDairy MEAN(TotMilkG)=AvgMilk 
MEAN(TotHFMilkG)=AvgHFMilk MEAN(TotLFMilkG)=AvgLFMilk MEAN(TotYogG)=AvgYog MEAN(TotCheeseG)=AvgCheese MEAN(TotCreamG)=AvgCream 
MEAN(TotDairyBevG)=AvgDairyBev MEAN(TotDessertG)=AvgDessert
/* Meat */ 
MEAN(TotMEATG)=AvgMeat MEAN(TotUPMeatG)=AvgUPMeat MEAN(TotPMeatG)=AvgPMeat MEAN(TotWMeatG)=AvgWMeat MEAN(TotRMeatG)=AvgRMeat 
/* Beverages */ 
MEAN(TotSSB)=AvgSSB MEAN(TotWaterG)=AvgWater MEAN(TotSugWaterG)=AvgSugWater
MEAN(TotSportBevG)=AvgSportBev MEAN(TotCoffG)=AvgCoff MEAN(TotSCoffG)=AvgSugCoff MEAN(TotSodaG)=AvgSoda MEAN(TotSSodaG)=AvgSugSoda 
MEAN(TotDSodaG)=AvgDietSoda MEAN(TotJuiceG)=AvgJuice MEAN(TotFJuiceG)=AvgFJuice MEAN(TotSJuiceG)=AvgSugJuice MEAN(TotTea)=AvgTea
MEAN(TotSTea)=AvgSugTea MEAN(TotSwMilkSubG)=AvgSwMilkSub MEAN(TotMilkSubG)=AvgMilkSub MEAN(TotSwMilkG)=AvgSwMilk MEAN(TotFlvPowG)=AvgFlvPow
MEAN(TotSwMilkAndSub)=AvgSwMilkAndSub MEAN(TotSwYogG)=AvgSwYogG;
run;
proc means data = avgDIETperGIRL; 
	var  AvgCAL AvgPRO AvgFAT AvgCARB 
		AvgDairy AvgDairyBev AvgMeat 
		AvgSSB AvgSugSoda AvgSwMilkSub AvgMilkSub AvgSwMilk AvgSwMilkAndSub AvgSwYogG; 
run; 


* Merging single-row diet and bd; 
proc sort data=bdcovarcomplete; by child_id; 
proc sort data = avgDIETperGIRL; by child_id; 
data dietBDperGIRL; 
	merge bdcovarcomplete avgDIETperGIRL; 
	by child_id; 
run; 
proc contents data = dietBDperGIRL order=varnum; run; 


* Creating quartiles of diet and BD variables; 
proc rank data=dietBDperGIRL out=DietRank groups=4;                               
     var	AvgDairy AvgSSB AvgMeat AvgCal;                                                          
     ranks 	AvgDairyQ AvgSSBQ AvgMeatQ AvgCalQ;                                                      
  run;   
proc means data=dietRank n nmiss min median max mean stddev;
	class AvgSSBQ;
	var AvgSSB;
run; * SSBQ medians: 120, 250, 372, 617;


* Creating median vars;
data dietBDperGIRL2;
set DietRank;
	AvgPerFat=((AvgFAT*9)/AvgCal)*100;*1g fat = 9 calories; 
	AvgPerPro=((AvgPRO*4)/AvgCal)*100;*1g protein = 4 cal; 
	AvgPerCarb=((AvgCARB*4)/AvgCal)*100;*1g carb = 4 cal;

	if AvgDairyBev=0 then do; rk3_AvgDairyBev=0; med3_AvgDairyBev=0; end;
	else if AvgDairyBev>0 and AvgDairyBev<=125 then do; rk3_AvgDairyBev=1; med3_AvgDairyBev=63; end;
	else if AvgDairyBev>125 then do; rk3_AvgDairyBev=2; med3_AvgDairyBev=125; end;

	/* Creating median continuous vars for trend test (quartiles) */ 
	if AvgSSBq = 0 then medQ_AvgSSBQ = 120; 
	else if AvgSSBq = 1 then medQ_AvgSSBQ = 250; 
	else if AvgSSBq = 2 then medQ_AvgSSBQ = 372; 
	else if AvgSSBq = 3 then medQ_AvgSSBQ = 617; 

	/* categorizing the number of 24-hr recalls */ 
	num_recall_cat=_FREQ_;
	if _FREQ_ in (4,5,6) then num_recall_cat=4;

run; 

 
/***********************************************************************************
************************************************************************************
					5. 	Distributions of diet, breast and covariate variables 
************************************************************************************
***********************************************************************************/

ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\Diet_histograms.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc'); 

* checking data distribution for diet; 
proc univariate data = dietBDperGIRL2; 
	var AvgCAL; 
	histogram/ ODSTITLE='Histogram, mean energy intake per day(kCal)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var AvgSSB; 
	histogram/ ODSTITLE='Histogram, mean SSB intake per day(ml)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var AvgDairy; 
	histogram/ ODSTITLE='Histogram, mean dairy intake per day(g)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var AvgMeat; 
	histogram/ ODSTITLE='Histogram, mean meat intake per day(g)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var AvgFAT; 
	histogram/ ODSTITLE='Histogram, mean fat intake per day(g)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var AvgPRO; 
	histogram/ ODSTITLE='Histogram, mean protein intake per day(g)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var AvgCARB; 
	histogram/ ODSTITLE='Histogram, mean carb intake per day(g)';; 
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
ods excel close; 


ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\bdcovar_distributions.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;

proc univariate data = dietBDperGIRL2; 
	var avg_aFGV; 
	histogram/ODSTITLE='Histogram, absolute FGV';
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var avg_perFGV; 
	histogram/ODSTITLE='Histogram, percent FGV';
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var avg_TotVol; 
	histogram/ODSTITLE='Histogram, total volume';
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var antro_baz; 
	histogram/ODSTITLE='Histogram, BMI Z-score';
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var fat_p; 
	histogram/ODSTITLE='Histogram, BMI Z-score';
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 
proc univariate data = dietBDperGIRL2; 
	var antro_promcint; 
	histogram/ODSTITLE='Histogram, BMI Z-score';
	INSET N = 'Number of Girls'  MEDIAN (8.2) MEAN (8.2) STD = 'Standard Deviation' (8.3) /POSITION = ne;	
run; 

Title 'Correlation- BMI and TBV'; 
proc corr data = dietBDperGIRL2 plots=scatter(nvar=2 alpha=.05 .10); 
	var antro_baz avg_TotVol; 
	label antro_baz="BMI Z-score" avg_TotVol="Total Breast Volume"; 
run; 
Title 'Correlation- BMI and aFGV'; 
proc corr data = dietBDperGIRL2 plots=scatter(nvar=2 alpha=.05 .10); 
	var antro_baz avg_aFGV; 
	label antro_baz="BMI Z-score" avg_TotVol="Absolute breast FGV"; 
run; 
Title 'Correlation- BMI and %FGV'; 
proc corr data = dietBDperGIRL2 plots=scatter(nvar=2 alpha=.05 .10); 
	var antro_baz avg_perFGV; 
	label antro_baz="BMI Z-score" avg_TotVol="Percent breast FGV"; 
run; 

Title 'Correlation- BMI and TBV'; 
proc corr data = dietBDperGIRL2 plots=scatter(nvar=2 alpha=.05 .10) ; 
	var antro_baz avg_TotVol; 
	partial AvgCal; 
	label antro_baz="BMI Z-score" avg_TotVol="Total Breast Volume"; 
run; 
Title 'Correlation- BMI and aFGV'; 
proc corr data = dietBDperGIRL2 plots=scatter(nvar=2 alpha=.05 .10) ; 
	var antro_baz avg_aFGV; 
	partial AvgCal; 
	label antro_baz="BMI Z-score" avg_TotVol="Absolute breast FGV"; 
run; 
Title 'Correlation- BMI and %FGV'; 
proc corr data = dietBDperGIRL2 plots=scatter(nvar=2 alpha=.05 .10)  ; 
	var antro_baz avg_perFGV; 
	partial AvgCal; 
	label antro_baz="BMI Z-score" avg_TotVol="Percent breast FGV"; 
run; 
ods excel close; 


* Log transformation of breast outcome; 
data dietBDperGIRL2; 
	set dietBDperGIRL2; 
	logavg_aFGV = log(avg_aFGV); 
	logavg_perFGV = log(avg_perFGV); 
	logavg_TotVol = log(avg_TotVol); 
	logavg_TotArea = log(avg_TotArea); 
run; 


 
/***********************************************************************************
************************************************************************************
					6. 	Save final dataset 
************************************************************************************
***********************************************************************************/

data dat.BDR24_final; 
	set dietBDperGIRL2; 
	run; 
