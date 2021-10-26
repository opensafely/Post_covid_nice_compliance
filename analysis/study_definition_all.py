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
        "incidence": 0.95
    },

    index_date = "2020-11-01",

    #keep to Alex's date (2020-11-01) to sense check outputs for now 
    population = patients.registered_as_of("index_date"),
    
    #demographic info
    age = patients.age_as_of("index_date", return_expectations = {"rate" : "uniform", "int" : {"distribution" : "population_ages"}}),
    sex = patients.sex(return_expectations = {"rate" : "universal", "category" : {"ratios": {"M":0.49, "F":0.51}}}),
    region = patients.registered_practice_as_of("index_date",
        returning="nuts1_region_name",
        return_expectations = {"rate": "universal",
                                "category": {"ratios": {"North East": 0.1,
                                                        "North West": 0.1,
                                                        "Yorkshire and The Humber": 0.1,
                                                        "East Midlands": 0.1,
                                                        "West Midlands": 0.1,
                                                        "East": 0.1,
                                                        "London": 0.2,
                                                        "South East": 0.1,
                                                        "South West": 0.1}}}),

    imd = patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
            "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
            "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
            "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
            "5": """index_of_multiple_deprivation >= 32844*4/5 AND index_of_multiple_deprivation < 32844""",
        },
        index_of_multiple_deprivation=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0": 0.05,
                    "1": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5": 0.19,
                }
            },
        },
    ),
    
    ethnicity = patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        on_or_before="index_date",
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),
    
    #diagnosis variables
    diag_acute_covid = patients.with_these_clinical_events(acute_covid_codes,
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
    
    #referral variables
    referral_pc_clinic = patients.with_these_clinical_events(referral_pc_clinic, 
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    referral_self_care = patients.with_these_clinical_events(self_care_codes, 
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
    referral_primary_care_codes = patients.with_these_clinical_events(primary_care_codes, 
                                                            find_first_match_in_period = True,
                                                            #between = ["pc_or_oc_diag_dat", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    )
)
