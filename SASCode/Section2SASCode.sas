**************************
*SAS code from section 2
**************************;

*Slide 14;
proc corr data=ST514.Emissions_High;
   VAR E_HIGH_CO ODOMETER;
RUN;

*Slide 53;
proc reg data=ST514.AdSales;
	model Sales_y = Advexp_x;
run;
quit;

*Slide 60;
data ST514.Emissions_High;
	set ST514.Emissions_High;
	ODOMETER_K = ODOMETER/1000;
run;

proc reg data=ST514.Emissions_High;
	model E_HIGH_CO = ODOMETER_K;
run;
quit;

*Slide 100;
proc reg data=ST514.Emissions_High;
   model E_HIGH_CO = ODOMETER_K / CLB ;
run;
quit;

*Slide 124;
proc reg data=ST514.Emissions_High;
	model E_HIGH_CO = ODOMETER / CLM CLI;
run;
quit;
