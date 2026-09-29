-- PART A:

CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary     INTEGER,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(50) NOT NULL UNIQUE,
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);

-- PART B:

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Ali', 'Karimov', 'Finance'),
       (2, 'Bota', 'Serik', 'Finance'),
       (3, 'Camila', 'Ruiz', 'Finance');

SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('employees', 'emp_id'),
              (SELECT MAX(emp_id) FROM employees));

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Aigerim', 'Sarsen', 'HR', DEFAULT, DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('IT',    150000, 101),
       ('Sales',  80000, 102),
       ('HR',     60000, 103);

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES ('Website Redesign', 1, '2022-01-01', '2022-12-31',  80000),
       ('Mobile App',       1, '2024-01-01', '2026-12-31', 120000),
       ('Sales Campaign',   2, '2025-03-01', '2026-06-30',  40000),
       ('HR Portal',        3, '2025-05-01', '2026-11-30',  90000);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Expr', 'Test', 'Finance', 50000 * 1.1, CURRENT_DATE);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Aidos',  'Nurlan',  'IT',    90000, '2019-03-15', 'Active'),
       ('Dana',   'Kim',     'IT',    62000, '2021-06-01', 'Active'),
       ('Ruslan', 'Omarov',  'IT',    45000, '2022-09-10', 'Active'),
       ('Madina', 'Aliyeva', 'IT',    70000, '2018-11-20', 'Active'),
       ('Timur',  'Sadykov', 'Sales', 55000, '2020-02-14', 'Active'),
       ('Laura',  'Sey',     'Sales', 47000, '2021-04-04', 'Inactive'),
       ('Yerlan', 'Kasym',   'HR',    52000, '2017-08-30', 'Active');

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE 1 = 0;

INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

SELECT * FROM temp_employees;

-- PART C:

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
                     WHEN salary > 80000 THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
                 END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Nurgul',  'Abay',    'IT',    120000, '2015-05-10', 'Active'),
       ('Bakyt',   'Zhan',    'IT',    110000, '2016-07-21', 'Active'),
       ('Kamila',  'Tas',     'IT',     90000, '2021-01-12', 'Active'),
       ('Daulet',  'Ermek',   'IT',    100000, '2022-02-02', 'Active'),
       ('Saltanat','Ibray',   'Sales',  60000, '2019-09-09', 'Active'),
       ('Arman',   'Kuat',    'Sales',  50000, '2023-04-01', 'Active'),
       ('Zhanna',  'Mukan',   'HR',     45000, '2018-03-03', 'Active'),
       ('Marat',   'Zhak',    'HR',     42000, '2016-01-10', 'Terminated'),
       ('Nurbol',  'Ali',     NULL,     35000, '2023-06-15', 'Active');

INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('Legal', 30000, 104);

UPDATE departments d
SET budget = (SELECT ROUND(AVG(e.salary) * 1.2)
              FROM employees e
              WHERE e.department = d.dept_name)
WHERE EXISTS (SELECT 1
              FROM employees e
              WHERE e.department = d.dept_name
                AND e.salary IS NOT NULL);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- PART D:

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (SELECT DISTINCT department
                        FROM employees
                        WHERE department IS NOT NULL);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- PART E: 

INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Null', 'Person', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- PART F:

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Gulnara', 'Bekova', 'Finance', 65000, CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees e
SET salary = old.salary + 5000
FROM employees old
WHERE old.emp_id = e.emp_id
  AND e.department = 'IT'
RETURNING e.emp_id, old.salary AS old_salary, e.salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- PART G: 

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Zarina', 'Ospan', 'HR', 48000, CURRENT_DATE
WHERE NOT EXISTS (SELECT 1
                  FROM employees
                  WHERE first_name = 'Zarina' AND last_name = 'Ospan');

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Zarina', 'Ospan', 'HR', 48000, CURRENT_DATE
WHERE NOT EXISTS (SELECT 1
                  FROM employees
                  WHERE first_name = 'Zarina' AND last_name = 'Ospan');

UPDATE employees e
SET salary = salary * CASE
                          WHEN (SELECT d.budget
                                FROM departments d
                                WHERE d.dept_name = e.department) > 100000
                              THEN 1.10
                          ELSE 1.05
                      END;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bulk1', 'Batch25', 'Sales', 40000, CURRENT_DATE),
       ('Bulk2', 'Batch25', 'Sales', 41000, CURRENT_DATE),
       ('Bulk3', 'Batch25', 'Sales', 42000, CURRENT_DATE),
       ('Bulk4', 'Batch25', 'Sales', 43000, CURRENT_DATE),
       ('Bulk5', 'Batch25', 'Sales', 44000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Batch25';

CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Old1', 'Inactive26', 'HR',    39000, '2021-01-01', 'Inactive'),
       ('Old2', 'Inactive26', 'Sales', 41000, '2022-01-01', 'Inactive');

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

SELECT * FROM employee_archive;

UPDATE projects p
SET end_date = end_date + 30
WHERE p.budget > 50000
  AND (SELECT COUNT(*)
       FROM employees e
       JOIN departments d ON d.dept_name = e.department
       WHERE d.dept_id = p.dept_id) > 3;

SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;
