-- Problem Statement 1: 
-- Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
-- Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
-- and their age, Sort the data in a way that the patients who have undergone more treatments appear on top.

use healthcare;

select t.patientID , p.personName , year (now()) - year(p2.dob) as age ,count(t.patientID) as cnt from
treatment t join patient p2 using(patientID)
join person p on t.patientID = p.personID
group by p.personID  having cnt > 1 order by cnt desc;

-- Problem Statement 2:  
-- Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain disease
-- is more likely to infect a certain gender or not.
-- Help Bharat analyze this by creating a report showing for every disease how many males and females underwent
-- treatment for each in the year 2021. It would also be helpful for Bharat if the male-to-female ratio is also
-- shown.

with cte as (
select t.diseaseID , d.diseaseName ,sum( if(p.gender = 'male',1,0)) as males, sum(if(p.gender = 'female', 1, 0)) as females
from treatment t join person p on t.patientID = p.personID 
join disease d using (diseaseID)
where year(t.`date`) = 2021
group by t.diseaseID)
select *, males/females as ratio from cte;


-- Problem Statement 3:  
-- Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
-- the top 3 cities that had the most number treatment for that disease.
-- Generate a report for Kelly’s requirement.

with cte as (
select a.city , t.diseaseID , count(t.treatmentID) as cnt
, dense_rank() over(partition by t.diseaseID  order by count(t.treatmentID) desc) as r
from treatment t join person p on t.patientID = p.personID 
join address a using(addressID) group by a.city,t.diseaseID)
select * from cte where r in (1,2,3) order by r desc;

-- Problem Statement 4: 
-- Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies 
-- over others or not, For this purpose, she has requested a detailed pharmacy report that shows each pharmacy 
-- name, and how many prescriptions they have prescribed for each disease in 2021 and 2022, She expects the 
-- number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
-- Write a query for Brooke’s requirement.

select p.pharmacyID , t.diseaseID,
sum( if(year(date) = 2021, 1,0 ))  as in_2021,
sum( if(year(date) = 2022, 1,0 )) as in_2022
from prescription p join treatment t using(treatmentID)
where year(date) between 2021 and 2022
group by  t.diseaseID, p.pharmacyID
order by p.pharmacyID , t.diseaseID;


-- Problem Statement 5:  
-- Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance 
-- company is targeting the patients of which state the most. 
-- Write a query for Walde that fulfills the requirement of Walde.
-- Note: We can assume that the insurance company is targeting a region more if the patients of that region 
-- are claiming more insurance of that company.

with cte as (
select i2.companyName, a.state ,count(c.claimID)
, rank() over(partition by i.companyID order by count(c.claimID) desc ) as r
from 
treatment t join person p on p.personID = t.patientID
join address a using(addressID)
join claim c using(claimID)
join insuranceplan i using(uin)
join insurancecompany i2 using(companyID)
group by a.state,i.companyID) 
select * from cte 
where r = 1;
