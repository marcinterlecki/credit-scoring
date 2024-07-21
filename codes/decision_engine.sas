
%macro scoring_engine(wej,wyj);

data cal;
set &wej;
run;

%let ins_omega_s=-0.028455066;
%let ins_omega_zero=9.1924286563;
%let css_omega_s=-0.0347375271307214;
%let css_omega_zero=76.1761191281994;
%let cross_css_omega_s=-0.0341550404026672;
%let cross_css_omega_zero=6.435939306400602;
%let response_omega_s=-0.03513697883384056; 
%let response_omega_zero=3.3486912506924087;

%let dodatkowy_element_w_nazwie_pliku =;

%let zbior=cal;
%include "&dir.process\calibration\model_ins_risk\scoring_code.sas";

data cal1;
	set cal_score;
	risk_ins_score=.;
	if product='ins' then risk_ins_score=SCORECARD_POINTS;
	pd_ins=1/(1+exp(-(&ins_omega_s*risk_ins_score+&ins_omega_zero)));
	drop psc: SCORECARD_POINTS;
run;

%let zbior=cal1;
%include "&dir.process\calibration\model_css_risk\scoring_code.sas";


data cal2;
	set cal1_score;
	risk_css_score=.;
	if product='css' then risk_css_score=SCORECARD_POINTS;
	pd_css=1/(1+exp(-(&css_omega_s*risk_css_score+&css_omega_zero)));
	drop psc: SCORECARD_POINTS;
run;


%let zbior=cal2;
%include "&dir.process\calibration\model_cross_css_risk\scoring_code.sas";

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

%let pd_css=0.28773;
%let pd_ins1=0.0619;
%let pd_ins2=0.0258; 
%let pr2=0.031;


data &wyj;
	length cid $10 aid $16 product $3 period $6 decision $1 decline_reason $20
	app_loan_amount app_n_installments pd cross_pd pr 8;

	set cal4;
	decision='A';
	decline_reason='999ok';

	cross_pd=pd_cross_css;
	pd=.;
	if product='ins' then pd=pd_ins;
	if product='css' then pd=pd_css;

	if (act_cins_n_statB>0 or act_ccss_n_statB>0) then do;
		decision='D';
		decline_reason='1 bad customer';
	end;

/*	*/
/*	if agr12_Max_CMaxA_Due>3 then do;*/
/*		decision='D';*/
/*		decline_reason='1 bad customer';*/
/*	end;*/

	if product='css' and pd_css>&pd_css then do;
		decision='D';
		decline_reason="1 PD cut-off on css";
	end;
	if product='ins' and pd_ins>&pd_ins1 then do;
		decision='D';
		decline_reason="2 PD cut-off on ins";
	end;

	if product='ins' and &pd_ins1>=pd_ins>&pd_ins2 
		and (pr<&pr2 or pd_cross_css>&pd_css) then do;
		decision='D';
		decline_reason="3 PD,PDCross and PR cut-offs on ins";
	end;

	if period<'197501' then do;
		decision='A';
		decline_reason='999ok';
	end;

	if product='css' and act_cus_active ne 1 then do;
		decision='N';
		decline_reason='998 not active customer';
	end;

	keep
	cid aid product period decision decline_reason app_loan_amount 
	app_n_installments pd cross_pd pr;
	format pd cross_pd pr nlpct12.2;
run;
%mend;
