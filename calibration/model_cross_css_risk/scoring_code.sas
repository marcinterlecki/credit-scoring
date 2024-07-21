proc sql; 
create table  &zbior._score as 
select indataset.*  
, case 
when app_income < 575.0 then 9.0 
when 3833.0 <= app_income then 21.0 
when 575.0 <= app_income  and  app_income < 1063.0 then 25.0 
when 1063.0 <= app_income  and  app_income < 3833.0 then 37.0 
else 9.0 end as PSC_app_income 
 
, case 
when 4996.0 <= app_loan_amount  and  app_loan_amount < 5002.0 then 9.0 
when 2154.0 <= app_loan_amount  and  app_loan_amount < 4996.0 then 37.0 
when 5002.0 <= app_loan_amount then 40.0 
when app_loan_amount < 2154.0 then 47.0 
else 9.0 end as PSC_app_loan_amount 
 
, case 
when app_number_of_children < 0.5 then 9.0 
when 0.5 <= app_number_of_children  and  app_number_of_children < 1.5 then 18.0 
when 1.5 <= app_number_of_children  and  app_number_of_children < 2.5 then 30.0 
when 2.5 <= app_number_of_children then 72.0 
else 9.0 end as PSC_app_number_of_children 
 
, case 
when 1.581 <= act_call_cc then 9.0 
when 1.254 <= act_call_cc  and  act_call_cc < 1.581 then 18.0 
when 0.761 <= act_call_cc  and  act_call_cc < 1.254 then 23.0 
when act_call_cc < 0.761 then 29.0 
else 9.0 end as PSC_act_call_cc 
 
, case 
when act_ccss_n_statC < 4.5 then 9.0 
when 4.5 <= act_ccss_n_statC  and  act_ccss_n_statC < 10.5 then 32.0 
when 10.5 <= act_ccss_n_statC  and  act_ccss_n_statC < 19.5 then 67.0 
when 19.5 <= act_ccss_n_statC then 127.0 
else 9.0 end as PSC_act_ccss_n_statC 
 
, case 
when 1.5 <= act_ccss_maxdue  and  act_ccss_maxdue < 3.5 then 9.0 
when 3.5 <= act_ccss_maxdue then 23.0 
when 0.5 <= act_ccss_maxdue  and  act_ccss_maxdue < 1.5 then 44.0 
when act_ccss_maxdue < 0.5 then 76.0 
when act_ccss_maxdue is null then 100.0 
else 9.0 end as PSC_act_ccss_maxdue 
 
/* , 1/(1+exp(-(-0.0341550404026672*(0.0+ calculated PSC_app_income+ calculated PSC_app_loan_amount+ calculated PSC_app_number_of_children+ calculated PSC_act_call_cc+ calculated PSC_act_ccss_n_statC+ calculated PSC_act_ccss_maxdue)+(6.435939306400602)))) as PD */ 
 
, 0.0 
+ calculated PSC_app_income + calculated PSC_app_loan_amount + calculated PSC_app_number_of_children + calculated PSC_act_call_cc + calculated PSC_act_ccss_n_statC + calculated PSC_act_ccss_maxdue  as SCORECARD_POINTS 
 
from &zbior as indataset; 
quit; 
