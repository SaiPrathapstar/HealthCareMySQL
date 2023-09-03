-- Problem Statement 1: 
-- Insurance companies want to know if a disease is claimed higher or lower than average.  
-- Write a stored procedure that returns “claimed higher than average” or “claimed lower than average” 
-- when the diseaseID is passed to it. 
-- Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed 
-- disease is higher than the average return “claimed higher than average” otherwise “claimed lower than average”.

use healthcare;

drop procedure getUsage;

delimiter //
create procedure getUsage(in did varchar(30), out op varchar(20))
begin 
	declare avg decimal(10,6);
	declare col decimal(10,6);

	select count(claimID)/count(treatmentID) into avg from treatment t;
	select count(claimID)/ count(treatmentID) into col from treatment where diseaseID = did;
	if col > avg then set op = 'less';
	else set op = 'large';
	end if;
end //
delimiter ;

call getUsage(25, @o);

select @o;

-- Problem Statement 2:  
-- Joseph from Healthcare department has requested for an application which helps him get genderwise 
-- report for any disease. 
-- Write a stored procedure when passed a disease_id returns 4 columns,
-- disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
-- Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often 
-- for the disease, if the number is same for both the genders, the value should be ‘same’.

drop procedure getGenderWise;


delimiter //
create procedure getGenderWise(in did int)
begin 
	with cte as (
	select d.diseaseName , 
	sum( if(p.gender = 'male',1,0) ) as males,
	sum( if(p.gender= 'female',1,0) ) as females
	from disease d join treatment t using(diseaseID) join person p on p.personID = t.patientID where 
	diseaseID = did group by d.diseaseName)
	select *, case 
		when males > females then 'males'
		when males < females then 'females'
		else 'same'
	end as more_treated_gender
	from cte;
end //
delimiter ;

call getGenderWise(25);


-- Problem Statement 3:  
-- The insurance companies want a report on the claims of different insurance plans. 
-- Write a query that finds the top 3 most and top 3 least claimed insurance plans.
-- The query is expected to return the insurance plan name, the insurance company name which has that plan,
-- and whether the plan is the most claimed or least claimed. 

with cte as (
select i.planName , i2.companyName
, rank() over (partition by i2.companyName  order by count(c.claimID) desc) as r_d
, rank() over (partition by i2.companyName  order by count(c.claimID)) as r_a
from claim c join insuranceplan i using(UIN)
join insurancecompany i2 using(companyID)
group by i.planName, i2.companyName
order by  i2.companyName, i.planName)
select * from cte where r_a <= 3 or r_d <= 3;

-- Problem Statement 4:

select personname,gender,dob,
case when dob>='2005-01-01' and gender='male' then 'Youngmale'
when dob>='2005-01-01'and gender ='female' then 'youngfemale'
when dob>'1985-01-01' and dob<'2005-01-01'and gender='male' then 'Adultmale'
when dob>'1985-01-01' and dob<'2005-01-01'and gender='female' then 'Adultfemale'
when p2.dob>'1970-01-01' and p2.dob<'1985-01-01'and p1.gender='male' then 'midagemale'
when p2.dob>'1970-01-01' and p2.dob<'1985-01-01'and p1.gender='female' then 'midagefemale'
when p2.dob<'1970-01-01' and p1.gender='male' then 'Eldermale'
when p2.dob<'1970-01-01' and p1.gender='female' then 'Elderfemale'
end as category from person p1 join patient p2 on p1.personid=p2.patientid;

-- Problem Statement 5:  
-- Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most 
-- affordable medicines only. 
-- Assist anna by creating a report of all the medicines which are pricey and affordable, listing the 
-- companyName, productName, description, maxPrice, and the price category of each. Sort the list in 
-- descending order of the maxPrice.
-- Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the 
-- price is under 5. Write a query to find 

select companyName, productName, description, maxPrice
,case when maxPrice > 1000 then 'Pricey'
when maxPrice < 5 then 'Affordable'
end as Price_category
from medicine 
where maxPrice < 5 or maxPrice > 1000
order by maxPrice desc;




