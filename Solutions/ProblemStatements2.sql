use healthcare;
-- Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an idea that the 
-- pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest and the number of 
-- prescriptions should exceed 100. Assist the company to identify those cities where the pharmacy can be set up.

select a.city , (count(temp.pharmacyID)/ sum(temp.cnt_p) ) as ratio
from (select p.pharmacyID, p.addressID , count(p2.prescriptionID) as cnt_p from 
pharmacy p  join prescription p2 on p.pharmacyID = p2.pharmacyID 
group by p.pharmacyID) temp 
join address a on a.addressID = temp.addressID group by a.city having sum(temp.cnt_p) > 100 order by ratio limit 3;

-- select p.pharmacyID  ,count(p.prescriptionID) as cnt from prescription p group by p.pharmacyID ;


-- Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more efficiently
-- For each city in their state, they need to identify the disease for which the maximum number of patients
-- have gone for treatment. Assist the state for this purpose.
with temp as
(select a.city , count(t.diseaseID) as cnt_d,t.diseaseID from 
treatment t join prescription p on t.treatmentID = p.treatmentID 
join person p3 on p3.personID = t.patientID
join pharmacy p2 on p2.pharmacyID = p.pharmacyID 
join address a on a.addressID = p3.addressID where a.state = 'Al' group by a.city,t.diseaseID)
select city, cnt_d, diseaseID from 
( select city, cnt_d, diseaseID, rank() over(partition by city order by cnt_d desc) as r from temp) 
temp2 where temp2.r = 1;

-- Problem Statement 3: The healthcare department needs a report about insurance plans. The report is required
-- to include the insurance plan, which was claimed the most and least for each disease.
--  Assist to create such a report.



with cte as (select t.diseaseID , i.planName , count(i.planName) as cnt from 
treatment t right join claim c using(claimId)
join insuranceplan i using(UIN)
group by i.planName,t.diseaseID),
cte2 as ( select diseaseID , min(cnt) as minn, max(cnt) as maxx from cte group by diseaseID)
select cte.* from cte2 join cte using(diseaseId) where cnt in (cte2.minn, cte2.maxx) order by diseaseID, 
cnt desc ;


-- Problem Statement 4: The Healthcare department wants to know which disease is most likely to infect
-- multiple people in the same household. For each disease find the number of households that has more than 
-- one patient with the same disease. 
-- Note: 2 people are considered to be in the same household if they have the same address. 

select d.diseaseID , d.diseaseName, count(a.addressID) as cnt from treatment t join person p on 
t.patientID = p.personID 
join address a using(addressID) 
join disease d using(diseaseID)
group by t.diseaseID having cnt > 1;

SELECT d.diseaseName, COUNT(p.personID) AS cnt
FROM treatment t
JOIN person p ON t.patientID = p.personID 
JOIN address a USING (addressID) 
JOIN disease d USING (diseaseID)
GROUP BY a.address1,d.diseasename
HAVING cnt > 1;



-- Problem Statement 5:  An Insurance company wants a state wise report of the treatments to claim ratio 
-- between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.

-- Division by zero when sum is 0, so used cte, case when to avoid zero division
with cte as (
select a.state ,count(t.treatmentID) as total 
, count(t.claimID) as claimed
-- ,sum(if(t.claimID is not null,1,0)) as claimed
from 
treatment t join person p on t.patientID = p.personID 
join address a using(addressID) 
join disease d using(diseaseID)
where date between '2021-04-01' and '2022-03-31'
group by a.state) 
select state,case 
	when claimed != 0 then total / claimed
end  as Ratio from cte;



-- We have nullif funtion to return null. this avoids division when the sum is 0
select a.state ,
-- count(t.treatmentID) / nullif(sum(if(t.claimID is not null,1,0)),0) as Ratio
count(t.treatmentID) / count( t.claimID  ) as Ratio
from 
treatment t join person p on t.patientID = p.personID 
join address a using(addressID) 
join disease d using(diseaseID)
where t.date between '2021-04-01' and '2022-03-31'
group by a.state ;

