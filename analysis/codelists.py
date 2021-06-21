from cohortextractor import (
    StudyDefinition,
    codelist,
    codelist_from_csv,
    combine_codelists,
    filter_codes_by_category,
    patients,
)

referral_codes = codelist_from_csv("codelists/rob_w-specialist-op-referrals-taken-from-nhse-guidance-on-longpost-covid-68f95f8f.csv", system="snomed", column="term")

pc_diag_codes = codelist_from_csv("codelists/opensafely-nice-managing-the-long-term-effects-of-covid-19-64f1ae69 (1).csv", system="snomed", column="term")