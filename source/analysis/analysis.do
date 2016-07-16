clear
version 12
set more off
adopath + ../input/lib/stata/gslab_misc/ado
preliminaries

program main
    summary_stat
	gen_shares
    k_densities
    box_plots
	gen_diff_share
	corr_coeff
	ols_reg
	avg_percentile_plots
	reshape_data
	summary_stat_reshaped_data
	gen_shares_resheped_data
	graph_trends
	scatter_plots
	xt_reg
	quartiles_analysis
	diff_in_diff
end

program summary_stat
    use "../../output_large/county_panel.dta", clear
    
	local var_of_interest land_area* density_pop* tot_pop* white_pop* black_pop*   ///
	    hispanic_pop* pop_25_om* *crime*
	
    tabstat `var_of_interest', stat(n mean median sd min max) col(stat) varwidth(16) format(%9.0f)
    sutex `var_of_interest', nobs minmax title("Descriptive Statistics")           ///
	    key(desc_stat_tab_1) file("../output/desc_stat_tab.tex") replace
end

program gen_shares
	
	drop tot_pop_1970b
	rename tot_pop_1970a tot_pop_1970
    
	foreach x in white black hispanic{
        foreach y in 1970 1980 1990 2000{
            gen `x'_share_`y' = `x'_pop_`y' / tot_pop_`y' * 100
        }
	}
	
	foreach x in pop_25_om pop_25_om_hs pop_25_om_coll{
	    foreach y in 1970 1980 1990 2000{
            gen `x'_share_`y' = `x'_`y' / tot_pop_`y' * 100
        }
	}
	
	foreach x in 1975 1981 1991 1999{
        gen s_crime_rate_`x' = serious_crimes_`x' / 100000
	}
end

program k_densities
	
	scalar count = 1
	foreach x in tot_pop white_pop black_pop hispanic_pop pop_25_om{
        if count == 1{
		    local xtitle "Total Population"
		}
		else if count == 2{
		    local xtitle "White Population"
		}
		else if count == 3{
		    local xtitle "Black Population"
		}
		else if count == 4{
		    local xtitle "Hispanic Population"
		}
		else if count == 5{
		    local xtitle "Population over 25"
		}
		twoway kdensity `x'_1970 if tot_pop_1970 < 500000 ||                                              ///
	        kdensity `x'_1980 if tot_pop_1980 < 500000 ||                                                 ///
	        kdensity `x'_1990 if tot_pop_1990 < 500000 ||                                                 ///
	        kdensity `x'_2000 if tot_pop_2000 < 500000                                                    ///
	        ,xtitle("`xtitle'") ytitle("Density function")                                                ///
	        title("Density of `xtitle' by County") subtitle(if total population is less than 500.000)     ///
	        legend(order(1 "1970" 2 "1980" 3 "1990" 4 "2000") pos(6) rows(1))                             ///
	        xlabel(25000 "25k" 100000 "100k" 200000 "200k" 300000 "300k" 400000 "400k" 500000 "500k")                                                                        
	    graph export "../output/density_`x'.pdf", replace
		scalar count = count + 1
    }
	
    twoway kdensity s_crime_rate_1975 if tot_pop_1970 < 500000 ||             ///
	    kdensity s_crime_rate_1981 if tot_pop_1980 < 500000 ||                ///
	    kdensity s_crime_rate_1991 if tot_pop_1990 < 500000 ||                ///
	    kdensity s_crime_rate_1999 if tot_pop_2000 < 500000                   ///
	    , xtitle("Serious crime rate") ytitle("Density function")             ///
	    title("Density of Serious Crime Rate (per 100k ppl) by County")       ///
		subtitle(if total population is less than 500.000)                    ///
        legend(order(1 "1970" 2 "1980" 3 "1990" 4 "2000") pos(6) rows(1))      
    graph export "../output/density_s_crime_rate.pdf", replace

    twoway kdensity crime_rate_1975 if tot_pop_1970 < 500000 ||                ///
	    kdensity crime_rate_1981 if tot_pop_1980 < 500000 ||                   ///
	    kdensity crime_rate_1991 if tot_pop_1990 < 500000 ||                   ///
	    kdensity crime_rate_1999 if tot_pop_2000 < 500000                      ///
	    , xtitle("Crime rate") ytitle("Density function")                      ///
        title("Density of Crime Rate (per 100k ppl) by County")                ///
		subtitle(if total population is less than 500.000)                     ///
        legend(order(1 "1970" 2 "1980" 3 "1990" 4 "2000") pos(6) rows(1))      ///
	    xlabel(1000 "1k" 5000 "5k" 10000 "10k" 20000 "20k" 30000 "30k")                                                                                                              
    graph export "../output/density_crime_rate.pdf", replace

	scalar count = 1
	foreach x in white_share black_share hispanic_share pop_25_om_share       ///
	    pop_25_om_hs_share pop_25_om_coll_share{                             
        if count == 1{
		    local xtitle "White Share"
		}
		else if count == 2{
		    local xtitle "Black Share"
		}
		else if count == 3{
		    local xtitle "Hispanic Share"
		}
		else if count == 4{
		    local xtitle "Share over 25"
		}
		else if count == 5{
		    local xtitle "Share over 25 w/ HS Degree"
		}        
		else if count == 6{
		    local xtitle "Share over 25 w/ College Degree"
		}       		
		twoway kdensity `x'_1970 ||                                            ///
	        kdensity `x'_1980 ||                                               ///
	        kdensity `x'_1990 ||                                               ///
	        kdensity `x'_2000                                                  ///
	        , xtitle("`xtitle'") ytitle("Density function")                    ///
	        title("Density of `xtitle' by County")                             ///
	        legend(order(1 "1970" 2 "1980" 3 "1990" 4 "2000") pos(6) rows(1))  
	    graph export "../output/density_`x'.pdf", replace
		scalar count = count + 1
    }
end

program box_plots

    preserve
	
	foreach x in 1970 1980 1990 2000{
	    local var_`x' tot_pop_`x' white_share_`x' black_share_`x' hispanic_share_`x' ///
	        pop_25_om_share_`x' pop_25_om_hs_share_`x' pop_25_om_coll_share_`x'
	    foreach var in `var_`x''{
            label var `var' "`x'"
	    }
	}
	
    foreach x in 1975 1981 1991 1999{
	    local var_`x' crime_rate_`x' s_crime_rate_`x'
	    foreach var in `var_`x''{
            label var `var' "`x'"
	    }
	}

	graph hbox tot_pop_1970 tot_pop_1980 tot_pop_1990 tot_pop_2000,         ///
        title("Total Population by County & by Year") ylabel(1000000 "1M"   ///
        2000000 "2M" 3000000 "3M" 4000000 "4M" 5000000 "5M" 6000000 "6M"    ///
        7000000 "7M" 8000000 "8M" 9000000 "9M" 10000000 "10M")
    graph export "../output/box_tot_pop.pdf", replace
    
	scalar count = 1
	foreach x in white black hispanic pop_25_om pop_25_om_hs pop_25_om_coll{
        if count == 1{
		    local title "White Share"
		}
		else if count == 2{
		    local title "Black Share"
		}
		else if count == 3{
		    local title "Hispanic Share"
		}
		else if count == 4{
		    local title "Share over 25"
		}
		else if count == 5{
		    local title "Share over 25 w/ HS Degree"
		}        
		else if count == 6{
		    local title "Share over 25 w/ College Degree"
		}     	    
        graph hbox `x'_share_1970 `x'_share_1980 `x'_share_1990 `x'_share_2000,     ///
            title("`title' by County & by Year")
        graph export "../output/box_`x'.pdf", replace
		scalar count = count + 1
    }
	
	scalar count = 1
	foreach x in crime_rate s_crime_rate{
        if count == 1{
		    local title "Crime Rate"
		}
		else if count == 2{
		   local title "Serious Crime Rate"
		}	    
        graph hbox `x'_1975 `x'_1981 `x'_1991 `x'_1999,                           ///
            title("`title' by County & by Year") subtitle(Per 100.000 Population) 
        graph export "../output/box_`x'.pdf", replace
		scalar count = count + 1
    }
	
    restore
end

program gen_diff_share

    foreach x in white_share black_share hispanic_share pop_25_om_share   ///
	    pop_25_om_hs_share pop_25_om_coll_share density_pop{
        gen diff_`x'_1 = `x'_1980 - `x'_1970
        gen diff_`x'_2 = `x'_1990 - `x'_1980
        gen diff_`x'_3 = `x'_2000 - `x'_1990
    }
	
	foreach x in s_crime_rate crime_rate{
        gen diff_`x'_1 = `x'_1981 - `x'_1975
        gen diff_`x'_2 = `x'_1991 - `x'_1981
        gen diff_`x'_3 = `x'_1999 - `x'_1991
	}
end

program corr_coeff
    
	foreach x in diff_density_pop diff_white_share diff_black_share diff_hispanic_share{ 
	    foreach y in 1 2 3{
            corr `x'_`y' diff_s_crime_rate_`y' diff_crime_rate_`y'
	    }
	}
end

program ols_reg
    
	foreach x in diff_s_crime_rate diff_crime_rate{
	    foreach y in diff_white_share diff_black_share diff_hispanic_share{
            foreach z in 1 2 3{
                reg `x'_`z' `y'_`z' diff_density_pop_`z' diff_pop_25_om_coll_share_`z'
                reg `x'_`z' `y'_`z' diff_density_pop_`z' diff_pop_25_om_coll_share_`z',r
                reg `x'_`z' `y'_`z' diff_density_pop_`z' diff_pop_25_om_hs_share_`z',r
            }
	    }
	}

end

program avg_percentile_plots
    
    drop if fipstate == "19" | fipstate == "02" // crime rates respectively in 1990 and 1975 are always missing for these 2 states
    levelsof fipstate, local(state)
    foreach z in hispanic black{
        gen diff_`z'_share = `z'_share_2000 - `z'_share_1970
        foreach x in diff_`z'_share `z'_share_1970 `z'_share_1980 `z'_share_1990 `z'_share_2000  ///
		    crime_rate_1975 crime_rate_1981 crime_rate_1991 crime_rate_1999{
	        scalar count = 1
	        foreach y of local state{
			    scalar count_2 = 0
				scalar count_3 = 0
                tabstat `x' if fipstate == "`y'", stat(p1 p10 p25 p50 p75 p90 p99) save
                matrix stats_`x'_`y' = r(StatTotal)
				if count == 1{
				    foreach s in p1 p10 p25 p50 p75 p90 p99{
					    scalar count_2 = count_2 + 1
			            scalar sum_`s'_`x' = stats_`x'_`y'[count_2,1]
						scalar mean_`s'_`x' = sum_`s'_`x' / count
					}
			    }
			    else if count > 1{
			        foreach s in p1 p10 p25 p50 p75 p90 p99{
					    scalar count_3 = count_3 + 1
					    scalar sum_`s'_`x' = sum_`s'_`x' + stats_`x'_`y'[count_3,1]
						scalar mean_`s'_`x' = sum_`s'_`x' / count
			        }
				}
			    scalar count = count + 1
            }
        }
		matrix stat_`z' = (1970, mean_p1_`z'_share_1970, mean_p10_`z'_share_1970, ///
            mean_p25_`z'_share_1970, mean_p50_`z'_share_1970,                     ///
		    mean_p75_`z'_share_1970, mean_p90_`z'_share_1970,                     ///
		    mean_p99_`z'_share_1970 \                                             ///
	        1980, mean_p1_`z'_share_1980, mean_p10_`z'_share_1980,                ///
            mean_p25_`z'_share_1980, mean_p50_`z'_share_1980,                     ///
		    mean_p75_`z'_share_1980, mean_p90_`z'_share_1980,                     ///
		    mean_p99_`z'_share_1980 \                                             ///
		    1990, mean_p1_`z'_share_1990, mean_p10_`z'_share_1990,                ///
            mean_p25_`z'_share_1990, mean_p50_`z'_share_1990,                     ///
		    mean_p75_`z'_share_1990, mean_p90_`z'_share_1990,                     ///
		    mean_p99_`z'_share_1990 \                                             ///
		    2000, mean_p1_`z'_share_2000, mean_p10_`z'_share_2000,                ///
            mean_p25_`z'_share_2000, mean_p50_`z'_share_2000,                     ///
		    mean_p75_`z'_share_2000, mean_p90_`z'_share_2000,                     ///
		    mean_p99_`z'_share_2000)
		svmat double stat_`z', name(stat_`z')
    }
	
	matrix stat_crime_rate = (1970, mean_p1_crime_rate_1975, mean_p10_crime_rate_1975,     ///
           mean_p25_crime_rate_1975, mean_p50_crime_rate_1975,                             ///
		    mean_p75_crime_rate_1975, mean_p90_crime_rate_1975,                            ///
		    mean_p99_crime_rate_1975 \                                                     ///
	        1980, mean_p1_crime_rate_1981, mean_p10_crime_rate_1981,                       ///
            mean_p25_crime_rate_1981, mean_p50_crime_rate_1981,                            ///
		    mean_p75_crime_rate_1981, mean_p90_crime_rate_1981,                            ///
		    mean_p99_crime_rate_1981 \                                                     ///
		    1990, mean_p1_crime_rate_1991, mean_p10_crime_rate_1991,                       ///
            mean_p25_crime_rate_1991, mean_p50_crime_rate_1991,                            ///
		    mean_p75_crime_rate_1991, mean_p90_crime_rate_1991,                            ///
		    mean_p99_crime_rate_1991 \                                                     ///
		    2000, mean_p1_crime_rate_1999, mean_p10_crime_rate_1999,                       ///
            mean_p25_crime_rate_1999, mean_p50_crime_rate_1999,                            ///
		    mean_p75_crime_rate_1999, mean_p90_crime_rate_1999,                            ///
		    mean_p99_crime_rate_1999)
		svmat double stat_crime_rate, name(stat_crime_rate)
		
	foreach x in hispanic black{
	    preserve
	    keep stat_`x'*
	    tsset stat_`x'1
		label var stat_`x'1 "Time"
	    label var stat_`x'2 "1st percentile"
	    label var stat_`x'3 "10th percentile" 
	    label var stat_`x'4 "25th percentile" 
		label var stat_`x'5 "50th percentile" 
	    label var stat_`x'6 "75th percentile" 
	    label var stat_`x'7 "90th percentile" 
	    label var stat_`x'8 "99th percentile"
	    tsline stat_`x'2 stat_`x'3 stat_`x'4 stat_`x'5 stat_`x'6 stat_`x'7 stat_`x'8,      ///
	        title("Percentiles of `x' shares") subtitle(Average percentiles across States) 
        graph export "../output/percentile_`x'_share.pdf", replace
		tsline stat_`x'4 stat_`x'5 stat_`x'6,                                              ///
	        title("Percentiles of `x' shares") subtitle(Average percentiles across States) 
        graph export "../output/percentile_`x'_share_2.pdf", replace
		restore
	}
	    keep stat_crime_rate*
	    tsset stat_crime_rate1
		label var stat_crime_rate1 "Time"
	    label var stat_crime_rate2 "1st percentile"
	    label var stat_crime_rate3 "10th percentile" 
	    label var stat_crime_rate4 "25th percentile" 
		label var stat_crime_rate5 "50th percentile" 
	    label var stat_crime_rate6 "75th percentile" 
	    label var stat_crime_rate7 "90th percentile" 
	    label var stat_crime_rate8 "99th percentile"
		ds stat_crime_rate1, not 
	    tsline `r(varlist)',                                                                ///
		    title("Percentiles of crime rate") subtitle(Average percentiles across States)  ///
			ylabel(2000 "2k" 4000 "4k" 6000 "6k" 8000 "8k" 10000 "10k") 
        graph export "../output/percentile_crime_rate.pdf", replace
		tsline stat_crime_rate4 stat_crime_rate5 stat_crime_rate6,                          ///
	        title("Percentiles of crime rate") subtitle(Average percentiles across States)  
        graph export "../output/percentile_crime_rate_2.pdf", replace

end

program reshape_data
    
	use "../../output_large/county_panel.dta", clear
	
	drop tot_pop_1970b areaname_1970 areaname_1990 areaname_2000
	rename tot_pop_1970a tot_pop_1970
	
	rename *_1975 *_1970
    rename *_1981 *_1980
    rename *_1991 *_1990
    rename *_1999 *_2000
	rename areaname* areaname

    reshape long tot_pop_ land_area_ density_pop_ white_pop_ black_pop_ hispanic_pop_ pop_25_om_ pop_25_om_hs_    ///
        pop_25_om_coll_ serious_crimes_ crime_rate_, i(fipstate fipscnty areaname) j(year)

    rename *_ *
end

program summary_stat_reshaped_data
    
	local var_of_interest *_pop pop_*
	
    tabstat `var_of_interest', stat(n mean median sd min max) col(stat) varwidth(16) format(%9.0f)
	sutex `var_of_interest', nobs minmax title("Descriptive Statistics")     ///
	    key(desc_stat_tab_2) file("../output/desc_stat_tab_2.tex") replace
end

program gen_shares_resheped_data

    foreach x in white black hispanic{
        gen `x'_share = `x'_pop / tot_pop * 100
		gen `x'_share_2 = `x'_share^2
    }
	
	foreach x in pop_25_om pop_25_om_hs pop_25_om_coll{
        gen `x'_share = `x' / tot_pop * 100
    }
	
	gen s_crime_rate = serious_crimes / 100000
	
	local var_of_interest tot_pop density_pop *_share *_rate
	sutex `var_of_interest', nobs minmax title("Descriptive Statistics")    ///
	    key(desc_stat_tab_3) file("../output/desc_stat_tab_3.tex") replace

	gen id = fipstate + fipscnty
	destring id, replace
	xtset id year
	save_data "../temp/reshaped.dta", key(fipstate fipscnty year) replace

end

program graph_trends
    
    scalar count = 1
    foreach x in tot_pop white_pop black_pop hispanic_pop pop_25_om crime_rate s_crime_rate{
	    use "../temp/reshaped.dta", clear
	    collapse (mean) `x', by(year)
		if count == 1{
	        local title "Total Population"
	    }
	    else if count == 2{
	        local title "White Population"
	    }
	    else if count == 3{
	        local title "Black Population"
	    }
        else if count == 4{
	        local title "Hispanic Population"
	    }
	    else if count == 5{
	        local title "Over 25 Population"
	    }
	    else if count == 6{
	        local title "Crime Rate"
		}
	    else if count == 7{
	        local title "Serious Crime Rate"
	    }
		tsline `x', title("Evolution of `title'")          ///
		legend(order(1 "1970" 2 "1980" 3 "1990" 4 "2000")  ///
		pos(6) rows(1)) ytitle("`title'")
	    graph export "../output/evolution_`x'.pdf", replace
		scalar count = count + 1
	}	
end

program scatter_plots
    
	use "../temp/reshaped.dta", clear
	scalar count = 1
    foreach x in crime_rate s_crime_rate{
        if count == 1{
		    local ytitle "Crime Rate"
		}
		else if count == 2{
		    local ytitle "Serious Crime Rate"
		}
	    scalar count_2 = 1
        foreach y in white_share black_share hispanic_share{
            if count_2 == 1{
		        local title "White Share"
		    }
		    else if count_2 == 2{
		        local title "Black Share"
		    }
		    else if count_2 == 3{
		        local title "Hispanic Share"
		    }		
			label var `y' "`title'"
			if count == 1 & count_2 == 2{
		        twoway scatter `x' `y' if crime_rate <10000 & s_crime_rate < 2 ||                                     ///
                    qfitci `x' `y' if crime_rate <10000 & s_crime_rate < 2, ciplot(rline)                             ///
				    title("Scatter & Prediction using Squared Term of `title'")                                       ///
				    subtitle(if Crime Rate is less than 10k & Serious Crime Rate is less than 2)                      ///
				    legend(order(1 "Counties" 2 "95% interval" 3 "Fitted values") pos(6) rows(1)) ytitle("`ytitle'")  ///
					ylabel(0 "0" 5000 "5000" 10000 "10000")
			    graph export "../output/scatter_`x'_`y'.pdf", replace
			    scalar count_2 = count_2 + 1
			}
			else{
			    twoway scatter `x' `y' if crime_rate <10000 & s_crime_rate < 2 ||                                     ///
                    qfitci `x' `y' if crime_rate <10000 & s_crime_rate < 2, ciplot(rline)                             ///
				    title("Scatter & Prediction using Squared Term of `title'")                                       ///
				    subtitle(if Crime Rate is less than 10k & Serious Crime Rate is less than 2)                      ///
				    legend(order(1 "Counties" 2 "95% interval" 3 "Fitted values") pos(6) rows(1)) ytitle("`ytitle'")
			    graph export "../output/scatter_`x'_`y'.pdf", replace
			    scalar count_2 = count_2 + 1
			}   
	    }
		scalar count = count + 1
	}
end

program xt_reg
	
	local controls density_pop pop_25_om_coll_share
	local controls_2 density_pop pop_25_om_hs_share
	
	foreach x in crime_rate s_crime_rate serious_crimes{
	    scalar count = 1
        foreach y in white_share black_share hispanic_share{
            if count == 1{
                local appendreplace "replace"
            }
            else{
		        local appendreplace "append"
            }
		    xtreg `x' `y' `y'_2 `controls' i.year, fe
            outreg2 using "../output/reg_`x'.tex", `appendreplace' label bdec(3) sdec(3) rdec(3)   ///
                symbol(***,**,*) alpha(0.01,0.05,0.1) keep(`x' `y' `y'_2 `controls')
		
		    local appendreplace "append"
		
		    xtreg `x' `y' `y'_2 `controls' i.year, vce(r) fe
            outreg2 using "../output/reg_`x'.tex", `appendreplace' label bdec(3) sdec(3) rdec(3)   ///
                symbol(***,**,*) alpha(0.01,0.05,0.1) keep(`x' `y' `y'_2 `controls')
		
		    xtreg `x' `y' `y'_2 `controls_2' i.year, vce(r) fe
            outreg2 using "../output/reg_`x'.tex", `appendreplace' label bdec(3) sdec(3) rdec(3)   ///
                symbol(***,**,*) alpha(0.01,0.05,0.1) keep(`x' `y' `y'_2 `controls_2')
		
            scalar count = count + 1
        }
	}
end

program quartiles_analysis
    
    foreach x in hispanic black{
        gen `x'_70_00 = `x'_share[_n+3] - `x'_share if areaname[_n+3] == areaname
		replace `x'_70_00 = `x'_70_00[_n-1] if `x'_70_00 ==.
	}
    
	foreach x in hispanic black{
        gen `x'_80_00 = `x'_share[_n+3] - `x'_share[_n+1] if areaname[_n+3] == areaname
		replace `x'_80_00 = `x'_80_00[_n-1] if `x'_80_00 ==.
	}
	
	sort fipstate fipscnty year
	foreach x in hispanic black{ 
	    foreach y in 25 50 75{
	        by fipstate: egen pct_`x'_70_00_`y' = pctile(`x'_70_00), p(`y')
			by fipstate: egen pct_`x'_80_00_`y' = pctile(`x'_80_00), p(`y')
	    }
	}
    
	sort fipstate year
	foreach y in 25 50 75{
	    by fipstate year: egen pct_density_pop_`y' = pctile(density_pop), p(`y')
	}
	
	foreach x in hispanic_70_00 black_70_00 hispanic_80_00 black_80_00 density_pop{
	    gen pct_`x' = 1 if `x' <= pct_`x'_25
	    replace pct_`x' = 2 if `x' > pct_`x'_25 & `x' <= pct_`x'_50
	    replace pct_`x' = 3 if `x' > pct_`x'_50 & `x' <= pct_`x'_75
	    replace pct_`x' = 4 if `x' > pct_`x'_75
	}
		
	foreach x in pct_hispanic_70_00 pct_black_70_00 pct_hispanic_80_00 pct_black_80_00{
	    preserve
	    collapse (mean) white_share black_share hispanic_share crime_rate, by(`x' year)
	    save_data "../temp/collapse_`x'.dta", key(`x' year) replace
		restore
	}

	foreach x in pct_hispanic_70_00 pct_black_70_00 pct_hispanic_80_00 pct_black_80_00{
	    preserve
	    collapse (mean) white_share black_share hispanic_share crime_rate, by(`x' pct_density_pop year)
	    save_data "../temp/collapse_`x'_and_density.dta", key(`x' pct_density_pop year) replace		
		restore
	}
	
	scalar count = 1
	foreach x in hispanic_70_00 hispanic_80_00 black_70_00 black_80_00{
		use "../temp/collapse_pct_`x'.dta", clear
	    xtset pct_`x' year
		if count == 1{
			local subtitle "diff hisp shares (1970-2000)"
			}
		else if count == 2{
			local subtitle "diff hisp shares (1980-2000)"
		}
		else if count == 3{
		    local subtitle "diff black shares (1970-2000)"
		}
		else if count == 4{
		    local subtitle "diff black shares (1980-2000)"
		}
		scalar count_2 = 1
	    foreach y in white_share black_share hispanic_share crime_rate{
		    if count_2 == 1{
			    local title "White Share"
			}
			else if count_2 == 2{
			    local title "Black Share"
			}
			else if count_2 == 3{
			    local title "Hispanic Share"
			}
			else if count_2 == 4{
			    local title "Crime Rate"
			}
			label var `y' "`y'"
			tsline `y' if pct_`x' == 1     ||                                                       ///
	            tsline `y' if pct_`x' == 2 ||                                                       ///
	            tsline `y' if pct_`x' == 3 ||                                                       ///
	            tsline `y' if pct_`x' == 4                                                          ///
	            , title("`title'") subtitle(Counties grouped by state & by quartiles in `subtitle') ///
				legend(order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4") pos(6) rows(1)) ytitle("`title'")
            graph export "../output/`y'_`x'.pdf", replace
			scalar count_2 = count_2 + 1
	    }
		scalar count =count + 1
	}
	
	scalar count = 1
	foreach x in hispanic_70_00 hispanic_80_00 black_70_00 black_80_00{
		use "../temp/collapse_pct_`x'_and_density.dta", clear
		egen group_`x' = group(pct_`x' pct_density_pop)
	    xtset group_`x' year
		if count == 1{
			local subtitle "diff hisp shares (1970-2000)"
			local legend "diff hisp shares"
			}
		else if count == 2{
			local subtitle "diff hisp shares (1980-2000)"
			local legend "diff hisp shares"
		}
		else if count == 3{
		    local subtitle "diff black shares (1970-2000)"
			local legend "diff black shares"
		}
		else if count == 4{
		    local subtitle "diff black shares (1980-2000)"
			local legend "diff black shares"
		}
		scalar count_2 = 1
	    foreach y in white_share black_share hispanic_share crime_rate{
		    if count_2 == 1{
			    local title "White Share"
			}
			else if count_2 == 2{
			    local title "Black Share"
			}
			else if count_2 == 3{
			    local title "Hispanic Share"
			}
			else if count_2 == 4{
			    local title "Crime Rate"
			}
			label var `y' "`y'"
			foreach z in 1 2 3 4{
			    tsline `y' if pct_`x' == 1 & pct_density_pop ==  `z'     ||                                                   ///
	                tsline `y' if pct_`x' == 2 & pct_density_pop ==  `z' ||                                                   ///
	                tsline `y' if pct_`x' == 3 & pct_density_pop ==  `z' ||                                                   ///
	                tsline `y' if pct_`x' == 4 & pct_density_pop ==  `z'                                                      ///
	                , title("`title': Pop Density Q`z'") subtitle(Counties grouped by state & by quartiles in `subtitle') ///
				    legend(order(1 "Q1 in `legend'" 2 "Q2 in `legend'" 3 "Q3 in `legend'" 4 "Q4 in `legend'")             ///
					pos(6) rows(2)) ytitle("`title'")
                graph export "../output/`y'_`x'_`z'.pdf", replace
				}
			scalar count_2 = count_2 + 1
	    }
		scalar count =count + 1
	}

end

program diff_in_diff
    
	use "../temp/reshaped.dta", clear
	foreach x in white_share black_share hispanic_share s_crime_rate crime_rate{
        gen diff_`x' = `x' - `x'[_n - 1] if id == id[_n - 1]
    }
	    
	/*
	Create lower and upper bounds for each variable of interest within each year
	(national avg in year x +\- st. dev. in year x)
	*/
	foreach x in 1970 1980 1990 2000{
	    scalar count = 1
	    tabstat white_share black_share hispanic_share diff_white_share diff_black_share diff_hispanic_share       ///
		   diff_crime_rate diff_s_crime_rate if year == `x', stat(mean sd) save
	    matrix stats_`x' = r(StatTotal)
	    foreach y in white_share black_share hispanic_share diff_white_share diff_black_share diff_hispanic_share   ///
	        diff_crime_rate diff_s_crime_rate{
			if count == 1{
		        local col 1
		    }
		    else if count == 2{
		        local col 2
            }
	        else if count == 3{
	            local col 3
	        }
	        else if count == 4{
	            local col 4
	        }
	        else if count == 5{
	            local col 5
	        }
	        else if count == 6{
	            local col 6
	        }
	        else if count == 7{
	            local col 7
	        }
	        else if count == 8{
	            local col 8
	        }
			if count < 7{
                scalar `y'_ub_`x' = stats_`x'[1,`col'] + (stats_`x'[2,`col'] / 5)
                scalar `y'_lb_`x' = stats_`x'[1,`col'] - (stats_`x'[2,`col'] / 5)
			}
			else if count > 6{
                scalar `y'_ub_`x' = stats_`x'[1,`col'] + (stats_`x'[2,`col'] / 100)
                scalar `y'_lb_`x' = stats_`x'[1,`col'] - (stats_`x'[2,`col'] / 100)				
			}
		    scalar count = count + 1
	    }
	}
	
	* Select counties with high diff in hispanic or black shares (TREATMENTS)
	scalar count = 1
	foreach y in hispanic black{
        foreach x in 1980 1990 2000{
	        if count == 1{
	            local year 1970
				local race `y'
		        local race_other black
		    }
			else if count == 2{
		        local year 1980
				local race `y'
		        local race_other black
		    }
			else if count == 3{
		        local year 1990
				local race `y'
		        local race_other black
		    }
			else if count == 4{
		        local year 1970
				local race `y'
		        local race_other hispanic
		    }
			else if count == 5{
		        local year 1980
				local race `y'
		        local race_other hispanic
		    }
			else if count == 6{
		        local year 1990
				local race `y'
		        local race_other hispanic
		    }
	        gen high_diff_`race'_share_`x' = 0
	        replace high_diff_`race'_share_`x' = 1 if year == `x'             ///
			    & id == id[_n - 1]                                            ///
			    & white_share[_n - 1] > white_share_ub_`year'                 ///
				& white_share[_n - 1] != .                                    ///
                & `race'_share[_n - 1] < `race'_share_lb_`year'               ///
		        & diff_`race'_share > diff_`race'_share_ub_`x'                ///
				& diff_`race'_share != .                                      ///
                & diff_`race_other'_share < diff_`race_other'_share_lb_`x'    ///
		        & diff_`race_other'_share > -1                                ///
		        & diff_crime_rate > diff_crime_rate_ub_`x'                    ///
				& diff_crime_rate != .                                      
            scalar count = count + 1
	    }
	}
    
	preserve
	local high_diff high_diff*
	egen high_diff = rowtotal(`high_diff')
	keep if high_diff >= 1
	save_data "../temp/high_diff_share_minorities.dta", key(fipstate fipscnty year) replace
	restore
	
	* Select counties with almost no diff in hispanic or black shares (CONTROLS)
	scalar count = 1
    foreach x in 1980 1990 2000{
	    if count == 1{
	        local year 1970
		}
		else if count == 2{
		    local year 1980
		}
		else if count == 3{
		    local year 1990
		}
        gen no_diff_share_`x' = 0
        replace no_diff_share_`x' = 1 if year == `x'               ///
		    & id == id[_n - 1]                                     ///
		    & white_share[_n - 1] > white_share_ub_`year'          ///
			& white_share[_n - 1] != .                             ///
            & white_share > white_share_ub_`x'                     ///
			& white_share != .                                     ///
            & black_share[_n - 1] < black_share_lb_`year'          ///
            & black_share < black_share_lb_`x'                     ///
            & hispanic_share[_n - 1] < hispanic_share_lb_`year'    ///
			& hispanic_share < hispanic_share_lb_`x'               ///
			& diff_black_share < diff_black_share_lb_`x'           ///
	        & diff_black_share > -1                                ///
            & diff_hispanic_share < diff_hispanic_share_lb_`x'     ///
	        & diff_hispanic_share > -1                             ///
			& diff_crime_rate < diff_crime_rate_lb_`x'                 
        scalar count = count + 1
    }
	
	preserve
	local no_diff no*
	egen no_diff = rowtotal(`no_diff')
	keep if no_diff == 1
	save_data "../temp/no_diff_share_minorities.dta", key(fipstate fipscnty year) replace
	restore
	
    * Select counties with high reduction in hispanic or black shares (TREATMENTS)
	scalar count = 1
	foreach y in hispanic black{
        foreach x in 1980 1990 2000{
	        if count == 1{
	            local year 1970
				local race `y'
		        local race_other black
		    }
			else if count == 2{
		        local year 1980
				local race `y'
		        local race_other black
		    }
			else if count == 3{
		        local year 1990
				local race `y'
		        local race_other black
		    }
			else if count == 4{
		        local year 1970
				local race `y'
		        local race_other hispanic
		    }
			else if count == 5{
		        local year 1980
				local race `y'
		        local race_other hispanic
		    }
			else if count == 6{
		        local year 1990
				local race `y'
		        local race_other hispanic
		    }
	        gen high_red_`race'_share_`x' = 0
	        replace high_red_`race'_share_`x' = 1 if year == `x'              ///
			    & id == id[_n - 1]                                            ///
			    & `race'_share[_n - 1] > `race'_share_ub_`year'               ///
				& `race'_share[_n - 1] != .                                   ///
                & white_share[_n - 1] < white_share_lb_`year'                 ///
		        & diff_`race'_share < -5                                       ///
                & diff_`race_other'_share < diff_`race_other'_share_lb_`x'    ///
		        & diff_`race_other'_share > -1                                ///
		        & diff_crime_rate < diff_crime_rate_lb_`x'                   
            scalar count = count + 1
	    }
	}
			
	preserve
	local high_red high_red*
	egen high_red = rowtotal(`high_red')
	keep if high_red == 1
	save_data "../temp/high_red_share_minorities.dta", key(fipstate fipscnty year) replace
	restore
    
	scalar count = 1
	foreach z in diff red{
	    use "../temp/high_`z'_share_minorities.dta", clear
	    merge 1:1 fipstate fipscnty year using "../temp/no_diff_share_minorities.dta", ///
            assert(1 2) keep(1 2)
	    save_data "../temp/merge_`z'_share_minorities.dta", key(fipstate fipscnty year) replace
		
	    egen group = group(fipstate year)
	    scalar count_2 = 1
		
        foreach x in hispanic black{
	        if count == 1{
		        local diffred diff
		    }
		    else if count == 2{
		        local diffred red
		    }			    
		    local high_`z'_`x' high_`z'_`x'*
	        egen high_`z'_`x' = rowtotal(`high_`z'_`x'')
	        gen treated_`x' = 0
	        replace treated_`x' = 1 if _merge == 1 & high_`diffred'_`x' == 1
		}
		
	    foreach x in hispanic black{
	        if count_2 == 1{
		        local race_other black
		    }
		    else if count_2 == 2{
		        local race_other hispanic
		    }		

	        preserve
	        drop if treated_`race_other' == 1
	        sort fipstate year density_pop treated_`x'
	        keep if (fipstate == fipstate[_n + 1] & year == year[_n + 1] & treated_`x' != treated_`x'[_n + 1]) |       ///
	            (fipstate == fipstate[_n - 1] & year == year[_n - 1] & treated_`x' != treated_`x'[_n - 1])
	        order fipstate fipscnty year treated_`x' density_pop group
	        rename diff_white_share diff_white
	        rename diff_black_share diff_black
	        rename diff_hispanic_share diff_hispanic
	        list areaname year treated_`x' density_pop group diff_white diff_black diff_hispanic diff_crime_rate, sepby(group) abb(21)
		    texsave areaname year treated_`x' density_pop group diff_white diff_black diff_hispanic diff_crime_rate     ///
		        using "../output/list_`z'_`x'.tex", title(Pairs of Counties to Apply Diff-in-Diff)                      ///
			    footnote("Check, if needed, the algorithm used to pick these pairs of counties") replace
		    restore
		    scalar count_2 = count_2 + 1
	    }
		scalar count = count + 1
	}
end

* EXECUTE
main
