/************************************************************************************************/
/*											 	*/
/*		Title: Deriving birth cohort in Hospital Episode Statistics	        	*/
/*            2. basic cleaning of HES-ONS mortality extract						*/
/* 		Author: Ania Zylbersztejn							*/
/*		Date created: 10.11.2017 							*/
/* 		Date modified: 12.11.2019							*/
/*												*/
/************************************************************************************************/

/* this do-file contains some preliminary cleaning rules for variables 
recorded in HES-ONS mortality extract. The code ensures e.g. consistent coding of missing values, 
removes implausible values etc. */

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


