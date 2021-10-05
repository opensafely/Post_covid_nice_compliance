from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

#acute, og_covid and pc_codes
acute_covid_codes = codelist_from_csv("codelists/user-rob_w-acute-covid-codes.csv", system = "snomed", column = "code")
ongoing_covid_code = codelist_from_csv("codelists/user-rob_w-ongoing-effects-of-covid.csv", system = "snomed", column = "code")
pc_code = codelist_from_csv("codelists/user-rob_w-post-covid-codelist.csv", system = "snomed", column = "code")
ongoing_and_pc_diag_codes = combine_codelists(ongoing_covid_code, pc_code)

# #diagnostics
diagnostic_bloods = codelist_from_csv("codelists/user-rob_w-diagnostic-blood-test.csv", system = "snomed", column = "code")
diagnostic_bp_test = codelist_from_csv("codelists/user-rob_w-lying-and-standing-blood-pressure-readings.csv", system = "snomed", column = "code")
diagnostic_sit_stand = codelist_from_csv("codelists/user-rob_w-assessment-using-1-min-sit-to-stand-test.csv", system = "snomed", column = "code")
diagnostic_chest_xray = codelist_from_csv("codelists/user-rob_w-chest-x-ray-code.csv", system = "snomed", column = "code")
 
# #referrals
referral_paed = codelist_from_csv("codelists/user-rob_w-referral-to-paediatric-service.csv", system = "snomed", column = "code")
referral_respiratory = codelist_from_csv("codelists/user-rob_w-referral-to-respiratory-medicine-service.csv", system = "snomed", column = "code")
referral_cardiology = codelist_from_csv("codelists/user-rob_w-referral-to-cardiology-service.csv", system = "snomed", column = "code")
referral_pain = codelist_from_csv("codelists/user-rob_w-referral-to-pain-management-service.csv", system = "snomed", column = "code")
referral_gastro = codelist_from_csv("codelists/user-rob_w-referral-to-gastroenterology-service.csv", system = "snomed", column = "code")
referral_endocrinology = codelist_from_csv("codelists/user-rob_w-referral-to-endocrinology-service.csv", system = "snomed", column = "code")
referral_neurology = codelist_from_csv("codelists/user-rob_w-referral-to-neurology.csv", system = "snomed", column = "code")
referral_rheumatology = codelist_from_csv("codelists/user-rob_w-referral-to-rheumatology-service.csv", system = "snomed", column = "code")
referral_dermatology = codelist_from_csv("codelists/user-rob_w-referral-to-dermatology-service.csv", system = "snomed", column = "code")
referral_ent = codelist_from_csv("codelists/user-rob_w-referral-to-ent-service.csv", system = "snomed", column = "code")
referral_inf_diseases = codelist_from_csv("codelists/user-rob_w-referral-to-infectious-diseases-service.csv", system = "snomed", column = "code")
referral_pc_clinic = codelist_from_csv("codelists/user-rob_w-referral-to-post-covid-clinic.csv", system = "snomed", column = "code")
referral_social_worker = codelist_from_csv("codelists/user-rob_w-referral-to-social-worker.csv", system = "snomed", column = "code")

#pysch variables
risk_of_self_harm = codelist_from_csv("codelists/user-rob_w-risk-of-self-harm.csv", system = "snomed", column = "code")
referral_psych = codelist_from_csv("codelists/user-rob_w-referral-to-iapt-programme-mental-health-team.csv", system = "snomed", column = "code")
referral_psych_iapt = codelist_from_csv("codelists/user-rob_w-referral-to-liason-psychiatry-service-iapt-programme.csv", system = "snomed", column = "code")
mild_anxiety_or_depression = codelist_from_csv("codelists/user-rob_w-mild-anxiety-or-depression.csv", system = "snomed", column = "code")
 
#management
self_care_codes = codelist_from_csv("codelists/user-rob_w-self-management-referral-codes-for-covid-recovery.csv", system = "snomed", column = "code")
primary_care_codes = codelist_from_csv("codelists/user-rob_w-primary-care-management-code.csv", system = "snomed", column = "code")
community_care_codes = codelist_from_csv("codelists/user-rob_w-management-in-community-care-code.csv", system = "snomed", column = "code")

#advice
advice_given = codelist_from_csv("codelists/user-rob_w-advice-about-covid-19-codes.csv", system = "snomed", column = "code")
interpreter_needed = codelist_from_csv("codelists/user-rob_w-interpreter-needed.csv", system = "snomed", column = "code")
interpreter_booked = codelist_from_csv("codelists/user-rob_w-interpreter-booked-or-used.csv", system = "snomed", column = "code")
discussion_about_daily_living = codelist_from_csv("codelists/user-rob_w-discussion-about-daily-living.csv", system = "snomed", column = "code")
