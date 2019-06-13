/*Set up*/
clear all
timer clear
timer on 1
macro drop _all
set linesize 95

if c(username) == "andresyichang" {
	gl folder = "C:/Users/andresyichang/Dropbox/scale_transformation/dev"
	}
gl dta "$folder/dta"

/*Dta Creation*/
use "$dta/timss_traits", clear
ren theta_mle testscore
drop if _n>200
keep testscore
set seed 9876543
gen noise = runiform(-1,1)
gen noisy_testscore = testscore + noise
sort noisy_testscore
gen year = 1
replace year = 2 if _n>100
bys year: gen id = _n
drop noise noisy_testscore 
sort id year 
lab var id "Child ID"
lab var year "Year"

reshape wide testscore, i(id) j(year)

lab var testscore1 "Test Score Year 1 (IRT-ThetaMLE)"
lab var testscore2 "Test Score Year 2 (IRT-ThetaMLE)"
ren test* *
gen noise2 = runiform(0,1) + score2
sort noise2
gen sex = 0
replace sex = 1 if _n>50
lab var sex "Child Sex"
drop noise2
order id sex score1 score2
replace score1 = score1 + 1 if sex==0
replace score2 = score2 - .6 if sex==1

saveold "$dta/timss_testscores", replace
