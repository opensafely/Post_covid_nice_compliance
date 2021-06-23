from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

referral_codes = codelist_from_csv("codelists/rob_w-specialist-op-referrals-taken-from-nhse-guidance-on-longpost-covid-68f95f8f.csv", system="snomed", column="term")

ongoing_covid_code = codelist_from_csv("codelists/ongoing_covid_codelist.csv", system = "snomed", column = "term")
pc_code = codelist_from_csv("codelists/post_covid_codelist.csv", system = "snomed", column = "term")

ongoing_and_pc_diag_codes = combine_codelists(ongoing_covid_code, pc_code)

hypoxaemia_codes = codelist_from_csv("codelists/oxygen_saturation.csv", system = "snomed", column = "term")

cardiac_pain_code = codelist_from_csv("codelists/cardiac_pain.csv", system = "snomed", column = "term")