*! version 1.0 2025-08-24
* by Maobin Xu, The Chinese University of Hong Kong, Shenzhen

program define robustreg
version 16.1

syntax [anything] , ///
    dep(string) indep(string)  [ ///
	order(string)   ORDERLabel(string asis)   ///
	                DEPLabel(string asis)     ///
	                INDEPLabel(string asis)   ///
	sample(string)  SAMPLELabel(string asis)  ///
	control(string) CONTROLLabel(string asis) ///
	fe(string)      FELabel(string asis)      ///
	se(string)      SELabel(string asis)      ///
	plot(string) level(integer 95) ratio(real 1) fontsize(string) twoway_opt(string asis) scatter_opt(string asis) rarea_opt(string asis) graph_opt(string asis) ///
	save(string) stats(string) reghdfe_opt(string asis) ///
	] 
	
	
/** Parse Specifications **/

// set specifications
local spec_names " sample dep indep control fe se"
local spec_labels `" "sample(s)" "dependent variable(s)" "key independent variable(s)" "control set(s)" "fixed effects" "clustering method(s)" "'
local spec_num: word count `spec_names'
forv each_spec = 1/`spec_num' {
	local spec      : word `each_spec' of `spec_names'
	local spec_label: word `each_spec' of `spec_labels'

	* standardize specifications
	local temp_`spec' = strtrim("``spec''")
	if inlist("`temp_`spec''",",","") {   // default case, or special case with only ","
		local temp_`spec' = "default"
	}
    local temp_`spec' = ustrregexra("`temp_`spec''", "^,"   , "default," , .)  // if default option is in the beginning part
	local temp_`spec' = ustrregexra("`temp_`spec''", ",\s+,", ",,"       , .)
    local temp_`spec' = ustrregexra("`temp_`spec''", ",,"   , ",default,", .)  // if default option is in the middle part
    local temp_`spec' = ustrregexra("`temp_`spec''", ",$"   , ",default" , .)  // if default option is in the end part

	* specification number of each specification choice
	local `spec'_count = ustrlen("`temp_`spec''") - ustrlen(usubinstr("`temp_`spec''",",","",.)) + 1 

	* set command and label of specification choice
    tokenize `"`temp_`spec''"' , parse(",")
    forv i = 1/``spec'_count' {  // for each specification choice
        * command of specification choice
		local temp_id = 2*`i' - 1  // tokenize contains parsing string, need to skip
        if strtrim("``temp_id''")=="default" {  // use default command
		    if "`spec'"=="fe" {
			    local `spec'_command_`i' "noabsorb"  // without fixed effect
			}
			else {
		        local `spec'_command_`i'  " "
			}
    	}
    	else { // use user-defined command
		    if "`spec'"=="sample" {
				local `spec'_command_`i' " if ``temp_id''==1 "
			}
			else if "`spec'"=="fe" {
				local `spec'_command_`i' "absorb(``temp_id'')" 
			}
			else if "`spec'"=="se" {
                if strtrim("``temp_id''")=="robust" {
                	local `spec'_command_`i' "vce(robust)"
                }
                else {
                    local `spec'_command_`i' "vce(cluster ``temp_id'')" 
                }
			}
			else {
				local `spec'_command_`i' ``temp_id''
			}
		}
        * label of specification choice
        if strtrim(`"``spec'label'"')=="" {  // use default label (command of the specification)
        	if strtrim("``temp_id''")=="default" & "`spec'"=="sample" {
				local `spec'_label_`i' "Full sample"
			}
			else if strtrim("``temp_id''")=="default" & inlist("`spec'","control","fe","se") {
				local `spec'_label_`i' "No"
			}
			else {
			    local `spec'_label_`i' ``spec'_command_`i''
			}
        }
        else { // use user-defined label
            local `spec'_label_`i': word `i' of ``spec'label'
        }
        // dis "``spec'_count', ``spec'_command_`i'', ``spec'_label_`i''"
    }

	* print choice count
    display as text "The number of `spec_label' is ``spec'_count'"
}

* model number
local model_num = `sample_count'*`dep_count'*`indep_count'*`control_count'*`fe_count'*`se_count'
display as text "The number of regression(s) is `model_num'"


/** Regression **/

cap: frame drop robustreg_output_table
frame create robustreg_output_table b t ll ul F N `stats'     ///
    strL command_dep     strL label_dep     plot_dot_dep_y     ///
	strL command_indep   strL label_indep   plot_dot_indep_y   ///
	strL command_control strL label_control plot_dot_control_y ///
	strL command_fe      strL label_fe      plot_dot_fe_y      ///
	strL command_se      strL label_se      plot_dot_se_y      ///
	strL command_sample  strL label_sample  plot_dot_sample_y
local reg_count = 0
/* Note: The order of the following loops does not matter */
* for each sample choice
forv each_sample = 1/`sample_count' {
	local each_sample_command `sample_command_`each_sample''
	local each_sample_label   `sample_label_`each_sample''
	* for each dependent variable choice
    forv each_dep = 1/`dep_count' {
	    local each_dep_command `dep_command_`each_dep''
	    local each_dep_label   `dep_label_`each_dep''
		* for each independent variable choice
        forv each_indep = 1/`indep_count' {
	        local each_indep_command `indep_command_`each_indep''
			local each_indep_label   `indep_label_`each_indep''
			* for each control choice
            forv each_control = 1/`control_count' {
	            local each_control_command `control_command_`each_control''
	            local each_control_label   `control_label_`each_control''
				* for each fixed effect choice
                forv each_fe = 1/`fe_count' {
	                local each_fe_command `fe_command_`each_fe''
	                local each_fe_label   `fe_label_`each_fe''
					* for each clustering choice
                    forv each_se = 1/`se_count' {	
    		            local each_se_command `se_command_`each_se''
    		            local each_se_label   `se_label_`each_se''
						* regression
						// dis "reghdfe `each_dep_command' `each_indep_command' `each_control_command' `each_sample_command' , `each_fe_command' `each_se_command' level(`level')"
	                    qui: reghdfe `each_dep_command' `each_indep_command' `each_control_command' `each_sample_command' , `each_fe_command' `each_se_command' level(`level') `reghdfe_opt'
	                    * store result
                        matrix results = r(table)
	                    // mat list results
                        scalar observation = e(N) 
						scalar F_value     = e(F) 
						* additional stats
						local add_stats ""
						if "`stats'"!="" {
							foreach stat in `stats' {
								local stat_`stat' = e(`stat')
                        	    local add_stats " `add_stats'  (`stat_`stat'') "
							}
                        }
	                    * save result to output table
                        frame post robustreg_output_table  ///
						    (results["b" ,"`each_indep_command'"]) ///
							(results["t" ,"`each_indep_command'"]) ///
							(results["ll","`each_indep_command'"]) ///
							(results["ul","`each_indep_command'"]) ///
							(F_value) (observation) `add_stats'        ///
						    ("`each_dep_command'")    ("`each_dep_label'")    (`each_dep')     ///
						    ("`each_indep_command'")  ("`each_indep_label'")  (`each_indep')   ///
						    ("`each_control_command'")("`each_control_label'")(`each_control') ///
						    ("`each_fe_command'")     ("`each_fe_label'")     (`each_fe')      ///
						    ("`each_se_command'")     ("`each_se_label'")     (`each_se')      ///
						    ("`each_sample_command'") ("`each_sample_label'") (`each_sample')
						// display progress
						if mod(`reg_count', 50) == 0 {   // display process for every 50 regressions
							display as text "`reg_count' -> " _continue
						}
						local reg_count = `reg_count' + 1
                    }
                }
            }
        }
    }
}
* change line
dis as text "`model_num'" _newline



/** Plot Specification Curve **/

if "`plot'"!="" { 
    // all specifications
    local sys_spec_list   " dep indep control fe se sample "
    local sys_spec_label `" "Dependent variable" "Independent variable" "Control variables" "Fixed effects" "Standard error clustering" "Sample" "'
    local sys_spec_num: word count `sys_spec_list'
    
    // specifications to plot
	local temp_order = ustrregexra("`order'", ",", "", .)
    local order_spec_num: word count `temp_order'
    local plot_spec_list  ""
    local plot_spec_label ""
    if `order_spec_num'==0 { // use default specification list
        local temp_order     "`sys_spec_list'"
        local orderlabel     "`sys_spec_label'"
		local order_spec_num  `sys_spec_num' 
    }
    forv i = 1/`order_spec_num' { // for each specification
    	local each_order_spec:  word `i' of `temp_order'
    	local each_order_label: word `i' of `orderlabel'
    	// match with default specification
    	forv j = 1/`sys_spec_num' {  // for each default specification
    	    local each_sys_spec:  word `j' of `sys_spec_list'
    		local each_sys_label: word `j' of `sys_spec_label'
    		* use user-defined label
    		if `"`each_order_label'"'!="" {
    			local each_sys_label "`each_order_label'"
    		}
    		* specification
    		if `"`each_order_spec'"'==`"`each_sys_spec'"' {
    			local plot_spec_list  `" `plot_spec_list' `each_order_spec' "'
    			local plot_spec_label `" `plot_spec_label' "`each_sys_label'" "'
    		}
        }
    }
    local plot_spec_count: word count `plot_spec_list'

	// others
	if "`fontsize'"=="" {
		local fontsize "vsmall"
	}
	
    // region parameters
    frame robustreg_output_table {
        * order by regression coefficient
        sort b
        * range of beta coefficients
        qui: sum ul
        local CI_max = r(max)
        qui: sum ll
        local CI_min = r(min)
        * range of specification region and curve
        local plot_spec_y_max = min(`CI_min', 0)  // max specfication y
        local plot_y_max      = max(`CI_max',0)   // max graph y
        local plot_spec_y_min = `plot_spec_y_max' - (`plot_y_max'-`plot_spec_y_max')*`ratio'
        * scale of each model dot
        local dot_range = (`plot_spec_y_max'-`plot_spec_y_min')/(`sample_count'+`dep_count'+`indep_count'+`control_count'+`fe_count'+`se_count'+`plot_spec_count')	
        
        // set x of labels and dots
        gen plot_x = _n  // model id
        
        // set y of labels and dots
        local start_y = 0       // start position for reference
        local plot_spec     ""  // text command for plotting curve in twoway
        local plot_dot_list ""  // dot variables to be plotted
        * each specification
        forv i = 1/`plot_spec_count'  {
        	local each_spec      : word `i' of `plot_spec_list'
        	local each_spec_label: word `i' of `plot_spec_label'
        	* initial position of specification label
        	local plot_label_`each_spec'_y = `start_y'  - 1
        	local start_y = `plot_label_`each_spec'_y' - ``each_spec'_count'
            * adjusted position of dots
	    	qui: replace plot_dot_`each_spec'_y = (`plot_label_`each_spec'_y' - plot_dot_`each_spec'_y )*`dot_range' + `plot_spec_y_max'
        	* dot variables to be plotted
        	local plot_dot_list = "`plot_dot_list' plot_dot_`each_spec'_y " 
	    	* adjusted position of sub-specification
        	forv j = 1/``each_spec'_count' {
        		local plot_label_`each_spec'`j'_y = (`plot_label_`each_spec'_y' - `j')*`dot_range'+ `plot_spec_y_max'
        		local plot_spec  " `plot_spec' text( `plot_label_`each_spec'`j'_y' 0 "``each_spec'_label_`j''", place(w) size(`fontsize') justification(right)) "
				// dis `" `plot_label_`each_spec'`j'_y' 0 "``each_spec'_label_`j''" "'
        	}
        	* adjusted position of specification
        	local plot_label_`each_spec'_y = `plot_label_`each_spec'_y'*`dot_range' +`plot_spec_y_max'
        	local plot_spec " `plot_spec' text( `plot_label_`each_spec'_y' 0 "{bf:`each_spec_label'}", place(w) size(`fontsize') justification(right)) "
			// dis `" `plot_label_`each_spec'_y' 0 "{bf:`each_spec_label'}" "'
        }
        * special labels
        local plot_label_coef_min_y = round(b[1],0.001)  // minimal beta
        local plot_label_coef_max_y = round(b[_N],0.001) // maximal beta
        local plot_label_ui_y       = ul[1]              // upper confidence interval
        local plot_label_li_y       = ll[1]              // lower confidence interval

        // graph
        twoway (rarea   ul ll plot_x , color(gray%40) `rarea_opt' ) ///
               (scatter b     plot_x , color(gray) connect(l) `scatter_opt' ) ///
               (scatter `plot_dot_list' plot_x )  ///
               , legend(off) xscale(off) yscale(noline) `plot_spec'  ///
        	   xlabel(1(1)`model_num', noticks nolabels grid glpattern(dot) glcolor(gray) )  ///
        	   ylabel(`plot_spec_y_min'(`dot_range')`plot_spec_y_max', noticks nolabels grid glpattern(dot) glcolor(gray) ) ///
               yline(0, noextend lpattern(solid) lcolor(gray)) ///
        	   text(`plot_label_coef_min_y'  0          "{bf:Coefficient estimate}", place(w) size(`fontsize') justification(right)               ) ///
        	   text(`plot_label_ui_y'        0          "`level'% upper interval"  , place(w) size(`fontsize') justification(right)               ) ///
        	   text(`plot_label_li_y'        0          "`level'% lower interval"  , place(w) size(`fontsize') justification(right)               ) ///
        	   text( 0                      `model_num' " 0"                       , place(e) size(`fontsize') justification(right)               ) ///
        	   text(`plot_label_coef_min_y'  1          "`plot_label_coef_min_y'"  , place(s) size(`fontsize') justification(right) margin(small) ) ///
               text(`plot_label_coef_max_y' `model_num' "`plot_label_coef_max_y'"  , place(n) size(`fontsize') justification(right) margin(small) ) ///
			   `twoway_opt'
		// color choice: dimgray%80, stblue
        * save graph 
        graph export "`plot'", replace `graph_opt'
        graph close
    }
}


/** Store Results **/

// Save Data
if "`save'"!="" { 
	frame robustreg_output_table {
		* drop position data
		drop plot_dot_dep_y plot_dot_indep_y plot_dot_control_y plot_dot_fe_y plot_dot_se_y plot_dot_sample_y
		*
	    qui compress 
	    save "`save'", replace
    }
}
frame drop robustreg_output_table
end



/*
Test Code:

set obs 1000
gen x1 = rnormal()
gen x2 = x1 + 0.2*rnormal()
gen c1 = rnormal()*2
gen c2 = runiform()-0.5 
gen e = rnormal()/5
gen y1 = 0.24*x1 + 0.4*exp(c1) + e
gen y2 = 0.26*x1 + 0.4*exp(c1) + e
gen s1 = mod(_n, 2) == 1
gen s2 = mod(_n-1, 3)==1 
gen f1 = mod(_n, 2) == 1
gen f2 = mod(_n-1, 3) + 1

robustreg , dep(y1, y2) indep(x1) control(c1, , c1 c2) fe( , f1, f2) sample( , s1) se(robust, , f2) save("regtab1")

robustreg , dep(y1, y2) indep(x1) control(c1, , c1 c2) fe( , f1, f2) sample( , s1)  plot("curve1.png") twoway_opt(graphregion(margin(l=42 r=5 t=0 b=0))) graph_opt(width(1500) height(1500))

robustreg , dep(y1, y2) indep(x1, x2) control( , c1, c1 c2) fe( , f1, f2) sample( , s1) se( , robust, f2) save("regtab2") plot("curve2.png") depl("Y1" "Y2") indepl("X1" "X2") controll("No" "Control set 1" "Control set 2") fel("No" "Fixed effects 1" "Fixed effects 2") samplel("Full sample" "Sample 1") sel("No" "Robust" "F2") level(90) ratio(1) fontsize(small) twoway_opt(graphregion(margin(l=22 r=5 t=0 b=0)) scale(0.6)) rarea_opt(color(gray%40)) scatter_opt(color(gray)) graph_opt(width(3000) height(2000))

*/




