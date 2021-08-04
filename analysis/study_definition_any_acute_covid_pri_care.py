from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

from codelists import *

study = StudyDefinition(
    
    #set index date as first march (right censor)
    index_date = "2021-06-01",

    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "index_date"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    acute_diag_dat = patients.with_these_clinical_events(acute_covid_codes,
                                                     find_first_match_in_period = True,
                                                     returning = "date",
                                                     date_format = "YYYY-MM-DD",
                                                     return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                            "rate": "uniform"}, 
                                                    ),

    population=patients.satisfying("has_acute_covid AND one_practice AND age_majority > 17", 
                                    has_acute_covid = patients.with_these_clinical_events(acute_covid_codes, returning = "binary_flag"),
                                    one_practice = patients.registered_with_one_practice_between("2019-02-01", "2021-06-01"),
                                    age_majority = patients.age_as_of("acute_diag_dat")
    ),
    
    age_at_diag=patients.age_as_of(
        "acute_diag_dat",
        return_expectations={"int": {"distribution": "population_ages"}}
    ),

    #commented out until prac_id works
    prac_id = patients.registered_practice_as_of("acute_diag_dat",
                                                returning="pseudo_id",
                                                # options for return_expectations
                                                #return_expectations={"category": {"ratios": {c: 1/1000 for c in range(1,1001)}}}
                                                #return_expectations={"category": {"ratios": {"prac_1": 0.3, "prac_2": 0.3, "prac_3": 0.4}}}
                                                return_expectations={"rate" : "universal", "int" : {"distribution":"normal", "mean":1500, "stddev":50}}),

    prac_msoa = patients.registered_practice_as_of("acute_diag_dat",
                                                    returning='msoa',
                                                    return_expectations={"rate":"universal", "category": {"ratios" : {'msoa1':0.5, 'msoa2':0.5}}}
    ),

    Rec_1_1_advice_given = patients.with_these_clinical_events(advice_given_1_1,
                                                                find_first_match_in_period = True,
                                                                on_or_after = "acute_diag_dat",
                                                                returning = "date",
                                                                return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                            "rate": "uniform"}),

    Rec_1_8_interpreter_needed = patients.with_these_clinical_events(interpreter_needed,
                                                                find_first_match_in_period = True,
                                                                on_or_after = "acute_diag_dat",
                                                                returning = "date",
                                                                return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                            "rate": "uniform"}),                                                 
    
    Rec_1_9_interpreter_booked = patients.with_these_clinical_events(interpreter_booked,
                                                                find_first_match_in_period = True,
                                                                on_or_after = "acute_diag_dat",
                                                                returning = "date",
                                                                return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                            "rate": "uniform"}),      

    )