/*  (c) Karol Przanowski   */
/*    kprzan@sgh.waw.pl    */

/* model calibration process, cut-off calculation, to make a profitable products */

/* kod lekko przerobiony przez pj; v. 1747 */

options mprint;
options nomprint;

%let dir=C:\Users\jnk\Documents\Studia\sgh_credit_scoring_refactored\PROCSS_SIMULATION\;

libname data "&dir.process\data\" compress=yes;



%let apr_ins=0.01;
%let apr_css=0.18;
%let lgd_ins=0.45;
%let lgd_css=0.55;
%let provision_ins=0;
%let provision_css=0;

/* glowne sterowanie: jesli liczymy nasz model to wartosc ma byc: nasz 
albo cokolwiek innego w odmiennym przypadku */

%let ktory_model = nasz;

%if &ktory_model eq nasz
%then 
%do;

	/* zmieniac tutaj!: 
	parametry wg wzoru ze slajdu 96
	*/

	%let ins_omega_s=-0.028455066;
	%let ins_omega_zero=9.1924286563;
	%let css_omega_s=-0.0347375271307214;
	%let css_omega_zero=76.1761191281994;
	%let cross_css_omega_s=-0.0341550404026672;
	%let cross_css_omega_zero=6.435939306400602;
	%let response_omega_s=-0.03513697883384056; 
	%let response_omega_zero=3.3486912506924087;

	* zwykle powinien byc tu pusty string;
	%let dodatkowy_element_w_nazwie_pliku =; 
%end;
%else 
%do;
	%let ins_omega_s=-0.032205144;
	%let ins_omega_zero=9.4025558419;
	%let css_omega_s=-0.028682728;
	%let css_omega_zero=8.1960829753;
	%let cross_css_omega_s=-0.028954669;
	%let cross_css_omega_zero=8.2497434934;
	%let response_omega_s=-0.035007455;
	%let response_omega_zero=10.492092793;

	%let dodatkowy_element_w_nazwie_pliku = _orig;
%end;


data cal;
	set data.abt_app;
	if default12 in (0,.i,.d) then default12=0;
	if default_cross12 in (0,.i,.d) then default_cross12=0;
	where '197501'<=period<='198712' and decision='A';
run;

%let zbior=cal;
%include "&dir.process\calibration\model_ins_risk\scoring_code.sas";

data cal1;
	set cal_score;
	risk_ins_score=.;
	if product='ins' then risk_ins_score=SCORECARD_POINTS;
	pd_ins=1/(1+exp(-(&ins_omega_s*risk_ins_score+&ins_omega_zero)));
	drop psc: SCORECARD_POINTS;
run;

/* 
	* do wyliczenia pd_ins przy pomocy proc logistic, ;
	* w celu sprawdzenia, czy wyliczone wy?ej jest dobre ;
	proc logistic data=cal1 desc outest=bety;
		model default12=risk_ins_score;
		output out=test p=p;
	run;

	data test2;
		set test;
		pd_ins=1/(1+exp(-(&ins_omega_s*risk_ins_score+&ins_omega_zero)));
	run;
	* koniec wyliczenia;

	* do sprawdzenia czy pd jest dobrze skalibrowane;
	* tzn. sprawdzamy, czy ?rednie pd_ins jest odsetkowi default12;

	proc means data=test2 noprint nway;
		var pd_ins p default12;
		output out=test3 mean()=;
		format pd_ins p default12 percent12.4;
		where product='ins';
	run; 
*/

%let zbior=cal1;
%include "&dir.process\calibration\model_css_risk\scoring_code.sas";


data cal2;
	set cal1_score;
	risk_css_score=.;
	if product='css' then risk_css_score=SCORECARD_POINTS;
	pd_css=1/(1+exp(-(&css_omega_s*risk_css_score+&css_omega_zero)));
	drop psc: SCORECARD_POINTS;
run;

/* 
*jw, sprawdzenie pd;
proc logistic data=cal2 desc outest=bety;
	model default12=risk_css_score;
	output out=test p=p;
run;

data test2;
	set test;
	pd_css=1/(1+exp(-(&css_omega_s*risk_css_score+&css_omega_zero)));
run; 
*/

%let zbior=cal2;
%include "&dir.process\calibration\model_cross_css_risk\scoring_code.sas";

/* 
	*nagranie 9, 36:11;
	data cal3;
		set cal2_score;
		risk_cross_css_score=.;
		if cross_response=1 then risk_cross_css_score=SCORECARD_POINTS;
		pd_cross_css=1/(1+exp(-(&cross_css_omega_s*risk_cross_css_score+&cross_css_omega_zero)));
		drop psc: SCORECARD_POINTS;
	run;

	proc logistic data=cal3 desc outest=bety;
		model default_cross12=risk_cross_css_score;
		output out=test p=p;
	run;

	data test2;
		set test;
		pd_cross_css=1/(1+exp(-(&cross_css_omega_s*risk_cross_css_score+&cross_css_omega_zero)));
	run; 
*/

data cal3;
	set cal2_score;
	risk_cross_css_score=SCORECARD_POINTS;
	pd_cross_css=1/(1+exp(-(&cross_css_omega_s*risk_cross_css_score+&cross_css_omega_zero)));
	drop psc: SCORECARD_POINTS;
run;


%let zbior=cal3;
%include "&dir.process\calibration\model_response\scoring_code.sas";


data cal4;
	set cal3_score;
	response_score=SCORECARD_POINTS;
	pr=1/(1+exp(-(&response_omega_s*response_score+&response_omega_zero)));
	drop psc: SCORECARD_POINTS;
run;

/* 
	* sprawdzanie dla cross response;
	proc logistic data=cal4 desc outest=bety;
		model cross_response=response_score;
		output out=test p=p;
	run;

	data test2;
		set test;
		pr=1/(1+exp(-(&response_omega_s*response_score+&response_omega_zero)));
	run;
 */

* wyliczanie zbioru profit_cal;
data data.profit_cal;
	set cal4;

	if product='ins' then do;
		lgd=&lgd_ins;
		apr=&apr_ins/12;
		provision=&provision_ins;
	end;
	if product='css' then do;
		lgd=&lgd_css;
		apr=&apr_css/12;
		provision=&provision_css;
	end;
	lgd_cross=&lgd_css;
	apr_cross=&apr_css/12;
	provision_cross=&provision_css;

	EL=0;
	if default12=1 then EL=app_loan_amount*lgd;
	installment=app_loan_amount*apr*((1+apr)**app_n_installments)/
	(((1+apr)**app_n_installments)-1);
	Income=0;
	if default12=0 then Income=app_n_installments*installment
		+app_loan_amount*(provision-1);
	Profit=income-el;

	EL_cross=0;
	if default_cross12=1 then EL_cross=cross_app_loan_amount*lgd_cross;
	installment=cross_app_loan_amount*apr_cross*((1+apr_cross)**cross_app_n_installments)/
	(((1+apr_cross)**cross_app_n_installments)-1);
	Income_cross=0;
	if default_cross12=0 then Income_cross=cross_app_n_installments*installment
		+cross_app_loan_amount*(provision_cross-1);
	Profit_cross=income_cross-el_cross;

	year=compress(put(input(period,yymmn6.),year4.));

	keep aid cid product cross: pd: pr: year
	el: income: profit:;
run;

/*analysis per cash CSS product*/
proc means data=data.profit_cal noprint nway;
	class pd_css;
	var profit;
	output out=cash sum(profit)=profit n(profit)=n;
	where product='css';
run;

proc sort data=cash;
	by pd_css;
run;

proc sql noprint;
	select sum(n) into :n_obs from cash;
quit;

%put &n_obs;

data cash_cum;
	set cash;
	n_cum+n;
	ar=n_cum/&n_obs;
	profit_cum+profit;
	format pd: ar: nlpct12.2 profit: nlnum18.;
run;


proc sort data=cash_cum;
	by descending profit_cum;
run;

* tutaj znajduje wartosc pd_css ;
proc sql;
	title 'pd_css with biggest profit_cum';
	select pd_css format=6.5
	into :pd_css trimmed
	from cash_cum
	where profit_cum eq (select max(profit_cum) from cash_cum)
	;
quit; run;

%put &pd_css;

/*%let pd_css=0.3654;*/
/*analysis per cash CSS product*/

/*instalment loan then cash*/
data instalment;
	set data.profit_cal;
	if pd_cross_css>&pd_css then profit_cross=0;
	profit_global=profit_cross+profit;
	where product='ins';
	format profit: nlnum18. pr pd_ins nlpct12.2;
run;
proc rank data=instalment out=instalment_rank groups=5;
	var pr pd_ins;
	ranks rpr rpd_ins;
run;
proc means data=instalment_rank noprint nway;
class rpr rpd_ins;
var profit_global pr pd_ins;
output out=instalment_rank_means 
	sum(profit_global)=profit_global n(profit_global)=n
	max(pr pd_ins)=max_pr max_pd_ins
	min(pr pd_ins)=min_pr min_pd_ins
;
run;
proc sort data=instalment_rank_means;
by descending profit_global;
run;

/*proc sql;*/
/*select sum(profit_global) from instalment_rank_means where profit_global > 0;*/
/*quit;*/

%let pd_ins1=0.0819;
%let pd_ins2=0.0218; %let pr2=0.028;
/*instalment loan then cash*/


/*all tests*/
data alltest;
set data.profit_cal;
decision='A';
if product='css' and pd_css>&pd_css then decision='D';
if product='ins' and pd_ins>&pd_ins1 then decision='D';
if product='ins' and &pd_ins1>=pd_ins>&pd_ins2 and 
	(pr<&pr2 or pd_cross_css>&pd_css) then decision='D';
format profit: nlnum18. pr pd_ins pd_css nlpct12.2;
run;
proc tabulate data=alltest;
class product decision;
var profit;
table product, decision='' all, profit=''*
(n*f=nlnum14. colpctn*f=nlnum12.2 sum*f=nlnum14.);
run;

/*1�687�901*/
/*1�359�256*/
/*all tests*/
