cap prog drop robust
prog def robust
	version 13
	
forv row = 1/6 {
	if `row'<=3 local rtype "max"
	if `row'>3 local rtype "min"
	
	m {
		init_cond = init_params[`row',1..7]
		S=optimize_init()
		optimize_init_evaluator(S, &objf())
		optimize_init_evaluatortype(S,"d0")
		optimize_init_which(S, "`rtype'")
		optimize_init_argument(S,1,sesgroup)
		optimize_init_argument(S,2,irt1)
		optimize_init_argument(S,3,irt2)
		optimize_init_argument(S,4,controls)
		optimize_init_argument(S,5,c1)
		optimize_init_argument(S,6,c2)
		optimize_init_argument(S,7,w)
		optimize_init_argument(S,8,mono_data)
		optimize_init_argument(S,9,type)
		optimize_init_singularHmethod(S,"`singhmethod'")
		optimize_init_trace_params(S,"on")
		optimize_init_conv_maxiter(S,`maxoptiterations')
		optimize_init_verbose(S,0)
		optimize_init_params(S, init_cond)
		}
		
	di ""  _newline(1) 	
	di "Optimizing - Iteration `row'/6 ROBUST `rtype'"  _newline(1) 
	cap noi m: _optimize(S)


	m {
		if (optimize_result_errorcode(S)==0) {
				p =  optimize_result_params(S)
				max_min = optimize_result_value(S)
				init_vals = optimize_init_params(S)
				if ("`nc_gapgrowth'"!="") {
					nc_gapgrowth = strtoreal("`nc_gapgrowth'")
					}
				else {
					nc_gapgrowth= J(1,1,.)
					}
				if ("`gapgrowth'"!="") {
					gapgrowth = strtoreal("`gapgrowth'")
					}
				else {
					gapgrowth= J(1,1,.)
					}
				results_robust = results_robust \ (max_min, p , init_vals, nc_gapgrowth, gapgrowth)
			}
		
		if (optimize_result_errorcode(S)!=0) {
				p =  J(1,7,.)
				max_min = J(1,1,.)
				nc_gapgrowth= J(1,1,.)
				gapgrowth = J(1,1,.)
				init_vals = optimize_init_params(S)
				results_robust = results_robust \ (max_min, p , init_vals, nc_gapgrowth, gapgrowth)
				}
	
		results_robust
		S=optimize_init()
		}
			
	if `c(rc)'==1 {
		qui cap drop temp_g* temp_other_group_crtl temp_weight
		error(1)
		e
		}
}

end
