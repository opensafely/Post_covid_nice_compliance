from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

from codelists import *
from health_inequalities_var import health_inequalities

start_date = "2019-02-01"
end_date = "2022-01-01"

study = StudyDefinition(

    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "2021-06-01"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    index_date= "2022-01-01",

    population=patients.satisfying(
        """
        has_acute_covid AND registered AND (sex = 'M' OR sex = 'F') AND (pat_age > 17)
        """, 
        has_acute_covid = patients.with_these_clinical_events(acute_covid_codes, on_or_after = start_date),
        registered = patients.registered_as_of("index_date"),
        pat_age = patients.age_as_of("2019-02-01")
        
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
                                                    return_expectations={"rate": "universal",
                                                    "category": {"ratios": {"E02002559": 0.1,
                                                                            "E02002583": 0.1,
                                                                            "E02002786": 0.1,
                                                                            "E02002810": 0.1,
                                                                            "E02002932": 0.1,
                                                                            "E02003060": 0.1,
                                                                            "E02006784": 0.2,
                                                                            "E02005993": 0.2}
                                                                            }
                                                                            },
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

    # Import common health inequalities variables (defined in another script)
    **health_inequalities
    )
