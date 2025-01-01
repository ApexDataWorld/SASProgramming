************************************************;
*Author: Saurabh Gupta                          ;                                              
*Collaborators: None                            ;                                 
*Program Purpose: ST 514 Mini project 3         ;
*Date: 01 Apr 2024                              ;                                     
************************************************;

/*
Problem 1 --> 

Total number of pizzas (N) = 25
Number of pepperoni-only pizzas (P) = 8
Number of green-pepper-only pizzas (G) = 7
Number of pepperoni-and-green-pepper pizzas (PG) = 5
Number of plain pizzas (Pl) = 5

P(plain slice|pepperoni-only pizza) = 1/8
P(plain slice|green-pepper-only pizza) = 1/4
P(plain slice|pepperoni-and-green-pepper pizza) = 1/40

Calculate P(plain slice)
P(plain slice)=P(plain slice∣pepperoni-only pizza)×P(pepperoni-only pizza)+
               P(plain slice∣green-pepper only pizza)×P(green-pepper only pizza)+
               P(plain slice∣pepperoni-and-green-pepper pizza)×P(pepperoni-and-green-pepper pizza)+
               P(plain slice|plain)xP(plain pizza)
              = (1/8)×(8/25)+(1/4)×(7/25)+(1/40)×(5/25)+(1)×(5/25)
              = 0.315

a) P(pepperoni-only pizza∣plain slice)= 
   P(plain slice∣pepperoni-only pizza)×P(pepperoni-only pizza) / P(plain slice)
​   = (1/8)×(8/25) / P(plain slice)
   = (1/8)×(8/25) / 0.315
   = 0.12698

b) P(pepperoni-and-green-pepper pizza∣plain slice) = 
   P(plain slice∣pepperoni-and-green-pepper pizza)×P(pepperoni-and-green-pepper pizza) /P(plain slice)
   = (1/40)×(5/25) / P(plain slice)
   = (1/40)×(5/25) / 0.315
   = 0.01587
​	
 
c) P(pizza contains green peppers∣plain slice)= 
   P(plain slice∣green-pepper only pizza)×P(green-pepper only pizza)+P(plain slice∣pepperoni-and-green-pepper pizza)×P(pepperoni-and-green-pepper pizza) / P(plain slice)
   = (1/4)×(7/25)+(1/40)×(5/25) / P(plain slice)
   = (1/4)×(7/25)+(1/40)×(5/25) / 0.315
   = 0.23809

*/

/*********************************************************************************/

* Declare the PDF output file ;
ods pdf file="/home/u63409250/sasuser.saurabh.v94/ST514MiniProject03Results.pdf"; 
ods graphics on;

/* Importing first file */
proc import datafile='/home/u63409250/sasuser.saurabh.v94/MiniProject03/weapons.txt'
            out=weapons
            dbms=dlm replace;
            delimiter=' ';
    getnames=yes;
run;

/* Importing second file */
proc import datafile='/home/u63409250/sasuser.saurabh.v94/MiniProject03/weapons1.txt'
            out=weapons1
            dbms=dlm replace;
            delimiter=' ';
    getnames=yes;
run;

/* Importing third file */
proc import datafile='/home/u63409250/sasuser.saurabh.v94/MiniProject03/weapons2.txt'
            out=weapons2
            dbms=dlm replace;
            delimiter=' ';
    getnames=yes;
run;

/*********************************************************************************/
/* Problem 2 --> May use proc freq or proc sql to calculate or 
do it manually by analyzing data or creating a matrix */

proc freq data=weapons;
    where sex = 'F' and an > 40;
    tables sex;
    output out=counts1;
run;

proc sql;
    select count(*) / (select count(*) from weapons) as count
    from weapons
    where sex = 'F' and an > 40;
run;

proc sql;
    select count(*) / (select count(*) from weapons where sex = 'F') as probability
    from weapons
    where sex = 'F' and an > 40;
run;


/* ANSWER --> page 2 and 3 of results.pdf
	•	P(an>40 and sex=F) =9/32 = 0.28125
	•	P(an>40  | sex=F) =9/15 = 0.6
*/	

/*********************************************************************************/


/* Problem 3 - Report the mean and 95% HPD for the beta coefficient for aw*cxen */
/* page 6 of results.pdf
   awcxen	Mean 0.0148	
            HPD  (0.00525 , 0.0253) */
PROC GENMOD DATA=Weapons;
MODEL an= aw cxen aw*cxen;
BAYES COEFFPRIOR=UNIFORM;
RUN;

/* Probem 4 a - Report the posterior mean and 95% HPD for the beta coefficient for aw */
/* page 15 of results.pdf
   aw	Mean 0.2791	 
        HPD ( -0.0785  ,  0.6127 )*/
PROC GENMOD DATA=Weapons;
MODEL an= aw cxen;
BAYES COEFFPRIOR=UNIFORM;
RUN;

/* Probem 4 b - Report the posterior mean and 95%  HPD for the beta coefficient for aw */
/* page 23 of results.pdf
   aw	Mean  0.4682 
        HPD   ( -0.1839  ,  1.0740 ) */
PROC GENMOD DATA=Weapons2;
MODEL an= aw cxen;
BAYES COEFFPRIOR=UNIFORM;
RUN;

/* Probem 4 c - output the means and covariances for the betas. */
/* page 29 and 32 of results.pdf
   aw   0.06436      
   cxen 0.76452      
   The normal distribution of aw is centered around 0.06436 
   The normal distribution of cxen is centered around 0.76452
*/


PROC REG DATA=Weapons1 OUTEST=Betas COVOUT;
MODEL an= aw cxen / covb;
RUN;

proc print data=Betas label;
   var _TYPE_ Intercept aw cxen _RMSE_ ;
run;

DATA WORK.Betas;
	SET WORK.Betas;
	IF(_TYPE_ = 'PARMS') THEN _TYPE_ = 'MEAN';
RUN;


/* Probem 4 d - Report the posterior mean for the beta coefficient for aw and its 95% HPD */
/* page 34 of results.pdf
awcxen	Mean 	 HPD   
Bayesian approach using the model created in previous step as in frequencist approach. 
So the prior is set as betas from 4c 
*/  
PROC GENMOD DATA=Weapons2;
MODEL an= aw cxen;
BAYES COEFFPRIOR=NORMAL(INPUT=Betas);
RUN;
/* Contrast these values with the analogous values obtained from parts a) and b), and comment on whether the results are what you might have expected. */
/*
The mean from posterier summaries can be compared here with the mean from normal prior table. 
the covariance matrix can also be analyzed between the two. 
The purpose of this model is to get the posterier data based on the prior model build in 4c. 
The mean values for aw and cxen may shift from the prior data as the model is now created with new data. 

I am constantly getting SAS error on executing this final proc GENMOD. 
NOTE: Algorithm converged.
NOTE: The scale parameter was estimated by maximum likelihood.
ERROR: Invalid Operation.
ERROR: Termination due to Floating Point Exception
NOTE: The SAS System stopped processing this step because of errors.

Discussed this with Dr. Wright and he said to mention it in the answering code (here), as 
it is not reproducible at his side. 

*/




ods graphics off;
/* Close PDF file */
ods pdf close;

Quit;