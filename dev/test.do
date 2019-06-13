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
if c(username) == "wb486079" {
	gl folder = "C:/Users/wb486079/Dropbox/scale_transformation/dev"
	}
	
gl dta "$folder/dta"

cd "$folder"

/*Test*/
use "$dta/timss_testscores", clear

if ( score1<0 | (score1>1 & score1!=.) ) | ( score2<0 | (score2>1 & score2!=.) ) {
		qui sum score1
		local s1min = r(min)
		local s1max = r(max)
		qui sum score2
		local s2min = r(min)
		local s2max = r(max)
		local max = ceil(max(`s1max',`s2max'))
		local min = floor(min(`s1min',`s2min'))
		qui replace score1 = (score1-`min') / (`max'-`min')
		qui replace score2 = (score2-`min') / (`max'-`min')
		}

scale_transformation, type(1) score1(score1) score2(score2) compgroup(sex) iterations(20) maxoptiterations(15) mono(2) seed(562) robust(20)

gsort -obj
qui keep if obj!=.

mkmat obj b1-c, mat(matrix) 
local N = _N

m: r_params=st_matrix("matrix")

use "$dta/timss_testscores", clear

if ( score1<0 | (score1>1 & score1!=.) ) | ( score2<0 | (score2>1 & score2!=.) ) {
		qui sum score1
		local s1min = r(min)
		local s1max = r(max)
		qui sum score2
		local s2min = r(min)
		local s2max = r(max)
		local max = ceil(max(`s1max',`s2max'))
		local min = floor(min(`s1min',`s2min'))
		qui replace score1 = (score1-`min') / (`max'-`min')
		qui replace score2 = (score2-`min') / (`max'-`min')
		}

	m{
		st_view(irt1=.,.,("score1"))
		st_view(irt2=.,.,("score2"))
		st_view(gender=.,.,("sex"))
		
		params = (r_params[1,2..8])
		obj = (r_params[1,1])
	
		r = params
		s_irt1 = r[1]:*(irt1:+r[7]) + r[2]:*(irt1:+r[7]):^2 + r[3]:*(irt1:+r[7]):^3 + r[4]:*(irt1:+r[7]):^4 + r[5]:*(irt1:+r[7]):^5 + r[6]:*(irt1:+r[7]):^6
		s_irt2 = r[1]:*(irt2:+r[7]) + r[2]:*(irt2:+r[7]):^2 + r[3]:*(irt2:+r[7]):^3 + r[4]:*(irt2:+r[7]):^4 + r[5]:*(irt2:+r[7]):^5 + r[6]:*(irt2:+r[7]):^6
		
		s_irt_comb = s_irt1 \ s_irt2
		mean_s_irt_comb = mean(s_irt_comb)
		var_s_irt_comb = variance(s_irt_comb)
		s_irt_comb = (s_irt_comb:-mean_s_irt_comb):/(var_s_irt_comb^.5)
		
		st_irt1 = s_irt_comb[1..100,.]
		st_irt2 = s_irt_comb[101..200,.]
		
		mean_s_irt1 = mean(s_irt1)
		var_s_irt1 = variance(s_irt1)
		s_irt1 = (s_irt1:-mean_s_irt1):/(var_s_irt1^.5)
		
		mean_s_irt2 = mean(s_irt2)
		var_s_irt2 = variance(s_irt2)
		s_irt2 = (s_irt2:-mean_s_irt2):/(var_s_irt2^.5)
		
		results = (s_irt1, s_irt2)
		st_local("obj",strofreal(obj))
		}
		
	getmata (s_irt1 s_irt2) = results, double
	
	qui{
		sum s_irt1, det
		local sk1_1 =  string(round(`r(skewness)',.01))
		local kur1_1 =  string(round(`r(kurtosis)',.01))
		sum s_irt2, det
		local sk2_1 =  string(round(`r(skewness)',.01))
		local kur2_1 =  string(round(`r(kurtosis)',.01))
		}

egen st_score1 = std(score1)
egen st_score2 = std(score2)

*Original scores scaled to be between 0 and 1
reg score1 sex
local b1 = _b[sex]
reg score2 sex
local b2 = _b[sex]
local gap1 = (`b2'-`b1') 

*Standardized scores after scaled to be between 0 and 1
reg st_score1 sex
local b1 = _b[sex]
reg st_score2 sex
local b2 = _b[sex]
local gap2 = (`b2'-`b1') 

*Transformed scores after scaled to be between 0 and 1
reg s_irt1 sex
local b1 = _b[sex]
reg s_irt2 sex
local b2 = _b[sex]
local gap3 = (`b2'-`b1') 

*Re-scale original test scores
qui replace score1 = (score1*(`max'-`min')) + `min'  
qui replace score2 = (score2*(`max'-`min')) + `min' 

*Original Raw scores (NOT scaled to be between 0 and 1)
reg score1 sex
local b1 = _b[sex]
reg score2 sex
local b2 = _b[sex]
local gap4 = (`b2'-`b1') 

noi dis "Gap Growth `gap1' (Original scores JOINTLY scaled to be between 0 and 1)" 
noi dis "Gap Growth `gap2' (SEPARATELY standardized scores after being JOINTLY scaled to be between 0 and 1)" 
noi dis "Gap Growth `gap3' (JOINTLY transformed scores after (a) being JOINTLY scaled to be between 0 and 1 and (b) being SEPARATELY standardized)" 
noi dis "Gap Growth `gap4' (Original RAW scores (NOT standardized NOR scaled to be between 0 and 1))" 

*Graph
local type = proper("max")
local subtitle = proper("sex")

tw ///
	(scatter score1 s_irt1, msize(small)) ///
	(scatter score2 s_irt2 , msize(small)) ///
	(kdensity s_irt1, yaxis(2) lcolor(navy)) ///
	(kdensity s_irt2, yaxis(2) lcolor(maroon)) ///
	(function y = x, range(-4 4) lcolor(black) lwidth(thin)) ///
		, title("Original vs Transformed Scores", size(medium) justification(left) color(black) span pos(11)) ///
		subtitle("`type' Gap Growth by `subtitle'", size(medsmall) justification(left) color(black) span pos(11)) ///
		xtitle("Transformed Scores", size(small)) ytitle("Original Scores", size(small)) yscale(axis(2) off) ///
		legend(order(1 "Scores Y1" 2 "Scores Y2" 4 "kdensity Transformed Scores Y1" 5 "kdensity Transformed Scores Y2" 3 "45 degree line") size(small)) ///
		note("Original Gap Growth=`gap4'" "`type' Gap Growth=`obj'", justification(left) color(black) span pos(7)) ///
		graphregion(color(white)) ylab(,angle(0) nogrid) legend(region(lc(none) fc(none))) xscale(r(-4(2)4)) xlab(-4(2)4) yscale(r(-4(1)4)) ylab(-4(2)4)
	
	graph export "../paper/scale_transformation/Transformed_vs_Original.png", replace 
	
reshape long score s_irt st_score, i(id) j(year)
tw ///
	(lfit score year if sex==0, lcolor(maroon)) ///
	(lfit score year if sex==1, lcolor(maroon)) ///
	(lfit s_irt year if sex==0, lcolor(navy)) ///
	(lfit s_irt year if sex==1, lcolor(navy)) ///
		, title("Original vs Transformed Gap Evolution", size(medium) justification(left) color(black) span pos(11)) ///
		xtitle("Years", size(small)) ytitle("Test Scores", size(small)) ///
		legend(order(1 "Original Gap Evolution" 3 "Transformed Gap Evolution") size(small)) ///
		note("Note: Top and bottom lines for each color represent sex groups", justification(left) color(black) span pos(7)) ///
		graphregion(color(white)) ylab(,angle(0) nogrid) legend(region(lc(none) fc(none))) xscale(r(.85 2.15)) xlab(1(1)2) yscale(r(-1(.5)1)) ylab(-1(.5)1)
	
	graph export "../paper/scale_transformation/Transformed_vs_Original_Gap.png", replace 
