using FHIR version '3.0.0'

/*
Description
The percentage of women 21-64 years of age who were screened for cervical
		cancer using either of the following criteria:
	* Women 21-64 years of age who had cervical cytology performed every 3 years.
	* Women 30-64 years of age who had cervical cytology/human papillomavirus
		(HPV) co-testing performed every 5 years.
*/

valueset "Absence of Cervix Value Set": '2.16.840.1.113883.3.464.1004.1123.17' // CPT
valueset "Cervical Cytology Value Set": '2.16.840.1.113883.3.464.1004.1208' // Grouping
valueset "HPV Tests Value Set": '2.16.840.1.113883.3.464.1004.1265.26' // CPT

parameter "Measurement Period" default Interval[Today() - 1 year, Today()]

context Patient

define "First Predecessor Year":
	Interval[start of "Measurement Period" - 1 year, start of "Measurement Period")

define "Second Predecessor Year":
	Interval[start of "Measurement Period" - 2 years, start of "Measurement Period" - 1 year)

define "Third Predecessor Quarter":
	Interval[start of "Measurement Period" - 2 years - 3 months, start of "Measurement Period" - 2 years)

define "Lookback Interval Two More Years":
	Interval[start of "Measurement Period" - 2 years, end of "Measurement Period")

define "Lookback Interval Four More Years":
	Interval[start of "Measurement Period" - 4 years, end of "Measurement Period")

define "Does Patient Qualify?":
	"Is Female"
		and "Is Age 24 to 64 at End"
		and if "Is Hysterectomy" is null
		        then true
		    else not "Is Hysterectomy"

define "Is Female":
	Patient.gender.value = 'female'

define "Is Age 24 to 64 at End":
	AgeInYearsAt(end of "Measurement Period") between 24 and 64

define "Needs Cervical Cytology Test":
    if "Is Cervical Cytology Test In Last 3 Years" is null
        then true
    else not "Is Cervical Cytology Test In Last 3 Years"

define "Is Cervical Cytology Test In Last 3 Years":
	exists(
		"Dates of Cervical Cytology Tests" WhenCC
			where WhenCC included in day of "Lookback Interval Two More Years"
	)

define "Is Cervical Cytology Plus HPV Test In Last 5 Years":
	exists(
		"Dates of Cervical Cytology Tests" WhenCC
			with "Dates of HPV Tests" WhenHPV
				such that (((difference in days between start of WhenCC and start of WhenHPV) <= 4)
					and AgeInYearsAt(start of WhenCC) >= 30
					and AgeInYearsAt(start of WhenHPV) >= 30
					and WhenCC included in "Lookback Interval Four More Years"
					and WhenHPV included in "Lookback Interval Four More Years")
	)

define "Dates of Cervical Cytology Tests":
	([Procedure: "Cervical Cytology Value Set"] Proc
		where Proc.status.value = 'completed'
		return PeriodToIntervalOfDT(Proc.performed))
	union
	([DiagnosticReport: "Cervical Cytology Value Set"] DiagRep
		where DiagRep.status.value in { 'preliminary', 'final', 'amended', 'corrected', 'appended' }
		return PeriodToIntervalOfDT(DiagRep.effective))
	union
	([Observation: "Cervical Cytology Value Set"] Obs
		where Obs.status.value in { 'final', 'amended' }
		return DateTimeToInterval(Obs.effective))

define "Dates of HPV Tests":
	([Procedure: "HPV Tests Value Set"] Proc
		where Proc.status.value = 'completed'
		return PeriodToIntervalOfDT(Proc.performed))
	union
	([DiagnosticReport: "HPV Tests Value Set"] DiagRep
		where DiagRep.status.value in { 'preliminary', 'final', 'amended', 'corrected', 'appended' }
		return PeriodToIntervalOfDT(DiagRep.effective))
	union
	([Observation: "HPV Tests Value Set"] Obs
		where Obs.status.value in { 'final', 'amended' }
		return DateTimeToInterval(Obs.effective))

define "Is Hysterectomy":
	exists(
		[Procedure: "Absence of Cervix Value Set"] Proc
			where Proc.status.value = 'completed'
				and end of case when Proc.performed is DateTime then Interval[Proc.performed.value, Proc.performed.value] else Interval[Proc.performed."start".value, Proc.performed."end".value] end same day or before end of "Measurement Period"
	)

define CervicalCytologySummary:
    'A Cervical Cytology procedure for the patient is recommended'

define CervicalCytologyDetail:
    'The patient has not had a Cervical Cytology procedure in the last 3 years'

define CervicalCytologyIndicator:
    'warning'

/*
Utility Functions
*/

define function DateTimeToInterval(date FHIR.dateTime):
	Interval[date.value, date.value]

define function PeriodToIntervalOfDT(value FHIR.Period):
	Interval[value."start".value, value."end".value]

define function CodingToCode(coding FHIR.Coding):
	System.Code {
		code: coding.code.value,
		system: coding.system.value,
		version: coding.version.value,
		display: coding.display.value
	}
	// From FHIRHelpers


