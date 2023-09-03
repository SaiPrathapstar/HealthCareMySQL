use healthcare;

show tables;

select * from address a ;
-- Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows 
-- how the number of treatments each age category of patients has gone through in the year 2022. 
-- The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), 
-- and Seniors (65 years and over).
-- Assist Jimmy in generating the report. 
select count(t.patientID) , p.age
from treatment t join (select patientID , case 
	when 2023 - year(dob) <= 14 then "Children"
	when 2023 - year(dob) <= 24 then "Youth"
	when 2023 - year(dob) <= 64 then "Adults"
	else "Seniors"
end as age from patient) p 
on t.patientID = p.patientID
where year(t.date) = 2022
group by age ;


-- Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people 
-- of which gender more often.
-- Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. 
-- Sort the data in a way that is helpful for Jimmy.

select d.diseaseName , 
(sum(case when p.gender = 'male' then 1 else 0 end)/ sum(case when p.gender = 'female' then 1 else 0 end)) as male_female_ratio from 
disease d join treatment t on t.diseaseId = d.diseaseID 
join person p on p.personId = t.patientID 
group by d.diseaseID;


-- Problem Statement 3: Jacob, from insurance management, has noticed that insurance claims are not made 
-- for all the treatments. He also wants to figure out if the gender of the patient has any impact on the 
-- insurance claim. Assist Jacob in this situation by generating a report that finds for each gender the 
-- number of treatments, number of claims, and treatment-to-claim ratio. And notice if there is a significant 
-- difference between the treatment-to-claim ratio of male and female patients.


select gender,
	sum(case when t.claimID  is not null then 1 else 0 end)/ count(gender) as male_female_ratio 
from treatment t left join person p on t.patientID = p.personID group by gender;


--  Problem Statement 4: The Healthcare department wants a report about the inventory of pharmacies. 
--  Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory, 
--  the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
-- Note: discount field in keep signifies the percentage of discount on the maximum price.

-- For each medicine in each pharamacy
select k.pharmacyID , k.medicineID ,m.maxPrice , m.maxPrice * (1 - k.discount/100) as discounted_price , k.quantity 
from keep k join medicine m on k.medicineID  = m.medicineID ;

-- For each pharmacy as a whole(combining all the medicines)
select k.pharmacyID ,sum(m.maxPrice) ,sum(m.maxPrice * (1 - k.discount/100)) as discounted_price, sum(k.quantity)
from keep k join medicine m on k.medicineID  = m.medicineID group by k.pharmacyID;


-- Problem Statement 5:  The healthcare department suspects that some pharmacies prescribe more medicines 
-- than others in a single prescription, for them, generate a report that finds for each pharmacy the maximum, 
-- minimum and average number of medicines prescribed in their prescriptions. 

-- select p.pharmacyID, c.prescriptionID  ,count(c.medicineID) from 
-- prescription p join contain c on c.prescriptionID = p.prescriptionID group by c.prescriptionID order by p.pharmacyID ;


with cte1 as (select pharmacyname,count(medicineid) as num_of_medicine from contain join
prescription using(prescriptionID)
join pharmacy using(pharmacyid)
group by prescriptionid)
select pharmacyname,max(num_of_medicine) as maximum, min(num_of_medicine) as minimum, 
avg(num_of_medicine) as average
from cte1 group by pharmacyname;









