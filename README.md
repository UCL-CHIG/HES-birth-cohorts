# HES-birth-cohorts
This repository covers methods for developing birth cohorts in Hospital Episode Statistics. Do-files 1) and 2) provide basic data cleaning for variables of interest. Do-file 3) provides methods for derivation of a birth cohort for singleton live births in Hospital Episode Statistics.

In brief, we used  all HES episodes with an age at admission <7 days and applied broad selection criteria based on diagnostic and procedure codes, healthcare resource group codes and administrative variables recorded in HES (such as admission method or level of provided neonatal care) to identify birth episodes. 
We then excluded multiple births, stillbirths, episodes marked as terminations of pregnancy, unfinshed episodes, likely false matches etc. 

## Hospital Episode Statistics
To find out more about Hospital Episode Statistics see:
- NHS Digital website: https://digital.nhs.uk/data-and-information/data-tools-and-services/data-services/hospital-episode-statistics
- Annie Herbert, Linda Wijlaars, Ania Zylbersztejn, David Cromwell, Pia Hardelid, Data Resource Profile: Hospital Episode Statistics 
Admitted Patient Care (HES APC), International Journal of Epidemiology, Volume 46, Issue 4, August 2017, Pages 1093–1093i, https://doi.org/10.1093/ije/dyx015

## Selected UCL-CHIG studies which used HES-ONS birth cohort:
- Verfürden M & Fitzpatrick T (joint first authors), Holder L, Zylbersztejn A, Rosella L, Gilbert R, Guttmann A, Hardelid P. Deprivation and pediatric respiratory tract infection mortality: a cohort study in three high-income jurisdictions. CMAJ Open (in press)
- Zylbersztejn A & Verfürden M (joint first authors), Hardelid P, Gilbert R, Wijlaars L. Phenotyping congenital anomalies in administrative hospital records. Paediatr Perinat Epidemiol. 2019;00:1–10. https://doi.org/10.1111/ppe.12627 (in press)
- Zylbersztejn A, Gilbert R, Hjern A, Hardelid P. Origins of disparities in preventable child mortality in England and Sweden: a birth cohort study. Archives of Disease in Childhood. Published Online First: 26 June 2019. https://doi.org/10.1136/archdischild-2018-316693
- Moore HC, de Klerk N, Blyth CC, Gilbert R, Fathima P, Zylbersztejn A, Verfürden M, Hardelid P. Temporal trends and socioeconomic differences in acute respiratory infection hospitalisations in children: an intercountry comparison of birth cohort studies in Western Australia, England and Scotland. BMJ Open 2019; 9, e028710. https://doi.org/10.1136/bmjopen-2018-028710
- Zylbersztejn A, Gilbert R, Hjern A, Wijlaars L, Hardelid P. Child mortality in England compared with Sweden: a birth cohort study. Lancet 2018;391:2008–18. https://doi.org/10.1016/s0140-6736(18)30670-6

## Hospital Episode Statistics
Useful references:
- Harron K , Gilbert R, Cromwell D, van der Meulen J. Linking data for mothers and babies in de-identified electronic health data. PLoS One2016;11:e0164667.
