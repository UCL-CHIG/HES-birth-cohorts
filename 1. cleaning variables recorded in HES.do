/************************************************************************************************/
/*												*/
/*		Project title: Deriving birth cohort in Hospital Episode Statistics	       	*/
/*            	Do-file title: 1. Basic cleaning for variables recorded in HES extracts		*/
/* 		Author: Ania Zylbersztejn							*/
/*		Date created: 10.11.2017 							*/
/* 		Date modified: 12.11.2019							*/
/*												*/
/************************************************************************************************/

/* this do-file contains some preliminary cleaning rules for variables 
recorded in HES. The code ensures e.g. consistent coding of missing values, 
removes implausible values etc. 

We used this do-file on an extract of HES admissions in children aged under 1 year old
prior to identifying births and linking episodes into admissions. */





********************************* housekeeping **********************************

* 1. use global macro filepath to define where you save the data created in the process
global filepath "write filepath here X:\...."

* 2. load the data
use "XXXXX.dta", clear


****************************** clean variables **********************************
* since coding of some variables changed from numerical to characters over time
* we save these variables as string for consistency over years
tostring admimeth, replace
tostring nhsnoind, replace
tostring sushrg, replace
tostring hrgnhs, replace
tostring opcs43, replace
tostring numbaby, replace


*********************** format dates to stata format *********************
foreach var of varlist *date* epistart epiend dob_full {
	rename `var' `var'_tmp
	gen `var'=date(`var'_tmp, "YMD")
	drop `var'_tmp
	format `var' %td
	}

************* change all diagnostic and operation fields to string *************	
foreach var of varlist diag* opertn*  { 
	tostring `var' , replace
} 


foreach var of varlist birord* { 
	tostring `var' , replace
}

/* age */
label define agel 7001 "Less than one day" 7002 "1 to 6 days" 7003 "7 to 28 days" ///
7004 "29 to 90 days" 7005 "3 to 6 months" 7006 "6 to 9 months" 7007 "9 to 12 months"
label value  startage agel
label value  endage agel

/* neodur - age of baby in days */
tab neodur
replace neodur=. if neodur>28 

/* ethnos */
replace ethnos="" if ethnos=="Z" | ethnos=="X" | ethnos=="9"
tab ethnos, mi /*  2,970,477  missing */

/* postdist - what to do? */
replace postdist="" if postdist=="-"

/* sex */
tab sex, mi
replace sex=. if sex==0 | sex==9
label define sexl 1 "Male" 2 "Female"
label value sex sexl

/* HES 2010-2013 - because since 2013 there are codes like 2A etc. */
replace admimeth="" if admimeth=="99" 

tab admisorc, mi
replace admisorc=. if admisorc==99

/* dismeth and disdest */
tab dismeth, mi
replace dismeth=. if dismeth==9
label define dismethl 1 "Discharged" 2 "Self-discharged" 3 "Discharged by a legal entity" 4 " Died" ///
5 "Stillborn" 8 "NA - Still in hospital" 
label val dismeth dismethl

tab disdest, mi
replace disdest=. if disdest==99

/* spells and epidur - derived fields so i don't need that... */
drop spelbgin speldur spelend epidur 

/* epiorder */
tab epiorder, mi
replace epiorder=. if epiorder==99 | epiorder==98

/* epistat */
tab epistat, mi
label define epistatl 1 "Unfinished" 3 "Finished" 9 "Derived unfinished"
label val epistat epistatl

/* epitype */
tab epitype, mi
label define epitypel 1 "General" 2 "Delivery" 3 "Birth" 4 "Mental Health" 5 "Delivery - other" 6 "Birth - other"
label val epitype epitypel

/* diagnosis codes */
*Remove dashes from cause and diag_01 to diag_20 (repeat until 0 changes reported)*

codebook diag* cause

foreach var of varlist cause diag* {
	replace `var' = subinstr(`var',"-","",.)
}

foreach var of varlist cause diag*  {
	replace `var' = subinstr(`var',"-","",.)
}

foreach var of varlist cause diag*  {
	replace `var' = subinstr(`var',"-","",.)
}

/*Remove spaces from cause and diag_01 to diag_20 (repeat until 0 changes reported)*/
foreach var of varlist cause diag_* {
	replace `var' = subinstr(`var'," ","",1)
}
foreach var of varlist cause diag_* {
	replace `var' = subinstr(`var'," ","",1)
}

foreach var of varlist cause diag_* {
	replace `var' = subinstr(`var',".","",1)
}
foreach var of varlist cause diag_* {
	replace `var' = subinstr(`var',".","",1)
}

foreach var of varlist cause diag_* {
	replace `var' = subinstr(`var',".","",1)
}

foreach var of varlist cause diag* {
	replace `var' = subinstr(`var',"/","",.)
}

foreach var of varlist cause diag*  {
	replace `var' = subinstr(`var',"/","",.)
}

foreach var of varlist cause diag*  {
	replace `var' = subinstr(`var',"/","",.)
}


/* clean procedure codes */
codebook opertn* 

forvalues i=1/9 {
	replace opertn_0`i'="" if opertn_0`i'=="&"|opertn_0`i'=="-"
	replace opertn_0`i'="" if substr(opertn_0`i',1,3)=="X63"|substr(opertn_0`i',1,3)=="X64"  /*These are retired codes according to OPCS book, 84 episodes contain codes with*/
}

forvalues i=10/24 {
	replace opertn_`i'="" if opertn_`i'=="&"|opertn_`i'=="-"
	replace opertn_`i'=""  if substr(opertn_`i',1,3)=="X63"|substr(opertn_`i',1,3)=="X64"
}
 
/* i have procodet, don't need all 3 */
drop procode3 procodet protype hrglate35 
 
/* residence */
replace rescty="" if rescty=="Y" /*uknown */
replace resha="" if resha=="Y"
replace resro="" if resro=="Y00" | resro=="Y" 
replace respct_his="" if respct_his=="59999" | respct_his=="59898"
replace resstha_his="" if resstha_his=="Y"

/* IMD decile */
label define imd04decl 0 "Most deprived 10%" 1 "More deprived 10-20%" 2 "More deprived 20-30%" ///
	3 "More deprived 30-40%" 4 "More deprived 40-50%" 5 "Less deprived 40-50%" ///
	6 "Less deprived 30-40%" 7 "Less deprived 20-30%" 8 "Less deprived 10-20%" ///
	9 "Least deprived 10%"
label value imd04_decile imd04decl 

/* GP practice */
replace gpprac="" if gpprac=="&" | gpprac=="V81999" | gpprac=="V81998"


/* delivery details */
replace delprean=. if delprean==9 | delprean==8
replace delposan=. if delposan==9 | delposan==8
replace delchang=. if delchang==9 | delchang==8

replace antedur=. if antedur>270

/* Birth order */
tab birordr_1, mi /* check if there are "X"s too */

/* from 2002 onwards - quite a lot of "X's" */
foreach var of varlist birordr_1-birordr_9 { 
	replace `var'="" if `var'=="X" 
	replace `var'="" if `var'=="9" | `var'=="8" 
	destring `var', replace
} 

/* Birth weight */
foreach var of varlist birweit_1-birweit_9 {
replace `var'=. if `var'>7000 
}

/* delivery method */
codebook delmeth*
tab delmeth_1, mi
replace delmeth_1="" if delmeth_1=="X"
destring delmeth_1, replace



replace delinten=. if delinten==9

/* gestation weeks */
foreach var of varlist gestat_1-gestat_9 {
replace `var'=. if `var'==99
}


/* Birth stat */
foreach var of varlist birstat_1-birstat_9 {
replace `var'=. if `var'==9 
}
label define birstatl 1 "Live" 2 "Still:antepart." 3 "Still:intrapart." 4 "Still:indeterm."
foreach var of varlist birstat_1-birstat_9 {
label value `var' birstatl 
}

replace delonset=. if delonset==9 | delonset==8

tab numbaby, mi /* check if got any Xs */
*replace numbaby=. if numbaby==9 /* HES 1997-2001 */
replace numbaby="" if numbaby=="9" | numbaby=="X" /* from 2002 onwards */
destring numbaby, replace

replace numpreg=. if numpreg==99
replace numpreg=. if numpreg>19 /* it's meant to go up to 19 */

replace postdur=. if postdur>270 /* it's meant to go to 270 days */

foreach var of varlist biresus* {
replace `var'=. if `var'==9 
}

tab sexbaby_1, mi
foreach var of varlist sexbaby* {
replace `var'=. if `var'!=1 &`var'!=2
}
foreach var of varlist sexbaby* {
label val `var' sexl
}

tab delstat_1, mi
foreach var of varlist delstat* {
replace `var'=. if `var'==9 
}


/* neocare */
tab neocare, mi
replace neocare=. if neocare==8 /* not applicable - episode doesnt involve neocare */
label define neocarel 0 "Normal Care" 1 "Special Care" 2 "L2 intensive" 3 "L1 intensive" 9 "Not known"
label val neocare neocarel

/* well baby*/
tab well_baby_ind, mi
encode well_baby_ind, generate(well_baby_ind2)
drop well_baby_ind
rename well_baby_ind2 well_baby_ind
order well_baby_ind, after(neocare)

/* date and year of birth */
gen ydob= mydob
tostring ydob, replace
replace ydob = "0"+ydob if length(ydob)==5
replace ydob = substr(ydob,-4, .)
tab ydob, missing
destring ydob, replace
order ydob, after (mydob)

/* calendar year */
gen calyr = year(epistart)



************ save the data **************

*drop if ydob<1998
drop if startage<7000 /* we focus on infants  */
drop if admidate<mdy(04,01,1997) /* episode end date before 1997 */
drop if epistart<mdy(04,01,1997) /* episode end date before 1997 */

compress
save "${filepath}infant_records.dta", replace

