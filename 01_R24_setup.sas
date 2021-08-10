/***********************************************************************************
************************************************************************************
					Lara Yoon 
					GOCS SSB & BD Project 
						FILE 1: 	
						- 24hr recall data 
						- food group classification

						Last Updated: 08/09/2021

						* With references to A. Gaskins 2015
************************************************************************************
***********************************************************************************/

libname dat  "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Final"; 
libname results "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08"; 


/***********************************************************************************
************************************************************************************
					1. 	Import data: 24 hour recalls, USDA codes
************************************************************************************
***********************************************************************************/

* 24hr recalls; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\R24_2013_2016_3.dta"
			out= work.recall24hr ;
run;
*USDA codes with nutrients; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\USDA_NDB_SR28.xlsx"
			out= work.usdaNDB 
			dbms = xlsx replace;
			sheet = "Hoja1"; 
			getnames = yes; 
run;
*USDA codes with food group classification; 
proc import datafile = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Data\Raw\Códigos USDA 24.08.2018.xlsx"
			out= work.usdaGRP 
			dbms = xlsx replace;
			sheet = "Hoja1"; 
			getnames = yes; 
run;

* Get overview of data contents; 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\RawDataContents_R24.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;
title 'Contents of raw data'; 
proc contents data = recall24hr; 
ods excel options(sheet_name = "recall24hr"); 
proc contents data = USDANDB; 
ods excel options(sheet_name = "USDANDB"); 
proc contents data = usdaGRP; 
ods excel options(sheet_name = "usdaGRP"); 
run; 
ods excel close;

/***********************************************************************************
************************************************************************************
					2.	Cleaning: diet data 
************************************************************************************
***********************************************************************************/

/**** 24hr recall data ***/

*keep only 24hr recalls for girls (sex=2, 46006 obs); 
data recall24hr1; 
	set recall24hr; 
	rename date=r24_date id_usda_receipe=usda_id group=r24_group subgroup=r24_subgroup category=r24_cat subcategory=r24_subcat year=r24_year sugar=sugar_r24;
	where sex = 2; 
run; 
* typo in original dataset: 16oct0215 --> 16oct2015; 
data recall24hr1; 
	set recall24hr1; 
	if r24_date = -637060 then r24_date = "16oct2015"d; 
run; 
*review years of data; 
proc freq data = recall24hr1; 
	table r24_year; 
run; 
proc sql; 
	create table daterange as
		select min(r24_date) as min_date format= MMDDYY10.,
			   max(r24_date) as max_date format= MMDDYY10.
		from recall24hr1; 
quit; 
proc print data= daterange; 
title 'Date range';
run; * 04/01/2013 02/10/2016 ; 
* convert usda_id from char variable to numeric; 
data recall24hr2; 
	set recall24hr1; 
	new = input(usda_id, 8.); 
	drop usda_id; 
	rename new=usda_id; 
run; 
* check missing values for group; 
proc means data = recall24hr2 n nmiss; 
	var usda_id energy; 
run; * OK; 


/**** NDB data ****/
* don't need this data; 


/**** Group USDA data ****/
proc contents data = usdaGRP; run; 
data usdaGRP1; 
	set usdaGRP; 
	rename codigo_usda=usda_id descripci_n=descripcion; 
run;
* drop empty rows; 
data usdaGRP1; 
	set usdaGRP1; 
	if usda_id = . then delete; 
run; * 5657 observations and 14 variables; 
* drop dupes; 
proc sort data=usdaGRP1; by usda_id;
data usdaGRP2;
	set usdaGRP1;
	by usda_id;
	if first.usda_id;
run; * 1742 observations and 14 variables; 


/** Merge 24H & USDA data **/ 
*review contents of datasets in prep for merge; 
proc contents data = recall24hr2; *OK; 
proc contents data = usdaGRP2; *OK; 
run; 
proc sort data = recall24hr2; by usda_id; run;
proc sort data = usdaGRP2; by usda_id; run; 
data dietfile; 
	merge recall24hr2 (in=a) usdaGRP2; 
	by usda_id; 
	if a; 
run;  * 46004 observations and 98 variables; 
proc contents data = dietfile;  run; 

*delete duplicates; 
data dietfile1a;
	set dietfile;
	trimming=trim(child_id)||trim(r24_date)||trim(time_meal)||trim(quantity)||trim(grams)||trim(food_name)||trim(energy);
		* key variables that indicate a duplicate (same date, time, amount, food, etc); 
run;
proc contents data = dietfile1a; run; 
proc print data = dietfile1a (obs=10); 
	var trimming; run; 

proc sort data=dietfile1a nodupkey;
	by trimming;
run;
* 46004 - 45663 = 341 dupes dropped; 

* identify missing usda ID data; 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\missing_grupo.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') 
;

proc sort data=dietfile1a; by child_id r24_date time_meal;
proc print data = dietfile1a; 
	where grupo = ' '; 
	var child_id menu food_name r24_group water sugar_r24 usda_id grupo subgrupo; 
run; 
* child id 267 is missing grupo data for 1 observations (usda_id = 162383824); 
ods excel close; 

* manual entry of USDA food group; 
data dietfile1b; 
	set dietfile1a; 
	* 14150  Bebidas n alcoholicas ; 
	if usda_id = 14150 then do; 
		grupo = "Bebidas"; 
		subgrupo = "No Alcohólicas"; 
		categoria = "Gaseosas"; 
		subcategoria = "No cola"; 
		tipo = "Con adición de azúcar"; 
	end; 
	else if usda_id =  14177 then do; 
		grupo = "Lácteos y sustitutos"; 
		subgrupo = "Bebidas Lácteas"; 
		categoria = "Bebida Láctea líquida"; 
		subcategoria = "Entera"; 
		tipo = "Con adición de azúcar";
	end; 	
run; 

* SAVE FINAL MERGED DIET DATASET with no DUPES!; 
data dat.finaldietnodup; 
	set dietfile1b; 
	run; 

data dietfile1; 
set dat.finaldietnodup; 
run; 
* 45663 obs; 

***** Count number of girls with 24-hour recall data; 
Proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from dietfile1;
quit;
* 516 girls; 
Proc sql;
	select 
	count (distinct survey_id) as Nr24 'Number of Distinct R24s'
	from dietfile1;
quit;


/***********************************************************************************
************************************************************************************
					3.	Categorizing: diet data 
************************************************************************************
***********************************************************************************/

/************ sugar-sweetened beverages ***************/
title; 

proc freq data = dietfile1; 
	where grupo = 'Bebidas' or grupo = 'Lácteos y sustitutos'; 
	table subgrupo categoria/ nocum; 
run; 
* rename categories with different spelling;
data dietfile1; 
	set dietfile1; 
	if categoria = 'Te' then categoria = 'Té'; 
	if categoria = 'Jugos/ Nectares y Refrescos de Frutas y verduras' then categoria = 'Jugos, Néctares y Refrescos  de Frutas y verduras'; 
	if categoria = 'Bebida Láctea líquida' then categoria = 'Bebida láctea líquida'; 
	if subgrupo = 'Bebidas Lácteas' then subgrupo = 'Bebidas lácteas'; 
	if subgrupo = 'Postres lácteos (Envasados)' then subgrupo = 'Postres lácteos (envasados)'; 
run;   
proc freq data = dietfile1;
	where categoria='Bebida láctea líquida';   
	table tipo; 
run; * Sin o Con adición de azúcar; 

*creating new data set for SSBs; 
data SSBs; set dietfile1; where grupo='Bebidas' or grupo='Lácteos y sustitutos' or grupo = 'Azúcares y golosinas';
		* flavored water; 
	if categoria='Aguas Aromatizadas/saborizadas' and tipo='Con adición de azúcar' then flavoredh2o_gsml=grams; else flavoredh2o_gsml=0;
		* unflavored water; 
	if categoria='Aguas Aromatizadas/saborizadas' and tipo='Sin adición de azúcar' then h2o_gsml=grams; 
	else if categoria='Agua sin sabor' then h2o_gsml=grams; else h2o_gsml=0;
		* sports drinks; 
	if categoria='Bebida para deportistas' then sportsdrinks_gsml=grams;  else sportsdrinks_gsml=0;
		* plain coffee; 
	if categoria='Café' and tipo='Sin adición de azúcar' then coffee_gsml=grams; else coffee_gsml=0;
		* coffee with added sugar; 
	if categoria='Café' and tipo='Con adición de azúcar' then coffeewsugar_gsml=grams; else coffeewsugar_gsml=0;
		* Sodas; 
	if categoria='Gaseosas' then totsoda_gsml=grams; else totsoda_gsml=0;
		* sugar soda; 
	if categoria='Gaseosas' and tipo='Con adición de azúcar' then soda_gsml=grams; else soda_gsml=0;
		* diet soda; 
	if categoria='Gaseosas' and tipo='Sin adición de azúcar' then dietsoda_gsml=grams; else dietsoda_gsml=0;
		* juice; 
	if categoria='Jugos, Néctares y Refrescos  de Frutas y verduras' then juice_gsml=grams; else juice_gsml=0;
		* juice w/o sugar; 
	if categoria='Jugos, Néctares y Refrescos  de Frutas y verduras' and tipo='Sin adición de azúcar' then freshjuice_gsml=grams; 
	else if categoria='Otros' then freshjuice_gsml=grams; else freshjuice_gsml=0;
		* juce w/ added sugar; 
	if categoria='Jugos, Néctares y Refrescos  de Frutas y verduras' and tipo='Con adición de azúcar' then sugarjuice_gsml=grams; else sugarjuice_gsml=0;
		* tea w added sugar; 
	if categoria='Té' and tipo='Con adición de azúcar' then teawsugar_gsml=grams; else teawsugar_gsml=0;
		* tea ; 
	if categoria='Té' then tea_gsml=grams; else tea_gsml=0;
		* milk substitutes with sugar; 
	if subgrupo='Sustitutos lácteos' and categoria='Bebidas líquidas' and tipo='Con adición de azúcar' then milksubwsugar_gsml=grams; else milksubwsugar_gsml=0; 
		* milk substitutes without sugar; 
	if subgrupo='Sustitutos lácteos' and categoria='Bebidas líquidas' and tipo='Sin adición de azúcar' then milksubwosugar_gsml=grams; else milksubwosugar_gsml=0;
		* milk with sugar; 
	if categoria='Bebida láctea líquida' and tipo='Con adición de azúcar' then milkwsugar_gsml=grams; 
	else if categoria='Bebida láctea en polvo' and tipo='Con adición de azúcar' then milkwsugar_gsml=grams; 
	else if categoria='Leche en polvo saborizada' and tipo='Con adición de azúcar' then milkwsugar_gsml=grams;
	else if categoria='Leche líquida saborizada' and tipo='Con adición de azúcar' then milkwsugar_gsml=grams;
	else if categoria='Leche en polvo saborizada preparada' and tipo='Con adición de azúcar' then milkwsugar_gsml=grams;
	else milkwsugar_gsml=0;
		* flavored beverage powder; 
	if subgrupo='Saborizantes en polvo' then flvpowder_gsml=grams; else flvpowder_gsml=0; 
		* sweetened drinkable yogurt or smoothie; 
	if subgrupo='Yogur y leche cultivada' and categoria='Leche cultivada' and tipo='Con adición de azúcar' then SwYog_gsml=grams;
	else if subgrupo='Yogur y leche cultivada' and categoria='Yogur batido natural' and tipo='Con adición de azúcar' then SwYog_gsml=grams;
	else if subgrupo='Yogur y leche cultivada' and categoria='Yogur batido sabores' and tipo='Con adición de azúcar' then SwYog_gsml=grams;
	else if subgrupo='Yogur y leche cultivada' and categoria='Yogur Bebible/líquido' and tipo='Con adición de azúcar' then SwYog_gsml=grams; else SwYog_gsml=0; 
run; 
proc contents data = SSBs; run; 
proc means data = SSBs n min  q1 mean median q3 max; 
	var h2o_gsml flavoredh2o_gsml sportsdrinks_gsml coffee_gsml coffeewsugar_gsml totsoda_gsml soda_gsml dietsoda_gsml juice_gsml freshjuice_gsml 
	sugarjuice_gsml tea_gsml teawsugar_gsml milksubwsugar_gsml milksubwosugar_gsml milkwsugar_gsml flvpowder_gsml SwYog_gsml; 
	run; 

* for each girl, get total (grams/ml) of SSB per day (ie- per recall); 
proc sort data=SSBs; by child_id r24_date;
proc  means data=SSBs noprint;
	by child_id r24_date;
	var h2o_gsml flavoredh2o_gsml sportsdrinks_gsml coffee_gsml coffeewsugar_gsml totsoda_gsml soda_gsml dietsoda_gsml juice_gsml freshjuice_gsml 
	sugarjuice_gsml tea_gsml teawsugar_gsml milksubwsugar_gsml milksubwosugar_gsml milkwsugar_gsml flvpowder_gsml day_survey;
	output out=avgSSBperDAY SUM(h2o_gsml)=TotWaterG SUM(flavoredh2o_gsml)=TotSugWaterG SUM(sportsdrinks_gsml)=TotSportBevG SUM(coffee_gsml)=TotCoffG
	SUM(coffeewsugar_gsml)=TotSCoffG SUM(totsoda_gsml)=TotSodaG SUM(soda_gsml)=TotSSodaG SUM(dietsoda_gsml)=TotDSodaG SUM(juice_gsml)=TotJuiceG
	SUM(freshjuice_gsml)=TotFJuiceG SUM(sugarjuice_gsml)=TotSJuiceG SUM(tea_gsml)=TotTea SUM(teawsugar_gsml)=TotSTea SUM(milksubwsugar_gsml)=TotSwMilkSubG 
	SUM(milksubwosugar_gsml)=TotMilkSubG SUM(milkwsugar_gsml)=TotSwMilkG SUM(flvpowder_gsml)=TotFlvPowG SUM(SwYog_gsml)=TotSwYogG MIN(day_survey)=R24day; 
run;
proc means data = avgSSBperDAY n min  q1 mean median q3 max; 
	var TotWaterG TotSugWaterG TotSportBevG TotCoffG TotSCoffG TotSSodaG TotDSodaG TotJuiceG TotFJuiceG TotSJuiceG  
			TotTea TotSTea TotMilkSubG TotSwMilkSubG TotSwMilkG TotFlvPowG TotSwYogG day; 
	run; 
data avgSSBperDAY;
	set avgSSBperDAY; 
	array SSBS TotSugWaterG TotSportBevG TotSCoffG TotSSodaG TotSJuiceG TotSTea TotSwMilkSubG TotSwMilkG TotFlvPowG TotSwYogG;
	do i=1 to 10;
	if SSBS(i)=. then SSBS(i)=0; end;
	TotSSB=TotSugWaterG+TotSportBevG+TotSCoffG+TotSSodaG+TotSJuiceG+TotSTea+TotSwMilkSubG+TotSwMilkG+TotFlvPowG+TotSwYogG; 
		*Total SSB Intake = flavored water (w/calories) + sports drinks +
		coffee w/sugar + full calorie sodas + sweet juice + tea w/sugar + milk subs w/sugar + milks /sugar + flv powder;
run;
proc print data = avgSSBperDAY (obs=10); run; 


/************ dairy  ***************/
title; 
proc freq data = dietfile1; 
	where grupo='Lácteos y sustitutos';
	table subgrupo; 
	run; 
/*exclude sugar-sweetened milks or milk-sub drinks here bc we included them in SSB */
data dairy; set dietfile1; where grupo='Lácteos y sustitutos';
	if grams>0 then fatpercent=(lipid/grams)*100;
	if fatpercent>0 and fatpercent<1.5 then lowfatdairy=grams; else lowfatdairy=0;
	if fatpercent>=1.5 then highfatdairy=grams; else highfatdairy=0;
	if subgrupo='Leche' and tipo~= 'Con adición de azúcar' then milk_gsml=grams; else milk_gsml=0;
	if subgrupo='Leche' and subcategoria='Entera' and tipo~= 'Con adición de azúcar' then wmilk_gsml=grams; else wmilk_gsml=0;
	if subgrupo='Leche' and subcategoria='Descremada' and tipo~= 'Con adición de azúcar' then smilk_gsml=grams; else smilk_gsml=0;
	if subgrupo='Leche' and subcategoria='Semidescremada' and tipo~= 'Con adición de azúcar' then rfmilk_gsml=grams; else rfmilk_gsml=0;
	if subgrupo='Yogur y leche cultivada' and tipo~= 'Con adición de azúcar'  then yogurt_gsml=grams; else yogurt_gsml=0;
	if subgrupo='Quesos' then cheese_gsml=grams; else cheese_gsml=0;
	if subgrupo='Cremas' then cream_gsml=grams; else cream_gsml=0;
	if subgrupo='Postres lácteos (envasados)' or subgrupo='Cubos de leche' or subgrupo='Helados de leche' then dairydessert_gsml=grams; else dairydessert_gsml=0;
	if subgrupo='Bebidas lácteas' and categoria~='Bebida láctea líquida' and tipo~='Con adición de azúcar' then dairybev_gsml=grams; 
	if categoria='Bebida láctea líquida' and tipo~='Con adición de azúcar' then dairybev_gsml=grams; 
	else if categoria='Bebida láctea en polvo' and tipo~='Con adición de azúcar' then dairybev_gsml=grams; 
	else if categoria='Leche en polvo saborizada' and tipo~='Con adición de azúcar' then dairybev_gsml=grams;
	else if categoria='Leche líquida saborizada' and tipo~='Con adición de azúcar' then dairybev_gsml=grams;
	else if categoria='Leche en polvo saborizada preparada' and tipo~='Con adición de azúcar' then dairybev_gsml=grams;
	else dairybev_gsml=0;
run;
proc sort data=dairy; by child_id r24_date;
proc  means data=dairy noprint; by child_id r24_date; var grams energy protein lipid carb sugar_r24 lowfatdairy highfatdairy wmilk_gsml smilk_gsml rfmilk_gsml yogurt_gsml
	dairybev_gsml cheese_gsml cream_gsml /*dairydessert_gsml*/ day_survey;
	output out=avgDAIRYperDAY SUM(grams)=TotDairyG SUM(energy)=TotDairyCAL SUM(protein)=TotDairyPRO SUM(lipid)=TotDairyFAT 
	SUM(carb)=TotDairyCARB SUM(sugar_r24)=TotDairySUG SUM(lowfatdairy)=TotLFDairyG SUM(highfatdairy)=TotHFDairyG SUM(milk_gsml)=TotMilkG
	SUM(wmilk_gsml)=TotHFMilkG SUM(smilk_gsml)=TotSMilkG SUM(rfmilk_gsml)=TotRFMilkG SUM(yogurt_gsml)=TotYogG
	SUM(dairybev_gsml)=TotDairyBevG SUM(cheese_gsml)=TotCheeseG SUM(cream_gsml)=TotCreamG SUM(dairydessert_gsml)=TotDessertG MIN(day_survey)=R24day;
run;
data avgDAIRYperDAY;
	set avgDAIRYperDAY;
	array milkv TotSMilkG TotRFMilkG;
	do i=1 to 2;
	if milkv(i)=. then milkv(i)=0; end;
	TotLFMilkG= TotSMilkG + TotRFMilkG;
run;
*1230 obs; 

/************ meat  ***************/
title; 
data meat; set dietfile1; where grupo='Carnes y sustitutos';
	if subgrupo='Sustitutos de la carne' then delete; *Deleting "Carne Vegetal" which is soy based*;
	if subgrupo='Carne no procesada' then unprocessed_gsml=grams; else unprocessed_gsml=0;
	if subgrupo='Carne procesada (envasada)' then processed_gsml=grams; else processed_gsml=0;
	if categoria='Pavo' or categoria='Pollo' then whitemeat_gsml=unprocessed_gsml; else whitemeat_gsml=0;
	if categoria='Cordero / Oveja' or categoria='Carnes' or categoria='Cerdo' or categoria='Vacuno' then redmeat_gsml=unprocessed_gsml; else redmeat_gsml=0;
run;
proc sort data=meat; by child_id r24_date;
proc  means data=meat noprint; by child_id r24_date; var grams energy protein lipid carb unprocessed_gsml processed_gsml whitemeat_gsml redmeat_gsml day_survey;
	output out=avgMEATperDAY SUM(grams)=TotMEATG SUM(energy)=TotMEATCAL SUM(protein)=TotMEATPRO SUM(lipid)=TotMEATFAT SUM(carb)=TotMEATCARB 
	SUM(unprocessed_gsml)=TotUPMeatG SUM(processed_gsml)=TotPMeatG SUM(whitemeat_gsml)=TotWMeatG SUM(redmeat_gsml)=TotRMeatG MIN(day_survey)=R24day;
run;
*1310; 

/************ macronutrients ***********/ 
title; 
proc sort data=dietfile1; by child_id r24_date;
proc  means data=dietfile1 noprint;
	by child_id r24_date;
	var water energy protein lipid fa_sat fa_mono fa_polu carb fiber sugar_r24 calcium iron magnesium phosphorus potassium sodium zinc copper 
	manganese selenium vit_c thiamin riboflavin niacin panto_acid vit_b6 folate_tot folic_acid food_folate folate_dfe choline vit_b12 
	vit_a_iu2 vit_a_rae2 retino alpha_carot beta_carot beta_crypt lycopene lutzea vit_e vit_d vit_d_iu2 vit_k cholestrl day_survey; 
	output out=avgNUTperDAY SUM(energy)=TotCAL SUM(protein)=TotPRO SUM(lipid)=TotFAT SUM(fa_sat)=TotSFA SUM(fa_mono)=TotMUFA SUM(fa_polu)=TotPUFA
	SUM(carb)=TotCARB SUM(fiber)=TotFIB SUM(sugar_r24)=TotSUG SUM(calcium)=TotCa SUM(iron)=TotIron SUM(magnesium)=TotMg SUM(phosphorus)=SUMPh 
	SUM(potassium)=TotK SUM(sodium)=TotaNa SUM(zinc)=TotZn SUM(copper)=TotCu SUM(manganese)=TotMn SUM(selenium)=TotSe SUM(vit_c)=TotVitC 
	SUM(thiamin)=TotVitB1 SUM(riboflavin)=TotVitB2 SUM(niacin)=TotVitB3 SUM(panto_acid)=TotVitB5 SUM(vit_b6)=TotVitB6 SUM(folate_tot)=TotFol
	SUM(folic_acid)=TotFolic SUM(food_folate)=TotFFol SUM(folate_dfe)=TotDFE SUM(choline)=TotChol SUM(vit_B12)=TotVitB12 SUM(vit_a_iu2)=TotVitA
	SUM(vit_a_rae2)=TotRAE SUM(retino)=TotRet SUM(alpha_carot)=TotACar SUM(beta_carot)=TotBCar SUM(beta_crypt)=TotBCrypt SUM(lycopene)=TotLyc
	SUM(lutzea)=TotLutZe SUM(vit_e)=TotVitE SUM(vit_d)=TotVitD SUM(vit_d_iu2)=TotVitDIU SUM(vit_k)=TotVitK SUM(cholestrl)=TotCholes MIN(day_survey)=R24day;
run;
*Creating percentage of calories from fat, protein, and carbs;
* https://www.nal.usda.gov/fnic/how-many-calories-are-one-gram-fat-carbohydrate-or-protein; 
data avgNUTperDAY;
	set avgNUTperDAY;
	TotFATPer=((TotFAT*9)/TotCAL)*100;  *1g fat = 9 calories; 
	TotCARBPer=((TotCARB*4)/TotCAL)*100; *1g protein = 4 cal; 
	TotPROPer=((TotPRO*4)/TotCAL)*100; *1g carb = 4 cal;
run;
*1613; 
proc means data = avgNUTperDAY; 
	var TotCal TotFATPer TotCARBPer TotPROPer; 
run; 


/**********************************************
		Checking intake per girl and per day
  ********************************************/

* Getting average intake per day; 
proc sort data=avgSSBperDAY; by child_id;
proc  means data=avgSSBperDAY noprint;
by child_id;
var TotSSB TotSugWaterG TotSportBevG TotSCoffG TotSSodaG TotJuiceG TotSTea TotSwMilkSubG TotFlvPowG;
output out=avgSSBperGIRL MEAN(TotSSB)=AvgSSB MEAN(TotSugWaterG)=AvgSugWat MEAN(TotSportBevG)=AvgSportBev MEAN(TotSCoffG)=AvgSCoff
			MEAN(TotSSodaG)=AvgSSoda MEAN(TotSJuiceG)=AvgJuice MEAN(TotSTea)=AvgSTea MEAN(TotSwMilkSubG)=AvgSwMilkSub  
			MEAN(TotSwMilkG)=AvgSwMilk MEAN(TotFlvPowG)=AvgFlvPow MEAN(TotSwYogG)=AvgSwYog;
run;

proc sort data=avgDAIRYperDAY; by child_id;
proc  means data=avgDAIRYperDAY noprint;
by child_id;
var TotDairyG TotLFDairyG TotHFDairyG TotMilkG TotHFMilkG TotSMilkG TotRFMilkG TotYogG TotDairyBevG TotCheeseG TotCreamG;
output out=avgDAIRYperGIRL MEAN(TotDairyG)=AvgDairy MEAN(TotLFDairyG)=AvgLGDairy MEAN(TotMilkG)=AvgMilk MEAN(TotYogG)=AvgYog MEAN(TotDairyBevG)=AvgDairyBev;
run; 

proc sort data=avgMEATperDAY; by child_id;
proc  means data=avgMEATperDAY noprint;
by child_id;
var TotMEATG;
output out=avgMEATperGIRL MEAN(TotMEATG)=AvgMeat;
run;

proc sort data=avgNUTperDAY; by child_id;
proc  means data=avgNUTperDAY noprint;
	by child_id;
	var TotCAL TotPRO TotFAT TotCARB TotSUG;
	output out=avgNUTperGIRL MEAN(TotCAL)=AvgCAL MEAN(TotPRO)=AvgPRO MEAN(TotFAT)=AvgFAT MEAN(TotCARB)=AvgCARB MEAN(TotSUG)=AvgSUG;
run;


* Output: Examing total and average intake per day; 
ods excel file = "C:\Users\laray\Box\Projects\2018-SSB\Analysis\Output\2021Aug08\DietIntakePerGirl.xlsx"
options(start_at="2,2" embedded_titles = 'on' sheet_interval='proc') ;
title 'Contents of raw data'; 

*SSB;
proc univariate data=avgSSBperDAY;
var TotSSB;
histogram;
Title 'Average SSB Intake Per 24-hr Recall';
run;
proc univariate data=avgSSBperGIRL;
var AvgSSB;
histogram;
Title 'Average SSB intake per Girl'; 
run;
proc sort data=avgSSBperGIRL; by child_id;
proc means data = avgSSBperGIRL n min q1 mean std median q3 max maxdec=3 stackodsoutput; 
var AvgSSB AvgSugWat AvgSportBev AvgSCoff AvgSSoda AvgJuice AvgSTea AvgSwMilkSub AvgSwMilk AvgFlvPow AvgSwYog; 
Title 'Average SSB Intake Per Girl per Day, by category'; 
run; 
proc univariate data=avgSSBperGIRL;
var AvgSwMilkSub;
histogram;
Title 'Average SweetMilkSub Intake Per Girl per Day';
run;

*DAIRY*;
proc univariate data=avgDAIRYperDAY;
var TotDairyG;
histogram;
Title 'Average Dairy Intake Per 24-hr Recall';
run;
proc univariate data=avgDAIRYperGIRL;
var AvgDairy;
histogram;
Title 'Average Dairy Per Girl';
run;

*MEAT*;
proc univariate data=avgMEATperDAY;
var TotMEATG;
histogram;
Title 'Average Meat Intake Per 24-hr Recall';
run;
proc univariate data=avgMEATperGIRL;
var AvgMeat;
histogram;
Title 'Average Meat Per Girl';
run;

* MACROs; 
proc univariate data=avgNUTperDAY;
var TotCAL;
histogram;
Title 'Average Calorie Intake Per 24-hr Recall';
run;
proc univariate data=avgNUTperGIRL;
var AvgCAL;
histogram;
Title 'Average Calorie Intake Per Girl';
run;
proc freq data=avgNUTperGIRL;
table _FREQ_;
Title 'Number of 24-hr Recalls Per Girl';
run;

ods excel close;



/***********************************************************************************
************************************************************************************
					4.	Merging and saving 
************************************************************************************
***********************************************************************************/

* SAVE per day DIET data; 
data dat.avgSSBperDAY; 
	set avgSSBperDAY; 
	run; 
data dat.avgDAIRYperDAY; 
	set avgDAIRYperDAY; 
	run; 
data dat.avgMEATperDAY; 
	set avgMEATperDAY; 
	run; 
data dat.avgNUTperDAY; 
	set avgNUTperDAY; 
	run; 

* Merge; 
proc sort data=avgNUTperDAY; by child_id;
proc sort data=avgDAIRYperDAY; by child_id; 
proc sort data=avgMEATperDAY; by child_id;
proc sort data=avgSSBperDAY; by child_id; 
run; 
data dietall;
merge avgNUTperDAY (in=b) avgDAIRYperDAY (in=c) avgMEATperDAY (in=d) avgSSBperDAY (in=e);
by child_id;

if TotDairyG=. then do; TotDairyG=0; TotDairyCAL=0; TotDairyPRO=0; TotDairyFAT=0; TotDairyCARB=0; TotLFDairyG=0; TotHFDairyG=0; TotMilkG=0; 
TotHFMilkG=0; TotLFMilkG=0; TotYogG=0; TotCheeseG=0; TotCreamG=0; TotDairyBevG=0; TotDessertG=0; end;

if TotMEATG=. then do; TotMEATG=0; TotMEATCAL=0; TotMEATPRO=0; TotMEATFAT=0; TotMEATCARB=0; end; 
if TotUPMeatG=. then TotUPMeatG=0; if TotPMeatG=. then TotPMeatG=0; if TotWMeatG=. then TotWMeatG=0; if TotRMeatG=. then TotRMeatG=0;

if TotWaterG=. then TotWaterG=0; if TotSugWaterG=. then TotSugWaterG=0; if TotSportBevG=. then TotSportBevG=0; if TotCoffG=. then TotCoffG=0;
if TotSCoffG=. then TotSCoffG=0; if TotSodaG=. then TotSodaG=0; if TotSSodaG=. then TotSSodaG=0; if TotDSodaG=. then TotDSodaG=0;       
if TotJuiceG=. then TotJuiceG=0; if TotFJuiceG=. then TotFJuiceG=0; if TotSJuiceG=. then TotSJuiceG=0; if TotTea=. then TotTea=0; 
if TotSTea=. then TotSTea=0; if TotSwMilkSubG=. then TotSwMilkSubG=0; if TotSwMilkG=. then TotSwMilkG=0; if TotFlvPowG=. then TotFlvPowG=0; 
if TotSSB=. then TotSSB=0; if TotSwYogG = . then TotSwYogG = 0; 

if b then nut = 1; else nut=0; 
if c then dairy = 1; else dairy=0; 
if d then meat = 1; else meat=0; 
if e then ssb = 1; else ssb=0; 

run;

proc sql;
	select 
	count (distinct child_id) as NGirls 'Number of Girls'
	from dietall;
quit; * 516; 

proc print data = dietall (obs=20); 
run; 

* Save final diet data; 
data dat.avgDIETperDAY; 
	set dietall; 
	run; 
