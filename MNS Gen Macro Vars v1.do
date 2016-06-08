************************************************************************************************************************************************
* Author: Sanjay Misra
* Date: May 30, 2016
* Principal Investigators: Maggiori, Neiman, Schreger
************************************************************************************************************************************************

clear
set more off
set matsize 11000

capture cd MNS
capture log close


* Define storage paths
global inputs Input_Files
global outputs Output_Files
global temp Temp_Files
* global code Code

************************************************************
**** READ-IN RAW DATA FROM IMF AND ISO CONCORDANCES
************************************************************

* Build country-level dataset with IMF and ISO Country Codes
insheet using $inputs/Concordances/IMFCountryCodes.csv, clear comma names
rename imf_code country_code
rename iso_code iso_country_code
drop if missing(country_name)
destring country_code, replace
save $outputs/IMF_Country_Codes, replace

* Build currency-level dataset
insheet using $inputs/Concordances/Country_and_Currency_Codes.csv, clear comma names
preserve
keep iso_currency currency_name
drop if missing(iso_currency)
duplicates drop
rename iso_currency iso_currency_code
save $outputs/ISO_Currency_Codes, replace
restore

* Keep match of countries and currencies (likely will do country-year version of this soon)
drop if missing(iso_currency)
keep iso_country iso_currency
rename iso_country country
rename iso_currency currency
save $temp/CurrentCountryCurrencies, replace

use $temp/CurrentCountryCurrencies, clear
rename country iso_country_code
merge 1:1 iso_country_code using $outputs/IMF_Country_Codes
drop if missing
save $temp/Merged_Country_Codes

************************************************************
**** UPLOAD IFS DATA
************************************************************
insheet using $inputs/IFS_data_2016.05.30.csv, clear names
save $temp/IFS_data

* Store IMF country codes
keep countryname countrycode
duplicates drop
save $temp/IMF_Country_Codes, replace

* Merge ISO and IMF country codes together
rename countrycode country_code
merge 1:1 country_code using $outputs/IMF_Country_Codes
tab _merge

