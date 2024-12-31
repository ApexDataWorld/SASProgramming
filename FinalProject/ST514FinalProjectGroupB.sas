************************************************;
*Author:  Saurabh Gupta                         ;
*Collaborators:                                 ;
*Program Purpose: ST 514 Final Project          ;
*Date: 02-May-2024                              ;
************************************************;

************************************************;
*This section is documenting the creation of the library and data import after upload to SAS; 

LIBNAME ST514 '/home/u63546043/ST514';

Filename REFILE '/home/u63546043/ST514/in-vehicle-coupon-recommendation.csv';

PROC IMPORT DATAFILE = '/home/u63546043/ST514/in-vehicle-coupon-recommendation.csv'
	DBMS = csv
	OUT = ST514.FinalProject;
	GETNAMES = YES;
	GUESSINGROWS=2000;
RUN;

*Data successfully imported with PROC IMPORT;
************************************************;

************************************************;
*Recoding variables for analysis. Coupon categories are given specific designations, age is being converted into ranges,
occupation is condensed to four levels, income is set to specific value points, marital status and children are being combined to determine
if person lives alone or not, passanger variable is condensed to provide outputs on whether the person is alone/withkids/withadults,
Y is converted to coupon_accepted with responses 0 and 1;

DATA ST514.FinalProject;
	SET ST514.FinalProject;
	IF coupon = 'Bar' THEN couponnum = 1;
	IF coupon = 'Carry out & Take away' THEN couponnum = 2;
	IF coupon = 'Coffee House' THEN couponnum = 3;
	IF coupon = 'Restaurant(20-50)' THEN couponnum = 4;
	IF coupon = 'Restaurant(<20)' THEN couponnum = 5;
	IF income = '$37500 - $49999' THEN incomemid = 43749.5;
	IF income = '$62500 - $74999' THEN incomemid = 68749.5;
	IF income = '$12500 - $24999' THEN incomemid = 18749.5;
	IF income = '$75000 - $87499' THEN incomemid = 81249.5;
	IF income = '$50000 - $62499' THEN incomemid = 56249.5;
	IF income = '$25000 - $37499' THEN incomemid = 31249.5;
	IF income = '$100000 or More' THEN incomemid = 100000;
	IF income = '$87500 - $99999' THEN incomemid = 93749.5;
	IF income = 'Less than $12500' THEN incomemid = 12500;
	IF (age = "below21") THEN agegroup = "below21";
	IF (age = "21") OR (age = "26") THEN agegroup = "21 - 30";
	IF (age = "31") OR (age = "36") THEN agegroup = "31 - 40";
	IF (age = "41") OR (age = "46") THEN agegroup = "41 - 50";
	IF (age = "50plus") THEN agegroup = "50plus";	
	IF (occupation = "Student") THEN employment = "Student";
	ELSE IF (occupation = "Retired") THEN employment = "Retired";
	ELSE IF (occupation = "Unemployed") THEN employment = "Unemployed";
	ELSE employment = "Employed";
	IF maritalStatus = 'Divorced' AND has_children = '0' THEN livesalone = '1';
	IF maritalStatus = 'Divorced' AND has_children = '1' THEN livesalone = '0';
	IF maritalStatus = 'Married partner' AND has_children = '1' THEN livesalone = '0';
	IF maritalStatus = 'Married partner' AND has_children = '0' THEN livesalone = '0';
	IF maritalStatus = 'Unmarried partner' AND has_children = '1' THEN livesalone = '0';
	IF maritalStatus = 'Unmarried partner' AND has_children = '0' THEN livesalone = '0';
	IF maritalStatus = 'Single' AND has_children = '1' THEN livesalone = '0';
	IF maritalStatus = 'Single' AND has_children = '0' THEN livesalone = '1';
	IF maritalStatus = 'Widowed' AND has_children = '1' THEN livesalone = '0';
	IF maritalStatus = 'Widowed' AND has_children = '0' THEN livesalone = '1';
	IF passanger = 'Alone' THEN passcat = 'solo';
	IF passanger = 'Friend(s)' THEN passcat = 'adult';
	IF passanger = 'Kid(s)' THEN passcat = 'wkids';
	IF passanger = 'Partner' THEN passcat = 'adult';
	IF Y = '1' THEN Coupon_accepted = 1;
    ELSE Coupon_accepted = 0;
RUN;

*Data step successfully manipulated and created variables;
************************************************;

************************************************;
*Generating basic demographics information;

PROC FREQ DATA = ST514.FinalProject;
	TABLES gender*agegroup*livesalone gender*agegroup*employment;
RUN;

*Using proc freq to understand how age, marital status, children status, and gender are related;
************************************************;

************************************************;
*Generating income information;

PROC FREQ DATA = ST514.FinalProject;
	TABLES gender*income*agegroup gender*income*employment livesalone*income;
RUN;

*Using proc freq to understand how age, employment, and living condition affect income ranges for each gender;
************************************************;

************************************************;
*MLR stepwise analysis and hypothesis test;

proc glmselect	data=ST514.FinalProject outdesign=model;
	class education (ref='Some college - no degree') employment (ref='Unemplo') gender (ref='Female')/ param = ref;
	model incomemid = education gender employment / selection = stepwise details=steps select=SL
														SLstay = 0.05 SLentry = 0.05;
run;

proc reg data=model;
	model incomemid = &_GLSMOD / best = 5;
run;
	
proc logistic data=ST514.finalproject alpha=0.05
              plots(only)=(effect oddsratio);
   class education(ref='Some college - no degree') / param=reference;
   model incomemid (event='P') = education / 
                                      clodds=pl;
run;
*Evaluating how education, gender, and employment impact income for the surveyed group compared to an unemployed female with some college education;
************************************************;

************************************************;
*Model 1 predictor variables - expiration  direction_opp direction_same;

PROC FREQ data= ST514.FinalProject;
    TABLES Coupon_accepted  * toCoupon_GEQ15min * direction_same / 
   	CHISQ EXPECTED NOROW NOCOL NOPERCENT  RELRISK 
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

PROC FREQ data=ST514.FinalProject;
    TABLES Coupon_accepted  * toCoupon_GEQ15min * direction_opp / 
    CHISQ EXPECTED NOROW NOCOL NOPERCENT  RELRISK 
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

proc logistic data=ST514.FinalProject ALPHA=0.05
    PLOTS(ONLY)=(effect oddsratio);
    CLASS expiration(REF='2h') / PARAM=reference;
    CLASS direction_same(REF='1') / PARAM=reference;
    CLASS toCoupon_GEQ15min(REF='1') / PARAM=reference;
    model Coupon_accepted(event='1') = expiration direction_same toCoupon_GEQ15min / 
                                      clodds=pl;
run;

*Successful creation of multiple logistic regression model. Evaluating coupon acceptance as determined by 
driving direction, detour duration, and coupon expiration time;
************************************************;

************************************************;
*Model 2 predictor variables - coupon weather temperature time destination;

PROC FREQ data=ST514.FinalProject;
    TABLES Coupon_accepted * time * destination  / 
    CHISQ EXPECTED NOROW NOCOL NOPERCENT  RELRISK 
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

PROC FREQ data=ST514.FinalProject;
    TABLES Coupon_accepted * weather * temperature / 
    CHISQ EXPECTED NOROW NOCOL NOPERCENT  RELRISK 
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

proc logistic data=ST514.FinalProject ALPHA=0.05
    PLOTS(ONLY)=(effect oddsratio);
    CLASS coupon(REF='Restaurant(20-50)') / PARAM=reference;
    class weather(REF='Rainy') / PARAM=reference;
    class temperature(REF='55') / PARAM=reference;
    class time(REF='6PM') / PARAM=reference;
    class destination(REF='Home') / PARAM=reference;
    model Coupon_accepted(event='1') =  coupon  weather * temperature time * destination / 
                                      clodds=pl;
run;

*Successful creation of multiple logistic regression model. Evaluating coupon acceptance as determined by
type of coupon, weather, temperature, time of day, and driving destination;
************************************************;

************************************************;
*END OF CODE;
************************************************;

