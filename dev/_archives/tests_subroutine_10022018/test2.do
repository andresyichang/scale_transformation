/*Set up*/
clear all
m: mata clear
timer clear
timer on 1
macro drop _all
set linesize 95

if c(username) == "andresyichang" {
	gl folder = "C:/Users/andresyichang/Dropbox/scale_transformation/dev"
	}
gl dta "$folder/dta"

cd "$folder"

/*Test*/
set obs 6
gen id = _n 
gen score = 0
replace score = 1 if _n>3

test_loops, score(score) robust


