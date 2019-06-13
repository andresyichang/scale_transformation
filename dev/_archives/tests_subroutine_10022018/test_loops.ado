cap prog drop test_loops
prog def test_loops
version 13
	syntax, score(varname numeric) ///
	[robust]
	
m: st_view(score=.,.,("`score'"))

di "this is my program..."

if "`robust'"=="robust" {
		di "if robust activated..."

		forv row = 1/6 {
			di `row'
			if `row'<=3 local rtype "max"
			if `row'>3 local rtype "min"
			di "`rtype'"
		
				
			di ""  _newline(1) 	
			di "`row'/6 ROBUST `rtype'"  _newline(1) 
			cap noi m: "Some text"
			
			m: row = strtoreal("`row'")
			m: rtype = "`rtype'"
			m: row
			m: rtype
			m: conditional(row,score,rtype,results_robust)
				
					
			if `c(rc)'==1 {
				qui cap drop dropper
				error(1)
				e
				}
			}
		
		}
		
di "My program is done!"
end


mata:
void conditional(row,score,rtype,results_robust) {

	real scalar p
	real scalar gapgrowth
	real scalar nc_gapgrowth
	
	if (score[row,1]==0) {
			p =  1
			if (rtype!="") {
				nc_gapgrowth = 1
				}
			else {
				nc_gapgrowth= J(1,1,.)
				}
			if (rtype!="") {
				gapgrowth = 1
				}
			else {
				gapgrowth= J(1,1,.)
				}
			results_robust = results_robust \ (p , nc_gapgrowth, gapgrowth)
			}

	else {
			p =  2
			nc_gapgrowth= J(1,1,.)
			gapgrowth = J(1,1,.)
			results_robust = results_robust \ (p , nc_gapgrowth, gapgrowth)
			}

			results_robust
			}
end

	
