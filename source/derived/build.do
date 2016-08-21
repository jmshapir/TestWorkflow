clear all
version 12
set more off

adopath + "source/lib/stata/ado/"


program main
    prepare_data_1970
    prepare_data_1980
    prepare_data_1990
    prepare_data_2000
    merge_files
end

program prepare_data_1970
    use "raw/County and City Databooks/data/1947-1977/07736-0001-Data.dta", clear
	//use "../external/raw_databooks/1947-1977/07736-0001-Data.dta", clear
	
    rename FIPSTATE fipstate
    rename FIPSCNTY fipscnty
    rename AREANAME areaname_1970
	rename CC00004F land_area_1970_f
	rename CC00004 land_area_1970
    rename CC00015F tot_pop_1970a_f
    rename CC00015 tot_pop_1970a
    rename CC00016F tot_pop_1970b_f
    rename CC00016 tot_pop_1970b
    rename CC00052F white_pop_1970_f
    rename CC00052 white_pop_1970
    rename CC00056F black_pop_pct_1970_f
    rename CC00056 black_pop_pct_1970
    rename CC00081F hispanic_pop_pct_1970_f
    rename CC00081 hispanic_pop_pct_1970
    rename CC00123F pop_25_om_1970_f
    rename CC00123 pop_25_om_1970
    rename CC00128F pop_25_om_hs_pct_1970_f
    rename CC00128 pop_25_om_hs_pct_1970
    rename CC00129F pop_25_om_coll_pct_1970_f
    rename CC00129 pop_25_om_coll_pct_1970
    rename CC00436F serious_crimes_1975_f
    rename CC00436 serious_crimes_1975
    rename CC00437F crime_rate_1975_f
    rename CC00437 crime_rate_1975
	rename CC00438F robberies_1975_f
	rename CC00438 robberies_1975
	rename CC00439F assaults_1975_f
	rename CC00439 assaults_1975
	rename CC00440F burglaries_1975_f
	rename CC00440 burglaries_1975
	rename CC00441F auto_thft_1975_f
	rename CC00441 auto_thft_1975
	
    keep fipstate fipscnty areaname_1970 land_area_1970_f land_area_1970 tot_pop_1970a_f             ///
	    tot_pop_1970a tot_pop_1970b_f tot_pop_1970b white_pop_1970_f white_pop_1970                  ///
	    black_pop_pct_1970_f black_pop_pct_1970 hispanic_pop_pct_1970_f hispanic_pop_pct_1970        ///
	    pop_25_om_1970_f pop_25_om_1970 pop_25_om_hs_pct_1970_f pop_25_om_hs_pct_1970                ///
	    pop_25_om_coll_pct_1970_f pop_25_om_coll_pct_1970 serious_crimes_1975_f serious_crimes_1975  ///
	    crime_rate_1975_f crime_rate_1975 robberies_1975_f robberies_1975 assaults_1975_f            ///
	    assaults_1975 burglaries_1975_f burglaries_1975 auto_thft_1975_f auto_thft_1975          
	
	foreach x in 1 2 3 6 7{
	    replace land_area_1970 = . if land_area_1970 == 0 & land_area_1970_f == "`x'"
	    replace tot_pop_1970a = . if tot_pop_1970a == 0 & tot_pop_1970a_f == "`x'"
	    replace tot_pop_1970b = . if tot_pop_1970b == 0 & tot_pop_1970b_f == "`x'"
	    replace white_pop_1970 = . if white_pop_1970 == 0 & white_pop_1970_f == "`x'"
	    replace black_pop_pct_1970 = . if black_pop_pct_1970 == 0 & black_pop_pct_1970_f == "`x'"
	    replace hispanic_pop_pct_1970 = . if hispanic_pop_pct_1970 == 0 & hispanic_pop_pct_1970_f == "`x'"
	    replace pop_25_om_1970 = . if pop_25_om_1970 == 0 & pop_25_om_1970_f == "`x'"
	    replace pop_25_om_hs_pct_1970 = . if pop_25_om_hs_pct_1970 == 0 & pop_25_om_hs_pct_1970_f == "`x'"
	    replace pop_25_om_coll_pct_1970 = . if pop_25_om_coll_pct_1970 == 0 & pop_25_om_coll_pct_1970_f == "`x'"
	    replace serious_crimes_1975 = . if serious_crimes_1975 == 0 & serious_crimes_1975_f == "`x'"
	    replace crime_rate_1975 = . if crime_rate_1975 == 0 & crime_rate_1975_f == "`x'"
	}
	
	/*
	When FLAG = 7 --> No data. Data omitted for negro or spanish herritage populations less than 400
	We replace misssing back otherwise too many missing values. These obs are close to zero anyway.
	*/
	replace hispanic_pop_pct_1970 = 0 if hispanic_pop_pct_1970 == . & hispanic_pop_pct_1970_f == "7" 
	
    gen black_pop_1970 = black_pop_pct_1970 * tot_pop_1970a / 100
    replace black_pop_1970 = round(black_pop_1970)
    rename black_pop_pct_1970_f black_pop_1970_f
    label var black_pop_1970 "BLACK POPULATION 1970"
    label var black_pop_1970_f "BLACK POPULATION 1970 FLAG"

    gen hispanic_pop_1970 = hispanic_pop_pct_1970 * tot_pop_1970a / 100
    replace hispanic_pop_1970 = round(hispanic_pop_1970)
    rename hispanic_pop_pct_1970_f hispanic_pop_1970_f
    label var hispanic_pop_1970 "HISPANIC POPULATION 1970"
    label var hispanic_pop_1970_f "HISPANIC POPULATION 1970 FLAG"
	
    gen pop_25_om_hs_1970 = pop_25_om_hs_pct_1970 * pop_25_om_1970 / 100
    replace pop_25_om_hs_1970 = round(pop_25_om_hs_1970)
    rename pop_25_om_hs_pct_1970_f pop_25_om_hs_1970_f
    label var pop_25_om_hs_1970 "PERSONS 25 YEARS OR MORE /W HI SCHL OM 1970"
    label var pop_25_om_hs_1970_f "PERSONS 25 YEARS OR MORE /W HI SCHL OM 1970 FLAG"

    gen pop_25_om_coll_1970 = pop_25_om_coll_pct_1970 * pop_25_om_1970 / 100
    replace pop_25_om_coll_1970 = round(pop_25_om_coll_1970)
    rename pop_25_om_coll_pct_1970_f pop_25_om_coll_1970_f
    label var pop_25_om_coll_1970 "PERSONS 25 YEARS OR MORE /W COLL OM 1970"
    label var pop_25_om_coll_1970_f "PERSONS 25 YEARS OR MORE /W COLL OM 1970 FLAG"
	
	gen density_pop_1970 = tot_pop_1970b / land_area_1970
	label var density_pop_1970 "POPULATION DENSITY IN SQ ML IN 1970"
	
    drop robberies_1975_f robberies_1975 assaults_1975_f assaults_1975 burglaries_1975_f            ///
	    burglaries_1975 auto_thft_1975_f auto_thft_1975 black_pop_pct_1970 hispanic_pop_pct_1970    ///
	    pop_25_om_hs_pct_1970 pop_25_om_coll_pct_1970

    save_data "temp/cleaned_1947_1977.dta", key(fipstate fipscnty) replace
end

program prepare_data_1980
	local dict_file "raw/County and City Databooks/data/1983/08256-0001-Setup.dct"
	local data_file "raw/County and City Databooks/data/1983/08256-0001-Data.txt"
    //local dict_file "../external/raw_databooks/1983/08256-0001-Setup.dct"
	//local data_file "../external/raw_databooks/1983/08256-0001-Data.txt"
    infile using `"`dict_file'"', using (`"`data_file'"') clear

	rename GEO8001A id
    rename GEOG8002 areaname_1980
	rename LAN8001F land_area_1980_f
	rename LAN8001 land_area_1980
    rename POP8001F tot_pop_1980_f
    rename POP8001 tot_pop_1980
    rename POP8009F white_pop_1980_f
    rename POP8009 white_pop_1980
    rename POPG811F black_pop_1980_f
    rename POPG811 black_pop_1980
    rename POP8017F hispanic_pop_1980_f
    rename POP8017 hispanic_pop_1980
    rename POP8022F pop_25_om_1980_f
    rename POP8022 pop_25_om_1980
    rename EDU8023F pop_25_om_hs_1980_f
    rename EDU8023 pop_25_om_hs_1980
    rename EDU8007F pop_25_om_coll_1980_f
    rename EDU8007 pop_25_om_coll_1980
    rename CRI8102F serious_crimes_1981_f
    rename CRI8102 serious_crimes_1981
    rename CRI8101F crime_rate_1981_f
    rename CRI8101 crime_rate_1981
	rename CRI8111F property_crimes_1981_f
	rename CRI8111 property_crimes_1981

    keep id areaname_1980 land_area_1980_f land_area_1980 tot_pop_1980_f tot_pop_1980                      ///
	    white_pop_1980_f white_pop_1980 black_pop_1980_f black_pop_1980 hispanic_pop_1980_f                ///
	    hispanic_pop_1980 pop_25_om_hs_1980_f  pop_25_om_hs_1980 pop_25_om_coll_1980_f                     ///
	    pop_25_om_coll_1980 pop_25_om_1980_f pop_25_om_1980 serious_crimes_1981_f                          ///
	    serious_crimes_1981 crime_rate_1981_f crime_rate_1981 property_crimes_1981_f property_crimes_1981 
	
	foreach x in 3 4 5 6{
	    replace land_area_1980 = . if land_area_1980 == 0 & land_area_1980_f == `x'
	    replace tot_pop_1980 = . if tot_pop_1980 == 0 & tot_pop_1980_f == `x'
	    replace white_pop_1980 = . if white_pop_1980 == 0 & white_pop_1980_f == `x'
	    replace black_pop_1980 = . if black_pop_1980 == 0 & black_pop_1980_f == `x'
	    replace hispanic_pop_1980 = . if hispanic_pop_1980 == 0 & hispanic_pop_1980_f == `x'
	    replace pop_25_om_1980 = . if pop_25_om_1980 == 0 & pop_25_om_1980_f == `x'
	    replace pop_25_om_hs_1980 = . if pop_25_om_hs_1980 == 0 & pop_25_om_hs_1980_f == `x'
	    replace pop_25_om_coll_1980 = . if pop_25_om_coll_1980 == 0 & pop_25_om_coll_1980_f == `x'
	    replace serious_crimes_1981 = . if serious_crimes_1981 == 0 & serious_crimes_1981_f == `x'
	    replace crime_rate_1981 = . if crime_rate_1981 == 0 & crime_rate_1981_f == `x'
    }
    
	tostring id, replace
	replace id = "0000" if id == "0"
	replace id = "0" + id if length(id) == 4
	gen fipstate = substr(id,1,2)
	gen fipscnty = substr(id,3,3)
	
	gen density_pop_1980 = tot_pop_1980 / land_area_1980
	label var density_pop_1980 "POPULATION DENSITY IN SQ ML IN 1980"
	
	drop id property_crimes_1981_f property_crimes_1981

    save_data "temp/cleaned_1980.dta", key(fipstate fipscnty) replace
end

program prepare_data_1990
	use "temp/COF01.dta", clear
    //use "../external/raw_databooks/1994/COF01.DTA", clear

	rename state fipstate
	rename county fipscnty
    rename areaname areaname_1990
	rename FLAG001 land_area_1990_f
	rename ITEM001 land_area_1990
	rename FLAG005 tot_pop_1990_f
    rename ITEM005 tot_pop_1990
    label var tot_pop_1990_f "FLAG FOR POPULATION 1990"
    label var tot_pop_1990 "POPULATION 1990"
	label var land_area_1990_f "FLAG FOR LAND AREA 1990"
    label var land_area_1990 "LAND AREA 1990"
		
    keep fipstate fipscnty areaname_1990 land_area_1990_f land_area_1990 tot_pop_1990_f tot_pop_1990
    save_data "temp/cleaned_1990_COF01.dta", key(fipstate fipscnty) replace

	use "temp/COF02.dta", clear
    //use "../external/raw_databooks/1994/COF02.DTA", clear

    rename state fipstate
	rename county fipscnty
    rename areaname areaname_1990
	rename FLAG009 white_pop_1990_f
    rename ITEM009 white_pop_1990
    rename FLAG010 black_pop_1990_f
    rename ITEM010 black_pop_1990
    rename FLAG013 hispanic_pop_1990_f
    rename ITEM013 hispanic_pop_1990
	label var white_pop_1990_f "FLAG FOR POPULATION BY RACE, WHITE 1990"
    label var white_pop_1990 "POPULATION BY RACE, WHITE 1990"
    label var black_pop_1990_f "FLAG FOR POPULATION BY RACE, BLACK 1990"
    label var black_pop_1990 "POPULATION BY RACE, BLACK 1990"
    label var hispanic_pop_1990_f "FLAG FOR HISPANIC ORIGIN POPULATION, TOTAL"
    label var hispanic_pop_1990 "HISPANIC ORIGIN POPULATION, TOTAL"
    
	keep fipstate fipscnty areaname_1990 white_pop_1990_f white_pop_1990     ///
	    black_pop_1990_f  black_pop_1990 hispanic_pop_1990_f hispanic_pop_1990
	save_data "temp/cleaned_1990_COF02.dta", key(fipstate fipscnty) replace

	use "temp/COF06.dta", clear
    //use "../external/raw_databooks/1994/COF06.DTA", clear 
    
	rename state fipstate
	rename county fipscnty
    rename areaname areaname_1990
	rename FLAG061 serious_crimes_1991_f
    rename ITEM061 serious_crimes_1991
	rename FLAG062 violent_crimes_1991_f
    rename ITEM062 violent_crimes_1991
    rename FLAG063 crime_rate_1991_f
    rename ITEM063 crime_rate_1991
	label var serious_crimes_1991_f "FLAG FOR SERIOUS CRIMES KNOWN TO POLICE 1991"
    label var serious_crimes_1991 "SERIOUS CRIMES KNOWN TO POLICE 1991"
	label var violent_crimes_1991_f "FLAG FOR SERIOUS CRIMES KNOWN TO POLICE, VIOLENT 1991"
	label var violent_crimes_1991 "SERIOUS CRIMES KNOWN TO POLICE, VIOLENT 1991"
    label var crime_rate_1991_f "FLAG FOR SERIOUS CRIMES PER 100,000 POPULATION 1991"
    label var crime_rate_1991 "SERIOUS CRIMES PER 100,000 POPULATION 1991"
	
	keep fipstate fipscnty areaname_1990 serious_crimes_1991_f serious_crimes_1991   ///
	    violent_crimes_1991_f violent_crimes_1991 crime_rate_1991_f crime_rate_1991
	save_data "temp/cleaned_1990_COF06.dta", key(fipstate fipscnty) replace

	use "temp/COF07.dta", clear
    //use "../external/raw_databooks/1994/COF07.DTA", clear
    
    rename state fipstate
	rename county fipscnty
    rename areaname areaname_1990
	rename FLAG069 pop_25_om_1990_f
    rename ITEM069 pop_25_om_1990
    rename FLAG070 pop_25_om_hs_pct_1990_f
    rename ITEM070 pop_25_om_hs_pct_1990
    rename FLAG071 pop_25_om_coll_pct_1990_f
    rename ITEM071 pop_25_om_coll_pct_1990
	label var pop_25_om_1990_f "FLAG FOR PERSONS 25 YEARS AND OVER 1990"
    label var pop_25_om_1990 "PERSONS 25 YEARS AND OVER 1990"
    label var pop_25_om_hs_pct_1990_f "FLAG FOR PERSONS 25 YEARS AND OVER, PERCENT HIGH SCHOOL GRADUATE OR HIGHER 1990"
    label var pop_25_om_hs_pct_1990 "PERSONS 25 YEARS AND OVER, PERCENT HIGH SCHOOL GRADUATE OR HIGHER 1990"
    label var pop_25_om_coll_pct_1990_f "FLAG FOR PERSONS 25 YEARS AND OVER, PERCENT WITH BACHELOR'S DEGREE OR HIGHER 1990"
    label var pop_25_om_coll_pct_1990 "PERSONS 25 YEARS AND OVER, PERCENT WITH BACHELOR'S DEGREE OR HIGHER 1990"
    
	keep fipstate fipscnty areaname_1990 pop_25_om_1990_f pop_25_om_1990 pop_25_om_hs_pct_1990_f   ///
	    pop_25_om_hs_pct_1990 pop_25_om_coll_pct_1990_f pop_25_om_coll_pct_1990
	save_data "temp/cleaned_1990_COF07.dta", key(fipstate fipscnty) replace

    * Merge of the temp dta just created
    use "temp/cleaned_1990_COF01.dta", replace
    foreach x in 2 6 7{
        merge 1:1 fipstate fipscnty using "temp/cleaned_1990_COF0`x'.dta", ///
            assert(3) nogen keep(3)
    }

    label var areaname_1990 "AREA NAME 1990"
	
	foreach x in 3 4 5 6{
	    replace land_area_1990 = . if land_area_1990 == 0 & land_area_1990_f == `x'
	    replace tot_pop_1990 = . if tot_pop_1990 == 0 & tot_pop_1990_f == `x'
	    replace white_pop_1990 = . if white_pop_1990 == 0 & white_pop_1990_f == `x'
	    replace black_pop_1990 = . if black_pop_1990 == 0 & black_pop_1990_f == `x'
	    replace hispanic_pop_1990 = . if hispanic_pop_1990 == 0 & hispanic_pop_1990_f == `x'
	    replace pop_25_om_1990 = . if pop_25_om_1990 == 0 & pop_25_om_1990_f == `x'
	    replace pop_25_om_hs_pct_1990 = . if pop_25_om_hs_pct_1990 == 0 & pop_25_om_hs_pct_1990_f == `x'
	    replace pop_25_om_coll_pct_1990 = . if pop_25_om_coll_pct_1990 == 0 & pop_25_om_coll_pct_1990_f == `x'
	    replace serious_crimes_1991 = . if serious_crimes_1991 == 0 & serious_crimes_1991_f == `x'
	    replace crime_rate_1991 = . if crime_rate_1991 == 0 & crime_rate_1991_f == `x'
    }
	
    gen pop_25_om_hs_1990 = pop_25_om_hs_pct_1990 * pop_25_om_1990 / 100
    replace pop_25_om_hs_1990 = round(pop_25_om_hs_1990)
    rename pop_25_om_hs_pct_1990_f pop_25_om_hs_1990_f
    label var pop_25_om_hs_1990 "PERSONS 25 YEARS OR MORE /W HI SCHL OM 1990"
    label var pop_25_om_hs_1990_f "PERSONS 25 YEARS OR MORE /W HI SCHL OM 1990 FLAG"

    gen pop_25_om_coll_1990 = pop_25_om_coll_pct_1990 * pop_25_om_1990 / 100
    replace pop_25_om_coll_1990 = round(pop_25_om_coll_1990)
    rename pop_25_om_coll_pct_1990_f pop_25_om_coll_1990_f
    label var pop_25_om_coll_1990 "PERSONS 25 YEARS OR MORE /W COLL OM 1990"
    label var pop_25_om_coll_1990_f "PERSONS 25 YEARS OR MORE /W COLL OM 1990 FLAG"

    gen density_pop_1990 = tot_pop_1990 / land_area_1990
	label var density_pop_1990 "POPULATION DENSITY IN SQ ML IN 1990"
	
	drop violent_crimes_1991_f violent_crimes_1991 pop_25_om_hs_pct_1990 pop_25_om_coll_pct_1990

    save_data "temp/cleaned_1990.dta", key(fipstate fipscnty) replace
end

program prepare_data_2000
	import delimited "raw/County and City Databooks/data/2000/cc00_tab_B1.csv", clear
    //import delimited "../external/raw_databooks/2000/cc00_tab_B1.csv", clear
    rename b1geo01 id
	rename b1geo09 areaname_2000
	rename b1lnd01 land_area_2000
    rename b1pop03 tot_pop_2000
	rename b1pop15 hispanic_pop_2000
	rename b1pop16 hispanic_pop_pct_2000
	tostring id, replace
	replace id = "0000" if id == "0"
	replace id = "0" + id if length(id) == 4
	
	keep id areaname_2000 land_area_2000 tot_pop_2000 hispanic_pop_2000 hispanic_pop_pct_2000	
    save_data "temp/cleaned_2000_cc00_tab_B1.dta.dta", key(id) replace

	import delimited "raw/County and City Databooks/data/2000/cc00_tab_B2.csv", clear
    //import delimited "../external/raw_databooks/2000/cc00_tab_B2.csv", clear
    rename b2geo01 id
	rename b2geo09 areaname_2000
	rename b2pop05 white_pop_2000
	rename b2pop06 white_pop_pct_2000
	rename b2pop07 black_pop_2000
	rename b2pop08 black_pop_pct_2000
	tostring id, replace
	replace id = "0000" if id == "0"
	replace id = "0" + id if length(id) == 4

	keep id areaname_2000 white_pop_2000 white_pop_pct_2000 black_pop_2000 black_pop_pct_2000
    save_data "temp/cleaned_2000_cc00_tab_B2.dta", key(id) replace

	import delimited "raw/County and City Databooks/data/2000/cc00_tab_B6.csv", clear
    //import delimited "../external/raw_databooks/2000/cc00_tab_B6.csv", clear
	rename b6geo01 id
	rename b6geo09 areaname_2000
	rename b6crm01f serious_crimes_1999_f
	rename b6crm01 serious_crimes_1999
	rename b6crm02f violent_crimes_1999_f
	rename b6crm02 violent_crimes_1999
	rename b6crm03f property_crimes_1999_f
	rename b6crm03 property_crimes_1999
	rename b6crm04f serious_crimes_1990_f
	rename b6crm04 serious_crimes_1990
	rename b6crm06f crime_rate_1999_f
	rename b6crm06 crime_rate_1999
	tostring id, replace
	replace id = "0000" if id == "0"
	replace id = "0" + id if length(id) == 4
	
	keep id areaname_2000 serious_crimes_1999_f serious_crimes_1999 violent_crimes_1999_f       ///
        violent_crimes_1999 property_crimes_1999_f property_crimes_1999 serious_crimes_1990_f   ///
		serious_crimes_1990 crime_rate_1999_f crime_rate_1999
	save_data "temp/cleaned_2000_cc00_tab_B6.dta", key(id) replace

	import excel "raw/County and City Databooks/data/2007/cc07_tabB4.xls", cellrange(A9:M3208) clear
    //import excel "../external/raw_databooks/2007/cc07_tabB4.xls", cellrange(A9:M3208) clear
    rename A areaname_2000
	rename D pop_25_om_2000
	rename E pop_25_om_hs_pct_2000
	rename F pop_25_om_coll_pct_2000

	keep areaname_2000 pop_25_om_2000 pop_25_om_hs_pct_2000 pop_25_om_coll_pct_2000
    
    replace areaname_2000 = subinstr(areaname_2000," ","",.)
    forval x = 1/9{
        replace areaname_2000 = subinstr(areaname_2000,"`x'","",.)
    }
    drop if areaname_2000 == "IndependentCity" | areaname_2000 == "IndependentCities"

    foreach var of varlist pop_25_om_2000 pop_25_om_hs_pct_2000 pop_25_om_coll_pct_2000{
        replace `var' = "." if `var' == "(X)" | `var' == "(NA)"
    }

	/*
	Drop two counties that have been incorporated with others before 2000
	(as reported from footnotes in cc07_tabB4.excel)
	*/
    drop if areaname_2000 == "SouthBoston,VA" | areaname_2000 == "YellowstoneNationalPark,MT"

    * For these variables we do not have id for areaname. We drop double observations.
    sort areaname_2000 pop_25_om_2000 
    drop if areaname_2000 == areaname_2000[_n-1]
    save_data "temp/cleaned_2000_cc07_tabB4.dta",key(areaname_2000) replace

	import excel "raw/County and City Databooks/data/2007/cc07_tabB1.xls", cellrange(B10:C3209) clear
	//import excel "../external/raw_databooks/2007/cc07_tabB1.xls", cellrange(B10:C3209) clear
	rename B id
	rename C areaname_2000
    replace areaname_2000 = subinstr(areaname_2000," ","",.)
    forval x = 1/9{
        replace areaname_2000 = subinstr(areaname_2000,"`x'","",.)
    }
    drop if areaname_2000 == "IndependentCity" | areaname_2000 == "IndependentCities"
    drop if areaname_2000 == "SouthBoston,VA" | areaname_2000 == "YellowstoneNationalPark,MT"
	sort areaname_2000 id
	drop if areaname_2000 == areaname_2000[_n-1]
	save_data "temp/cleaned_2000_cc07_tabB1.dta",key(id areaname_2000) replace

	/*
	Before merging all dta for 2000 we need to merge by areaname the 2 datasets
	from 2007 (referred to 2000 data) in order to associate an id to counties
	*/
	merge 1:1 areaname_2000 using "temp/cleaned_2000_cc07_tabB4.dta", assert(3) nogen keep(3)
	
	*Now merge with all other dta for 2000
    foreach x in cleaned_2000_cc00_tab_B1.dta cleaned_2000_cc00_tab_B2 cleaned_2000_cc00_tab_B6{
		merge 1:1 id using "temp/`x'.dta", assert(1 2 3) nogen keep(3)
    }

    * Destring variables
    foreach var of varlist land_area_2000 pop_25_om_2000 pop_25_om_hs_pct_2000 pop_25_om_coll_pct_2000                           ///
	        tot_pop_2000 hispanic_pop_2000 hispanic_pop_pct_2000 white_pop_2000 white_pop_pct_2000 black_pop_2000                ///
		    black_pop_pct_2000 serious_crimes_1999 violent_crimes_1999 property_crimes_1999 serious_crimes_1990 crime_rate_1999{
        replace `var' = subinstr(`var'," ","",.)
        replace `var' = "" if inlist(`var', "(NA)", "(X)", "(\8)", "(\9)")
        destring `var', replace
    }

    gen fipstate = substr(id,1,2)
	gen fipscnty = substr(id,3,3)
    gen density_pop_2000 = tot_pop_2000 / land_area_2000

	label var areaname_2000 "AREA NAME 2000"
	label var land_area_2000 "LAND AREA 2000"
	label var density_pop_2000 "LAND AREA, 2000 (SQUARE MILES)"
    label var tot_pop_2000 "POPULATION, 2000 (APRIL 1)"
    label var hispanic_pop_2000 "HISPANIC OR LATINO POPULATION, 2000: NUMBER"
	label var white_pop_2000 "POPULATION, ONE RACE, WHITE, 2000: NUMBER"
    label var black_pop_2000 "POPULATION, ONE RACE, BLACK OR AFRICAN AMERICAN, 2000: NUMBER"
	label var serious_crimes_1999 "NUMBER OF SERIOUS CRIMES KNOWN TO POLICE, 1999: TOTAL"
    label var serious_crimes_1999_f "FLAG FOR NUMBER OF SERIOUS CRIMES KNOWN TO POLICE, 1999: TOTAL"
    label var violent_crimes_1999 "NUMBER OF SERIOUS CRIMES KNOWN TO POLICE, 1999: VIOLENT"
	label var violent_crimes_1999_f "FLAG FOR NUMBER OF SERIOUS CRIMES KNOWN TO POLICE, 1999: VIOLENT"
    label var property_crimes_1999 "NUMBER OF SERIOUS CRIMES KNOWN TO POLICE, 1999: PROPERTY"
	label var property_crimes_1999_f "FLAG FOR NUMBER OF SERIOUS CRIMES KNOWN TO POLICE, 1999: PROPERTY"
    label var serious_crimes_1990 "NUMBER OF SERIOUS CRIMES KNOWN TO POLICE: 1990"
	label var serious_crimes_1990_f "FLAG FOR NUMBER OF SERIOUS CRIMES KNOWN TO POLICE: 1990"
    label var crime_rate_1999 "CRIME RATE (FBI): 1999"
	label var crime_rate_1999_f "FLAG FOR CRIME RATE (FBI): 1999"
    label var pop_25_om_2000 "PERSONS 25 YEARS AND OVER 2000"
	
    gen pop_25_om_hs_2000 = pop_25_om_hs_pct_2000 * pop_25_om_2000 / 100
    replace pop_25_om_hs_2000 = round(pop_25_om_hs_2000)
    label var pop_25_om_hs_2000 "PERSONS 25 YEARS OR MORE /W HI SCHL OM 2000"
	
    gen pop_25_om_coll_2000 = pop_25_om_coll_pct_2000 * pop_25_om_2000 / 100
    replace pop_25_om_coll_2000 = round(pop_25_om_coll_2000)
    label var pop_25_om_coll_2000 "PERSONS 25 YEARS OR MORE /W COLL OM 2000"
	
    drop id hispanic_pop_pct_2000 white_pop_pct_2000 black_pop_pct_2000 serious_crimes_1990 serious_crimes_1990_f   ///
	    violent_crimes_1999 violent_crimes_1999_f property_crimes_1999 property_crimes_1999_f pop_25_om_hs_pct_2000     ///
        pop_25_om_coll_pct_2000
	
    save_data "temp/cleaned_2000.dta", key(fipstate fipscnty) replace
end

program merge_files
    use "temp/cleaned_1947_1977.dta", clear
    foreach x in cleaned_1980 cleaned_1990 cleaned_2000{
        merge 1:1 fipstate fipscnty using "temp/`x'.dta", assert(1 2 3) nogen keep(3)
    }

	drop *_f
    drop if fipscnty == "000"
	* Inconsistent data across 2000 and 2007 (for instance perc of 25_om_hs and 25_om_coll or share_black)
	drop if areaname_2000 == "Richmond,VA" | areaname_2000 == "Suffolk,VA"
	
    save_data "output_large/derived/county_panel.dta", key(fipstate fipscnty) replace
end
 
* EXECUTE
main
