/************************************************************************************************/
/*											 	*/
/*	Project title: Deriving birth cohort in Hospital Episode Statistics	        	*/
/*      Do-file title: 3. basic cleaning of HES-ONS mortality extract				*/
/* 	Author: Ania Zylbersztejn								*/
/*	Date created: 10.11.2017 								*/
/* 	Date modified: 14.10.2020								*/
/*												*/
/************************************************************************************************/

/* this do-file contains cleaning rules for variables recorded in HES-ONS mortality extract. 
The code ensures e.g. consistent coding of missing values, removes implausible values etc. We then
link HES-ONS mortality records to HES, evaluate linkage and remove implausible links. 

Prior to running this do-file, we applied derived a clean dataset with infant hospital admissions 
using "1 - cleaning of HES extract.do" and "2 - cleaning and linking hospitalisation history infancy.do"

*/



********************************* housekeeping **********************************

* 1. use global macro filepath to define where you save the data created in the process
global filepath "write filepath here X:\...."

* 2. load the data
use "XXXXX.dta", clear


**************************** cleaning of deaths *******************************

/*Formating dates with DD/MM/YYYY information*/
foreach var of varlist dod dor  {
	gen d_`var' = date(`var',"YMD")
	format d_`var' %td
	drop `var'
	rename d_`var' `var'
}

foreach var of varlist dod dor  {
	replace `var' = . if `var' < mdy(01,01,1930)
}

/*Remove dashes from causes of death(repeat until 0 changes reported)*/
codebook cause_*
foreach var of varlist cause_*  {
	tostring `var', replace
	replace `var' = subinstr(`var',"-","",.)
}

/*Remove spaces from causes of death(repeat until 0 changes reported)*/
foreach var of varlist cause* {
	replace `var' = subinstr(`var'," ","",1)
}

foreach var of varlist cause* {
	replace `var' = subinstr(`var',"/","",1)
}

foreach var of varlist cause* {
	replace `var' = subinstr(`var',".","",1)
}


rename cause_of_death underlying_cause
rename nhs_indicator nhs_indicator_ons
rename respct respct_ons
replace respct_ons="" if respct_ons=="59999" | respct_ons=="59898"
rename resstha resstha_ons
replace resstha_ons="" if resstha_ons=="Y"

/* sex_ons */
rename sex sex_ons
tab sex_ons, mi
label define sexl 1 "Male" 2 "Female"
label value sex sexl
replace sex_ons=. if sex_ons!=1 & sex_ons!=2 /* not specified or not known */
label value sex_ons sexl 


************* save deaths that were linked to a HES record *************

drop if encrypted_hesid==""
save "${filepath}\linked_ONS.dta", replace





*********************************************************************************************** 
*
*		Link ONS mortality records with HES records for cross-validations
*
*********************************************************************************************** 


******************** load HES data
use "${filepath}clean_infant_records.dta", clear


******************** merge deaths
merge m:1 encrypted_hesid using "${filepath}\linked_ONS.dta"
drop if _merge==2 /* deaths that didn't match */
drop _merge


****************** generate new hes id number
capture drop hesid
egen hesid = group(encrypted_hesid)



*************************************************************************
*			keep only records with a potential death
************************************************************************

******** add hospital deaths
gen deathdate4 = disdate_compl if dismeth==4
bysort hesid: egen deathdate4_id=max(deathdate4)
format deathdate4_id %td
format deathdate4 %td

replace death_record_used="My HES" if dod==. & deathdate4_id!=.
replace dod=deathdate4_id  if dod==. & deathdate4_id!=.

tab ydob if dod!=.

********* keep only deaths
keep if dod!=.



*************************************************************************
*					false matches
************************************************************************

******** generate age at death variable
gen ageatdeath=dod-bday_compl
replace ageatdeath=. if dod==.
gen ageatdeath_year=ageatdeath/365.25
tab ageatdeath_year


*********** remove death information for those who died after the age of 1
tab ydob  if ageatdeath_year>=1 & ageatdeath_year!=.
gen tmp=1 if ageatdeath_year>=1 & ageatdeath_year!=.
tab ydob  if tmp==1, mi

foreach var of varlist  dod dor nhs_indicator_ons match_rank ///
	sex_ons  ageatdeath ageatdeath_year {
	qui replace `var'=. if tmp==1
}

foreach var of varlist resstha_ons respct_ons death_record_used ///
	 underlying_cause cause_of_death_* /// 
	communal_establishment {
	qui	replace `var'="" if tmp==1
}

drop tmp


********* remove deaths outside of the study period - zero
tab ydob  if dod<mdy(01,01,1998)
*tab ydob if dod>mdy(01,01,2016) & dod!=.


******** death before birth
*browse if ageatdeath<0
tab ageatdeath ydob if ageatdeath<0
tab ageatdeath match_rank if ageatdeath<0
tab ydob if ageatdeath==-1 & match_rank!=8
replace ageatdeath=0 if ageatdeath==-1 & match_rank!=8

gen tmp=1 if ageatdeath<0
tab ydob if tmp==1, mi

foreach var of varlist  dod dor nhs_indicator_ons match_rank ///
	sex_ons  ageatdeath ageatdeath_year { 
	qui replace `var'=. if tmp==1
}

foreach var of varlist resstha_ons respct_ons death_record_used ///
	 underlying_cause cause_of_death_* /// 
	communal_establishment {
	qui replace `var'="" if tmp==1
}

drop tmp
tab ydob if birth_compl==1 & dod!=., mi


******** subsequent activity - admissions after date of death
bysort hesid: egen last_admidate=max(admd)
format last_admidate %d

gen later_episodes=1 if last_admidate>dod
replace later_episodes=0 if later_episodes==.
replace later_episodes=0 if dod==.
tab later_episodes if birth_compl==1, mi 
tab ageatdeath if later_episodes==1 & birth_compl==1, mi 

gen later_episodes_dif= last_admidate-dod 
replace later_episodes_dif=. if later_episodes!=1
tab later_episodes_dif if birth_compl==1, mi 

tab death_record_used if later_episodes==1 & birth_compl==1

* if it is over 2 days difference - assume wrong link
gen tmp=1 if later_episodes_dif>1 & later_episodes_dif!=.
tab ydob  if tmp==1, mi

foreach var of varlist  dod dor nhs_indicator_ons match_rank ///
	sex_ons  ageatdeath ageatdeath_year ///
	later_episodes* {
	qui replace `var'=. if tmp==1
}

foreach var of varlist resstha_ons respct_ons death_record_used ///
	 underlying_cause cause_of_death_* /// 
	communal_establishment {
	qui replace `var'="" if tmp==1
}

drop tmp


************* difference in date of death in HES and in ONS
gen dod_diff = dod-deathdate4
tab  dod_diff death_record_used, mi

gen tmp=1 if (dod_diff>2 | dod_diff<-2) & dod_diff!=.
tab ydob  if tmp==1, mi

foreach var of varlist  dod dor nhs_indicator_ons match_rank ///
	sex_ons  ageatdeath ageatdeath_year ///
	later_episodes* {
	qui replace `var'=. if tmp==1
}

foreach var of varlist resstha_ons respct_ons death_record_used ///
	 underlying_cause cause_of_death_* /// 
	communal_establishment {
	qui replace `var'="" if tmp==1
}

drop tmp

drop hesid

drop dod_diff deathdate4_id deathdate4 
drop later_episodes_dif later_episodes last_admidate 

forvalues j=1(1)15 {
          rename cause_of_death_neonatal_`j' cod_neo_`j'
          rename cause_of_death_non_neonatal_`j' cod_non_neo_`j'
}

bysort encrypted_hesid: keep if _n==1
keep encrypted_hesid dod dor nhs_indicator_ons match_rank sex_ons  ageatdeath  resstha_ons respct_ons death_record_used underlying_cause cod_* communal_establishment

*********** save cleaned dataset with deaths
save "${filepath}\clean_linked_ONS.dta", replace




