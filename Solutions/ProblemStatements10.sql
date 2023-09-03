-- Problem Statement 1:
-- The healthcare department has requested a system to analyze the performance of insurance companies and their
-- plan.
-- For this purpose, create a stored procedure that returns the performance of different insurance plans of an
-- insurance company. When passed the insurance company ID the procedure should generate and return all the
-- insurance plan names the provided company issues, the number of treatments the plan was claimed for, and the
-- name of the disease the plan was claimed for the most. The plans which are claimed more are expected to appear
-- above the plans that are claimed less.
drop procedure getInsurancePlanDetails;
delimiter //
create procedure getInsurancePlanDetails(in c int)
begin 	
    select a.planName, b.total_claimed , a.diseaseName as MostClaimedDisease from 
(select i.planName ,d.diseaseName  ,
row_number () over (partition by i.planName order by count(d.diseaseName) desc ) as r
from insuranceplan i join claim c using(UIN) 
join treatment t using(claimID)
join disease d using(diseaseID) where i.companyID  = c 
group by i.planName,d.diseaseName) 
a
join
(select i.planName , count(c.claimID) as total_claimed from claim c join insuranceplan i using(UIN)
where i.companyID = c
group by i.planName)
b 
using(planName) where a.r = 1;
end //
delimiter ;

call getInsurancePlanDetails(1933);


-- Problem Statement 2:
-- It was reported by some unverified sources that some pharmacies are more popular for certain diseases. 
-- The healthcare department wants to check the validity of this report.
-- Create a stored procedure that takes a disease name as a parameter and would return the top 3 pharmacies 
-- the patients are preferring for the treatment of that disease in 2021 as well as for 2022.
-- Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
-- Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and draw a 
-- conclusion from the result.

drop procedure getTopPharmacies;

delimiter //
create procedure getTopPharmacies(in d varchar(100) ,in y int,in g int) 
-- d: diseaseName, y: Start_year, g : gap(How many years forward)
begin
	with cte as (
	select p.pharmacyID , count(t.treatmentID) as cnt
	from prescription p join treatment t using(treatmentID)
	join disease d using(diseaseID)
	where year(date) between y and y+g and d.diseaseName = d
	group by p.pharmacyID
	order by p.pharmacyID)
	, cte2 as(
	select *, row_number () over(order by cnt desc) as r from cte)
	select * from cte2 where r <= 3;
end //
delimiter ;


call getTopPharmacies('Asthma', 2021,1); -- for 2021, 2022

call getTopPharmacies('Asthma', 2021,0); -- for 2021 only
-- 7016, 9659, 5527
call getTopPharmacies('Asthma', 2022,0); -- for 2022 only
-- 8760, 2593, 1925
-- no common pharmacies

call getTopPharmacies('Psoriasis', 2022,0); -- for 2022 only
-- 1584, 2060, 1354
call getTopPharmacies('Psoriasis', 2021,0); -- for 2021 only
-- 4663, 3253, 4326
-- no common pharmacies



-- Problem Statement 3:
-- Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an 
-- insurance company or not.
-- Write a stored procedure that finds the num_patients, num_insurance_companies, and insurance_patient_ratio,
-- the stored procedure should also find the avg_insurance_patient_ratio and if the insurance_patient_ratio of
-- the given state is less than the avg_insurance_patient_ratio then it Recommendation section can have the
-- value “Recommended” otherwise the value can be “Not Recommended”.

drop procedure recommend;

delimiter //
create procedure recommend(in state varchar(20))
begin 
	declare avg_a decimal(16,6);
	declare avg_c decimal(16,6);
	declare num_pat int;
	declare num_companies int;
	select count(p.patientID) / count(distinct i.companyID) into avg_a from insurancecompany i , patient p ;


	select count(distinct patientID) into num_pat from 
	patient p join person p2 on p.patientID = p2.personID 
	join address a using(addressID) where a.state = state;

	select count(distinct i.companyID) into num_companies from address a join insurancecompany i 
	using(addressID) where a.state = state;
    
    set avg_c = num_pat/num_companies;
	select  avg_a, avg_c, num_pat, num_companies,
		case 
		when avg_a < avg_c then 'Not recommended'
		else 'Recommended'
		end as 'Recommendation'	;
end //
delimiter ;


call recommend('DC');


-- Problem Statement 4:
-- Currently, the data from every state is not in the database, The management has decided to add the data
-- from other states and cities as well. It is felt by the management that it would be helpful if the date
-- and time were to be stored whenever new city or state data is inserted.
-- The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, that 
-- has four attributes. placeID, placeName, placeType, and timeAdded


create table if not exists PlacesAdded(
 placeID int auto_increment primary key ,
 placeName varchar(50) unique,
 placeType varchar(10) not null,
 timeAdded datetime not null);



delimiter //
 create trigger for_PlacesAdded
 after insert on address for each row
 begin
	insert into PlacesAdded(placeName,placeType,timeAdded) values(new.city,'city',now());
    insert into PlacesAdded(placeName,placeType,timeAdded) values(new.state,'state',now());
 end;
 //

-- Some pharmacies suspect there is some discrepancy in their inventory management. The quantity in the
--  ‘Keep’ is updated regularly and there is no record of it. They have requested to create a system that
--  keeps track of all the transactions whenever the quantity of the inventory is updated.

create table if not exists Keep_Log(
id int auto_increment primary key,
medicineID int not null,
quantity int not null);


delimiter //
create trigger update_log
after update on keep for each row
begin
if old.quantity <> new.quantity then
	insert into Keep_Log(medicineID,quantity) values(new.medicineID,new.quantity-old.quantity);
end if;
end //
delimiter ;
