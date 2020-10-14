*******************************************************************************
*
*						Tim Cole's centiles
*						Ania Zylbersztejn
*							02.02.17
*
******************************************************************************

/* this do-file replaces implausible combinations of birth weight (birweit variable in HES) 
and gestational age (gestat variable in HES) as missing. These values are indicated if the recorded birth weight 
fell outside +/-4 standard deviations (SD) of mean birth weight for each gestational age. To obtain birth weight centiles, 
we used LMSgrowth, a Microsoft Excel add-in with growth references for children in the UK, 
developed by Pan and Cole (available from: https://www.healthforallchildren.com/shop-base/shop/software/lmsgrowth/) 
*/


gen ${implaus}=0

********************* Boys
replace ${implaus}=1 if ${sex}==1 & ${gestat}==22 & ${birweit}<=266 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==23 & ${birweit}<=309 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==24 & ${birweit}<=352 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==25 & ${birweit}<=396 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==26 & ${birweit}<=440 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==27 & ${birweit}<=486 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==28 & ${birweit}<=536 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==29 & ${birweit}<=593 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==30 & ${birweit}<=659 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==31 & ${birweit}<=741 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==32 & ${birweit}<=843 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==33 & ${birweit}<=968 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==34 & ${birweit}<=1115 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==35 & ${birweit}<=1283 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==36 & ${birweit}<=1470 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==37 & ${birweit}<=1699 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==38 & ${birweit}<=1857 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==39 & ${birweit}<=2014 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==40 & ${birweit}<=2170 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==41 & ${birweit}<=2329 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==42 & ${birweit}<=2492 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==43 & ${birweit}<=2492 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==44 & ${birweit}<=2492 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==45 & ${birweit}<=2492 & ${birweit}!=.

replace ${implaus}=1 if ${sex}==1 & ${gestat}==22 & ${birweit}>=745 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==23 & ${birweit}>=899 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==24 & ${birweit}>=1053 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==25 & ${birweit}>=1215 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==26 & ${birweit}>=1388 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==27 & ${birweit}>=1569 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==28 & ${birweit}>=1766 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==29 & ${birweit}>=1980 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==30 & ${birweit}>=2214 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==31 & ${birweit}>=2481 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==32 & ${birweit}>=2780 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==33 & ${birweit}>=3103 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==34 & ${birweit}>=3435 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==35 & ${birweit}>=3760 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==36 & ${birweit}>=4066 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==37 & ${birweit}>=4193 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==38 & ${birweit}>=4498 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==39 & ${birweit}>=4792 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==40 & ${birweit}>=5078 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==41 & ${birweit}>=5366 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==42 & ${birweit}>=5655 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==43 & ${birweit}>=5655 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==44 & ${birweit}>=5655 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==1 & ${gestat}==45 & ${birweit}>=5655 & ${birweit}!=.

***************** Girls
replace ${implaus}=1 if ${sex}==2 & ${gestat}==22 & ${birweit}<=190 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==23 & ${birweit}<=230 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==24 & ${birweit}<=270 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==25 & ${birweit}<=312 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==26 & ${birweit}<=354 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==27 & ${birweit}<=399 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==28 & ${birweit}<=448 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==29 & ${birweit}<=506 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==30 & ${birweit}<=580 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==31 & ${birweit}<=672 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==32 & ${birweit}<=785 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==33 & ${birweit}<=920 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==34 & ${birweit}<=1074 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==35 & ${birweit}<=1247 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==36 & ${birweit}<=1438 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==37 & ${birweit}<=1662 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==38 & ${birweit}<=1820 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==39 & ${birweit}<=1976 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==40 & ${birweit}<=2128 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==41 & ${birweit}<=2280 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==42 & ${birweit}<=2431 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==43 & ${birweit}<=2431 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==44 & ${birweit}<=2431 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==45 & ${birweit}<=2431 & ${birweit}!=.

replace ${implaus}=1 if ${sex}==2 & ${gestat}==22 & ${birweit}>=674 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==23 & ${birweit}>=831 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==24 & ${birweit}>=988 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==25 & ${birweit}>=1153 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==26 & ${birweit}>=1327 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==27 & ${birweit}>=1511 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==28 & ${birweit}>=1705 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==29 & ${birweit}>=1912 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==30 & ${birweit}>=2145 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==31 & ${birweit}>=2410 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==32 & ${birweit}>=2700 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==33 & ${birweit}>=3007 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==34 & ${birweit}>=3321 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==35 & ${birweit}>=3633 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==36 & ${birweit}>=3929 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==37 & ${birweit}>=4040 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==38 & ${birweit}>=4329 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==39 & ${birweit}>=4605 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==40 & ${birweit}>=4866 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==41 & ${birweit}>=5120 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==42 & ${birweit}>=5370 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==43 & ${birweit}>=5370 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==44 & ${birweit}>=5370 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==2 & ${gestat}==45 & ${birweit}>=5370 & ${birweit}!=.

************ missing
replace ${implaus}=1 if ${sex}==. & ${gestat}==22 & ${birweit}<=266 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==23 & ${birweit}<=309 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==24 & ${birweit}<=352 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==25 & ${birweit}<=396 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==26 & ${birweit}<=440 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==27 & ${birweit}<=486 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==28 & ${birweit}<=536 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==29 & ${birweit}<=593 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==30 & ${birweit}<=659 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==31 & ${birweit}<=741 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==32 & ${birweit}<=843 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==33 & ${birweit}<=968 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==34 & ${birweit}<=1115 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==35 & ${birweit}<=1283 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==36 & ${birweit}<=1470 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==37 & ${birweit}<=1699 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==38 & ${birweit}<=1857 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==39 & ${birweit}<=2014 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==40 & ${birweit}<=2170 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==41 & ${birweit}<=2329 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==42 & ${birweit}<=2492 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==43 & ${birweit}<=2492 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==44 & ${birweit}<=2492 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==45 & ${birweit}<=2492 & ${birweit}!=.

replace ${implaus}=1 if ${sex}==. & ${gestat}==22 & ${birweit}>=674 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==23 & ${birweit}>=831 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==24 & ${birweit}>=988 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==25 & ${birweit}>=1153 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==26 & ${birweit}>=1327 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==27 & ${birweit}>=1511 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==28 & ${birweit}>=1705 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==29 & ${birweit}>=1912 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==30 & ${birweit}>=2145 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==31 & ${birweit}>=2410 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==32 & ${birweit}>=2700 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==33 & ${birweit}>=3007 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==34 & ${birweit}>=3321 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==35 & ${birweit}>=3633 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==36 & ${birweit}>=3929 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==37 & ${birweit}>=4040 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==38 & ${birweit}>=4329 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==39 & ${birweit}>=4605 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==40 & ${birweit}>=4866 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==41 & ${birweit}>=5120 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==42 & ${birweit}>=5370 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==43 & ${birweit}>=5370 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==44 & ${birweit}>=5370 & ${birweit}!=.
replace ${implaus}=1 if ${sex}==. & ${gestat}==45 & ${birweit}>=5370 & ${birweit}!=.

tab ydob ${implaus}, mi


*log close
