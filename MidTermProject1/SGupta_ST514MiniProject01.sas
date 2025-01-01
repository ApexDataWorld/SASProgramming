************************************************;
*Author: Saurabh Gupta                          ;                                              
*Collaborators: None                            ;                                 
*Program Purpose: ST 514 Mini project 1         ;
*Date: 29 Jan 2024                              ;                                     
************************************************;

* Define the Emissions CSV data file path ;
FILENAME REFFILE '/folders/myfolders/ST514/Emissions-Alb.csv';

* Declare the PDF output file ;
ods pdf file="/home/u63409250/sasuser.saurabh.v94/ST514MiniProject01Results.pdf"; 
ods graphics on;

* Create SAS dataset ST514.Emissions_High by importing data from the Emissions CSV file;
PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=ST514.Emissions;
	GETNAMES=YES;
RUN;

* Display the contnets of Emissions dataset for verification purposes;
PROC CONTENTS DATA=ST514.Emissions; 
RUN;

* Create new data Emission_High by ignoring/deleting all such records which has E_HIGH_CO2 equal zero value ;
* Emission_High dataset has non zero E_HIGH_CO2 data records ;

data ST514.Emissions_High;
   set ST514.Emissions;
   if E_HIGH_CO2 eq 0 then delete;
run;

* Run CORR step to find the largest magnitude correlation of all attributes with ODOMETER ;
* Ignoring the other table and only considering PearsonCorr table in this step ;
proc corr data = ST514.Emissions_High;
 var E_HIGH_RPM E_HIGH_CO2 E_HIGH_O2 E_HIGH_HC E_HIGH_DCF E_HIGH_HC_LIMIT E_HIGH_CO ODOMETER;
 ods select PearsonCorr;
run;

* Result: 
* E_HIGH_HC has the correlation of highest magnitude, at 0.27133. 
* The p-value is  less than 0.0001.;

* Create the new variable square root of high carbon monoxide (SQRT_E_High_CO) in Emissions_High dataset ; 
data ST514.Emissions_High;
 set ST514.Emissions_High;
 SQRT_E_HIGH_CO = sqrt(E_HIGH_CO);
run;


* Run ttest to perform a one-sided test ;  
* Null hypothesis : population mean value of SQRT_E_HIGH_CO is 0.48 ;
* Alternative hypothesis : mean value is less than 0.48 ;
* Create histogram and QQplot ;
proc ttest data = ST514.Emissions_High H0=0.48 sides = l;
 var SQRT_E_HIGH_CO;
 ods output Histogram QQPlot;
run;

* May use the PROC UNIVARIATE to plot historgram separetely. Use the VAR statement otherwise all numeric variables in the data set are analyzed ;
 
* Run corr to determine correlation coefficient and p-value for SQRT_E_HIGH_CO and ODOMETER;
* This is to determine how strongly odometer value is correlated to the high emission carbon monoxide ;
* Also compare this correlation value with previously done with E_HIGH_CO ;
proc corr data = ST514.Emissions_High;
 var  SQRT_E_HIGH_CO ODOMETER;
 ods select PearsonCorr;
run; 

* Results :
* The correlation coefficient has increased to 0.25098 from its previous value of 0.18233. This indicates that the square root transformation has led to an enhancement in the correlation ;
* Based on the histogram, even though the transformed data remains non-normal, it appears that prior to the transformation, it was probably highly skewed ;
* It is more indicated that the transformation was beneficial in revealing a more linear relationship using the transformed variable ;


* Simple linear regression of SQRT_E_HIGH_CO (response) vs. ODOMETER (explanatory/predictor variable) ;
* Creare simplete linear regression model for coefficient estimated with 95% confidence intervals ;
proc reg data=ST514.Emissions_High;
   model SQRT_E_HIGH_CO = ODOMETER / CLB ;
run;

* Results 
* The results indicate that Intercept is 0.20814 and the slope ODOMETER is 0.00000145. ;
* Slope is the constant value which tells how much the y axis increase with one unit increse on x asis.
* And the 95% confidence intervals are (0.10375, 0.31254) and model interval is (8.540278E-7, 0.00000204).
* The p-value, associated with the slope, is extremely significant, with p < 0.001.



* From the information provided in the notes, it is evident that the formula for the t-statistic is t = r * sqrt(n-2) / sqrt(1-r^2). ;
* Substituting the values r = 0.25098 and n = 343 into the formula, we get a t-value of 4.7879, aligning with the t-statistic derived from the regression analysis, as expected ;
* A two sided p value ;

data findp;
   p = 2*(1-cdf('T', 4.7879, 341)) ; 
   put p=;
run;

proc print data=findp;
run; 

ods graphics off;
/* Close PDF file */
ods pdf close;
