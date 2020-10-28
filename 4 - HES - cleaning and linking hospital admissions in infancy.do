/************************************************************************************************/
/*											 	*/
/*	Project title: Deriving birth cohort in Hospital Episode Statistics	        	*/
/*      Do-file title: 4 - HES - cleaning and linking hospital admissions in infancy.do		*/
/* 	Author: Ania Zylbersztejn & Pia Hardelid						*/
/*	Date created: 10.11.2017 								*/
/* 	Date modified: 14.10.2020								*/
/*												*/
/************************************************************************************************/

/* this do-file contains code for cleaning episode records in HES and
linking them into admissions using algorithm developed by Dr Pia Hardelid 

Prior to running this do-file, we applied preliminary cleaning to the extract 
of HES using "1 - cleaning of HES extract.do" */




********************************* housekeeping **********************************

* 1. use global macro filepath to define where you save the data created in the process
global filepath "write filepath here X:\...."


* 2. load the data derived at the end of "1 - cleaning of HES extract.do" 
use "${filepath}infant_records.dta", clear

* drop admissions which started before 1998, as linkage to mortality records was not 
* available prior to that date
drop if admidate<mdy(01,01,1998)



******************************************************************************
*
*			additional data cleaning
*
******************************************************************************
 
******************************************************************************
*	        	remove duplicated episodes
******************************************************************************

duplicates tag encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* procode postdist ///
epistart epiend admidate disdate, generate(tag) 
tab tag ydob , mi

duplicates drop encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* procode postdist ///
epistart epiend admidate disdate, force



******************************************************************************
*						remove unfinished episodes
******************************************************************************
/* NHD Digital advises to remove unfinished episodes as they should not contain any
clinical details and more complete episodes should be recorded within HES */

tab ydob if epistat!=3, mi /* unfinished episodes */
drop if epistat!=3 



******************************************************************************
*		remove episodes with no clinical information
******************************************************************************

**************************** all diagnoses missing ******************************
capture drop tag
duplicates tag encrypted_hesid admidate epistart epiend, gen(tag)
tab tag, mi

egen miss_op_diag = rowmiss( opertn_0* opertn_1* opertn_2* diag_0* diag_1* diag_2* cause)    
/* calcualtes how many diagnoses+operations are missing for each row */

*** check how many episodes have missing diagnoses
tab ydob if miss_op_diag==45

*** drop episodes with no diagnoses
drop if miss_op_diag==45 & tag!=0
drop miss_op_diag tag


******************** only recorded diagnosis is R69X ****************************
duplicates tag encrypted_hesid admidate epistart epiend, gen(tag)
tab tag, mi
gen tmp=1 if substr(diag_01,1,3)=="R69"
tab ydob if tmp==1
tab tag tmp, mi
drop if tmp==1 & tag!=0
drop tmp* tag



*************************************************************************
				clean recordings of dates
*************************************************************************

************ fix admidate
tab ydob if admidate==.
replace admidate=epistart if admidate==. & epiorder==1 
tab ydob if admidate==.
sort encrypted_hesid epistart epiorder
replace admidate=admidate[_n-1] if admidate==. & epiorder!=1 & encrypted_hesid==encrypted_hesid[_n-1] & epiorder==epiorder[_n-1]+1
tab ydob if admidate==.
replace admidate=epistart if admidate==.

************ fix epistart
tab ydob if epistart==.
replace epistart=admidate if epistart==. & epiorder==1
sort encrypted_hesid admidate epiorder
replace epistart=epiend[_n-1] if epistart==. & epiorder!=1 & encrypted_hesid==encrypted_hesid[_n-1]

************ episode start is after the episode end
tab ydob if epistart>epiend 
replace epistart=admidate if epistart>epiend & epiend>=admidate 
replace epiend=epistart if epistart>epiend & epistart==admidate 

/* fix the dates if they are likely the other way round*/
tab ydob if epistart>epiend 
gen tmp=1 if epistart>epiend & admidate>disdate & disdate!=. 
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
replace epiend=epistart if epistart>epiend 

************ episode start is before admission date
tab ydob if epistart<admidate
replace epistart=admidate if epistart<admidate

************ episode start is before admission date
tab ydob if epiend<admidate

************ generate complete discharge date
bysort encrypted_hesid admidate: egen disdate_compl=max(disdate) 
bysort encrypted_hesid admidate: egen max_epiend=max(epiend) 
replace disdate_compl=max_epiend if disdate_compl==.
replace disdate_compl=max_epiend if disdate_compl<max_epiend
format disdate_compl %td
drop max_epiend 

tab ydob if epiend>disdate_compl

******* an episode lasts more than 1 year - incorreclty recorded year at date, more complete record present
gen epiendyr=year(epiend)
br *yr* if epiendyr!=calyr & epiendyr!=hesyr & epiend!=(calyr+1) & epiend!=(hesyr+1) & epiendyr!=.
gen diff_calyr= epiendyr-calyr
tab diff_calyr
drop if diff_calyr>1 & diff_calyr!=.

gen diff_hesyr= epiendyr-hesyr
tab diff_hesyr, mi
drop epiendyr diff_calyr diff_hesyr


************ missing age
tab ydob if startage==.  
tab ydob  if endage==.

gen tmp1=1 if endage==.
gen tmp=epiend-epistart if endage==.
replace endage=7001 if startage==7001 & endage==. & tmp==0
replace endage=7002 if startage==7001 & endage==. & tmp>0 & tmp<7
replace endage=7003 if startage==7001 & endage==. & tmp>=7 & tmp<=28
replace endage=7004 if startage==7001 & endage==. & tmp>=29 & tmp<=90
replace endage=7005 if startage==7001 & endage==. & tmp>=91 & tmp<=180
replace endage=7006 if startage==7001 & endage==. & tmp>=181 & tmp<=270
replace endage=7007 if startage==7001 & endage==. & tmp>=271 & tmp<=364
drop *tmp*

************ age the wrong way round - it is derived from epistart and epiend
gen tmp=1 if endage<startage & endage>7000
tab ydob if tmp==1
gen endage_tmp=endage if tmp==1
gen startage_tmp=startage if tmp==1
replace endage=startage_tmp if tmp==1
replace startage=endage_tmp if tmp==1
drop *tmp*

tab ydob if endage<startage & startage<7000 

*** deduplicate after cleaning the dates
duplicates tag encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* procode postdist ///
epistart epiend admidate disdate, gen(tag)
tab tag

duplicates drop encrypted_hesid startage endage mydob sex ///
epiorder diag* cause opertn* procode postdist ///
epistart epiend admidate disdate, force






*****************************************************************************
*                                                                           *
*               number the admissions (method developed by Dr Pia Hardelid)                                       
*                                                                                                                    
*****************************************************************************

/************** IDENTIFYING AND NUMBERING ADMISSIONS ***************************/

capture drop hesid 
capture drop episode_no 
capture drop episode_no2


egen hesid = group(encrypted_hesid)     /* shorter identifier */

************ fix disdate complete
capture drop disdate_compl 
bysort encrypted_hesid admidate: egen disdate_compl=max(disdate) 
capture drop max_epiend 
bysort encrypted_hesid admidate: egen max_epiend=max(epiend) 
replace disdate_compl=max_epiend if disdate_compl==.
replace disdate_compl=max_epiend if disdate_compl<max_epiend
format disdate_compl %td
drop max_epiend 

bysort hesid admidate (epistart epiend disdate_compl): gen episode_no=_n 


/*Assign a consecutive number to each admission for all individuals
 - we are numbering all separate admissions in the dataset */
egen admission_no = group(hesid admidate), missing

/*Assign a general consecutive number per child, to each admission within individuals
 - we are numbering admissions within a HEs ID*/
bysort hesid: egen minadm = min(admission_no)
gen genadmno = admission_no - minadm + 1
label variable genadmno "Admission order per child"


/* number of admissions per individual */
bysort hesid: egen nadmch=max(genadmno)


/************ COMPARING DISCHARGE DATES AND SUBSEQUENT ADMISSION DATES *********/
gen disdate_compl_chron=disdate_compl

set varabbrev off

local i=1

* This loop generates a new discharge date if the discharge date of a previous admission 
* is greater than the current admissionsIt will do this going back up to 20 discharge 
* dates from current discharge dateWhen there are no more discharge dates where 
* the difference between the current and the previous discharge date is negative, 
* it will stopMay have to increase to higher number depending on how many loops are required 

while `i'<=20 {
         capture drop  disdif disdif_test
         sort hesid admidate episode_no
         gen prevdisdate`i' = disdate_compl_chron[_n-`i']                                
         /*assign the date of discharge of subsequent row to a new variable*/
         format prevdisdate`i' %td       
         replace prevdisdate`i'=. if hesid[_n-`i']!=hesid[_n]  
         /*assign missing value to first date of last discharge or episode of same hesid*/

         gen disdif=disdate_compl_chron-prevdisdate`i'
         replace disdate_compl_chron =prevdisdate`i' if disdif<=0
         /* replace disdate_compl_chron with previous discharge date if there's an overlap */

         gen disdif_test=disdate_compl_chron-disdate_compl_chron[_n-(`i'+1)]
         replace disdif_test=. if hesid[_n-(`i'+1)]!=hesid[_n]
 
         qui: tab disdif_test if disdif_test<0
         di r(N)
		 
         if r(N)==0 {   
               local i= 21
			}

         else {         
			local i =`i'+1
			}

}

capture drop prevdisdate* disdif disdif_test

format disdate_compl_chron %td  

/*This is the dishcarge date variable which is used to check 
whether there is overlap between the current admission date and previous discharge date */

gen prevdisdate=disdate_compl_chron[_n-1]

gen disgap=admidate-prevdisdate  /*This indicates the number of days' difference between admissions */

format prevdisdate %td

replace disgap = . if nadmch==1				/*delete 'number of days between admissions' (usually '0' for admissions with more than one episode) for cases with only 1 admission*/
replace disgap = . if genadmno==1			/*delete 'number of days between admissions' for first admission*/
replace disgap = . if episode_no!=1			/*delete 'number of days between admissions' for subsequent episodes of one admission*/

gen admi_flag=1 if disgap<=0

sort hesid episode_no admidate disdate_compl  

/*Sort it so that episode numbers are grouped together - otherwise will not flag admissions but episodes */

gen admi_flag_consec=admi_flag  /*this variable will be used to create the new admission number by chronologically re-ordering overlapping admissions*/

replace admi_flag_consec=admi_flag_consec[_n-1]+admi_flag[_n] if admi_flag[_n]==1 & admi_flag_consec[_n-1]!=.

* this numbered episodes within overlapping admissions
replace admi_flag_consec=. if episode_no>1  /* flag the first episode of an admission */

sort hesid admidate episode_no
bysort hesid admidate: egen admi_flag_consec2=max(admi_flag_consec)



/**************** Create a new admission number ****************************/
gen newadmno=genadmno
replace newadmno=genadmno-admi_flag_consec2 if admi_flag_consec2!=.

* genadmo - admission order per child
* admi_flag_consec2 - numbered episodes within overlapping admissions
* the resulting numbering of admissions is not sequential but episodes within the same admission
* have the same number 

egen admno2 = group(hesid newadmno), missing    /*generates new sequential number for all admissions in the dataset*/

bysort hesid (admidate genadmno episode_no): egen minadmno2 = min(admno2) /* assigns the same number to episodes of the same HES ID */
gen adm_no = admno2 - minadmno2 + 1                                             /*re-start admission number to 1 at each hesid*/

bysort hesid adm_no (epistart epiend): gen episode_no2 = _n
label variable episode_no2 "Episode order of renumbered admission"

bysort hesid adm_no: egen maxepino=max(episode_no)
bysort hesid adm_no: egen maxepino2=max(episode_no2)


/*Counting number of collapsed admissions per child*/
bysort hesid: egen nadm = max(adm_no)
label variable nadm "number of admissions per child"

bysort hesid: egen nadm_inf = max(adm_no) if startage>7000
label variable nadm_inf "number of admissions per child in infancy"

bysort hesid adm_no: egen admd=min(admidate)   
bysort hesid adm_no: egen disd=max(disdate_compl)
format admd %td
format disd %td

/* gap between admissions */
gen disgap55=admd-disd[_n-1] 
replace disgap55 =. if adm_no==1                       /*delete 'number of days between admissions' for first admission*/
replace disgap55 =. if episode_no2!=1                  /*delete 'number of days between admissions' for subsequent episodes of one admission*/
drop disgap55

gen birth_compl=1 if adm_no==1 & episode_no2==1

* adding length of neonatal admission
gen length_adm=disd-admd
label var length_adm "Length of an admission"

gen tmp=disd-admd
label var tmp "Length of an admission"
replace tmp=. if episode_no2!=1
bysort hesid: gen bed_years1=sum(tmp) if startage>7000
bysort hesid: gen bed_years2=sum(tmp) if startage>7000 | startage==1
drop tmp

sort hesid episode_no2 admd disd  

gen readm_afterbirth=admd[_n+1]-disd if birth_compl==1

replace readm_afterbirth=. if nadm==1 /* change to missing if only one readmission */
replace readm_afterbirth=. if  hesid[_n+1]!=hesid

label var readm_afterbirth "Time till a re-admission after birth"

egen admcount = group(encrypted_hesid adm_no)
egen admcount_old = group(encrypted_hesid admidate) /*ok*/

label variable admd "admidate of new admission indicator"
label variable disd "disdate of new discharge indicator"
la var admidate "Admission date (HES)"
la var disdate "Discharge date (HES)"

drop minadmno2 admno2 newadmno admi_flag_consec2 admi_flag_consec admi_flag disgap prevdisdate disdate_compl_chron nadmch genadmno minadm admission_no episode_no 
drop   admcount admcount_old




*****************************************************************************
*
*	derive the most commonly recorded value of variables per admission 
*
*****************************************************************************

*********** rescty ***************
tab resgor, mi
replace resgor="" if resgor=="Y"
encode resgor, generate(resgor_tmp)
bysort hesid adm_no: egen resgor_compl=mode(resgor_tmp)
label val resgor_compl resgor_tmp
gen resgor1_check=1 if resgor_tmp!=.  & resgor_compl!=resgor_tmp
bysort hesid adm_no: egen resgor1_check_id=min(resgor1_check)
drop resgor1_check
label val resgor_compl resgor_tmp
decode resgor_compl, gen(resgor_str)
drop resgor_compl
rename resgor_str resgor_compl


*********** imd04rk ***************
bysort hesid adm_no: egen imd04rk_compl=mode(imd04rk)
label val imd04rk_compl imd04rk1
gen imd04rk1_check=1 if imd04rk!=.  & imd04rk_compl!=imd04rk
bysort hesid adm_no: egen imd04rk1_check_id=min(imd04rk1_check)
drop imd04rk1_check

*********** post dist ***************
replace postdist="" if postdist=="ZZ99"
encode postdist, generate(postdist_tmp)
bysort hesid adm_no: egen postdist_compl=mode(postdist_tmp)
label val postdist_compl postdist_tmp
gen postdist1_check=1 if postdist_tmp!=.  & postdist_compl!=postdist_tmp
bysort hesid adm_no: egen postdist1_check_id=min(postdist1_check)
br if postdist1_check_id==1
drop postdist1_check* postdist_tmp
decode postdist_compl, gen(postdist_str)
drop postdist_compl
rename postdist_str postdist_compl


*********** reslads *************** 
replace resladst="" if resladst=="Y"
encode resladst, generate(resladst_tmp)
bysort hesid adm_no: egen resladst_compl=mode(resladst_tmp)
label val resladst_compl resladst_tmp
gen resladst1_check=1 if resladst_tmp!=.  & resladst_compl!=resladst_tmp
bysort hesid adm_no: egen resladst1_check_id=min(resladst1_check)
br if resladst1_check_id==1
drop resladst1_check* resladst_tmp
decode resladst_compl, gen(resladst_str)
drop resladst_compl
rename resladst_str resladst_compl

drop *_check*

label var postdist "Baby's postcode - original"
label var postdist_compl "Baby's postcode - mode per admission"
label var resladst "Baby's loc.authority - original"
label var resladst_compl "Baby's loc.authority - mode per admission"
label var resgor "Baby's region of residency - original"
label var resgor_compl "Baby's region of residency - mode per admission"
label var imd04rk "Baby's IMD score - original"
label var imd04rk_compl "Baby's IMD score - mode per admission"

drop admincat admisorc admistat anagest anasdate antedur bed_years1 bed_years2 bedyear detndate elecdate elecdur gortreat gppracha gppracro gpprpct gpprstha hatreat hesid maxepino maxepino2 nadm nadm_inf resgor_tmp resha respct_his respct02 respct06 resro resstha02 resstha06 resstha_his rotreat rururb_ind sushrg sushrgvers tag

drop birord* gestat* birweit*
drop del*
drop bir*
drop sexbaby*

compress
save "${filepath}clean_infant_records.dta", replace



