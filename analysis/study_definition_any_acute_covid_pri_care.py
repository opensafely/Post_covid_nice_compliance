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
end_date = "2021-06-01"

study = StudyDefinition(

    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "2021-06-01"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    population=patients.satisfying(
        """
        one_practice
        AND
        (age_majority >= 18)
        AND
        has_acute_covid
        """, 
        has_acute_covid = patients.with_these_clinical_events(acute_covid_codes, on_or_after = start_date),
        one_practice = patients.registered_with_one_practice_between(start_date, end_date),
        age_majority = patients.age_as_of("acute_diag_dat")
    ),
    
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

    advice_given = patients.with_these_clinical_events(advice_given,
                                                                find_first_match_in_period = True,
                                                                on_or_after = "acute_diag_dat",
                                                                date_format = "YYYY-MM-DD",
                                                                returning = "date",
                                                                return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                            "rate": "uniform"}),

    interpreter_needed = patients.with_these_clinical_events(interpreter_needed,   #checked
                                                                find_first_match_in_period = True,
                                                                on_or_after = "acute_diag_dat",
                                                                date_format = "YYYY-MM-DD",
                                                                returning = "date",
                                                                return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                            "rate": "uniform"}),                                                 
    
    interpreter_booked = patients.with_these_clinical_events(interpreter_booked,   #checked
                                                                find_first_match_in_period = True,
                                                                on_or_after = "acute_diag_dat",
                                                                date_format = "YYYY-MM-DD",
                                                                returning = "date",
                                                                return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                            "rate": "uniform"}),      

    )
