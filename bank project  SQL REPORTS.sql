-- 1. Display customer id, first name, initials and last name of female customers who have some initials.
SELECT CUST_ID,
  CUST_FIRST_NAME,
  INITIALS,
  CUST_LAST_NAME
FROM BANK_CUST
WHERE CUST_GENDER='F'
AND INITIALS    IS NOT NULL;
-- 2. Write a query to show customer id, phone no.,state and full address of customers who live either in 'Karnataka' or 'Tamilnadu'.
--    in acending order of the state
SELECT CUST_ID,
  CUST_PHONE,
  CUST_ADDR_LINE1,
  CUST_ADDR_LINE2,
  CUST_STATE
FROM BANK_CUST_CONTACT
WHERE CUST_STATE IN ('Karnataka','Tamilnadu')
ORDER BY CUST_STATE;
-- 3. Display details (account no, primary customer id, current balance and a/c start date) of active SB accounts in the order of latest start date (first) to earliest start date (last).
SELECT ACCOUNT_NO,
  PRIMARY_CUST_ID,
  CURR_BAL_AMT,
  START_DATE
FROM BANK_SB_ACCOUNT
WHERE ACC_STATUS='Active'
ORDER BY START_DATE DESC;
-- 4. Display bank employee designation, id, name and gender of those employees who have a manager,
--    sorted in descending order of designation and ascending order of employee name.
SELECT BANK_EMP_ID,
  DESIGNATION,
  MANAGER_ID,
  EMP_NAME,
  EMP_GENDER
FROM BANK_EMPLOYEE
WHERE MANAGER_ID IS NOT NULL
ORDER BY DESIGNATION DESC ,
  EMP_NAME ASC;
-- 5. What are the minimum and maximum installment amounts of RD accounts which were started during year 2008?
SELECT MIN(INSTALLMENT_AMT),
  MAX(INSTALLMENT_AMT)
FROM BANK_RD_ACCOUNT
WHERE RD_START_DT BETWEEN '01-JAN-2008' AND '31-DEC-2008';
-- 6. Write a query to show designation and the no. of employees under each designation except 'ATTENDER'.
--    Arrange the output by no. of employees and then by designation.
SELECT COUNT(*) TOTAL_NO_OF_EMP ,
  DESIGNATION
FROM BANK_EMPLOYEE
WHERE DESIGNATION <>'ATTENDER'
GROUP BY DESIGNATION;
-- 7. Write a query to show customer id and the no. of office phones they have of those customers who have more than one office phone.
SELECT CUST_ID,
  COUNT(*) "NO OF OFFICE PHONES"
FROM BANK_CUST_CONTACT
WHERE CONTACT_TYPE='OFFICE'
GROUP BY CUST_ID
HAVING COUNT(*)>1;
-- 8. Display customer id, first & last names, home phone no. and city of those customers who live outside Karnataka.
SELECT BANK_CUST.CUST_ID,
  CUST_FIRST_NAME,
  CUST_LAST_NAME,
  CUST_PHONE,
  CUST_CITY
FROM BANK_CUST
INNER JOIN BANK_CUST_CONTACT
ON (BANK_CUST.CUST_ID =BANK_CUST_CONTACT.CUST_ID)
WHERE CUST_STATE NOT IN ('Karnataka');

-- 9. Show transaction details – SB a/c no., transaction type, date, description and amount, for transaction amounts > 1000.
-- Sort the output based on a/c no, transaction type and date.
SELECT BANK_SB_ACCOUNT.ACCOUNT_NO,
  BANK_TRANSACTION.TRANS_TYPE,
  BANK_TRANSACTION.TRANS_DT,
  BANK_TRANSACTION.TRANS_AMT
FROM BANK_TRANSACTION
INNER JOIN BANK_SB_ACCOUNT
ON (BANK_TRANSACTION.TRANS_ACC_NO=BANK_SB_ACCOUNT.ACCOUNT_NO)
AND BANK_TRANSACTION.TRANS_AMT   >1000
ORDER BY BANK_SB_ACCOUNT.ACCOUNT_NO,
  BANK_TRANSACTION.TRANS_TYPE,
  BANK_TRANSACTION.TRANS_DT;

-- 10.	Show customer id, his/her phone no.(s), SB account no., transaction date and amount of the customer(s) who have done ATM withdrawal transaction.

SELECT BANK_CUST.CUST_ID,
  BANK_CUST_CONTACT.CUST_PHONE,
  BANK_SB_ACCOUNT.ACCOUNT_NO,
  BANK_TRANSACTION.TRANS_DT,
  BANK_TRANSACTION.TRANS_AMT
FROM BANK_CUST
INNER JOIN BANK_CUST_CONTACT
ON (BANK_CUST.CUST_ID=BANK_CUST_CONTACT.CUST_ID)
INNER JOIN BANK_SB_ACCOUNT
ON (BANK_CUST.CUST_ID=BANK_SB_ACCOUNT.PRIMARY_CUST_ID)
INNER JOIN BANK_TRANSACTION
ON (BANK_SB_ACCOUNT.ACCOUNT_NO=BANK_TRANSACTION.TRANS_ACC_NO)
WHERE BANK_TRANSACTION.TRANS_DESC LIKE '%ATM%';

-- 11.	For every state and for every city find the total transactions performed by every customer. Get the data for every combination of the dimension.
--      we need to display cust_id cust state , cust city and total number of transactions
SELECT BANK_CUST.CUST_ID,
  CUST_STATE,
  CUST_CITY,
  COUNT(*) "TOTAL TRANSACTIONS"
FROM BANK_CUST_CONTACT
INNER JOIN BANK_CUST
ON (BANK_CUST_CONTACT.CUST_ID=BANK_CUST.CUST_ID)
INNER JOIN BANK_SB_ACCOUNT
ON (BANK_CUST.CUST_ID=BANK_SB_ACCOUNT.PRIMARY_CUST_ID)
INNER JOIN BANK_TRANSACTION
ON (BANK_SB_ACCOUNT.ACCOUNT_NO=BANK_TRANSACTION.TRANS_ACC_NO)
GROUP BY BANK_CUST.CUST_ID,
  BANK_CUST_CONTACT.CUST_STATE,
  BANK_CUST_CONTACT.CUST_CITY;
  
