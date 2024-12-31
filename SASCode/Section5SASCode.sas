**************************
*SAS code from section 5
**************************;

*Slide 10;
proc freq data=ST514.Emissions_High;
   tables E_RESULT_STRING TRANS_TYPE
          TRANS_TYPE*E_RESULT_STRING /
          plots(only)=freqplot(scale=percent);
run;
quit;

*Slide 34;
proc freq data=ST514.Emissions_High;
   tables TRANS_TYPE*E_RESULT_STRING / chisq expected  
                                       cellchi2 nocol 
                                       nopercent;
run;
quit;

*Slide 44;
proc freq data=ST514.Emissions_High(where=(CYL>3));
   tables CYL*E_RESULT_STRING / chisq expected  
                                cellchi2 nocol 
                                nopercent;
run;
quit;

*Slide 60;
proc freq data=ST514.Emissions_High(where=(CYL>3));
   tables CYL*E_RESULT_STRING / chisq relrisk;
run;
quit;

*Slide 66;
proc freq data=ST514.athlete;
   tables Treatment_A*Treatment_B / agree expected norow 
                                    nocol nopercent;
   title "McNemar's test for Paired Samples";
   format Treatment_A Treatment_B $result.;
run;
quit;

*Slide 77;
data ST514.Emissions_High_LPM;
   set ST514.Emissions_High;
   E_RESULT_STRING2 = 0;
   if E_RESULT_STRING = 'P' then E_RESULT_STRING2 = 1;
run;
	
proc freq data=ST514.Emissions_High_LPM;
   tables TRANS_TYPE*E_RESULT_STRING2;
run;
quit;

proc reg data=ST514.Emissions_High_LPM   
         plots=diagnostics(unpack);
   model E_RESULT_STRING2 = ODOMETER_K;
run;
quit;

*Slide 87;
proc logistic data=ST514.Emissions_High alpha=0.05
              plots(only)=(effect oddsratio);
   class TRANS_TYPE(ref='M') / param=reference;
   model E_RESULT_STRING(event='P') = ODOMETER_K TRANS_TYPE / 
                                      clodds=pl;
run;
quit;
