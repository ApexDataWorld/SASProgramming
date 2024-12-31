**************************
*SAS code from section 3
**************************;

*Slide 47;
proc reg data=ST514.Emissions_High;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR;
run;
quit;

*Slide 76;
proc reg data=ST514.Emissions_High;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR / CLB;
run;
quit;

*Slide 85;
data ST514.Emissions_High; 
	set ST514.Emissions_High;
	X1 = RANNOR(4321); 
	X2 = RANNOR(321);
	X3 = RANNOR(21);
run;

proc reg data=ST514.Emissions_High;
	Original: model E_HIGH_CO = ODOMETER_K MODEL_YEAR;
	New1: model E_HIGH_CO = ODOMETER_K MODEL_YEAR X1;
	New2: model E_HIGH_CO = ODOMETER_K MODEL_YEAR X1 X2;
	New3: model E_HIGH_CO = ODOMETER_K MODEL_YEAR X1 X2 X3;
run;
quit;

*Slide 102;
proc sgplot data=ST514.Emissions_High;
	scatter x=CYL y=E_HIGH_CO;
run;

proc sgplot data=ST514.Emissions_High;
	reg x=CYL y=E_HIGH_CO / degree=1;
	reg x=CYL y=E_HIGH_CO / degree=2;
run;

*Slide 105;
data ST514.Emissions_High; 
	set ST514.Emissions_High;
	CYL2 = CYL**2;
run;

proc reg data=ST514.Emissions_High;
	model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL2;
run;
quit;

*Slide 115;
proc standard data=ST514.Emissions_High  
              out=ST514.Emissions_HighSTD mean=0 std=1;
   var CYL;
run;

data ST514.Emissions_HighSTD; 
   set ST514.Emissions_HighSTD;
   CYL2 = CYL**2;
run;

proc reg data=ST514.Emissions_HighSTD;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL2;
run;
quit;

*Slide 139;
proc glmselect data=ST514.Emissions_HighSTD;
   class TRANS_TYPE(ref='M') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL2 TRANS_TYPE / 
                     selection=none;
run;

*Slide 158;
proc glmselect data=ST514.Emissions_HighSTD;
   class TRANS_TYPE(ref='M') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL2 TRANS_TYPE                     TRANS_TYPE*ODOMETER_K / selection=none;
run;


*Slide 172;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL2 TRANS_TYPE                      TRANS_TYPE*ODOMETER_K / selection=none;
run;

proc reg data=model;
   model E_HIGH_CO = &_GLSMOD;
   test CYL = 0, CYL2 = 0;
run;
quit;


*Slide 192;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL 
                     TRANS_TYPE TRANS_TYPE*ODOMETER_K 
                     DUAL_EXHAUST /                      selection=stepwise details=steps select=SL                      slstay=0.025 slentry=0.025                      hierarchy=single;
run;


*Slide 196;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL 
                     TRANS_TYPE TRANS_TYPE*ODOMETER_K 
                     DUAL_EXHAUST /                      selection=stepwise details=steps select=BIC                      hierarchy=single;
run;


*Slide 200;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL 
                     TRANS_TYPE TRANS_TYPE*ODOMETER_K 
                     DUAL_EXHAUST /                      selection=forward details=steps select=SL                      slentry=0.025 hierarchy=single;
run;


*Slide 209;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL 
                     TRANS_TYPE TRANS_TYPE*ODOMETER_K 
                     DUAL_EXHAUST /                      selection=backward details=steps select=SL                      slstay=0.025 hierarchy=single;
run;


*Slide 225;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL                      TRANS_TYPE TRANS_TYPE*ODOMETER_K                      DUAL_EXHAUST / selection=none;
run;

proc reg data=model;
   R2: model E_HIGH_CO = &_GLSMOD / selection=rsquare best=3;
   AR2: model E_HIGH_CO = &_GLSMOD / selection=adjrsq best=3;
run;
quit;

*Slide 240;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL                      TRANS_TYPE TRANS_TYPE*ODOMETER_K                      DUAL_EXHAUST / selection=none;
run;

proc reg data=model;
   Cp: model E_HIGH_CO = &_GLSMOD / selection=cp best=5;
run;
quit;


*Slide 254;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL                      TRANS_TYPE TRANS_TYPE*ODOMETER_K                      DUAL_EXHAUST / selection=none;
run;

proc reg data=model;
   model E_HIGH_CO = &_GLSMOD / vif;
run;
quit;


*Slide 283;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL                      TRANS_TYPE TRANS_TYPE*ODOMETER_K                      DUAL_EXHAUST / selection=none;
run;

proc reg data=model;
   model E_HIGH_CO = &_GLSMOD / p;
run;
quit;

*Slide 309;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model LN_E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL 
                        TRANS_TYPE TRANS_TYPE*ODOMETER_K /  
                        selection=none;
run;

proc reg data=model plots=diagnostics(unpack);
   model LN_E_HIGH_CO = &_GLSMOD / p;
run;
quit;


*Slide 315;
data ST514.Emissions_HighSTD;
   set ST514.Emissions_HighSTD;
   LN_E_HIGH_CO = log(E_HIGH_CO);
run;

proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model LN_E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL                         TRANS_TYPE TRANS_TYPE*ODOMETER_K /  
                        selection=none;
run;


*Slide 318;
data ST514.Emissions_HighSTD;
   set ST514.Emissions_HighSTD;
   LN_E_HIGH_CO = log(E_HIGH_CO);
run;

proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model LN_E_HIGH_CO = ODOMETER_K MODEL_YEAR / selection=none;
run;

*Slide 335;
proc glmselect data=ST514.Emissions_HighSTD outdesign=model;
   class TRANS_TYPE(ref='M') DUAL_EXHAUST(ref='N') / param=ref;
   model LN_E_HIGH_CO = ODOMETER_K MODEL_YEAR / selection=none;
run;

proc reg data=model plots=(diagnostics(unpack) dfbetas dffits);
   model LN_E_HIGH_CO = &_GLSMOD / r influence;
run;
quit;

*Slide 351;
proc reg data=ST514.Sales35 plot(unpack)=residuals;
   model Sales = T / dw dwProb;
run;
quit;




