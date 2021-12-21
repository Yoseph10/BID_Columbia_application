
********************* BID-COLUMBIA APPLICATION ************************

*Author: Yoseph Daniel Ayala 
*Date: 12/20/2021
*Total time employed: 1 hour and 40 minutes

************************************************************************

clear all
cls

global main "C:/BID_Columbia"
global data "$main/Data"
global output "$main/Output"


*importing dataset (CSV)
import delimited "$data\scp-1205.csv", numericcols(7 8 9) clear 


*----------------------------------------------------
*Cleaning our dataset
*----------------------------------------------------

*renaming variables
rename v1 countyname
rename v2 state 
rename v3 contract
rename v4 healthplanname
rename v5 typeofplan
rename v6 countyssa
rename v7 eligibles
rename v8 enrollees
rename v9 penetration
rename v10 ABrate

*replacing missing values with 0
foreach x of varlist eligibles enrollees penetration{
  replace `x' = 0 if(`x' == .)
}

*excluding Guam and Puerto Rico
drop if strpos(countyname, "GUAM")
drop if  strpos(healthplanname, "PUERTO RICO")

*sorting by state and county
sort state countyname

*---------------------------------------------------
*Creating variables for our country-level dataset
*---------------------------------------------------

*health plan with more than 10 enrollees (dummy)
gen dum_plans1 = 1 if enrollees > 10 
replace dum_plans1 = 0 if dum_plans1 == .

	*sum all dummys by state and county
	egen numberofplans1 = total(dum_plans1), by(state countyname)


*health plan with penetration > 0.5 (dummy)
gen dum_plans2  = 1 if penetration > 0.5
replace dum_plans2 = 0 if dum_plans2 == .

	*sum all dummys by state and county
	egen numberofplans2 = total(dum_plans2), by(state countyname)


*totalenrollees for each plan
egen totalenrollees = total(enrollees), by(state countyname)


*---------------------------------------------------
*Creating our county-level dataset
*---------------------------------------------------

*keeping one observation for each county
sort state countyname
quietly by state countyname :  gen dup = cond(_N==1,0,_n)

drop if dup>1

*generating totalpenetration
gen totalpenetration = 100*(totalenrollees/eligibles)

*replacing totalpenetration missing values with 0
replace totalpenetration = 0 if totalpenetration == .

*keeping our final variables
keep countyname state numberofplans1 numberofplans2 countyssa eligibles totalenrollees totalpenetration

*ordering our final dataset
order countyname state numberofplans1 numberofplans2 countyssa eligibles totalenrollees totalpenetration

*---------------------------------------------------
*Exporting data in to a CSV file
*---------------------------------------------------

export delimited using "$output/final_dataset", replace


/*NOTE

  I dropped all health plans that are from Puerto Rico, because there wasn't any county that is called Puerto Rico.

/*

