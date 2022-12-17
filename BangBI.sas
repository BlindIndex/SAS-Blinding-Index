/*https://zhuanlan.zhihu.com/p/563065503*/
*===========================================================================================================================
Description
%BangBI:To estimate the Bang's blinding index (BBI) for randomized controlled trials with two arms  
Author:Qin Zongshi,The University of Hong Kong
E-mail:arisq@connect.hku.hk
Date and version:20220906|v1.2
For details of Bang's BI pls refer to following manuscript:
Heejung Bang.Random guess and wishful thinking are the best blinding scenarios.Contemp Clin Trials Commun.2016

Variable annotation:
Tt = people in the treatment arm and guess 'treatment'
Tc = people in the treatment arm and guess 'control'
Tunknown = peolple in the treatment arm and guess 'unknown'
Tall = total people in the treatment arm
Ct = people in the control arm and guess 'treatment'
Cc = people in the control arm and guess 'control'
Cunknown = peolple in the control arm and guess 'unknown'
Call = total people in the contrl arm

Log:
20220811 start the program
20220816 inserted the 3x2 table
20220821 inserted the forestplot for visualization
|----------------------------------|
|         |          Arms          |
|---------|-----------|------------|
| Guess   | Treatment |  Control   |
|---------|-----------|------------|
|Treatment|     Tt    |     Ct     |
|---------|-----------|------------| 
|Control  |     Tc    |     Cc     |
|---------|-----------|------------|
|Unknown  |  Tunknown |  Cunknown  |
|---------|-----------|------------|
|         |     Tall  |     Call   |
*===========================================================================================================================;
%MACRO BangBI(
Tt= , 
Tc= , 
Tunknown= , 
Tall= , 
Ct= , 
Cc= , 
Cunknown= , 
Call=
);

data BBI;
	var1=((&Tt/&Tall*(&Tc+&Tunknown)/&Tall)+(&Tc/&Tall*(&Tt+&Tunknown)/&Tall)+(2*&Tt/&Tall*&Tc/&Tall))/&Tall;
	varBIt=sqrt(var1);
/*estimate the BI for the treatment arm*/
	BI_treatment=(&Tt-&Tc)/&Tall;
/*estimate the 95%CI of BI for the treatment arm*/
	BI_treatment_95lower=BI_treatment-1.96*varBIt;
	BI_treatment_95upper=BI_treatment+1.96*varBIt;

	var2=((&Ct/&Call*(&Cc+&Tunknown)/&Call)+(&Cc/&Call*(&Ct+&Cunknown)/&Call)+(2*&Ct/&Call*&Cc/&Call))/&Call;
	varBIc=sqrt(var2);
/*estimate the BI for the control arm*/
	BI_control=(&Cc-&Ct)/&Call;
/*estimate the 95%CI of BI for the control arm*/
	BI_control_95lower=BI_control-1.96*varBIc;
	BI_control_95upper=BI_control+1.96*varBIc;
run;

/*estimate the frequency and proportion for each cell*/
data freqtable;
	do arm = 1 to 2;	
		do guess = 1 to 3;	
			output;
		end;
	end;
run;
data f;
	f=&Tt;output;
	f=&Tc;output;
	f=&Tunknown;output; 
	f=&Ct;output;
	f=&Cc;output;
	f=&Cunknown;output; 
run;
data freqtable;
	merge freqtable f;
run;
proc format;
	value guess 1='Treatment'
				2='Control'
				3='Unknown';
	value arm   1='Treatment'
				2='Control';

proc freq data=freqtable; 
	format guess guess. arm arm.; 
	weight f; 
	tables guess*arm/norow;
	title 'Assessment of blinding success';
run;

proc transpose data=BBI(drop=var1 varBIt var2 varBIc) out=BBI_trans(rename=(col1=estimation)) name=variable;
run;

proc print data=BBI_trans;
	title "Results of Bang's blinding index";
run;

/*forestplot for BI*/
data BBI_trans;
	set BBI_trans;
	if variable="BI_treatment" then do; var="BI"; X="Arm1_Treatment";end;
	if variable="BI_treatment_95lower" then do; var="lo"; X="Arm1_Treatment";end;
	if variable="BI_treatment_95upper" then do; var="up"; X="Arm1_Treatment";end;
	if variable="BI_control" then do; var="BI"; X="Arm2_Control";end;
	if variable="BI_control_95lower" then do; var="lo"; X="Arm2_Control";end;
	if variable="BI_control_95upper" then do; var="up"; X="Arm2_Control";end;
run;

proc transpose data=BBI_trans(drop=variable) out=forestplot(drop=_name_);
	by x;
	id var;
	var estimation;
run;

title "Forest Plot of BI and 95% CI";
proc sgplot data=forestplot;
	scatter x=BI y=X /xerrorlower=lo
					  xerrorupper=up
					  markerattrs=(color=orange symbol=diamondfilled size=8)	;
	refline 0/axis=x;
	xaxis label="BI and 95% CI" min=-1 max=1;
	yaxis label="Arm" offsetmin=0.3 offsetmax=0.3;
run;
%MEND BangBI;

%BangBI(
Tt= , 
Tc= , 
Tunknown= , 
Tall= , 
Ct= , 
Cc= , 
Cunknown= , 
Call=
)
