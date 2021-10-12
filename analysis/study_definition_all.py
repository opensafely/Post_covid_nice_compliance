from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

from codelists import *

start_date = "2019-02-01"
end_date = "2021-10-01"

study = StudyDefinition(

    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "2021-06-01"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    #keep to Alex's date (2020-11-01) to sense check outputs for now 
    population=patients.registered_as_of("2020-11-01"),
    
    acute_diag_dat = patients.with_these_clinical_events(acute_covid_codes,
                                                     find_first_match_in_period = True,
                                                     returning = "date",
                                                     date_format = "YYYY-MM-DD",
                                                     return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                            "rate": "uniform"}, 
                                                    ),

    age_at_diag=patients.age_as_of(
        "acute_diag_dat",
        return_expectations={"int": {"distribution": "population_ages"}}
    ),

    prac_id = patients.registered_practice_as_of("acute_diag_dat",
                                                returning="pseudo_id",
                                                return_expectations={"rate" : "universal", "int" : {"distribution":"normal", "mean":1500, "stddev":50}}),

    prac_msoa = patients.registered_practice_as_of("acute_diag_dat",
                                                    returning='msoa',
                                                    return_expectations={"rate":"universal", "category": {"ratios" : {'msoa1':0.5, 'msoa2':0.5}}}
    ),

    #diagnosis variables
    diag_ongoing_covid = patients.with_these_clinical_events(ongoing_covid_code,
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_post_covid = patients.with_these_clinical_events(pc_code,
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    diag_any_lc_diag = patients.with_these_clinical_events(ongoing_and_pc_diag_codes,
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),                                                                                
                                                                                    
    #referral variables
    referral_pc_clinic = patients.with_these_clinical_events(referral_pc_clinic, 
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
)
