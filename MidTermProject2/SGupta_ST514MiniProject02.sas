************************************************;
*Author: Saurabh Gupta                          ;                                              
*Collaborators: None                            ;                                 
*Program Purpose: ST 514 Mini project 1         ;
*Date: START 24 Feb 2024 END 04 Mar 2024        ;                                     
************************************************;

* Define the Emissions CSV data file path ;
FILENAME REFFILE '/folders/myfolders/ST514/Emissions-Alb.csv';

* Declare the PDF output file ;
ods pdf file="/home/u63409250/sasuser.saurabh.v94/ST514MiniProject02Results.pdf"; 
ods graphics on;

* Create SAS dataset ST514.Emissions_High by importing data from the Emissions CSV file;
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=Emissions;
	GETNAMES=YES;
RUN;

/* Problem 1 */

/* The following DATA statement removes all records from the dataset that has 
E_HIGH_CO2 as zero value and creates a new dataset in which non-zero E_HIGH_CO2 records*/

DATA Emissions_High;
   SET Emissions;
   IF E_HIGH_CO2 eq 0 THEN delete;
RUN;

DATA Emissions_High;
  SET Emissions_High;
  ODOMETER_K = ODOMETER/1000; 
RUN;

/*
Following the STANDARD statement standardizes the CYL variable to have a mean of 0 and a 
the standard deviation of 1, like a Z score.
*/

PROC STANDARD DATA=Emissions_High OUT=Emissions_HighSTD MEAN=0 STD=1;
VAR CYL; 
RUN;

/*
The following statement creates a new variable in the dataset which is a quadratic term for 
CYL (squared value). 
*/

DATA Emissions_HighSTD; 
SET Emissions_HighSTD; CYL2 = CYL**2;
RUN;

/*Following REG statement will go the linear regression analysis and will give the 
output of regression coefficients, standard errors, significance tests, 
and other relevant statistics for assessing the fit of the model. */
PROC REG DATA=Emissions_HighSTD;
MODEL E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL2;
RUN; 

/* Problem 2 a */

/*Following statement creates a new variable LNP_E_HIGH_CO and assigns it the 
natural logarithm of the variable E_HIGH_CO plus a small constant (0.005). 
The purpose of adding the constant is to prevent taking the logarithm of zero, 
as the logarithm of zero is undefined.*/ 
DATA Emissions_HighSTD;
SET Emissions_HighSTD; 
LNP_E_HIGH_CO = LOG(E_HIGH_CO + 0.005);
RUN;

/* Problem 2 b */
/*  The following GLMSELECT statement takes the input dataset as Emissions_HighSTD and requests. 
The output design matrix is to be saved in a dataset named model.
The model input variables contain the interaction of transmission and odometer. 
As per model hierarchy, keep both variables in the model if the interaction is significant.  
SELECTION=none option indicates that no variable selection is performed. 
All specified variables are included in the model.*/ 
PROC GLMSELECT DATA=Emissions_HighSTD OUTDESIGN=model; 
CLASS TRANS_TYPE(REF='M') DUAL_EXHAUST(REF='N') / PARAM=ref; 
MODEL LNP_E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL
                        TRANS_TYPE TRANS_TYPE*ODOMETER_K /
                        SELECTION=none;
RUN; 
 
PROC REG DATA=model PLOTS=DIAGNOSTICS(UNPACK); 
MODEL LNP_E_HIGH_CO = &_GLSMOD / P;
RUN; 

/* Analysis
The model here contains 343 observations. The model in notes on page 320 has 289 observations 
because the natural log did not account for the zero values in the notes. If the reading in the dataset is 0, 
then the natural log of 0 is undefined or negative infinity. SAS report it missing. That's why 
notes have fewer observations than the mini project 02 SAS code model. We used 0.005 offset here 
to retail all the observations. Otherwise, some of them have been dropped from analysis if the offset was not used. 

Also the mini proj 02 model has 6 predictor variables - ODOMETER_K MODEL_YEAR CYL CYL*CYL
TRANS_TYPE TRANS_TYPE*ODOMETER_K whereas model in notes page 320 has only 2 predictor variables 

The scatterplot for residuals vs predicted values in notes page 320 or the mini proj 02 model 
shows eros are more spread out as natural logarithmic damp the effect. 
The spread looks better and quite random. It's just both the compared models have different 
observations and different predictors, but there is no long-going tail or skewness or asymmetry.  

As per The linear regression model, CYL(0.8822) CYL*CYL(0.2206) TRANS_TYPE(0.3243) TRANS_TYPE*ODOMETER_K(0.5523) 
predictors are insignificant even when adding an offset of 0.005 in the mini porj 02 models. 
This could be due to the scale of offset being relatively large in comparison to range of predictor variables 
or maybe the collinearity between predictors. 
The 4 predictors CYL(0.8822) CYL*CYL(0.2206) TRANS_TYPE(0.3243) TRANS_TYPE*ODOMETER_K(0.5523) 
can be removed from model, and only two may retain ODOMETER_K(0.0086) and MODEL_YEAR(0.0294)
*/
 

 /* Problem 2 c */
/* 
The following statement will give the cook's D data on the model generated here .
Cook’s D measures the influence of each observation on the estimated coefficients:
R is for residuals, and INFLUENCE is for the influence of each observation on the coefficients. 
mini project 02 model still has 343 observations and 6 predictors, whereas the model in notes has only 2 predictors and possibly fewer observations. 

The combined coefficient of 6 predictors would certainly be different than the combined coefficient of 2 observations. 
Cook's D plot on page 336 of notes has a high residual for only ONE observation ~135. 
Meanwhile, the mini project model clearly has few other observation points (SAS reports outliers more than 2 std deviations away). 

The studentied residual and cook D table can also be used here to anlayze the observations which are more than 2 std. dev. away and closer to 3. 
The LNP_E_HIGH_CO response variable is standardised to fit in the model. so the outliers are evaluated on the scale of -3,-2,-1,0,1,2,3.
The parallel line to the axis shows the baseline for outliers, and anything going higher than that parallel baseline is considered an outlier.

Observation 137 is still a peak in mini proj 02  with a cook's D value of 0.072 and this is much higher than 3 std dev which is 0.03 or 0.02 in SAS
The natural logarithmic value for the response variable does not fit in our model with an offset of 0.005. This has impacted the coefficients and statistics of our model.
Without 0.005 offsets, the D's value for 137 observation is 0.144. 

The log transformation on the response variable (dependent variable) can impact the distribution of residuals (making the residuals more homoscedastic). 
Cook's D is sensitive to the residuals, and changes in the distribution or variance of residuals can affect the calculation of Cook's D. 
In some cases, a log transformation may reduce the influence of outliers, leading to smaller Cook's D values for specific observations.
The offset affects the linear predictor. Cook's D is more concerned with influence, but if the offset changes the scale of the linear predictor,  
it will indirectly impact the cook's D value as well. */

PROC REG DATA=model PLOTS=DIAGNOSTICS(UNPACK); 
MODEL LNP_E_HIGH_CO = &_GLSMOD / R;
RUN; 

/* Problem 3 a */


/* stepwise variable selction by setting the significance levels for variable selection 
and retention in the model.
*/

PROC GLMSELECT DATA=Emissions_HighSTD OUTDESIGN=model; 
CLASS TRANS_TYPE(REF='M') DUAL_EXHAUST(REF='N') / PARAM=ref;
MODEL LNP_E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL TRANS_TYPE TRANS_TYPE*ODOMETER_K DUAL_EXHAUST
E_HIGH_RPM E_HIGH_CO2 E_HIGH_O2 E_HIGH_HC E_HIGH_DCF E_HIGH_HC_LIMIT/
SELECTION=stepwise DETAILS=steps select=SL slstay=0.005 slentry=0.005 HIERARCHY=single;
title 'Stepwise Selection Analysis of Variance and Regression Table';
RUN;

/* Analysis - 
The selected model is the model at the last step (Step 2).
Effects:	Intercept ODOMETER_K E_HIGH_HC
Estimated coefficient for ODOMETER_K is 0.003327 and E_HIGH_HC is 0.007645
*/

/* Problem 3 b */

/* May have also used BACKWARD and FORWARD options in SELECTION parameter here 
I have created different models here as part of subset regression modelling: R2, AR2 and CV
 */


PROC GLMSELECT DATA=Emissions_HighSTD OUTDESIGN=model; 
CLASS TRANS_TYPE(REF='M') DUAL_EXHAUST(REF='N') / PARAM=ref;
MODEL LNP_E_HIGH_CO = ODOMETER_K MODEL_YEAR CYL CYL*CYL TRANS_TYPE TRANS_TYPE*ODOMETER_K DUAL_EXHAUST
E_HIGH_RPM E_HIGH_CO2 E_HIGH_O2 E_HIGH_HC E_HIGH_DCF E_HIGH_HC_LIMIT/
SELECTION=none ;
RUN;

/*
SAS Calculate R2 from each one of predictor variables and rank them from highest to lowest 
Here best three of those are reorted. 
SAS will build every single possible cobination of variable and report best three in each number of variables
AR2 - top three models in terms of Adjusted R square. 
CP - Best of total mean square error. Rank from lowest cp to highest. 
*/

proc reg data=model;
   R2: model LNP_E_HIGH_CO = &_GLSMOD / selection=rsquare best=3;
   AR2: model LNP_E_HIGH_CO = &_GLSMOD / selection=adjrsq best=3;
   Cp: MODEL LNP_E_HIGH_CO = &_GLSMOD / SELECTION=cp BEST=5;
run;

/*
Analysis - 
3a final model has ODOMETER_K and E_HIGH_HC variables only. R2 with same 2 variables 
ODOMETER_K E_HIGH_HC is	0.1983. It is same as in 3a. 
Stepwise or subset R2 regression model values is differnt for same number of predictor variables in final model. 
*/

/* Problem 3 c */

/*The higest number of adjusted R2 has 8 variables in model - 
Number in Model | Adjusted R-Square | R-Square  |  Variables in Model
____________________________________________________________________
        8	            0.3762	       0.3908	   TRANS_TYPE A ODOMETER_*TRANS_TYPE A DUAL_EXHAUST Y 
                                                   E_HIGH_CO2 E_HIGH_O2 E_HIGH_HC E_HIGH_DCF E_HIGH_HC_LIMIT

*/

proc glmselect data=Emissions_HighSTD OUTDESIGN=mymodel;
   CLASS TRANS_TYPE(REF='A') DUAL_EXHAUST(REF='Y')  / PARAM=ref;
   MODEL LNP_E_HIGH_CO = TRANS_TYPE ODOMETER_K*TRANS_TYPE DUAL_EXHAUST 
   E_HIGH_CO2 E_HIGH_O2 E_HIGH_HC E_HIGH_DCF E_HIGH_HC_LIMIT / selection=none;
run;

/*
TRANS_TYPE 0.3341 
ODOMETER_K*TRANS_TYPE 0.4780
DUAL_EXHAUST 0.0551 
E_HIGH_CO2 <.0001
E_HIGH_O2 0.2530
E_HIGH_HC <.0001
E_HIGH_DCF <.0001
E_HIGH_HC_LIMIT. 0.4606

The adjusted R2 is how well the independent variables explain the variability of the dependent variable, 
adjusted for the number of predictors in the model. It doesn't necessarily mean that all individual predictors are statistically significant.
It's possible to have a high adjusted R2 even if some individual predictors are not statistically significant.

*/


/* Problem 4 */

* Define and load the Emissions CSV data file;
FILENAME IBMFILE '/home/u63409250/sasuser.saurabh.v94/ibm.csv';

PROC IMPORT DATAFILE=IBMFILE
	DBMS=CSV
	OUT=IBMDATA;
	GETNAMES=YES;
RUN;

/* Following REG statement includes the DW option to calculate the Durbin-Watson statistic 
and the DWPROB option to obtain the associated p-value for testing the null hypothesis 
of no autocorrelation in the residuals.

The Durbin-Watson statistic is a test for the presence of auto correlation in the 
residuals of a regression model. The statistic ranges from 0 to 4, and a value close to 2 
suggests no auto correlation, while values lower or higher than 2 may indicate 
positive or negative autocorrelation.

The associated p-value (DWPROB) is used to assess the statistical significance of 
the Durbin-Watson statistic. A small p-value suggests evidence against the null hypothesis 
of no correlation, indicating the presence of auto correlation in the residuals.

May also user plot(unpack)=residuals in REG statement 
*/	

PROC REG DATA=IBMDATA;
  MODEL Close = Day / DW DWPROB;
run;

/* 
Durbin-Watson D	0.103 --> indicates a high level of positive correlation in the residuals.
Pr < DW	<.0001. --> This extremely small p-value suggests strong evidence against the null hypothesis of no correlation. In other words, there is a significant positive correlation in the residuals.
Pr > DW	1.0000. --> This result is expected since the Durbin-Watson statistic is low, indicating a significant positive correlation.
Number of Observations	295.  --> total number of records / observtions on modelling
1st Order Autocorrelation	0.948. --> This value is very close to 1, indicating a high positive correlation between the residuals at consecutive observations.
*/


ods graphics off;
/* Close PDF file */
ods pdf close;

QUIT;