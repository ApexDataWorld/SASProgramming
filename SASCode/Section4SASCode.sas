**************************
*SAS code from section 4
**************************;

*Slide 79;
proc reg data=ST514.Emissions_High;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR;
run;
quit;

*slide 81;
proc genmod data=ST514.Emissions_High;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR;
   bayes coeffprior=uniform;
run;


*slide 108;
data ST514.Emissions;
   set ST514.Emissions;
   ODOMETER_K = ODOMETER/1000;
run;

proc standard data=ST514.Emissions out=ST514.Emissions_STD 
              mean=0 std=1;
   var ODOMETER_K MODEL_YEAR;
run;

proc reg data=ST514.Emissions_STD outest=Betas covout;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR;
run;
quit;

*slide 110;
data Betas;
   set Betas;
   if _TYPE_ = 'PARMS' then _TYPE_ = 'MEAN';
run;

proc standard data=ST514.Emissions_High 
              out=ST514.Emissions_High_Bayes mean=0 std=1;
   var ODOMETER_K MODEL_YEAR;
run;

proc genmod data=ST514.Emissions_High_Bayes;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR;
   bayes coeffprior=normal(input=Betas);
run;
