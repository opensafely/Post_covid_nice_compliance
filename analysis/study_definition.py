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
    
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    pc_diag_date=patients.with_these_clinical_events(pc_diag_codes,
                                                     find_first_match_in_period = True,
                                                     returning = "date",
                                                     date_format = "YYYY-MM-DD",
                                                     return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                            "rate": "uniform"}, 
                                                    ),

    population=patients.satisfying("has_pc AND one_practice AND age_majority > 17", 
                                    has_pc = patients.with_these_clinical_events(pc_diag_codes, on_or_before = "2021-01-01"),
                                    one_practice = patients.registered_with_one_practice_between("2019-02-01", "2021-06-01"),
                                    age_majority = patients.age_as_of("pc_diag_date")
    ),
    
    age_at_diag=patients.age_as_of(
        "2021-01-01",
        return_expectations={"int": {"distribution": "population_ages"}}
    ),

    prac_id = patients.registered_practice_as_of("pc_diag_date",
                                                returning="pseudo_id",
                                                # options for return_expectations
                                                return_expectations={"category": {"ratios": {c: 1/1000 for c in range(1,1001)}}}
                                                #return_expectations={"category": {"ratios": {"prac_1": 0.3, "prac_2": 0.3, "prac_3": 0.4}}}
                                                #return_expectations={"rate" : "universal", "int" : {"distribution" : "normal", "mean": 1500, "stddev": 50}}
    )

    #commented out until prac_id works
    # prac_msoa = patients.registered_practice_as_of("pc_diag_date",
    #                                         returning='msoa',
    #                                         return_expectations={"rate":"universal",
    #                                         #  "category": {
    #                                         #                       "ratios" : {
    #                                         #                           'msoa1' : 0.5,
    #                                         #                           'ms0a2' : 0.5,}
    #                                         #                   },
    #                                     #},
    #                                     )#,

    # #diag_og_covid = patients.with_these_clinical_events()

)
