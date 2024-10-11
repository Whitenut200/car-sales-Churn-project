# 가장 최근 구매날짜
select max(orderdate) mx_order from classicmodels.orders; # 2005-05-31

# 고객번호별 가장 최근 구매 날짜
select customernumber, max(orderdate) mx_order from classicmodels.orders group by 1;

# 고객번호별 마지막 구매까지 걸린 시간 (이탈률 구하기)
select customernumber, datediff('2005-05-31',mx_order) diff from (select customernumber, max(orderdate) mx_order from classicmodels.orders group by 1) A;
select avg(diff) from classicmodels.customerdiff; # 최근 구매간격 평균

# 이탈률 구하기 (180일 이상 구매 안한 고객을 이탈고객으로 판단)- 약 52%
select case when diff>=180 then 'CHURN' else 'NON-CHURN' end churn_type, count(distinct(customernumber)) n_cus from classicmodels.customerdiff group by 1;

# 새로운 테이블 만들기 (이탈률 180일 이상)
create table classicmodels.customerdiff180 as
select *,case when diff>=180 then 'CHURN' else 'NON-CHURN' end churn_type from(select customernumber ,mx_order,datediff('2005-06-01',MX_ORDER) diff from (select *,max(orderdate) MX_ORDER
from classicmodels.orders group by 1)A)B;

# 전체 데이터 만들기
# 중복되는 행 이름 바꾸기 (ex) 고객 전화번호, 직원 전화번호
drop table classicmodels.alldata;
alter table classicmodels.offices change column city office_city varchar(20) ;
alter table classicmodels.offices change column phone office_phone varchar(20) ;
alter table classicmodels.offices change column country office_country varchar(20) ;
alter table classicmodels.offices change column postalCode office_postalCode varchar(20) ;

# 테이블 만들기 (필요없는 행 지우고 필요한 행만 추출) - 40개
create table classicmodels.alldata as
select A.customernumber,A.customername,A.contactLastName,A.contactFirstName, A.phone,A.city,A.postalCode,A.country,A.creditLimit,
B.orderNumber,B.orderDate,B.requiredDate,B.shippedDate,B.status,B.comments,
C.productcode,c.quantityOrdered,c.priceEach,
D.productName,D.productLine,D.productVendor,D.productDescription,D.quantityInStock,D.buyPrice,D.MSRP,
E.paymentDate,E.amount,
F.employeeNumber,F.lastName,F.firstName,F.extension,F.email,F.officeCode,F.jobTitle,
G.office_city,G.office_phone,G.state,G.office_country,G.office_postalCode,G.territory from classicmodels.customers A
left join classicmodels.orders B on A.customernumber=B.customerNumber
left join classicmodels.orderdetails C on B.ordernumber=C.orderNumber
left join classicmodels.products D on C.productCode=D.productCode
left join classicmodels.payments E on A.customerNumber=E.customerNumber
left join classicmodels.employees F on A.salesRepEmployeeNumber=F.employeeNumber
left join classicmodels.offices G on F.officeCode=G.officeCode;







