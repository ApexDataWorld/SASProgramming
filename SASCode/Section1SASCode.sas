***********************************
*Code from Section 1 notes
***********************************;

*slide 28;
DATA normal;
	z = 0.83;
	p = 1 - cdf('NORMAL', z);
RUN;

PROC PRINT DATA = normal;
RUN;

*Slide 39;
DATA binom;
	p = cdf('BINOMIAL', 3, 1/6, 10) - cdf('BINOMIAL', 2, 1/6, 10);
RUN;

PROC PRINT DATA = binom;
RUN;

*Slide 58;
DATA ST514.Emissions_High;
   SET ST514.Emissions;
   IF E_HIGH_CO2 eq 0 THEN DELETE;
RUN;

PROC MEANS DATA=ST514.Emissions_High MEAN STDDEV STDERR CLM 				       ALPHA=0.01;
   VAR ODOMETER;
RUN;

*Slide 72;
PROC TTEST DATA=ST514.Emissions_High H0=175000 sides=l;
   VAR ODOMETER;
RUN;

*Slide 68;
PROC TTEST DATA=ST514.Emissions_High;
   CLASS E_RESULT_STRING;
   VAR ODOMETER;
RUN;

*Slide 102;
PROC GLM DATA=ST514.Emissions_High;
   CLASS CYL;
   MODEL ODOMETER = CYL;
RUN;
