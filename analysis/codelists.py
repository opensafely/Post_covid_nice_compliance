from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

#all_referral_codes
referral_codes = codelist_from_csv("codelists/rob_w-specialist-op-referrals-taken-from-nhse-guidance-on-longpost-covid-68f95f8f.csv", system="snomed", column="term")

#og_covid and pc_codes
ongoing_covid_code = codelist_from_csv("codelists/ongoing_covid_codelist.csv", system = "snomed", column = "term")
pc_code = codelist_from_csv("codelists/post_covid_codelist.csv", system = "snomed", column = "term")
ongoing_and_pc_diag_codes = combine_codelists(ongoing_covid_code, pc_code)

#red flag diags
rf_hypoxaemia_codes = codelist_from_csv("codelists/oxygen_saturation.csv", system = "snomed", column = "term")
rf_respiratory_disease_code = codelist_from_csv("codelists/respiratory_disease.csv", system = "snomed", column = "term")
rf_cardiac_pain_code = codelist_from_csv("codelists/cardiac_pain.csv", system = "snomed", column = "term")

#diagnostics
diagnostic_bloods = codelist_from_csv("codelists/blood_test.csv", system = "snomed", column = "term")
diagnostic_bp_stand = codelist_from_csv("codelists/standing_bp.csv", system = "snomed", column = "term")
diagnostic_bp_sit = codelist_from_csv("codelists/lying_bp.csv", system = "snomed", column = "term")
diagnostic_sit_stand = codelist_from_csv("codelists/sit_stand_test.csv", system = "snomed", column = "term")
diagnostic_chest_xray = codelist_from_csv("codelists/chest_x_ray.csv", system = "snomed", column = "term")

#referrals
referral_paed = codelist_from_csv("codelists/paed_referral.csv", system = "snomed", column = "term")
referral_mental_health = codelist_from_csv("codelists/psych_referral.csv", system = "snomed", column = "term")
referral_respiratory = codelist_from_csv("codelists/resp_med_referral.csv", system = "snomed", column = "term")
referral_cardiology = codelist_from_csv("codelists/cardiac_referral.csv", system = "snomed", column = "term")
referral_pain = codelist_from_csv("codelists/pain_referral.csv", system = "snomed", column = "term")
referral_gastro = codelist_from_csv("codelists/gastro_referral.csv", system = "snomed", column = "term")
referral_endocrinology = codelist_from_csv("codelists/endocrine_referral.csv", system = "snomed", column = "term")
referral_neurology = codelist_from_csv("codelists/neurology_referral.csv", system = "snomed", column = "term")
referral_rheumatology = codelist_from_csv("codelists/rheumatology_referral.csv", system = "snomed", column = "term")
referral_dermatology = codelist_from_csv("codelists/dermatology_referral.csv", system = "snomed", column = "term")
referral_ent = codelist_from_csv("codelists/ENT_referral.csv", system = "snomed", column = "term")
referral_inf_diseases = codelist_from_csv("codelists/inf_diseases_referral.csv", system = "snomed", column = "term")
referral_pc_clinic = codelist_from_csv("codelists/pc_referral.csv", system = "snomed", column = "term")

#management - self-care 
self_care_codes = codelist_from_csv("codelists/self_care.csv", system = "snomed", column = "term")

#management - primary care
primary_care_codes = codelist_from_csv("codelists/primary_care.csv", system = "snomed", column = "term")

#management - community
community_care_codes = codelist_from_csv("codelists/community_care.csv", system = "snomed", column = "term")