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
    index_date = "2021-03-01",

    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "index_date"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    acute_diag_dat = patients.with_these_clinical_events(acute_covid_codes,
                                                     find_first_match_in_period = True,
                                                     returning = "date",
                                                     date_format = "YYYY-MM-DD",
                                                    #  return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                    #                         "rate": "uniform"}, 
                                                    ),

    positive_test_dat = patients.with_test_result_in_sgss(pathogen="SARS-CoV-2",
                                                         test_result='postitive',
                                                         restrict_to_earliest_specimen_date=True,
                                                         returning='date',
                                                         date_format="YYYY-MM-DD",
                                                         return_expectations={"date:" {"earliest":"2019-02-01", "latest":"2021-03-01"}}
                                                         ), 

    population=patients.satisfying("(tested_positive_covid OR hospitalised_with_covid OR other_covid) AND one_practice AND age_majority > 17 AND attends_GP_at_least_4_weeks_after", 
                                    tested_positive_covid = patients.with_test_result_in_sgss(pathogen="NoSARS-CoV-2", test_result='postitive', restrict_to_earliest_specimen_date=True, returning='binary_flag') 
                                    hospitalised_with_covid = patients.admitted_to_hospital(returning='binary_flag', find_first_match_in_period=True, with_these_diagnoses=None, with_discharge_destination=None) 
                                    has_acute_covid_ = patients.with_these_clinical_events(acute_diag_dat, on_or_before = "2021-01-01"),
                                    one_practice = patients.registered_with_one_practice_between("2019-02-01", "2021-06-01"),
                                    age_majority = patients.age_as_of("positive_test_dat")
    ),
    
    age_at_diag=patients.age_as_of(
        "acute_diag_dat",
        return_expectations={"int": {"distribution": "population_ages"}}
    ),

    prac_id = patients.registered_practice_as_of("pc_or_oc_diag_dat",
                                                returning="pseudo_id",
                                                # options for return_expectations
                                                #return_expectations={"category": {"ratios": {c: 1/1000 for c in range(1,1001)}}}
                                                #return_expectations={"category": {"ratios": {"prac_1": 0.3, "prac_2": 0.3, "prac_3": 0.4}}}
                                                return_expectations={"rate" : "universal", "int" : {"distribution":"normal", "mean":1500, "stddev":50}}),

    #commented out until prac_id works
    prac_msoa = patients.registered_practice_as_of("pc_or_oc_diag_dat",
                                                    returning='msoa',
                                                    return_expectations={"rate":"universal", "category": {"ratios" : {'msoa1':0.5, 'msoa2':0.5}}}
    ),

    #diagnosis variables
    diag_ongoing_covid = patients.with_these_clinical_events(ongoing_covid_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_post_covid = patients.with_these_clinical_events(pc_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_hypoxaemia = patients.with_these_clinical_events(rf_hypoxaemia_codes,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_cardiac_pain = patients.with_these_clinical_events(rf_cardiac_pain_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_resp_disease = patients.with_these_clinical_events(rf_respiratory_disease_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #diagnostic dates
    diagnostic_bloods = patients.with_these_clinical_events(diagnostic_bloods,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diagnostic_sit_stand = patients.with_these_clinical_events(diagnostic_sit_stand,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diagnostic_bp_sit = patients.with_these_clinical_events(diagnostic_bp_sit,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diagnostic_bp_stand = patients.with_these_clinical_events(diagnostic_bp_stand,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diagnostic_chest_xray = patients.with_these_clinical_events(diagnostic_chest_xray,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_paed = patients.with_these_clinical_events(referral_paed,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_mental_health = patients.with_these_clinical_events(referral_mental_health,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_respiratory = patients.with_these_clinical_events(referral_respiratory,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_cardiology = patients.with_these_clinical_events(referral_cardiology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_pain = patients.with_these_clinical_events(referral_pain,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_gastro = patients.with_these_clinical_events(referral_gastro,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_endocrinology = patients.with_these_clinical_events(referral_endocrinology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_neurology = patients.with_these_clinical_events(referral_neurology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_rheumatology = patients.with_these_clinical_events(referral_rheumatology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_dermatology = patients.with_these_clinical_events(referral_dermatology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_ent = patients.with_these_clinical_events(referral_ent,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_inf_diseases = patients.with_these_clinical_events(referral_inf_diseases,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_pc_clinic = patients.with_these_clinical_events(referral_pc_clinic,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #self-care, community or primary care management
    self_care_advise_or_support = patients.with_these_clinical_events(self_care_codes,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    primary_care_managment = patients.with_these_clinical_events(primary_care_codes,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    community_care = patients.with_these_clinical_events(community_care_codes,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-03-01"},
                                                                                    "rate": "uniform"}
                                                                                    )    

)