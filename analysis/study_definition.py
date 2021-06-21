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
        "incidence": 0.5,
    },
    population=patients.satisfying("has_pc AND one_practice AND age_majority > 17", 
                                    has_pc = patients.with_these_clinical_events(pc_diag_codes, on_or_before = "2021-01-01"),
                                    one_practice = patients.registered_with_one_practice_between("2019-02-01", "2021-06-01"),
                                    age_majority = patients.age_as_of("2019-09-01")
    ),
    
    age=patients.age_as_of(
        "2019-09-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    prac_msoa = registered_practice_as_of(date, returning=None, return_expectations={"rate":"uniform", "categories"= ['1234', '5678']})


)
