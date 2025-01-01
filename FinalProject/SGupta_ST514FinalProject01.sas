************************************************;
*Author: Group B                                ;                                              
*Collaborators:  Saurabh Gupta,                 ;
*Program Purpose: ST 514 Final project          ;
*Date: 28 Apr 2024                              ;                                     
************************************************;

************************************************
#2 Predict whether coupons are accepted (Y=1 vs. Y=0) based on other variables.
Selected coupon dataset attributes - 
1- coupon - Bar, Carry out & Take away, Coffee House, Restaurant(20-50), Restaurant(<20)
2- expiration - 1d, 2h
3- time -  10AM , 10PM , 2PM , 6PM , 7AM
4- destination - Home , No Urgent Place , Work
5- direction_same - 0 , 1
6- direction_opp - 0, 1
7- weather - Rainy, Snowy, Sunny
8- temperature - 30, 55, 80
9 - maritalStatus - Divorced , Married partner , Single , Unmarried partner , Widowed
10 - income - 
	$100000 or More
	$12500 - $24999
	$25000 - $37499
	$37500 - $49999
	$50000 - $62499
	$62500 - $74999
	$75000 - $87499
	$87500 - $99999
	Less than $1250
	
contingency tables - 
1- Y * coupon
2- Y * time * destination
3- Y * expiration * direction_same
4- Y * expiration * direction_opp
5- Y * weather * temperature
6- Y * maritalStatus * income
	
Logistic Model 1 variables - 
coupon, time, expiration,  weather, temperature, 
time * expiration, weather * temperature

Logistic Model 2 variables - 
coupon, expiration,  direction_same, direction_opp,  

Logistic Model 3 variables - 
coupon,  maritalStatus, income,  maritalStatus * income
************************************************;

LIBNAME ST514 '/home/u63409250/sasuser.saurabh.v94/ST514';
* Declare the PDF output file ;
ods pdf file="/home/u63409250/sasuser.saurabh.v94/ST514FinalProjectLogisticResults.pdf"; 
ods graphics on;

/* Importing first file */
FILENAME REFFILE '/home/u63409250/sasuser.saurabh.v94/FinalProject/in-vehicle-coupon-recommendation.csv';
PROC IMPORT datafile=REFFILE
            out=FinalProject
            DBMS=CSV;
            GETNAMES=YES;
RUN;


DATA FinalProject ;
	set FinalProject ;
	if income = 'Less than $1250' then incomerange = 'minimal';
	if income = '$12500 - $24999' then incomerange = 'very low';
	if income = '$25000 - $37499' then incomerange = 'low';
	if income = '$37500 - $49999' then incomerange = 'lower middle';
	if income = '$50000 - $62499' then incomerange = 'middle';
	if income = '$62500 - $74999' then incomerange = 'upper middle';
	if income = '$75000 - $87499' then incomerange = 'lower high';
	if income = '$87500 - $99999' then incomerange = 'high';
	if income = '$100000 or More' then incomerange = 'upper high';
RUN;

PROC SQL;
    SELECT distinct  coupon
    FROM FinalProject;
RUN;

/* Convert Y to Coupon_accepted binary outcome */
data FinalProject;
    set FinalProject;
    if Y = '1' then Coupon_accepted = 1;
    else Coupon_accepted = 0;
run;

/*******************************************************************/
/* predictor variables - expiration  coupon type                   */
/*******************************************************************/


PROC FREQ data=FinalProject;
    TABLES  Coupon_accepted * coupon * expiration /
    CHISQ NOROW NOCOL NOPERCENT
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

proc logistic data=FinalProject ALPHA=0.05
    PLOTS(ONLY)=(effect oddsratio);
    CLASS coupon(REF='Restaurant(<20)') / PARAM=reference;
    CLASS expiration(REF='2h') / PARAM=reference;
    model Coupon_accepted(event='1') = coupon expiration / 
                                      clodds=pl;
run; 

PROC GENMOD DATA=FinalProject;
	CLASS coupon(REF='Restaurant(<20)') / PARAM=reference;
	CLASS expiration(REF='2h') / PARAM=reference;
	MODEL Coupon_accepted= coupon expiration;
	BAYES COEFFPRIOR=UNIFORM;
RUN;

/*******************************************************************/
*NULL Hypothesis - Coupon acceptance and expiration date are independed events
*Alternate Hypothesis - Coupon acceptance and expiration date events has some relationship 

*ANALYSIS - 
*The Chi-Square Test indicates that there is a significant relationship between 
coupon expiration and coupon acceptance, even after controlling for whether 
the coupon was accepted or not.
*Likelihood Ratio also indicates a highly significant relationship between 
coupon expiration and coupon acceptance.

*For Mantel-Haenszel Chi-Square, the very low p-value indicates a 
significant relationship between coupon expiration and coupon acceptance.

*Overall, these statistics collectively indicate that both 'coupon' and 'expiration' variables 
significantly influence the outcome, with the model providing a good fit to the data. 
*The odds ratios further quantify the strength and direction of these relationships.
/*******************************************************************/

/*******************************************************************/
/* predictor variables - expiration  direction_opp direction_same  */
/*******************************************************************/;


PROC FREQ data=FinalProject;
    TABLES Coupon_accepted  * toCoupon_GEQ15min * direction_same / 
    CHISQ EXPECTED CELLCHI2 RELRISK NOCOL NOPERCENT
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

PROC FREQ data=FinalProject;
    TABLES Coupon_accepted  * toCoupon_GEQ15min * direction_opp / 
    CHISQ EXPECTED CELLCHI2 RELRISK NOCOL NOPERCENT
    PLOTS(ONLY)=freqplot(SCALE=percent);
RUN;

*** Selected model for final report *** ; 

proc logistic data=FinalProject ALPHA=0.05
    PLOTS(ONLY)=(effect oddsratio);
    CLASS expiration(REF='2h') / PARAM=reference;
    CLASS toCoupon_GEQ15min(REF='1') / PARAM=reference;
    model Coupon_accepted(event='1') = expiration direction_same  toCoupon_GEQ15min / 
                                      clodds=pl;
run;


/*******************************************************************/
*NULL Hypothesis - coupon acceptance and driving distance in same direction are independed events
*Alternate Hypothesis - coupon acceptance and driving distance in same direction events has some association to each other 

*NUll Hypothesis - coupon acceptance and driving distance in opposite direction events has some relationship 
*Alternate Hypothesis - coupon acceptance and driving distance in oppostie direction has some association to each other 

feature meaning: driving distance to the restaurant/bar for using the coupon is greater than 15 minutes)

*ANALYSIS - 

/*******************************************************************/


/***************************************************************/
/* predictor variables - weather temperature time destination  */
/***************************************************************/;

PROC FREQ data=FinalProject;
    TABLES Coupon_accepted * time * destination  / 
    EXPECTED NOROW NOCOL NOPERCENT CHISQ   RELRISK ;
RUN;

PROC FREQ data=FinalProject;
    TABLES Coupon_accepted * weather * temperature / 
    EXPECTED NOROW NOCOL NOPERCENT CHISQ   RELRISK ;
RUN;

*** Selected model for final report *** ; 

proc logistic data=FinalProject ALPHA=0.05
    PLOTS(ONLY)=(effect oddsratio);
    CLASS coupon(REF='Restaurant(20-50)') / PARAM=reference;
    class weather(REF='Rainy') / PARAM=reference;
    class temperature(REF='55') / PARAM=reference;
    class time(REF='6PM') / PARAM=reference;
    class destination(REF='Home') / PARAM=reference;
    model Coupon_accepted(event='1') =  coupon  weather * temperature time * destination / 
                                      clodds=pl;
run;

/***************************************************/
/* predictor variables - maritalstatus incomerange */
/***************************************************/

PROC FREQ data=FinalProject;
    TABLES Coupon_accepted * incomerange * maritalstatus / 
    NOROW NOCOL NOPERCENT CHISQ   RELRISK ;
RUN;


PROC LOGISTIC DATA=FinalProject ALPHA=0.05
PLOTS(ONLY)=(effect oddsratio);
CLASS coupon(REF='Restaurant(20-50)') / PARAM=reference;
CLASS maritalstatus(REF='Married partner') / PARAM=reference;
CLASS incomerange(REF='middle') / PARAM=reference;
MODEL Coupon_accepted(EVENT='1') =   coupon maritalstatus incomerange  / CLODDS=pl;
RUN;

/***************************************************/
/* predictor variables - Multiple                  */
/***************************************************/

PROC LOGISTIC DATA=FinalProject ALPHA=0.05
PLOTS(ONLY)=(effect oddsratio);
CLASS coupon(REF='Restaurant(20-50)') / PARAM=reference;
CLASS destination(REF='Home') / PARAM=reference;
CLASS time(REF='6PM') / PARAM=reference;
CLASS direction_same(REF='1') / PARAM=reference;
CLASS direction_opp(REF='1') / PARAM=reference;
CLASS expiration(REF='2h') / PARAM=reference;
CLASS weather(REF='Rainy') / PARAM=reference;
CLASS toCoupon_GEQ15min(REF='1') / PARAM=reference;
CLASS coupon(REF='Restaurant(20-50)') / PARAM=reference;
CLASS temperature(REF='55') / PARAM=reference;
MODEL Coupon_accepted(EVENT='1') = coupon destination  time toCoupon_GEQ15min 
                      direction_same direction_opp
                      expiration weather coupon temperature
                      Weather * temperature 
                      Time*expiration  / CLODDS=pl;
RUN;

ods graphics off;
/* Close PDF file */
ods pdf close;

QUIT;

