CREATE OR REPLACE PACKAGE BODY HDFC_BANK IS
FUNCTION COUNT_BANK_CUST RETURN NUMBER;
FUNCTION CHECK_CUST_ID (P_CUST_ID IN BANK_CUST.CUST_ID%TYPE) RETURN NUMBER;
FUNCTION COUNT_BANK_SB_ACCOUNT RETURN NUMBER;
FUNCTION COUNT_BANK_CUST RETURN NUMBER
IS
V_CUST_COUNT NUMBER;
BEGIN
 SELECT COUNT(*) INTO V_CUST_COUNT FROM BANK_CUST;
 RETURN V_CUST_COUNT;
EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END COUNT_BANK_CUST;
FUNCTION CHECK_CUST_ID (P_CUST_ID IN BANK_CUST.CUST_ID%TYPE)
RETURN NUMBER IS
  CURSOR C1(P_CUR_CUST_ID IN BANK_CUST.CUST_ID%TYPE) 
  IS 
  SELECT 'A' FROM BANK_CUST 
  WHERE CUST_ID=P_CUR_CUST_ID;
  V_TEMP CHAR(1);
BEGIN
  OPEN C1(P_CUST_ID);
  FETCH C1 INTO V_TEMP;
  CLOSE C1;
  IF V_TEMP='A' THEN
    RETURN 1;
  ELSE
    RETURN -1;
  END IF;
EXCEPTION 
  WHEN OTHERS THEN
    RETURN NULL;
END CHECK_CUST_ID;  

FUNCTION COUNT_BANK_SB_ACCOUNT RETURN NUMBER
IS
V_SB_ACCOUNT_COUNT NUMBER;
BEGIN
 SELECT COUNT(*) INTO V_SB_ACCOUNT_COUNT FROM BANK_SB_ACCOUNT;
 RETURN V_SB_ACCOUNT_COUNT;
EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END COUNT_BANK_SB_ACCOUNT ;

PROCEDURE PNAME_ADD_CUSTOMER 
(P_CUST_FIRST_NAME BANK_CUST.CUST_FIRST_NAME%TYPE,
 P_INITIALS BANK_CUST.INITIALS%TYPE,
 P_CUST_LAST_NAME BANK_CUST.CUST_LAST_NAME%TYPE,
 P_CUST_GENDER BANK_CUST.CUST_GENDER%TYPE DEFAULT 'F',
 P_CUST_DOB BANK_CUST.CUST_DOB%TYPE,
 P_CUST_TYPE BANK_CUST.CUST_TYPE%TYPE DEFAULT 'IND')
IS
V_COUNT NUMBER;
V_CUST_ID BANK_CUST.CUST_ID%TYPE;
BEGIN
  IF UPPER(P_CUST_GENDER) NOT IN ('M','F') THEN
    RAISE ESTOP;
  END IF;
  IF UPPER(P_CUST_TYPE) NOT IN ('IND','CORP') THEN
    RAISE ESTOP;
  END IF;
  V_COUNT:=COUNT_BANK_CUST;
  IF V_COUNT=0 THEN
    V_CUST_ID:=1001;
  ELSE
    SELECT MAX(CUST_ID)+1 INTO V_CUST_ID FROM BANK_CUST;
  END IF;
    INSERT INTO BANK_CUST 
  VALUES
  (V_CUST_ID,
   INITCAP(P_CUST_FIRST_NAME),
   INITCAP (P_INITIALS),
   INITCAP(P_CUST_LAST_NAME) ,
   UPPER(P_CUST_GENDER) ,
   P_CUST_DOB ,
   UPPER(P_CUST_TYPE) );
   -- COMMITING THE CHANGES
   COMMIT;
EXCEPTION
   WHEN ESTOP THEN
    RAISE_APPLICATION_ERROR (-20001,'THE GENDER OR CUSTOMER TYPE HAS BEEN INCORRECTLY SPECIFIED');
   WHEN OTHERS THEN
    NULL;
END PNAME_ADD_CUSTOMER;

 PROCEDURE PNAME_ADD_CUST_CONTACT
(P_CUST_ID  BANK_CUST_CONTACT.CUST_ID%TYPE,
 P_CUST_PHONE BANK_CUST_CONTACT.CUST_PHONE%TYPE,
 P_CONTACT_TYPE BANK_CUST_CONTACT.CONTACT_TYPE%TYPE DEFAULT 'HOME',
 P_CUST_ADDR_LINE1 BANK_CUST_CONTACT.CUST_ADDR_LINE1%TYPE,
 P_CUST_ADDR_LINE2 BANK_CUST_CONTACT.CUST_ADDR_LINE2%TYPE,
 P_CUST_CITY BANK_CUST_CONTACT.CUST_CITY%TYPE,
 P_CUST_STATE BANK_CUST_CONTACT.CUST_STATE%TYPE,
 P_CUST_PIN BANK_CUST_CONTACT.CUST_PIN%TYPE) IS
V_TEMP NUMBER;
BEGIN
 V_TEMP:=CHECK_CUST_ID(P_CUST_ID);
 IF V_TEMP=-1 THEN
  RAISE ESTOP1;
 END IF;
 IF LENGTH(P_CUST_PHONE) NOT BETWEEN 6 AND 10 THEN
  RAISE ESTOP2;
 END IF;
 IF P_CONTACT_TYPE NOT IN ('HOME','OFFICE') THEN
  RAISE ESTOP3;
 END IF; 
 IF LENGTH(P_CUST_PIN)<>6 THEN
  RAISE ESTOP4;
 END IF; 
 INSERT INTO BANK_CUST_CONTACT
 VALUES
 (P_CUST_ID  ,
 P_CUST_PHONE ,
 P_CONTACT_TYPE ,
 INITCAP(P_CUST_ADDR_LINE1) ,
 INITCAP(P_CUST_ADDR_LINE2) ,
 INITCAP(P_CUST_CITY) ,
 INITCAP(P_CUST_STATE) ,
 P_CUST_PIN );
 COMMIT;
 EXCEPTION
 WHEN ESTOP1 THEN
 RAISE_APPLICATION_ERROR(-20002,'THE CUSTOMER ID IS NOT CORRECT');
 WHEN ESTOP2 THEN
 RAISE_APPLICATION_ERROR(-20003,'THE CUSTOMER PHONE IS NOT CORRECT NO OF DIGITS');
 WHEN ESTOP3 THEN
 RAISE_APPLICATION_ERROR(-20004,'THE CUSTOMER CONTACT TYPE IS NOT CORRECT');
 WHEN ESTOP4 THEN
 RAISE_APPLICATION_ERROR(-20005,'THE CUSTOMER CONTACT PIN IS NOT CORRECT');
 WHEN OTHERS THEN
  NULL;
END PNAME_ADD_CUST_CONTACT;

PROCEDURE PNAME_DEL_CUST(P_BANK_CUST_ID BANK_CUST.CUST_ID%TYPE) IS
BEGIN
 DELETE BANK_CUST WHERE BANK_CUST.CUST_ID=P_BANK_CUST_ID;
 --COMMIT;
END PNAME_DEL_CUST;

PROCEDURE PNAME_DEL_CUST(P_CUST_FIRST_NAME BANK_CUST.CUST_FIRST_NAME%TYPE) IS
BEGIN
 DELETE BANK_CUST WHERE CUST_FIRST_NAME=INITCAP(P_CUST_FIRST_NAME);
 --COMMIT;
END PNAME_DEL_CUST;

PROCEDURE PNAME_ADD_SB_ACCOUNT (
  P_PRIMARY_CUST_ID BANK_SB_ACCOUNT.PRIMARY_CUST_ID%TYPE,
  P_SECONDARY_CUST_ID BANK_SB_ACCOUNT.SECONDARY_CUST_ID%TYPE DEFAULT NULL,
  P_CURR_BAL_AMT BANK_SB_ACCOUNT.CURR_BAL_AMT%TYPE,
  P_ACC_STATUS BANK_SB_ACCOUNT.ACC_STATUS%TYPE DEFAULT 'Active',
  P_START_DATE BANK_SB_ACCOUNT.START_DATE%TYPE DEFAULT SYSDATE,
  P_END_DATE BANK_SB_ACCOUNT.END_DATE%TYPE DEFAULT NULL
) IS
V_COUNT NUMBER;
V_ACCOUNT_NO BANK_SB_ACCOUNT.ACCOUNT_NO%TYPE;
V_TEMP NUMBER;
V_MIN_AMT NUMBER;
BEGIN
 V_TEMP:=CHECK_CUST_ID(P_PRIMARY_CUST_ID);
 IF V_TEMP=-1 THEN
  RAISE ESTOP1;
 END IF;
 IF P_SECONDARY_CUST_ID IS NOT NULL THEN
  V_TEMP:=CHECK_CUST_ID(P_PRIMARY_CUST_ID);
    IF V_TEMP=-1 THEN
      RAISE ESTOP2;
    END IF;
 END IF;
 IF INITCAP(P_ACC_STATUS) NOT IN ('Active','Closed') THEN
    RAISE ESTOP3;
 END IF;
 SELECT MIN_AMT INTO V_MIN_AMT FROM BANK_INT_RATE WHERE ACCOUNT_TYPE_CD='SB';
 IF P_CURR_BAL_AMT <V_MIN_AMT OR P_CURR_BAL_AMT IS NULL THEN
    RAISE ESTOP4  ;
 END IF;
 V_COUNT:=COUNT_BANK_SB_ACCOUNT;
 IF V_COUNT=0 THEN
    V_ACCOUNT_NO:=1000012001;
 ELSE
    SELECT MAX(ACCOUNT_NO)+1 INTO V_ACCOUNT_NO FROM BANK_SB_ACCOUNT;
 END IF;
  
INSERT INTO BANK_SB_ACCOUNT 
VALUES (V_ACCOUNT_NO,P_PRIMARY_CUST_ID,P_SECONDARY_CUST_ID,
P_CURR_BAL_AMT,INITCAP(P_ACC_STATUS),P_START_DATE,P_END_DATE);

SELECT COUNT(*) INTO V_COUNT FROM BANK_TRANSACTION;
IF V_COUNT=0 THEN
 INSERT INTO BANK_TRANSACTION VALUES (100001201,'CR',SYSDATE,V_ACCOUNT_NO,'OPENING NEW ACCOUNT',P_CURR_BAL_AMT);
ELSE
 SELECT MAX(TRANS_NO)+1 INTO V_COUNT FROM BANK_TRANSACTION ;
 INSERT INTO BANK_TRANSACTION VALUES (V_COUNT,'CR',SYSDATE,V_ACCOUNT_NO,'OPENING NEW ACCOUNT',P_CURR_BAL_AMT);
END IF;
EXCEPTION
  WHEN ESTOP1 THEN
  RAISE_APPLICATION_ERROR(-20006,'The primary customer id is incorrect');
  WHEN ESTOP2 THEN
  RAISE_APPLICATION_ERROR(-20007,'The secondary customer id is incorrect');
  WHEN ESTOP3 THEN
  RAISE_APPLICATION_ERROR(-20008,'The account status should be Active or Inactive');
  WHEN ESTOP4 THEN
  RAISE_APPLICATION_ERROR(-20009,'The account balance has to be >= 1000 and cannot be null');
  WHEN OTHERS THEN
  NULL;
END PNAME_ADD_SB_ACCOUNT;

PROCEDURE PNAME_SB_DEPOSIT (P_TRANS_ACC_NO BANK_TRANSACTION.TRANS_ACC_NO%TYPE,
                         P_TRANS_DESC BANK_TRANSACTION.TRANS_DESC%TYPE,
                         P_TRANS_AMT BANK_TRANSACTION.TRANS_AMT%TYPE) IS
 V_COUNT NUMBER;
BEGIN
SELECT COUNT(*) INTO V_COUNT FROM BANK_TRANSACTION;
IF V_COUNT=0 THEN
 INSERT INTO BANK_TRANSACTION VALUES (100001201,'CR',SYSDATE,P_TRANS_ACC_NO,P_TRANS_DESC,P_TRANS_AMT);
ELSE
 SELECT MAX(TRANS_NO)+1 INTO V_COUNT FROM BANK_TRANSACTION ;
 INSERT INTO BANK_TRANSACTION VALUES (V_COUNT,'CR',SYSDATE,P_TRANS_ACC_NO,P_TRANS_DESC,P_TRANS_AMT);
 UPDATE BANK_SB_ACCOUNT SET CURR_BAL_AMT=CURR_BAL_AMT+P_TRANS_AMT WHERE ACCOUNT_NO=P_TRANS_ACC_NO;
END IF;
END PNAME_SB_DEPOSIT;

PROCEDURE PNAME_SB_WITHDRAW (P_TRANS_ACC_NO BANK_TRANSACTION.TRANS_ACC_NO%TYPE,
                          P_TRANS_DESC BANK_TRANSACTION.TRANS_DESC%TYPE,
                          P_TRANS_AMT BANK_TRANSACTION.TRANS_AMT%TYPE) IS
V_COUNT NUMBER;
V_CURR_BAL_AMT BANK_SB_ACCOUNT.CURR_BAL_AMT%TYPE;
BEGIN
SELECT CURR_BAL_AMT INTO V_CURR_BAL_AMT FROM BANK_SB_ACCOUNT WHERE ACCOUNT_NO=P_TRANS_ACC_NO;
IF V_CURR_BAL_AMT<=1000 THEN
RAISE ESTOP;
END IF;
SELECT COUNT(*) INTO V_COUNT FROM BANK_TRANSACTION;
IF V_COUNT=0 THEN
  INSERT INTO BANK_TRANSACTION VALUES (100001201,'DB',SYSDATE,P_TRANS_ACC_NO,P_TRANS_DESC,P_TRANS_AMT);
ELSE
 SELECT MAX(TRANS_NO)+1 INTO V_COUNT FROM BANK_TRANSACTION ;
 INSERT INTO BANK_TRANSACTION VALUES (V_COUNT,'DB',SYSDATE,P_TRANS_ACC_NO,P_TRANS_DESC,P_TRANS_AMT);
 UPDATE BANK_SB_ACCOUNT SET CURR_BAL_AMT=CURR_BAL_AMT-P_TRANS_AMT WHERE ACCOUNT_NO=P_TRANS_ACC_NO;
END IF;
EXCEPTION 
WHEN ESTOP THEN
RAISE_APPLICATION_ERROR(-20010,'The account balance is not adequate to withdraw funds');
WHEN NO_DATA_FOUND THEN
RAISE_APPLICATION_ERROR(-20011,'The account number is invalid');
END  PNAME_SB_WITHDRAW;                        
END HDFC_BANK;