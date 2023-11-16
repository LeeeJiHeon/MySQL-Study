# 6.5 a
SELECT DNAME, COUNT(*) AS Number_Of_Employees
FROM DEPARTMENT, EMPLOYEE
WHERE DNO = DNUMBER
GROUP BY DNAME
HAVING AVG(SALARY) > 30000;

# 6.5 b
SELECT DNAME, COUNT(*) AS Number_Of_Male_Employee
from DEPARTMENT, EMPLOYEE
where DNO = DNUMBER and SEX = 'M' and DNAME 
in (select DNAME 
	from DEPARTMENT, EMPLOYEE
	where DNO = DNUMBER
	group by DNAME
	having AVG(SALARY) > 30000)
group by DNAME;

# 6.8 a
CREATE VIEW manger_info
AS SELECT Dname, Fname, Lname, Salary
	FROM DEPARTMENT, EMPLOYEE
	WHERE Mgrssn = Ssn;

# 6.8 b
CREATE VIEW research_employee_info 
AS SELECT
    E1.Fname AS Employee_FirstName,
    E1.Lname AS Employee_LastName,
    E2.Fname AS Supervisor_FirstName,
    E2.Lname AS Supervisor_LastName,
    E1.Salary AS Employee_Salary
FROM Employee E1
JOIN Employee E2 ON E1.SUPERSSN = E2.SSN
JOIN Department D ON E1.DNO = D.DNUMBER
WHERE D.DName = 'Research';

# 6.8 c   
CREATE VIEW project_info
AS SELECT Pname, Dname, (SELECT COUNT(*)
						FROM WORKS_ON W1
						WHERE W1.Pno = P1.Pnumber) AS Num_Employee, 
						(SELECT SUM(W2.Hours)
						FROM WORKS_ON W2
						WHERE W2.Pno = P1.Pnumber 
						GROUP BY Pno) AS Total_Hours
	FROM PROJECT P1, DEPARTMENT D1
	WHERE P1.Dnum = D1.Dnumber;

# 6.8 d
CREATE VIEW project_info_d
AS SELECT Pname, Dname, (SELECT COUNT(*)
						FROM WORKS_ON W1
						WHERE W1.Pno = P1.Pnumber) AS Num_Employee, 
						(SELECT SUM(W2.Hours)
						FROM WORKS_ON W2
						WHERE W2.Pno = P1.Pnumber 
						GROUP BY Pno) AS Total_Hours
	FROM PROJECT P1, DEPARTMENT D1
	WHERE P1.Dnum = D1.Dnumber AND (SELECT COUNT(*)
								  FROM WORKS_ON W2
								  WHERE W2.Pno = P1.Pnumber
								  GROUP BY W2.Pno) > 1;
# 7.16 a
SELECT E.FNAME, E.MINIT, E.LNAME
FROM EMPLOYEE E
INNER JOIN WORKS_ON WO ON E.SSN = WO.ESSN
INNER JOIN PROJECT P ON WO.PNO = P.PNUMBER
WHERE E.DNO = 5 
AND P.PNAME = 'ProductX' 
AND WO.HOURS >= 10;

# 7.16 b
SELECT FNAME, MINIT, LNAME
FROM EMPLOYEE, DEPENDENT
WHERE SSN = ESSN
AND DEPENDENT_NAME = FNAME;

# 7.16 c
SELECT E.FNAME, E.MINIT, E.LNAME
FROM EMPLOYEE E
	INNER JOIN EMPLOYEE super on super.SSN = E.SUPERSSN
WHERE super.FNAME = 'Franklin' 
AND super.LNAME = 'Wong';

# 7.16 d
SELECT P.Pname, AVG(E.Salary)
FROM PROJECT P
JOIN WORKS_ON WO ON P.Pnumber = WO.Pno
JOIN Employee E ON WO.ESSN = E.SSN
GROUP BY P.Pname;

# 7.16 g
SELECT Dname, AVG(Salary)
FROM EMPLOYEE JOIN DEPARTMENT ON Dno = Dnumber
GROUP BY Dname;

# 7.16 h
SELECT AVG(Salary)
FROM EMPLOYEE
WHERE Sex = 'F';

# 7.16 j
SELECT Fname, Lname
FROM EMPLOYEE JOIN DEPARTMENT ON Ssn = Mgrssn 
WHERE NOT EXISTS ( SELECT *
				FROM DEPENDENT
				WHERE Ssn = Essn );
                
# 질의: 5번 부서에 근무하는 사원보다 급여가 많은 사원을 검색
SELECT LNAME, FNAME
FROM EMPLOYEE
WHERE SALARY > ALL (SELECT SALARY
					FROM EMPLOYEE
					WHERE DNO = 5);
                    
# 질의 16B : 자신의 부양가족과 이름, 성별이 같은 종업원들의 이름을 검색
SELECT E.FNAME, E.LNAME
FROM EMPLOYEE E
WHERE EXISTS (SELECT *
			FROM DEPENDENT AS D
			WHERE E.SSN = D.ESSN AND E.SEX = D.SEX AND E.FNAME = D.DEPENDENT_NAME);
            
# 질의 7 : 부양가족이 적어도 한 명 이상 있는 관리자의 이름을 검색
SELECT FNAME, LNAME 
FROM EMPLOYEE
WHERE EXISTS (SELECT *
			FROM DEPENDENT 
            WHERE SSN = ESSN)
	AND
	EXISTS (SELECT *
	FROM DEPARTMENT
    WHERE SSN = MGRSSN);

/*질의 20 : ‘Research’부서에 있는 모든 종업원들의 급여의 합과 최고 급여,
 최소 급여, 평균 급여를 계산하고 검색 (두 방법 각각 실행 후 결과 확인)*/
 SELECT SUM(SALARY), MAX(SALARY), MIN(SALARY), AVG(SALARY)
 FROM EMPLOYEE, DEPARTMENT
 WHERE DNO = DNUMBER AND DNAME = 'Research';
 
 SELECT SUM(SALARY), MAX(SALARY), MIN(SALARY), AVG(SALARY) 
 FROM (EMPLOYEE JOIN DEPARTMENT ON DNO = DNUMBER)
 WHERE DNAME = 'Research';
 
 /* 질의 27 : 각 프로젝트에 대해서 프로젝트 번호, 프로젝트 이름, 
 5번 부서에 속하면서 프로젝트에서 근무하는 사원의 수를 검색 */
 SELECT PNUMBER, PNAME, COUNT(*) 
 FROM PROJECT, WORKS_ON, EMPLOYEE 
 WHERE PNUMBER = PNO AND SSN = ESSN AND DNO = 5;
 
 /* 질의 28 : 3명을 초과하는 사원이 근무하는 각 부서에 대해서 부서번호와 30,000달러가 
 넘는 급여를 받는 사원의 수를 검색 */
SELECT DNUMBER, COUNT(*)
FROM DEPARTMENT, EMPLOYEE 
WHERE DNUMBER = DNO AND SALARY>30000 AND 
	DNO IN (SELECT DNO 
    FROM EMPLOYEE 
    GROUP BY DNO 
    HAVING COUNT(*) > 3)
GROUP BY DNUMBER;