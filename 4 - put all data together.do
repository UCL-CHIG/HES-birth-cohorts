***************************************************************************
*
*						derive extra indicators
*
***************************************************************************

******************************************************************
*			earliest mention of postcode and related vars in infancy
******************************************************************

use "${filepath2}\clean_hesons.dta", clear

tab ydob if bday_compl==., mi

**** keep if post code is not missing:
keep if postdist_compl!=""
keep if startage>7000

**** sort records by admission date to keep the first mention of postcode
bysort encrypted_hesid (adm_no episode_no2): gen tmp=_n
keep if tmp==1

**** optionally, can derive age at which psotcode was first recorded
gen postcode_age=admd-bday_compl
tab postcode_age if postcode_age<10
replace postcode_age=0 if postcode_age<0
rename admd postcode_date

**** keep only records in infancy
keep if postcode_age<365 & postcode_age!=.

**** keep all other previously derived variables
keep encrypted_hesid ydob imd04rk_compl resgor_compl postdist_compl postcode_date 

save "${filepath2}\postcode_info.dta"


******************************************************************
*			Ethnicity (based on most frequently recorded value)
******************************************************************

log using "${filepath2}\logs\ethnos.log", replace
keep encrypted_hesid ethnos
tab ethnos, mi

encode ethnos, gen(eth_tmp)

tab eth_tmp, mi
drop if eth_tmp==.

bysort encrypted_hesid: egen ethnos_compl = mode(eth_tmp)
tab eth_tmp, mi
tab ethnos_compl, mi
* only 15k where conflicting info

drop if ethnos_compl==.
* those conflicting - try to make them into broader cat and see if still conflicting

keep encrypted_hesid ethnos_compl

decode ethnos_compl, gen(ethnos_baby)

drop ethnos_compl

duplicates drop *, force
duplicates tag encrypted_hesid, gen(tag)
tab tag
drop tag

save "${filepath2}\ethnos_baby.dta", replace



************************************************************
*				length of birth admission
************************************************************

use "${filepath2}\clean_hesons.dta", clear

**** keep the first admission
keep if adm_no==1

gen birth_adm=disd-admd
tab birth_adm if birth_adm==.
replace birth_adm=disdate-admidate if birth_adm==.
tab ydob if birth_adm==.
label var birth_adm "Length of birth admission"

keep encrypted_hesid birth_adm

duplicates tag encrypted_hesid, gen(tag)
tab tag
duplicates tag *, gen(tag1)
tab tag1
drop tag*
duplicates drop *, force 
duplicates drop encrypted_hesid, force 

save "${filepath2}\length_birth_adm.dta", replace



***************************************************************************
*
*						merge
*
***************************************************************************

use "{filepath2}\clean_birthcohort.dta", clear
 
rename birweit birweit_compl
rename matage matage_compl
rename gestat gestat_compl
 
keep encrypted_hesid sex hesyr ydob misclasssb gestat_compl birweit_compl matage_compl bday
 
format bday %td

duplicates tag encrypted_hesid, gen(tag)	
tab tag
drop tag

duplicates drop encrypted_hesid birweit_compl gestat_compl matage_compl, force

duplicates tag encrypted_hesid, gen(tag)	
tab tag

duplicates drop encrypted_hesid, force

save  "{filepath2}\clean_birthcohort.dta", replace


********************************************************************************
*								sort out deaths
********************************************************************************
use "{filepath2}\clean_onsdeaths.dta", clear


tab source if nhs_indicator_ons!=.
replace nhs_indicator=nhs_indicator_ons if nhs_indicator==.	
drop nhs_indicator_ons
	
duplicates drop encrypted_hesid resstha_ons respct_ons sex_ons communal_establishment ///
 nhs_indicator underlying_cause cod_* match_rank death_record_used dod dor ageatdeath, force 
	
duplicates tag encrypted_hesid, gen(tag)	
tab tag

duplicates drop encrypted_hesid, force
	
merge 1:1 encrypted_hesid using "{filepath2}\clean_birthcohort.dta"

drop if _merge==1

drop _merge source tag

save "{filepath2}\clean_birthcohort.dta", replace

********************************************************************************
*								add postcode
********************************************************************************
use "\imd_scores_birth.dta", clear

duplicates tag encrypted_hesid, gen(tag)	
tab tag
drop tag

tab ydob, mi

tab resgor_compl ydob, mi

merge 1:1 encrypted_hesid using "{filepath2}\clean_birthcohort.dta"

* these are mainly non english residents anyways
drop if _merge==1

tab resgor_compl, mi

tab ydob if resgor_compl=="S" | resgor_compl=="W" | resgor_compl=="X" | resgor_compl=="Z"

* need to drop non-English residents from updated data
drop  if resgor_compl=="S" | resgor_compl=="W" | resgor_compl=="X" | resgor_compl=="Z"

gen imd04decile=.
replace imd04decile=0 if imd04rk_compl<=3248
replace imd04decile=1 if imd04rk_compl>3248 & imd04rk_compl<=6496
replace imd04decile=2 if imd04rk_compl>6496 & imd04rk_compl<=9745
replace imd04decile=3 if imd04rk_compl>9745 & imd04rk_compl<=12993
replace imd04decile=4 if imd04rk_compl>12993 & imd04rk_compl<=16241
replace imd04decile=5 if imd04rk_compl>16241 & imd04rk_compl<=19489
replace imd04decile=6 if imd04rk_compl>19489 & imd04rk_compl<=22737
replace imd04decile=7 if imd04rk_compl>22737 & imd04rk_compl<=25986
replace imd04decile=8 if imd04rk_compl>25986 & imd04rk_compl<=29234
replace imd04decile=9 if imd04rk_compl>29234 & imd04rk_compl<=32482

tab imd04decile, mi


drop _merge 

save "{filepath2}\clean_birthcohort.dta", replace


********************************************************************************
*							Tim Cole's centiles
********************************************************************************
global implaus "implaus"
global birweit "birweit_compl"
global gestat "gestat_compl"
global sex "sex"
do "S:\CPRU_HES_9713\CPRU_Data\Extracts\Ania\cleaning BW and GA\Centiles for +-4SD v1.do"

tab implaus, mi
replace ${gestat}=. if ${implaus}==1
replace ${birweit}=. if ${implaus}==1

drop implaus

save "{filepath2}\clean_birthcohort.dta", replace

********************************************************************************
*								add ethnos and length of stay
********************************************************************************
use "\ethnos_baby.dta", clear

duplicates tag encrypted_hesid, gen(tag)	
tab tag

merge 1:1 encrypted_hesid using "length_birth_adm.dta"

drop tag _merge
duplicates tag encrypted_hesid, gen(tag)	
tab tag

drop tag

merge 1:1 encrypted_hesid using "{filepath2}\clean_birthcohort.dta"

drop if _merge==1
drop _merge
replace birth_adm=0 if birth_adm==. /*only 7 like that */

save "{filepath2}\clean_birthcohort.dta", replace


************************* extra weird things *******************************
tab resgor_compl ydob, mi
replace resgor_compl="" if resgor_compl=="x"

tab ydob if birth_adm==.
replace birth_adm=0 if birth_adm==.

tab ydob cong_anom, mi row

drop imd04i_compl imd04ed_compl resstha_ons respct_ons sex_ons communal_establishment nhs_indicator
label var dod "date of death"
label var dor "date of registration"

tab sex, mi

save "{filepath2}\clean_birthcohort.dta", replace
