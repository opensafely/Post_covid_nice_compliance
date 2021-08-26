from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

#acute, og_covid and pc_codes
acute_covid_codes = codelist_from_csv("codelists/user-rob_w-acute-covid-codes.csv", system = "snomed", column = "term")
ongoing_covid_code = codelist_from_csv("codelists/user-rob_w-ongoing-effects-of-covid.csv", system = "snomed", column = "term")
pc_code = codelist_from_csv("codelists/user-rob_w-post-covid-codelist.csv", system = "snomed", column = "term")
ongoing_and_pc_diag_codes = combine_codelists(ongoing_covid_code, pc_code)

# #diagnostics
diagnostic_bloods = codelist_from_csv("codelists/user-rob_w_diagnostic-blood-test.csv", system = "snomed", column = "term")
diagnostic_bp_test = codelist_from_csv("codelists/user-rob_w_-lying-and-standing-blood-pressure-readings.csv", system = "snomed", column = "term")
diagnostic_sit_stand = codelist_from_csv("codelists/user-rob_w-assessment-using-1-min-sit-to-stand-text.csv", system = "snomed", column = "term")
diagnostic_chest_xray = codelist_from_csv("codelists/user-rob_w-chest-x-ray-code.csv", system = "snomed", column = "term")
 
# #referrals
# referral_paed = codelist_from_csv("codelists/referral_paed.csv", system = "snomed", column = "term")
# referral_respiratory = codelist_from_csv("codelists/referral_resp_med.csv", system = "snomed", column = "term")
# referral_cardiology = codelist_from_csv("codelists/referral_cardiac.csv", system = "snomed", column = "term")
# referral_pain = codelist_from_csv("codelists/referral_pain.csv", system = "snomed", column = "term")
# referral_gastro = codelist_from_csv("codelists/referral_gastro.csv", system = "snomed", column = "term")
# referral_endocrinology = codelist_from_csv("codelists/referral_endocrine.csv", system = "snomed", column = "term")
# referral_neurology = codelist_from_csv("codelists/referral_neurology.csv", system = "snomed", column = "term")
# referral_rheumatology = codelist_from_csv("codelists/referral_rheumatology.csv", system = "snomed", column = "term")
# referral_dermatology = codelist_from_csv("codelists/referral_dermatology.csv", system = "snomed", column = "term")
# referral_ent = codelist_from_csv("codelists/referral_ENT.csv", system = "snomed", column = "term")
# referral_inf_diseases = codelist_from_csv("codelists/referral_inf_diseases.csv", system = "snomed", column = "term")
# referral_pc_clinic = codelist_from_csv("codelists/referral_pc_clinic.csv", system = "snomed", column = "term")
 
#pysch variables
risk_of_self_harm = codelist_from_csv("codelists/user-rob_w-risk_of_self_harm.csv", system = "snomed", column = "term")
referral_psych = codelist_from_csv("codelists/user-rob_w-referral-to-iapt-programme-mental-health-team.csv", system = "snomed", column = "term")
referral_psych_iapt = codelist_from_csv("codelists/user-rob_w-referral-to-liason-psychiatry-service-iapt-programme.csv", system = "snomed", column = "term")
mild_anxiety_or_depression = codelist_from_csv("codelists/user-rob_w-mild_anxiety-or-depression.csv", system = "snomed", column = "term")
 
#management
self_care_codes = codelist_from_csv("codelists/user-rob_w-self-management-referral-codes-for-covid-recovery.csv", system = "snomed", column = "term")
primary_care_codes = codelist_from_csv("codelists/user-rob_w-primary-care-management-code.csv", system = "snomed", column = "term")
community_care_codes = codelist_from_csv("codelists/user-rob_w-management-in-community-care-code.csv", system = "snomed", column = "term")

#advice
advice_given = codelist_from_csv("codelists/user-rob_w-advice-about-covid-19-codes.csv", system = "snomed", column = "term")
interpreter_needed = codelist_from_csv("codelists/user-rob_w-interpreter_needed.csv", system = "snomed", column = "term")
interpreter_booked = codelist_from_csv("codelists/user-rob_w-interpreter-booked-or-used.csv", system = "snomed", column = "term")
discussion_about_daily_living = codelist_from_csv("codelists/user-rob_w-discussion-about-daily-living.csv", system = "snomed", column = "term")
