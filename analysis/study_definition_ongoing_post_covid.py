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
        "date": {"earliest": "1900-01-01", "latest": "index_date"},
        "rate": "uniform",
        "incidence": 0.95,
    },

    #set index date as first of march (right censor)
    index_date = "2021-03-01",

    pc_or_oc_diag_dat = patients.with_these_clinical_events(ongoing_and_pc_diag_codes,
                                                     find_first_match_in_period = True,
                                                     returning = "date",
                                                     date_format = "YYYY-MM-DD",
                                                     return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                             "rate": "uniform"}, 
                                                    ),

    population=patients.satisfying("has_pc AND one_practice AND has_gp_appt_post_diag", 
                                    has_pc = patients.with_these_clinical_events(ongoing_and_pc_diag_codes, on_or_before = "2020-06-01"),
                                    one_practice = patients.registered_with_one_practice_between("2019-02-01", "2020-06-01"),
                                    #age_majority = patients.age_as_of("pc_or_oc_diag_dat"),
                                    has_gp_appt_post_diag = patients.with_gp_consultations(on_or_after = "pc_or_oc_diag_dat", returning = "binary_flag")
    ),
    
    age_at_diag=patients.age_as_of(
        "pc_or_oc_diag_dat",
        return_expectations={"int": {"distribution": "population_ages"}}
    ),

    prac_id = patients.registered_practice_as_of("pc_or_oc_diag_dat",
                                                returning="pseudo_id",
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
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_post_covid = patients.with_these_clinical_events(pc_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #diagnostic dates
    diagnostic_bloods = patients.with_these_clinical_events(diagnostic_bloods, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diagnostic_sit_stand = patients.with_these_clinical_events(diagnostic_sit_stand, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #ARE THESE NUMERIC VALUES/CODE/CATEGORY? may need to revisit these
    diagnostic_bp_test = patients.with_these_clinical_events(diagnostic_bp_test, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "numeric_value",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"float": {"distribution":"normal", "mean":80, "stddev":20}, "incidence" : 0.7}
                                                                                    ),

    diagnostic_chest_xray = patients.with_these_clinical_events(diagnostic_chest_xray, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),


    #referrals
    referral_paed = patients.with_these_clinical_events(referral_paed,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_psych = patients.with_these_clinical_events(referral_psych, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_psych_iapt = patients.with_these_clinical_events(referral_psych_iapt,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),


    referral_respiratory = patients.with_these_clinical_events(referral_respiratory,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_cardiology = patients.with_these_clinical_events(referral_cardiology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_pain = patients.with_these_clinical_events(referral_pain,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_gastro = patients.with_these_clinical_events(referral_gastro,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_endocrinology = patients.with_these_clinical_events(referral_endocrinology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_neurology = patients.with_these_clinical_events(referral_neurology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_rheumatology = patients.with_these_clinical_events(referral_rheumatology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_dermatology = patients.with_these_clinical_events(referral_dermatology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_ent = patients.with_these_clinical_events(referral_ent,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_inf_diseases = patients.with_these_clinical_events(referral_inf_diseases,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_pc_clinic = patients.with_these_clinical_events(referral_pc_clinic, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #risk of self harm/anxiety/depression
    risk_of_self_harm = patients.with_these_clinical_events(referral_pc_clinic, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    mild_anxiety_or_depression = patients.with_these_clinical_events(mild_anxiety_or_depression,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #psych referral variables
    psych_referral = patients.with_these_clinical_events(referral_psych, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    psych_referral_iapt = patients.with_these_clinical_events(referral_psych_iapt, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #self-care, community or primary care management
    discussion_about_daily_living = patients.with_these_clinical_events(discussion_about_daily_living, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    self_care_advise_or_support = patients.with_these_clinical_events(self_care_codes, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    primary_care_managment = patients.with_these_clinical_events(primary_care_codes, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    ),

    community_care = patients.with_these_clinical_events(community_care_codes, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_dat", "index_date"],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":"2019-02-01", "latest":"2021-06-01"},
                                                                                    "rate": "uniform"}
                                                                                    )    

)
