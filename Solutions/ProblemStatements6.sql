use healthcare;
-- Problem Statement 1: 
-- The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed
-- in the year 2022.
-- Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity
-- of medicine prescribed in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy
-- in 2022, and the percentage of hospital-exclusive medicine to the total medicine prescribed in 2022.
-- Order the result in descending order of the percentage found. 

select * from medicine m ;

with cte as(
select p.pharmacyID ,p2.pharmacyName  , sum( if(m.hospitalExclusive = 'S' , c.quantity , 0) ) as Exclusive
, sum(c.quantity) as Total
from 
prescription p join contain c using(prescriptionID) 
join medicine m using(medicineID) 
join treatment t using(treatmentID)
join pharmacy p2 using(pharmacyID)
where year (t.`date`) = 2022
group by p.pharmacyID)
select *,(exclusive/total)*100 as percentage from cte order by percentage desc;


-- Problem Statement 2:  
-- Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment.
-- She has requested a state-wise report of the percentage of treatments that took place without claiming
-- insurance. Assist Sarah by creating a report as per her requirement.

select a.state , (sum( if(t.claimID is null, 1, 0) ) / count(t.treatmentID)) * 100 as percentage_not_claimed
from treatment t join person p on p.personID = t.patientID 
join address a using(addressID) group by a.state ;



-- Problem Statement 3:  
-- Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular
-- region. Assist Sarah by creating a report which shows for each state, the number of the most and least
-- treated diseases by the patients of that state in the year 2022. 

with cte as (
select a.state ,t.diseaseID  , count(t.diseaseID) as cnt
, rank() over (partition by a.state order by count(t.diseaseID) desc) as r
from 
address a join person p using(addressID) 
join treatment t on t.patientID = p.personID 
where year(t.`date`) = 2022
group by a.state,t.diseaseID)
, cte2 as (select state , min(r) as minn, max(r) as maxx from cte group by state)
-- select * from cte2;
select cte.* from cte join cte2 on cte.state = cte2.state where cte.r in (cte2.minn, cte2.maxx );

-- Problem Statement 4: 
-- Manish, from the healthcare department, wants to know how many registered people are registered as patients
-- as well, in each city. Generate a report that shows each city that has 10 or more registered people belonging
-- to it and the number of patients from that city as well as the percentage of the patient with respect to the
-- registered people.

with cte as (
select a.city , count(p2.personID) as persons, count(p.patientID) patients from 
patient p right join person p2 on p.patientID = p2.personID
join address a using(addressID)
group by a.city having count(p2.personID) > 10)
select *, (patients/persons) * 100 as percent_of_patients from cte;

-- Problem Statement 5:  
-- It is suspected by healthcare research department that the substance “ranitidina” might be causing some 
-- side effects. Find the top 3 companies using the substance in their medicine so that they can be informed 
-- about it.


select companyName , count(medicineID) cnt from medicine 
where substanceName like 'ranitidina' group by companyName order by cnt desc limit 3;
















select concat(companyName,'---' , productName) from medicine m ;
select concat_ws("---", companyName , productName ,description  ) from medicine m ; 
select ascii('a');
select char_length(companyName) from medicine m ; 
select length(companyName) from medicine m ;
select insert('Sai Kalakuntla', 4,0,' Prathap');
select insert('Sai Kalakuntla', 4,1,'Prathap ');
select insert('Sai Kalakuntla', 5,0,'Prathap ');

select locate('sai', 'Kalakuntla Sai Prathap Guptha');
select locate('Sai', 'Kalakuntla Sai Prathap Guptha', 10);

