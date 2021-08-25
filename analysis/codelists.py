from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

#acute, og_covid and pc_codes
acute_covid_codes = codelist_from_csv("codelists/acute_covid.csv", system = "snomed", column = "term")
ongoing_covid_code = codelist_from_csv("codelists/ongoing_covid.csv", system = "snomed", column = "term")
pc_code = codelist_from_csv("codelists/post_covid.csv", system = "snomed", column = "term")
ongoing_and_pc_diag_codes = combine_codelists(ongoing_covid_code, pc_code)

#diagnostics
diagnostic_bloods = codelist_from_csv("codelists/diagnostic_bloods.csv", system = "snomed", column = "term")
diagnostic_bp_test = codelist_from_csv("codelists/diagnostic_bp_test.csv", system = "snomed", column = "term")
diagnostic_sit_stand = codelist_from_csv("codelists/diagnostic_sit_stand_test.csv", system = "snomed", column = "term")
diagnostic_chest_xray = codelist_from_csv("codelists/diagnostic_chest_x_ray.csv", system = "snomed", column = "term")

#referrals
referral_paed = codelist_from_csv("codelists/referral_paed.csv", system = "snomed", column = "term")
referral_respiratory = codelist_from_csv("codelists/referral_resp_med.csv", system = "snomed", column = "term")
referral_cardiology = codelist_from_csv("codelists/referral_cardiac.csv", system = "snomed", column = "term")
referral_pain = codelist_from_csv("codelists/referral_pain.csv", system = "snomed", column = "term")
referral_gastro = codelist_from_csv("codelists/referral_gastro.csv", system = "snomed", column = "term")
referral_endocrinology = codelist_from_csv("codelists/referral_endocrine.csv", system = "snomed", column = "term")
referral_neurology = codelist_from_csv("codelists/referral_neurology.csv", system = "snomed", column = "term")
referral_rheumatology = codelist_from_csv("codelists/referral_rheumatology.csv", system = "snomed", column = "term")
referral_dermatology = codelist_from_csv("codelists/referral_dermatology.csv", system = "snomed", column = "term")
referral_ent = codelist_from_csv("codelists/referral_ENT.csv", system = "snomed", column = "term")
referral_inf_diseases = codelist_from_csv("codelists/referral_inf_diseases.csv", system = "snomed", column = "term")
referral_pc_clinic = codelist_from_csv("codelists/referral_pc_clinic.csv", system = "snomed", column = "term")

#pysch variables
risk_of_self_harm = codelist_from_csv("codelists/risk_of_self_harm.csv", system = "snomed", column = "term")
referral_psych = codelist_from_csv("codelists/referral_psych.csv", system = "snomed", column = "term")
referral_psych_iapt = codelist_from_csv("codelists/referral_psych_iapt.csv", system = "snomed", column = "term")
mild_anxiety_or_depression = codelist_from_csv("codelists/mild_anxiety_or_depression.csv", system = "snomed", column = "term")

#management
self_care_codes = codelist_from_csv("codelists/mgmt_self_care.csv", system = "snomed", column = "term")
primary_care_codes = codelist_from_csv("codelists/mgmt_primary_care.csv", system = "snomed", column = "term")
community_care_codes = codelist_from_csv("codelists/mgmt_community_care.csv", system = "snomed", column = "term")

#advice
advice_given = codelist_from_csv("codelists/advice_given.csv", system = "snomed", column = "term") #check
interpreter_needed = codelist_from_csv("codelists/interpreter_needed.csv", system = "snomed", column = "term")
interpreter_booked = codelist_from_csv("codelists/interpreter_booked.csv", system = "snomed", column = "term")
discussion_about_daily_living = codelist_from_csv("codelists/discussion_about_daily_living.csv", system = "snomed", column = "term")
