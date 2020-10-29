/************************************************************************************************/
/*											 	*/
/*	Project title: Deriving birth cohort in Hospital Episode Statistics	        	*/
/*      Do-file title: 3. Deriving a birth cohort in HES data					*/
/* 	Author: Ania Zylbersztejn								*/
/*	Date created: 10.11.2017 								*/
/* 	Date modified: 14.10.2020								*/
/*												*/
/************************************************************************************************/

/* this do-file contains criteria for identifying birth episodes
and excluding stillbirths, multiple births  

Prior to running this do-file, we applied preliminary cleaning to the extract 
of HES (using "1. HES - basic cleaning for recorded variables.do") and to the extract of HES-ONS death data 
using (using 2. HES-ONS death file - basic cleaning for recorded variables.do") */


********************************* housekeeping **********************************

* 1. use global macro filepath to define where you save the data created in the process
global filepath "write filepath here X:\...."


* 2. load the data created previously
use "${filepath}\infant_records.dta", clear		


		
********** check initial number of episodes and unique HESIDs in the dataset
capture drop tmp
bysort encrypted_hesid: gen tmp=_n
tab ydob, mi
tab ydob if tmp==1
drop tmp

*********** generate year of birth
capture drop ydob
tostring mydob, replace
gen ydob=substr(mydob, -4, .)  /*year of birth */
destring ydob, replace
tab ydob

********** we shouldn't have any episodes before 1997
drop if ydob<1997
drop if ydob<2014

********** keep only potential birth episodes
keep if startage==7001 | startage==7002            /* age at admission <6 days */


********** check the numbers of episodes and unique HES IDs
capture drop tmp
bysort encrypted_hesid: gen tmp=_n
tab ydob, mi
tab ydob if tmp==1
drop tmp

********** merge ONS deaths
merge m:1 encrypted_hesid using "${filepath}\linked_ONS.dta"
drop if _merge==2      /*drop deaths that did not link to a birth */
drop _merge



*******************************************************************************
*
*			Inclusion criteria						   
*
*******************************************************************************

*** generate an indicator of birth episiode
gen birth=.

*** identify births based on diagnostic codes
foreach var of varlist diag_01-diag_20 {
	replace birth = 1 if strpos(`var', "Z38")>0
	replace birth = 1 if strpos(`var', "Z37")>0
}

*** identify births based on healthcare resource group codes
replace birth = 1 if (strpos(hrgnhs, "N01")>0 | strpos(hrgnhs, "N02")>0 | strpos(hrgnhs, "N03")>0 | strpos(hrgnhs, "N04")>0 | strpos(hrgnhs, "N05")>0 )
replace birth = 1 if (strpos(hrgnhs, "PB01")>0 | strpos(hrgnhs, "PB02")>0 | strpos(hrgnhs, "PB03")>0 )

*** identify births using HES specific fields
replace birth = 1 if (epitype==3 | epitype==6)  /* episode type */
replace birth = 1 if classpat==5				/* patient classification */
replace birth = 1 if (admimeth== "82" | admimeth== "83" | admimeth=="2C") /* admission method */
replace birth = 1 if (neocare==1 | neocare==2 | neocare==3 | neocare==0) /* level of provided neonatal care */

*** indicate HESIDs for which at least one birth episode was identified
bysort encrypted_hesid: egen birth_id=min(birth)

*** count the number of identified unique HESIDs
capture drop tmp
bysort encrypted_hesid: gen tmp=_n
tab ydob if tmp==1 & birth_id==1
drop tmp

*** drop records with no birth episodes from the birth cohort
drop if birth_id!=1



************************************************************************
*
*			Exclusion Criteria
*
************************************************************************

************************************************************************
*			remove multiple births
************************************************************************

*** generate an indicator of multiple birth
gen multibirth=.

*** identify multiple births using diagnostic codes
foreach var of varlist diag_01-diag_20 {
	replace multibirth=1 if (substr(`var',1,4)=="Z383" | substr(`var',1,4)=="Z384" | substr(`var',1,4)=="Z385") 	/* twins */
	replace multibirth=1 if (substr(`var',1,4)=="Z372" | substr(`var',1,4)=="Z373" | substr(`var',1,4)=="Z374") 	/* twins */
	replace multibirth=1 if (substr(`var',1,4)=="Z386" | substr(`var',1,4)=="Z387" | substr(`var',1,4)=="Z388") 	/* other multiple birth */
	replace multibirth=1 if (substr(`var',1,4)=="Z375" | substr(`var',1,4)=="Z376" | substr(`var',1,4)=="Z377") 	/* other multiple birth */
}

*** identify multiple births using variables in the baby tail
replace multibirth=1 if birordr_1>1 & birordr_1!=. /*position in the sequence of births */
replace multibirth=1 if numbaby>1 & numbaby!=. /* number of babies delivered at the end of a single pregnancy */

*** tag all episodes of care for HESIDs marked as multiple births
bysort encrypted_hesid: egen multibirth_id=max(multibirth)

*** count the number of multiple births
capture drop tmp
bysort encrypted_hesid: gen tmp=_n
tab ydob if tmp==1 & multibirth_id!=.
drop tmp

*** save multiple births in a separate dataset
preserve
	keep if multibirth_id!=. 
	save "${filepath}\multiple_births.dta", replace
	tab birth, mi
restore

*** drop multiple births from the cohort
drop if multibirth_id!=. 

*** drop variables associated with multiple births which we do not need anymore
drop multibirth*
drop birweit_2 birweit_3 birweit_4 birweit_5 birweit_6 birweit_7 birweit_8 birweit_9 
drop gestat_2 gestat_3 gestat_4 gestat_5 gestat_6 gestat_7 gestat_8 gestat_9  
drop birstat_2 birstat_3  birstat_4  birstat_5  birstat_6  birstat_7  birstat_8  birstat_9 
drop biresus_2 biresus_3 biresus_4 biresus_5 biresus_6 biresus_7 biresus_8 biresus_9 
drop delstat_2 delstat_3 delstat_4 delstat_5 delstat_6 delstat_7 delstat_8 delstat_9
drop delmeth_2 delmeth_3 delmeth_4 delmeth_5 delmeth_6 delmeth_7 delmeth_8 delmeth_9
drop birordr_2 birordr_3 birordr_4 birordr_5 birordr_6 birordr_7 birordr_8 birordr_9
drop sexbaby_2 sexbaby_3 sexbaby_4 sexbaby_5 sexbaby_6 sexbaby_7 sexbaby_8 sexbaby_9

*** rename variables for singleton births
rename birordr_1 birordr
rename gestat_1 gestat
rename birweit_1 birweit
rename birstat_1 birstat
rename delstat_1 delstat
rename biresus_1 biresus
rename delmeth_1 delmeth
rename sexbaby_1 sexbaby




*****************************************************************************
* 		remove records marked as termination of pregnancy
*****************************************************************************

*** generate an indicator of TOP
gen tmp=.

*** indentify TOPs using diagnostic codes
foreach var of varlist diag_01-diag_20 {
	replace tmp=1 if substr(`var',1,4)=="P964" 
}

*** tag all episodes for HESIDs marked as TOPs
bysort encrypted_hesid: egen tmp_id=min(tmp)
	

*** drop all episodes for HESIDs indicated as TOPs from the cohort
drop if tmp_id==1

*** drop all variables associated with TOP
drop tmp_id*




**************************************************************************
* 			remove stillbirths		       
**************************************************************************

*** generate an indicator for a stillbirth
gen stillbirth=.

*** indicate stillbirths based on diagnostic codes
foreach var of varlist diag_01-diag_20 {
	replace stillbirth=1 if substr(`var',1,4)=="Z371" | substr(`var',1,3)=="P95" 	
}

*** indicate stillbirths based on HES specific fields
replace stillbirth=1 if dismeth==5						/* discharge method */
replace stillbirth=1 if birstat==2 | birstat==3 | birstat==4  /* birth status */

*** tag all episodes of care for HESIDs marked as stillbirths
bysort encrypted_hesid: egen stillbirth_id=min(stillbirth)

*** calculate the number of identified stillbirths
capture drop tmp
bysort encrypted_hesid: gen tmp=_n
tab ydob if stillbirth_id==1 & tmp==1, mi
drop tmp

*** save stillbirths in a separate dataset and investigate misclassified stillbirths	
preserve
	
	* save all stillbirths in a separate folder
	keep if stillbirth_id!=. 
	save "${filepath}\stillbirth.dta", replace

	* merge information about deaths with a death certificate from ONS
	merge m:1 encrypted_hesid using "${filepath}\linked_ONS.dta"
	keep if _merge==3
	keep if dod!=.

	* remove deaths with no death certificate
	tab death_record_used dismeth
	drop if death_record_used=="HES1" | death_record_used=="HES2"

	* keep highest quality matches with ONS to add back to the cohort
	* they are likely to be misclassified stillbirths since stillbirths 
	* have different death certificate 
	tab death_record_used match_rank
	keep if match_rank==1 | match_rank==2 /* only ones based on NHS number */

	* indicate these misclassified births
	gen misclasssb=1

	* remove information about deaths - it will be merged with the cohort at later stage
	drop record_id age_at_death underlying_cause cause_of_* communal_establishment ///
		death_record_used nhs_indicator_ons respct_ons resstha_ons sex_ons ///
		match_rank dod dor partyear _merge
	
	* save these stillbirths in a separate file
	save "${filepath}\misclassified_stillbirths.dta", replace
	
restore

*** drop all episodes for HESIDs indicated as stillbirths from the cohort
drop if stillbirth_id==1 

*** add misclassified stillbirths back to the cohort
append using "${filepath}\misclassified_stillbirths.dta"
tab misclasssb, mi

*** drop all variables generated for stillbirths
drop stillbirth*


**************************************************************************
* 			save the cohort		       
**************************************************************************
save "${filepath}birth_cohort.dta", replace





******************************************************************************************************
*
*	Additional data cleaning & deduplication to ensure one birth episode per HESID
*
******************************************************************************************************

************************************************************************************
*        			remove unfinished episodes
************************************************************************************
/* NHD Digital advises to remove unfinished episodes as they should not contain any
clinical details and more complete episodes should be recorded within HES */

*** count number of episodes that are unfinished
tab ydob if epistat!=3, mi

*** remove unfinished episodes
drop if epistat!=3 

****************************************************************************
*				clean recorded admission dates
****************************************************************************

/* cleaning of implausible combinations of dates in the admission is especially
important for earlier HES years, where there were more errors in the data */

************ missing admission dates
tab ydob if admidate==.
replace admidate=epistart if admidate==. & epiorder==1 /* 2 changes */
tab ydob if admidate==.
sort encrypted_hesid epistart epiorder
replace admidate=admidate[_n-1] if admidate==. & epiorder!=1 & encrypted_hesid==encrypted_hesid[_n-1]
tab ydob if admidate==.
replace admidate=epistart if admidate==.

************ missing episode start dates
tab ydob if epistart==.

************ episode start is after the episode end
tab ydob if epistart>epiend 
replace epistart=admidate if epistart>epiend & epiend>=admidate 
/* if there's an issue with episode start and rest looks ok*/
replace epiend=epistart if epistart>epiend & epistart==admidate 
/* if there's an issue with episode end and rest looks ok*/

tab ydob if epistart>epiend 
gen tmp=1 if epistart>epiend & admidate>disdate & disdate!=. /* if dates are the other way round*/
gen epiend_tmp=epiend if tmp==1
gen epistart_tmp=epistart if tmp==1
replace epistart=epiend_tmp if tmp==1
replace epiend=epistart_tmp if tmp==1
gen admidate_tmp=admidate if tmp==1
gen disdate_tmp=disdate if tmp==1
replace admidate=disdate_tmp if tmp==1
replace disdate=admidate_tmp if tmp==1
drop *tmp*

tab ydob if epistart>epiend

************ episode start is before admission date
tab ydob if epistart<admidate
replace epistart=admidate if epistart<admidate

************ episode start is before admission date
tab ydob if epiend<admidate
replace epiend=epistart if  epiend<admidate

************ age at start of admission is higher than age at the end of admission
gen tmp=1 if endage<startage & endage>7000
tab ydob if tmp==1
gen endage_tmp=endage if tmp==1
gen startage_tmp=startage if tmp==1
replace endage=startage_tmp if tmp==1
replace startage=endage_tmp if tmp==1
drop *tmp*

************************************************************************************
*        		remove exact duplicates
************************************************************************************

duplicates tag encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* birweit gestat matage procode rescty ///
epistart epiend admidate disdate imd04rk, generate(tag) 
tab tag ydob, mi

duplicates drop encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* birweit gestat matage procode rescty ///
epistart epiend admidate disdate imd04rk, force
drop tag

************************************************************************************
*      			additional cleaning of risk factors at birth
************************************************************************************

*********** gestational age **************

*** additional data cleaning
tab gestat
replace gestat=. if gestat>45
replace gestat=. if gestat<22

*** copy mode of gestational age between episodes of the same HESID
bysort encrypted_hesid: egen gestat_compl=mode(gestat) /* get mode of gestational age for each HESID*/

*** flag plausible false matches, where information is conflicting between episodes
gen gestat_check=1 if gestat!=. & gestat!= gestat_compl /* flag those where gestational age is not the same as the mode (where it's not NA) */
bysort encrypted_hesid: egen gestat_check_id=min(gestat_check) /*flag all episodes for these HESIDs*/
tab gestat_check_id, mi
 


*********** birthweight **************

*** additional data cleaning
hist birweit
replace birweit=. if birweit<200

*** copy mode of birth weight between episodes of the same HESID
bysort encrypted_hesid: egen birweit_compl=mode(birweit) /* get mode of birthweight for each HESID*/

*** flag plausible false matches, where information is conflicting between episodes
gen birweit_check=1 if birweit!=. & birweit!= birweit_compl /* flag those where birthweight is not the same as the mode (where it's not NA) */
bysort encrypted_hesid: egen birweit_check_id=min(birweit_check) /*flag all episodes for these HESIDs*/
tab birweit_check_id, mi


*********** mother's age **************

*** additional cleaning
tab matage
replace matage=. if matage>60
replace matage=. if matage<10

*** copy mode of maternal age between episodes of the same HESID
bysort encrypted_hesid: egen matage_compl=mode(matage) /* get mode of maternal age */
gen matage_check=1 if matage!=. & matage!= matage_compl /* flag HESIDs where maternal age differs between episodes */

*** flag plausible false matches, where information is conflicting between episodes
bysort encrypted_hesid: egen matage_check_id=min(matage_check) /*flag all episodes for these HESIDs*/
tab matage_check_id, mi


*****************************************************************************
*			remove likely false matches
*****************************************************************************

/* check if there are likely false matches by exploring conflicting information for 
birth weigth, gestational age or maternal age between multiple records with the same HESID */

tab ydob if (birweit_check_id==1 | gestat_check_id==1 | matage_check_id==1), mi

preserve
	* save likely missed matches in a separate folder
	keep if (birweit_check_id==1 | gestat_check_id==1 | matage_check_id==1)
	save "${filepath}\false_matches.dta", replace
restore

*** remove false matches from the cohort
drop if (birweit_check_id==1 | gestat_check_id==1 | matage_check_id==1)

*** drop variables that we dont need anymore
capture drop *_check*


*** indicate HESIDs for which there is more than one recorded month and year of birth
destring mydob, replace
bysort encrypted_hesid: egen mydob_tmp=min(mydob)
gen diff=mydob-mydob_tmp
tab diff
gen mydob_tmp2=1 if diff!=0


*** indicate all episodes for HESIDs with multiple month and year of birth recorded
bysort encrypted_hesid: egen mydob_tmp3=max(mydob_tmp2)
tab ydob if mydob_tmp3==1, mi

*** add these indicated false matches to dataset with false matches identified above
preserve
	tostring mydob, replace
	keep if mydob_tmp3==1
	append using "${filepath}\false_matches.dta"
	save "${filepath}\false_matches.dta", replace
restore

*** remove these false matches from the cohort
drop if  mydob_tmp3==1

*** remove unneeded variables
capture drop  mydob_tmp* diff


********************************************************************
*			remove near exact duplicates
********************************************************************

/* we de-duplicated the records once again after copying information on
birth weight, gestational age and maternal age between episodes of care */

capture drop tag
duplicates tag encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* birweit_compl gestat_compl matage_compl ///
epistart epiend admidate procode, generate(tag) 
tab tag ydob
drop tag

duplicates drop encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* birweit_compl gestat_compl matage_compl ///
epistart epiend admidate procode , force

/* remaining multiple episodes of care per HESID are consecutive episodes of 
care after birth. We kept the first episode as the birth episode */

*** check how many HESIDs have more than one birth episode in the cohort
capture drop tag
duplicates tag encrypted_hesid, gen(tag)
tab tag
drop tag

*** number episodes of care per HESID from the earliest to the latest
bysort encrypted_hesid (admidate epistart epiend epiorder): gen episode_no2=_n

*** keep the first episode per HESID
keep if episode_no2==1

*** drop unnecessary variables
keep encrypted_hesid ydob bday birweit_compl gestat_compl matage_compl sex misclasssb hesyr

tab ydob, mi


**************************************************************************************************
*
*	Apply centiles (based on work of Professor Tim Cole) to remove implausible 
*                combinations of birth weight and gestational age 
* 			from  "BW GA centiles.do" do-file"
*
**************************************************************************************************

global implaus "implaus"
global birweit "birweit_compl"
global gestat "gestat_compl"
global sex "sex"
do "{filepath}\BW GA centiles.do"

tab implaus, mi
replace ${gestat}=. if ${implaus}==1
replace ${birweit}=. if ${implaus}==1

drop implaus


*** save the cohort
compress
save "${filepath}clean_births.dta", replace



