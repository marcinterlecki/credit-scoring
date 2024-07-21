proc sql; 
create table  &zbior._score as 
select indataset.*  
, case 
when act_ccss_n_loan < 1.5 then 64.0 
when 1.5 <= act_ccss_n_loan  and  act_ccss_n_loan < 2.5 then -25.0 
when 2.5 <= act_ccss_n_loan  and  act_ccss_n_loan < 3.5 then -78.0 
when 3.5 <= act_ccss_n_loan  and  act_ccss_n_loan < 4.5 then -100.0 
when 4.5 <= act_ccss_n_loan then -136.0 
else 64.0 end as PSC_act_ccss_n_loan 
 
, case 
when act_cins_n_loans_hist < 1.5 then 64.0 
when 1.5 <= act_cins_n_loans_hist  and  act_cins_n_loans_hist < 2.5 then 52.0 
when 2.5 <= act_cins_n_loans_hist  and  act_cins_n_loans_hist < 3.5 then 48.0 
when 3.5 <= act_cins_n_loans_hist  and  act_cins_n_loans_hist < 5.5 then 41.0 
when 5.5 <= act_cins_n_loans_hist then 31.0 
else 64.0 end as PSC_act_cins_n_loans_hist 
 
, case 
when 2.5 <= act_cins_n_statB then 64.0 
when 0.5 <= act_cins_n_statB  and  act_cins_n_statB < 1.5 then 43.0 
when 1.5 <= act_cins_n_statB  and  act_cins_n_statB < 2.5 then 36.0 
when act_cins_n_statB < 0.5 then 27.0 
else 64.0 end as PSC_act_cins_n_statB 
 
, case 
when ags3_Max_CMaxC_Due is null then 64.0 
when ags3_Max_CMaxC_Due < 0.5 then 27.0 
when 6.5 <= ags3_Max_CMaxC_Due then 23.0 
when 4.5 <= ags3_Max_CMaxC_Due  and  ags3_Max_CMaxC_Due < 6.5 then 22.0 
when 0.5 <= ags3_Max_CMaxC_Due  and  ags3_Max_CMaxC_Due < 1.5 then 18.0 
when 1.5 <= ags3_Max_CMaxC_Due  and  ags3_Max_CMaxC_Due < 4.5 then 16.0 
else 64.0 end as PSC_ags3_Max_CMaxC_Due 
 
, case 
when app_char_gender in ('Male') then 64.0 
when app_char_gender in ('Female') then 52.0 
else 64.0 end as PSC_app_char_gender 
 
/* , 1/(1+exp(-(-0.03513697883384056*(0.0+ calculated PSC_act_ccss_n_loan+ calculated PSC_act_cins_n_loans_hist+ calculated PSC_act_cins_n_statB+ calculated PSC_ags3_Max_CMaxC_Due+ calculated PSC_app_char_gender)+(3.3486912506924087)))) as PD */ 
 
, 0.0 
+ calculated PSC_act_ccss_n_loan + calculated PSC_act_cins_n_loans_hist + calculated PSC_act_cins_n_statB + calculated PSC_ags3_Max_CMaxC_Due + calculated PSC_app_char_gender  as SCORECARD_POINTS 
 
from &zbior as indataset; 
quit; 
