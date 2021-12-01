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
end_date = "2021-10-01"

study = StudyDefinition(
    
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": end_date},
        "rate": "uniform",
        "incidence": 0.95,
        "int": {"distribution": "poisson", "mean" : 2}, "incidence" : 0.2
    },

    index_date= "2019-02-01",

    pc_or_oc_diag_or_referral_date = patients.with_these_clinical_events(ongoing_and_pc_diag_and_referal_codes,
                                                     find_first_match_in_period = True,
                                                     returning = "date",
                                                     date_format = "YYYY-MM-DD",
                                                     return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                             "rate": "uniform"}, 
                                                    ),

    population = patients.satisfying(
        """
        ongoing_and_pc_diag_and_referal_codes AND registered AND (sex = 'M' OR sex = 'F')
        """,
        ongoing_and_pc_diag_and_referal_codes = patients.with_these_clinical_events(ongoing_and_pc_diag_and_referal_codes, on_or_before = end_date),
        registered = patients.registered_as_of("index_date")),
    
    age_at_diag=patients.age_as_of(
        "pc_or_oc_diag_or_referral_date",
        return_expectations={"int": {"distribution": "population_ages"}}
    ),

    prac_id = patients.registered_practice_as_of("pc_or_oc_diag_or_referral_date",
                                                returning="pseudo_id",
                                                return_expectations={"rate" : "universal", "int" : {"distribution":"normal", "mean":1500, "stddev":50}}),

    prac_msoa = patients.registered_practice_as_of("pc_or_oc_diag_or_referral_date",
                                                    returning='msoa',
                                                    return_expectations={"rate":"universal", "category": {"ratios" : {'msoa1':0.5, 'msoa2':0.5}}}
    ),

    #diagnosis variables
    diag_ongoing_covid = patients.with_these_clinical_events(ongoing_covid_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diag_post_covid = patients.with_these_clinical_events(pc_code,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
    #outpatient usages
    op_count_card = patients.outpatient_appointment_date(returning = "number_of_matches_in_period",
                                                        attended = True,
                                                        with_these_treatment_function_codes = '320',
                                                        between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                        return_expectations = {"int" : {"distribution": "poisson", "mean" : 2}, "incidence" : 0.2}
                                                        ),

    op_count_rheum = patients.outpatient_appointment_date(returning = "number_of_matches_in_period",
                                                        attended = True,
                                                        with_these_treatment_function_codes = '410',
                                                        between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                        return_expectations = {"int" : {"distribution": "poisson", "mean" : 2}, "incidence" : 0.2}
                                                        ),

    op_count_neuro = patients.outpatient_appointment_date(returning = "number_of_matches_in_period",
                                                        attended = True,
                                                        with_these_treatment_function_codes = '400',
                                                        between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                        return_expectations = {"int" : {"distribution": "poisson", "mean" : 2}, "incidence": 0.2}
                                                        ),

    op_count_respiratory = patients.outpatient_appointment_date(returning = "number_of_matches_in_period",
                                                        attended = True,
                                                        with_these_treatment_function_codes = '400',
                                                        between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                        return_expectations = {"int" : {"distribution": "poisson", "mean" : 2}, "incidence": 0.2}
                                                        ),

    op_count_pc = patients.outpatient_appointment_date(returning = "number_of_matches_in_period",
                                                        attended = True,
                                                        with_these_treatment_function_codes = '348',
                                                        between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                        return_expectations = {
                                                            "int" : {"distribution": "poisson", "mean" : 3},
                                                            "incidence": 0.9}
                                                        ),

    #diagnostic dates
    diagnostic_bloods = patients.with_these_clinical_events(diagnostic_bloods, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    diagnostic_sit_stand = patients.with_these_clinical_events(diagnostic_sit_stand, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #ARE THESE NUMERIC VALUES/CODE/CATEGORY? may need to revisit these
    diagnostic_bp_test = patients.with_these_clinical_events(diagnostic_bp_test, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "numeric_value",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"float": {"distribution":"normal", "mean":80, "stddev":20}, "incidence" : 0.7}
                                                                                    ),

    diagnostic_chest_xray = patients.with_these_clinical_events(diagnostic_chest_xray, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),


    #referrals
    referral_paed = patients.with_these_clinical_events(referral_paed,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_psych = patients.with_these_clinical_events(referral_psych, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_psych_iapt = patients.with_these_clinical_events(referral_psych_iapt,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),


    referral_respiratory = patients.with_these_clinical_events(referral_respiratory,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_cardiology = patients.with_these_clinical_events(referral_cardiology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_pain = patients.with_these_clinical_events(referral_pain,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_gastro = patients.with_these_clinical_events(referral_gastro,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_endocrinology = patients.with_these_clinical_events(referral_endocrinology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_neurology = patients.with_these_clinical_events(referral_neurology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_rheumatology = patients.with_these_clinical_events(referral_rheumatology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_dermatology = patients.with_these_clinical_events(referral_dermatology,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_ent = patients.with_these_clinical_events(referral_ent,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_inf_diseases = patients.with_these_clinical_events(referral_inf_diseases,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    referral_pc_clinic = patients.with_these_clinical_events(referral_pc_clinic, 
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    referral_pc_clinic_counts = patients.with_these_clinical_events(referral_pc_clinic, 
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "number_of_matches_in_period",
                                                            return_expectations = {"int": {"distribution": "poisson", "mean":2}, "incidence":0.75},
                                                                                    ),

    referral_social_worker = patients.with_these_clinical_events(referral_social_worker, 
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #risk of self harm/anxiety/depression
    risk_of_self_harm = patients.with_these_clinical_events(risk_of_self_harm,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    mild_anxiety_or_depression = patients.with_these_clinical_events(mild_anxiety_or_depression,
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #psych referral variables
    psych_referral = patients.with_these_clinical_events(referral_psych, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),
                                                                                    
    psych_referral_iapt = patients.with_these_clinical_events(referral_psych_iapt, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    #self-care, community or primary care management
    discussion_about_daily_living = patients.with_these_clinical_events(discussion_about_daily_living, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    self_care_advise_or_support = patients.with_these_clinical_events(self_care_codes, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    primary_care_managment = patients.with_these_clinical_events(primary_care_codes, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    community_care = patients.with_these_clinical_events(community_care_codes, #check
                                                            find_first_match_in_period = True,
                                                            between = ["pc_or_oc_diag_or_referral_date", end_date],
                                                            returning = "date",
                                                            date_format = "YYYY-MM-DD",
                                                            return_expectations = {"date": {"earliest":start_date, "latest":end_date},
                                                                                    "rate": "uniform"}
                                                                                    ),

    # Import common health inequalities variables (defined in another script)
    **health_inequalities
)
