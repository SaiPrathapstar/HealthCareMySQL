-- Problem Statement 1: 
-- Brian, the healthcare department, has requested for a report that shows for each state how many people 
-- underwent treatment for the disease “Autism”.  He expects the report to show the data for each state as 
-- well as each gender and for each state and gender combination. 
-- Prepare a report for Brian for his requirement.

use healthcare;

select coalesce(a.state, 'Total') as state
,coalesce(p.gender, "Total State") as Gender
-- , sum(if(p.gender = 'Male',1,0)) as male
-- , sum( if(p.gender = 'female',1,0) ) as female
,count(p.gender) as All_
from 
disease d join treatment t on t.diseaseID = d.diseaseId
join person p on t.patientID = p.personID
join address a using(addressID)
where d.diseaseName = 'Autism'
group by a.state
,p.gender
with rollup;

-- Problem Statement 2:  
-- Insurance companies want to evaluate the performance of different insurance plans they offer. 
-- Generate a report that shows each insurance plan, the company that issues the plan, and the number of
--  treatments the plan was claimed for. The report would be more relevant if the data compares the
--  performance for different years(2020, 2021 and 2022) and if the report also includes the total number
--  of claims in the different years, as well as the total number of claims for each plan in all 3 years
--  combined.


select coalesce(companyname,"ALL")as companyname,coalesce(planname,"Total") as planname,
sum(if(year(t.date) = 2020, 1, 0)) as claims_2020
,sum(if(year(t.date) = 2021, 1, 0)) as claims_2021
,sum(if(year(t.date) = 2022, 1, 0)) as claims_20222
from treatment t join claim c using(claimid)
join insuranceplan using(uin) 
join insurancecompany using(companyid)
group by companyname,planname with rollup;

-- Problem Statement 3:  
-- Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a
-- particular region. Assist Sarah by creating a report which shows each state the number of the most and
--  least treated diseases by the patients of that state in the year 2022. It would be helpful for Sarah 
--  if the aggregation for the different combinations is found as well. Assist Sarah to create this report. 

with cte as (
	select state,diseaseName,count(d.diseaseName) as treatments,
		rank() over(partition by a.state order by count(*) desc) asce,
		rank() over(partition by a.state order by count(*)) descn from disease d 
	join treatment t using (diseaseID)
	join patient p using (patientID)
	join person p2 on p2.personID = p.patientID 
	join address a using (addressID) where year(date) = 2022
	group by a.state, d.diseaseName
)
select state,t1.diseaseName as Most_effected_disease,t1.treatments as treatments, 
t2.diseaseName as Least_effected_disease,t2.treatments as treatments
from (select * from cte where  asce = 1) t1 join
 (select * from cte where descn = 1) t2 using(state)  ;


-- Problem Statement 4: 
-- Jackson has requested a detailed pharmacy report that shows each pharmacy name, and how many 
-- prescriptions they have prescribed for each disease in the year 2022, along with this Jackson also 
-- needs to view how many prescriptions were prescribed by each pharmacy, and the total number 
-- prescriptions were prescribed for each disease. Assist Jackson to create this report. 

select coalesce(p.pharmacyName,"All") as pharmace_name
,coalesce(d.diseaseName, 'Total') as Disease_Name
,count(prescriptionID) as prescriptions
from pharmacy p 
join prescription p2 using (pharmacyID)
join treatment t using (treatmentID)
join disease d using (diseaseID) where year(date) = 2022
group by p.pharmacyName, d.diseaseName with rollup ;

-- Problem Statement 5:  
-- Praveen has requested for a report that finds for every disease how many males and females
--  underwent treatment for each in the year 2022. It would be helpful for Praveen if the aggregation for
--  the different combinations is found as well. Assist Praveen to create this report. 

select coalesce(diseaseName, 'All') as Disease_Name
,coalesce(gender,"Total") as Gender
,count(*) as treatements
from disease  join treatment t using (diseaseID)
join patient p using (patientID)
join person p2 on p2.personID = p.patientID
where year(date) = 2022
group by diseaseName,gender with rollup ;
