-- Problem Statement 1:
-- Patients are complaining that it is often difficult to find some medicines. They move from pharmacy to 
-- pharmacy to get the required medicine. A system is required that finds the pharmacies and their contact 
-- number that have the required medicine in their inventory. So that the patients can contact the pharmacy 
-- and order the required medicine.
-- Create a stored procedure that can fix the issue.

drop procedure searchMedicine;

delimiter //
create procedure searchMedicine(in name varchar(50))
begin 
--     set @pattern = concat('%', name, '%');
	declare pattern varchar(50);
  	set pattern = concat('%', name, '%');

	select p.pharmacyName,p.phone,m.maxPrice  ,k.discount  from 
	medicine m join keep k using(medicineID)
	join pharmacy p using(pharmacyID) 
	where m.productName like pattern;
	end //
delimiter ;

call searchMedicine('REVECTINA');

-- Problem Statement 2:
-- The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription,
-- for all the prescriptions they have prescribed in a particular year. Create a stored function that will
-- return the required value when the pharmacyID and year are passed to it. Test the function with multiple
-- values.


drop function calculateAveragePrescriptionAmount;

delimiter //
create function calculateAveragePrescriptionAmount(pID int, y int)
returns decimal(12,6)
deterministic
begin 
	declare op decimal(12,6);
	with cte as (
	select p.prescriptionID as pid , sum(c.quantity*m.maxPrice) as price from treatment t 
	join prescription p using(treatmentID)
	join contain c using(prescriptionID) 
	join medicine m using(medicineID)
	where year(t.`date`) = y and p.pharmacyID = pID
	group by p.prescriptionID)
	select sum(price)/count(pid) into op from cte;
	return op;
end //
delimiter ;

select calculateAveragePrescriptionAmount(9139,'2021');

drop procedure calculateAveragePrescriptionAmount;

delimiter //
create procedure calculateAveragePrescriptionAmount(in pID int, in y int)
begin 
	with cte as (
	select p.prescriptionID as pid , sum(c.quantity*m.maxPrice) as price from treatment t 
	join prescription p using(treatmentID)
	join contain c using(prescriptionID) 
	join medicine m using(medicineID)
	where year(t.`date`) = y and p.pharmacyID = pID
	group by p.prescriptionID)
	select sum(price)/count(pid) from cte;
end //
delimiter ;

call calculateAveragePrescriptionAmount(7448,2022);

select distinct c.prescriptionID  from contain c ;

select distinct p.prescriptionID  from prescription p join treatment t  where p.pharmacyID = 7448 and year(t.`date`) = 2022;

-- Problem Statement 3:
-- The healthcare department has requested an application that finds out the disease that was spread the 
-- most in a state for a given year. So that they can use the information to compare the historical data 
-- and gain some insight.
-- Create a stored function that returns the name of the disease for which the patients from a particular 
-- state had the most number of treatments for a particular year. Provided the name of the state and year 
-- is passed to the stored function.
use healthcare;

drop function getMostAffectedDisease;

delimiter //
create function getMostAffectedDisease(state varchar(50), y int)
returns varchar(50)
deterministic
begin 
	declare op varchar(50);
	select d.diseaseName into op
	from disease d join treatment t using(diseaseID)
	join person p on p.personID = t.patientID 
	join address a using(addressID)
	where a.state = state and year(t.`date`) = y 
	group by d.diseaseID 
	order by count(d.diseaseID) desc
	limit 1;
    return op;
end //
delimiter ;

select getMostAffectedDisease('OK',2022);


drop procedure getMostAffectedDisease;

delimiter //
create procedure getMostAffectedDisease(in state varchar(50), in y int)
begin 
	select d.diseaseName
	from disease d join treatment t using(diseaseID)
	join person p on p.personID = t.patientID 
	join address a using(addressID)
	where a.state = state and year(t.`date`) = y 
	group by d.diseaseID 
	order by count(d.diseaseID) desc
	limit 1;
end //
delimiter ;

call getMostAffectedDisease('OK', 2022);



-- Problem Statement 4:
-- The representative of the pharma union, Aubrey, has requested a system that she can use to find how many
-- people in a specific city have been treated for a specific disease in a specific year.
-- Create a stored function for this purpose.
delimiter //
create function getNumPatients(city varchar(30), did int, y int )
returns int
deterministic 
begin 
	declare op int;
	select count(t.patientID) into op from treatment t join disease d using(diseaseID)
	join person p on p.personID  = t.patientID 
	join address a using(addressID)
	where year(t.`date` ) = y and d.diseaseID = did and a.city = city;
	return op;
end //
delimiter ;

select getNumPatients('Savannah',25,2021);



delimiter //
create procedure getNumPatients(in city varchar(30), in did int, in y int )
begin
	select count(t.patientID) from treatment t join disease d using(diseaseID)
	join person p on p.personID  = t.patientID 
	join address a using(addressID)
	where year(t.`date` ) = y and d.diseaseID = did and a.city = city;
end //
delimiter ;


call getNumPatients('Savannah',25,2022);


-- Problem Statement 5:
-- The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies.
-- She has requested a system that can be used to find the average balance for claims submitted by a specific
-- insurance company in the year 2022. 
-- Create a stored function that can be used in the requested application. 

drop function getAvgBalance;

delimiter //
create function getAvgBalance(cid int)
returns decimal(12,6)
deterministic
begin
	declare op decimal(12,6);
	select avg(c.balance) into op from 
	claim c join insuranceplan i using(UIN) 
	where i.companyID = cid;
	return op;
end //
delimiter ;

select getAvgBalance(3489);

drop procedure getAvgBalance;

delimiter //
create procedure getAvgBalance(in cid int)
begin 
	select avg(c.balance) from 
	claim c join insuranceplan i using(UIN) 
	where i.companyID = cid;
end //

delimiter ;


call getAvgBalance(3489);



