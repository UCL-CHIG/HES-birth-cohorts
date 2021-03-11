# Developing a national birth cohort using Hospital Episode Statistics

## Project and repository description
We developed a national birth cohort covering all singleton live births using Hospital Episode Statistics (HES) data. Details of derivation and validation of the cohort are described in:

Zylbersztejn A, Gilbert R, Hardelid P. Developing a national birth cohort for child health research using a hospital admissions database in England: The impact of changes to data collection practices. PLoS One 2020. https://doi.org/10.1371/journal.pone.0243843

This repository covers methods for developing birth cohorts in Hospital Episode Statistics:
- Do-file 1) covers basic data cleaning for variables of interest in HES. 
- Do file 2) covers basic data cleaning for variables of interest in ONS mortality records. 
- Do-file 3) covers methods for derivation of a birth cohort for singleton live births in HES.
- Do-file 4) covers additional data cleaning for longitudinal follow-up records in HES, including code for linking episodes into admissions using algorithm developed by Dr Pia Hardelid. 
- Do-file 5) covers further data cleaning for follow-up ONS mortality records and our proposed approach to define implausible links between between HES and ONS.
- Do-file 6) covers final steps in derivation of a birth cohort using HES (including finalising variables of interest, excluding non-English residents)
- BW GA centiles do-file replaces implausible combinations of birth weight and gestational age as missing. 

See the appendix of Zylbersztejn et al. (2020) for more detailed description of steps described in each do-file.

## Data sources
We used Hospital Episode Statistics, a national database covering details of all patient care in NHS funded hospitals. To find out more about Hospital Episode Statistics see:
- NHS Digital website: https://digital.nhs.uk/data-and-information/data-tools-and-services/data-services/hospital-episode-statistics
- Annie Herbert, Linda Wijlaars, Ania Zylbersztejn, David Cromwell, Pia Hardelid, Data Resource Profile: Hospital Episode Statistics 
Admitted Patient Care (HES APC), International Journal of Epidemiology, Volume 46, Issue 4, August 2017, Pages 1093–1093i, https://doi.org/10.1093/ije/dyx015

## Software
This code was developed using Stata.

## Other useful references for work on developing birth cohorts using HES
- Harron K , Gilbert R, Cromwell D, van der Meulen J. Linking data for mothers and babies in de-identified electronic health data. PLoS One2016;11:e0164667.


## Selected UCL-CHIG studies which used HES-ONS birth cohort:
- Zylbersztejn A, Gilbert R, Hjern A, Wijlaars L, Hardelid P. Child mortality in England compared with Sweden: a birth cohort study. Lancet 2018;391:2008–18. https://doi.org/10.1016/s0140-6736(18)30670-6
- Verfürden M & Fitzpatrick T (joint first authors), Holder L, Zylbersztejn A, Rosella L, Gilbert R, Guttmann A, Hardelid P. Deprivation and pediatric respiratory tract infection mortality: a cohort study in three high-income jurisdictions. CMAJ Open (in press)
- Zylbersztejn A & Verfürden M (joint first authors), Hardelid P, Gilbert R, Wijlaars L. Phenotyping congenital anomalies in administrative hospital records. Paediatr Perinat Epidemiol. 2019;00:1–10. https://doi.org/10.1111/ppe.12627 (in press)
- Zylbersztejn A, Gilbert R, Hjern A, Hardelid P. Origins of disparities in preventable child mortality in England and Sweden: a birth cohort study. Archives of Disease in Childhood. Published Online First: 26 June 2019. https://doi.org/10.1136/archdischild-2018-316693
- Moore HC, de Klerk N, Blyth CC, Gilbert R, Fathima P, Zylbersztejn A, Verfürden M, Hardelid P. Temporal trends and socioeconomic differences in acute respiratory infection hospitalisations in children: an intercountry comparison of birth cohort studies in Western Australia, England and Scotland. BMJ Open 2019; 9, e028710. https://doi.org/10.1136/bmjopen-2018-028710


## Authors
Ania Zylbersztejn - [github](https://github.com/AniaZylb) [twitter](https://twitter.com/zylberek)
Pia Hardelid - [github](https://github.com/kanelbulle778) [twitter](https://twitter.com/PHardelid)

## Acknowledgments:
Katie Harron - [github](https://github.com/klharron)  [twitter](https://twitter.com/Klharron)
Linda Wijlaars - [github](https://github.com/LWijlaars)  [twitter](https://twitter.com/epi_counts)
