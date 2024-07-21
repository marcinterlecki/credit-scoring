proc sql; 
create table  &zbior._score as 
select indataset.*  
, case 
when act_age < 52.5 then 201.0 
when 52.5 <= act_age  and  act_age < 61.5 then 213.0 
when 61.5 <= act_age  and  act_age < 68.5 then 225.0 
when 68.5 <= act_age  and  act_age < 76.5 then 236.0 
when 76.5 <= act_age then 264.0 
else 201.0 end as PSC_act_age 
 
, case 
when 0.838 <= act_cc then 201.0 
when 0.618 <= act_cc  and  act_cc < 0.838 then 214.0 
when 0.506 <= act_cc  and  act_cc < 0.561 then 218.0 
when 0.561 <= act_cc  and  act_cc < 0.618 then 221.0 
when act_cc < 0.506 then 225.0 
else 201.0 end as PSC_act_cc 
 
, case 
when app_number_of_children < 0.5 then 201.0 
when 0.5 <= app_number_of_children  and  app_number_of_children < 1.5 then 211.0 
when 1.5 <= app_number_of_children then 241.0 
else 201.0 end as PSC_app_number_of_children 
 
, case 
when app_spendings < 250.0 then 201.0 
when 870.0 <= app_spendings then 207.0 
when 250.0 <= app_spendings  and  app_spendings < 370.0 then 211.0 
when 470.0 <= app_spendings  and  app_spendings < 870.0 then 212.0 
when 370.0 <= app_spendings  and  app_spendings < 470.0 then 216.0 
else 201.0 end as PSC_app_spendings 
 
, case 
when 1.453 <= act_call_cc then 201.0 
when 1.254 <= act_call_cc  and  act_call_cc < 1.453 then 216.0 
when 0.767 <= act_call_cc  and  act_call_cc < 1.254 then 226.0 
when 0.519 <= act_call_cc  and  act_call_cc < 0.767 then 229.0 
when act_call_cc < 0.519 then 234.0 
else 201.0 end as PSC_act_call_cc 
 
, case 
when 1.5 <= act_ccss_n_statC  and  act_ccss_n_statC < 3.5 then 201.0 
when 0.5 <= act_ccss_n_statC  and  act_ccss_n_statC < 1.5 then 203.0 
when 3.5 <= act_ccss_n_statC  and  act_ccss_n_statC < 8.5 then 207.0 
when act_ccss_n_statC < 0.5 then 212.0 
when 8.5 <= act_ccss_n_statC then 251.0 
else 201.0 end as PSC_act_ccss_n_statC 
 
, case 
when 3.5 <= act_ccss_maxdue  and  act_ccss_maxdue < 6.5 then 201.0 
when 6.5 <= act_ccss_maxdue then 211.0 
when 1.5 <= act_ccss_maxdue  and  act_ccss_maxdue < 3.5 then 212.0 
when 0.5 <= act_ccss_maxdue  and  act_ccss_maxdue < 1.5 then 253.0 
when act_ccss_maxdue < 0.5 then 283.0 
when act_ccss_maxdue is null then 284.0 
else 201.0 end as PSC_act_ccss_maxdue 
 
, case 
when 3.5 <= act_ccss_min_lninst  and  act_ccss_min_lninst < 8.5 then 201.0 
when 1.5 <= act_ccss_min_lninst  and  act_ccss_min_lninst < 3.5 then 203.0 
when 8.5 <= act_ccss_min_lninst  and  act_ccss_min_lninst < 11.5 then 206.0 
when 11.5 <= act_ccss_min_lninst then 212.0 
when act_ccss_min_lninst < 1.5 then 220.0 
when act_ccss_min_lninst is null then 231.0 
else 201.0 end as PSC_act_ccss_min_lninst 
 
, case 
when 11.5 <= ags3_Min_CMaxA_Days  and  ags3_Min_CMaxA_Days < 13.5 then 201.0 
when 10.5 <= ags3_Min_CMaxA_Days  and  ags3_Min_CMaxA_Days < 11.5 then 203.0 
when 14.5 <= ags3_Min_CMaxA_Days then 203.0 
when 13.5 <= ags3_Min_CMaxA_Days  and  ags3_Min_CMaxA_Days < 14.5 then 204.0 
when ags3_Min_CMaxA_Days < 10.5 then 207.0 
else 201.0 end as PSC_ags3_Min_CMaxA_Days 
 
, case 
when ags6_Mean_CMaxI_Due is null then 201.0 
when 0.292 <= ags6_Mean_CMaxI_Due then 206.0 
when ags6_Mean_CMaxI_Due < 0.292 then 216.0 
else 201.0 end as PSC_ags6_Mean_CMaxI_Due 
 
/* , 1/(1+exp(-(-0.03473752713072145*(0.0+ calculated PSC_act_age+ calculated PSC_act_cc+ calculated PSC_app_number_of_children+ calculated PSC_app_spendings+ calculated PSC_act_call_cc+ calculated PSC_act_ccss_n_statC+ calculated PSC_act_ccss_maxdue+ calculated PSC_act_ccss_min_lninst+ calculated PSC_ags3_Min_CMaxA_Days+ calculated PSC_ags6_Mean_CMaxI_Due)+(76.17611912819946)))) as PD */ 
 
, 0.0 
+ calculated PSC_act_age + calculated PSC_act_cc + calculated PSC_app_number_of_children + calculated PSC_app_spendings + calculated PSC_act_call_cc + calculated PSC_act_ccss_n_statC + calculated PSC_act_ccss_maxdue + calculated PSC_act_ccss_min_lninst + calculated PSC_ags3_Min_CMaxA_Days + calculated PSC_ags6_Mean_CMaxI_Due  as SCORECARD_POINTS 
 
from &zbior as indataset; 
quit; 
