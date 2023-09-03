-- Problem Statement 1:  Some complaints have been lodged by patients that they have been prescribed 
-- hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. Joshua, 
-- from the pharmacy management, wants to get a report of which pharmacies have prescribed hospital-exclusive 
-- medicines the most in the years 2021 and 2022. Assist Joshua to generate the report so that the pharmacies 
-- who prescribe hospital-exclusive medicine more often are advised to avoid such practice if possible.   

select * from keep k join keep k2 on k.pharmacyID = k2.pharmacyID ;

desc keep;

SELECT DISTINCT k1.pharmacyID ,k1.medicineID
FROM keep k1
WHERE NOT EXISTS (
    SELECT k2.medicineID 
    FROM keep k2
    WHERE k2.pharmacyID <> k1.pharmacyID
      AND k2.medicineID = k1.medicineID
);

-- Problem Statement 2: Insurance companies want to assess the performance of their insurance plans. 
-- Generate a report that shows each insurance plan, the company that issues the plan, and the number of 
-- treatments the plan was claimed for.

select i.companyID , i.planName ,count(c.claimID) from treatment t join claim c using(claimId) 
join insuranceplan i using(UIN)
group by i.companyID , i.planName ;


-- Problem Statement 3: Insurance companies want to assess the performance of their insurance plans. 
-- Generate a report that shows each insurance company's name with their most and least claimed insurance plans.

with cte as (select i.companyID , i.planName ,count(c.claimID) as cnt from treatment t join claim c using(claimId) 
join insuranceplan i using(UIN)
group by i.companyID , i.planName),
cte2 as (
select companyId, min(cnt) as minn, max(cnt) as maxx from cte group by companyId)
-- select * from cte2;
select cte.companyID, cte.planName, cte.cnt
from cte2 join cte using(companyID) 
where cte.cnt in (cte2.maxx, cte2.minn) order by companyID;

-- Problem Statement 4:  The healthcare department wants a state-wise health report to assess which state 
-- requires more attention in the healthcare sector. Generate a report for them that shows the state name,
-- number of registered people in the state, number of registered patients in the state, and the 
-- people-to-patient ratio. sort the data by people-to-patient ratio. 

with cte as (
select a.state , count(p.patientID) as patients, count(p2.personID) as persons
from patient p right join person p2 on p.patientID = p2.personID 
left join address a using (addressID) group by a.state)
select *, persons/patients from cte;
-- sum( if(p.patientID is not null,1,0) ) as patients



-- Problem Statement 5:  Jhonny, from the finance department of Arizona(AZ), has requested a report that lists 
-- the total quantity of medicine each pharmacy in his state has prescribed that falls under Tax criteria I 
-- for treatments that took place in 2021. Assist Jhonny in generating the report. 

select * from address a where state = 'AZ';

with cte as (
select p2.pharmacyID  , sum(c.quantity), a.state  from 
address a join pharmacy p using(addressID) 
join prescription p2 using(pharmacyID)
join contain c using(prescriptionID)
join medicine m using(medicineID)
join treatment t using(treatmentID)
where a.state like 'AZ' and m.taxCriteria like 'I' and year(t.`date`) = 2021
group by p2.pharmacyID)
select * from cte;



