-- 1
SELECT medicineID,companyName,productName,description,substanceName,
CASE productType WHEN 1 THEN 'Generic'
WHEN 2 THEN 'Patent'
WHEN 3 THEN 'Reference'
WHEN 4 THEN 'Similar'
WHEN 5 THEN 'New'
WHEN 6 THEN 'Specific'
WHEN 7 THEN 'Biological'
WHEN 8 THEN 'Dinamized'
ELSE 'Unknown'
END AS productTypeInWords,
productType,
taxCriteria,
hospitalExclusive,
governmentDiscount,
taxImunity,
maxPrice
FROM Medicine
WHERE
(productType IN (1, 2, 3) AND taxCriteria = 'I')
or (productType IN (4, 5, 6) AND taxCriteria = 'II');


-- 2
select t.prescriptionid,t.totalquantity ,case when t.totalquantity<20 then  'low quantity'
when t.totalquantity between 20 and 49 then 'medium quatity'
else 'high quantity' end as tag
from (select prescriptionid,sum(quantity) as totalquantity from 
contain group by prescriptionID) t limit 10;

-- 3

select k.medicineid,case when quantity>7500 then ' high quantity'
else 'low quantity' end as quantity,
case when discount>=30 then 'high'
when discount=0 then 'none' end as discount_category
from keep k join 
pharmacy p on 
k.pharmacyid=p.pharmacyid
where p.pharmacyname='spot rx' and ((quantity<=1000 and discount>=30) 
or (quantity>7500 and discount=0));

-- 4
with Average as
(
	select avg(maxprice) as avgg from medicine
),
a2 as (select medicineid,case when(maxprice)<0.5*avgg then 'affordable'
when(maxprice)>2*avgg then 'costly' end as medicine_category
from medicine,Average where hospitalexclusive='S')
select * from a2 where medicine_category is not null ;

-- 5
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