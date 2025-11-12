CREATE DATABASE HospitalDB;
USE HospitalDB;

CREATE TABLE Department (
    Dept_ID INT PRIMARY KEY,
    Dept_Name VARCHAR(50),
    Location VARCHAR(50)
);

CREATE TABLE Doctor (
    Doctor_ID INT PRIMARY KEY,
    Doctor_Name VARCHAR(50),
    Dept_ID INT,
    Qualification VARCHAR(50),
    Salary DECIMAL(10,2),
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

CREATE TABLE Patient (
    Patient_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(50),
    Gender CHAR(1),
    Age INT,
    Address VARCHAR(100),
    Disease VARCHAR(50)
);

CREATE TABLE Room (
    Room_ID INT PRIMARY KEY,
    Room_Type VARCHAR(30),
    Status VARCHAR(20),
    Charges DECIMAL(10,2)
);

CREATE TABLE Admission (
    Admission_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_ID INT,
    Room_ID INT,
    Admit_Date DATE,
    Discharge_Date DATE,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID),
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID)
);

INSERT INTO Department VALUES
(1, 'Cardiology', 'Block A'),
(2, 'Neurology', 'Block B'),
(3, 'Orthopedics', 'Block C'),
(4, 'Pediatrics', 'Block D');

INSERT INTO Doctor VALUES
(101, 'Dr. Sharma', 1, 'MD Cardiology', 95000),
(102, 'Dr. Mehta', 2, 'MD Neurology', 90000),
(103, 'Dr. Rao', 3, 'MS Orthopedics', 87000),
(104, 'Dr. Verma', 4, 'MD Pediatrics', 88000);

INSERT INTO Patient VALUES
(201, 'Amit Kumar', 'M', 45, 'Delhi', 'Heart Disease'),
(202, 'Priya Singh', 'F', 30, 'Mumbai', 'Migraine'),
(203, 'Raj Patel', 'M', 60, 'Ahmedabad', 'Fracture'),
(204, 'Sneha Das', 'F', 5, 'Kolkata', 'Fever'),
(205, 'Ankit Yadav', 'M', 50, 'Jaipur', 'Heart Disease');

INSERT INTO Room VALUES
(301, 'ICU', 'Occupied', 5000),
(302, 'General', 'Vacant', 2000),
(303, 'Private', 'Occupied', 3500),
(304, 'General', 'Occupied', 2000);

INSERT INTO Admission VALUES
(401, 201, 101, 301, '2025-11-01', NULL),
(402, 202, 102, 304, '2025-11-03', '2025-11-05'),
(403, 203, 103, 303, '2025-11-02', NULL),
(404, 204, 104, 302, '2025-11-04', '2025-11-06'),
(405, 205, 101, 301, '2025-11-05', NULL);

SELECT Patient_Name, Disease 
FROM Patient 
WHERE Patient_ID IN (
    SELECT Patient_ID FROM Admission WHERE Discharge_Date IS NULL
);

SELECT Doctor_Name 
FROM Doctor 
WHERE Dept_ID = (SELECT Dept_ID FROM Department WHERE Dept_Name = 'Cardiology');

SELECT d.Dept_Name, COUNT(a.Patient_ID) AS Total_Patients
FROM Admission a
JOIN Doctor doc ON a.Doctor_ID = doc.Doctor_ID
JOIN Department d ON doc.Dept_ID = d.Dept_ID
GROUP BY d.Dept_Name;

SELECT p.Patient_Name, p.Disease, a.Admit_Date, a.Room_ID
FROM Patient p
JOIN Admission a ON p.Patient_ID = a.Patient_ID
WHERE a.Doctor_ID = (SELECT Doctor_ID FROM Doctor WHERE Doctor_Name = 'Dr. Sharma');

SELECT Room_Type, COUNT(*) AS Vacant_Rooms
FROM Room
WHERE Status = 'Vacant'
GROUP BY Room_Type;

SELECT p.Patient_Name, d.Doctor_Name, dept.Dept_Name
FROM Admission a
JOIN Patient p ON a.Patient_ID = p.Patient_ID
JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
JOIN Department dept ON d.Dept_ID = dept.Dept_ID
WHERE a.Discharge_Date IS NULL;

SELECT Doctor_Name, Salary
FROM Doctor
WHERE Salary > (SELECT AVG(Salary) FROM Doctor);

SELECT p.Patient_Name, p.Age, p.Disease
FROM Patient p
JOIN Admission a ON p.Patient_ID = a.Patient_ID
JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
JOIN Department dept ON d.Dept_ID = dept.Dept_ID
WHERE p.Age > 40 AND dept.Dept_Name = 'Cardiology';

SELECT d.Doctor_Name, COUNT(a.Patient_ID) AS Total_Patients
FROM Doctor d
LEFT JOIN Admission a ON d.Doctor_ID = a.Doctor_ID
GROUP BY d.Doctor_Name;

SELECT p.Patient_Name, DATEDIFF(a.Discharge_Date, a.Admit_Date) AS Stay_Days
FROM Admission a
JOIN Patient p ON a.Patient_ID = p.Patient_ID
WHERE a.Discharge_Date IS NOT NULL
ORDER BY Stay_Days DESC
LIMIT 1;

SELECT Dept_Name
FROM Department
WHERE Dept_ID = (
    SELECT d.Dept_ID
    FROM Doctor d
    JOIN Admission a ON d.Doctor_ID = a.Doctor_ID
    WHERE a.Discharge_Date IS NULL
    GROUP BY d.Dept_ID
    ORDER BY COUNT(a.Patient_ID) DESC
    LIMIT 1
);

SELECT DISTINCT r.Room_ID, r.Room_Type
FROM Room r
JOIN Admission a ON r.Room_ID = a.Room_ID
JOIN Patient p ON a.Patient_ID = p.Patient_ID
WHERE p.Disease = 'Heart Disease';

SELECT p.Patient_Name, p.Disease
FROM Patient p
WHERE Patient_ID IN (
    SELECT a.Patient_ID
    FROM Admission a
    JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
    WHERE d.Salary > 90000
);

SELECT Disease, COUNT(*) AS Count
FROM Patient
WHERE Patient_ID IN (SELECT Patient_ID FROM Admission)
GROUP BY Disease
ORDER BY Count DESC
LIMIT 1;

SELECT d.Doctor_Name, 
       (COUNT(a.Patient_ID) * 500 + d.Salary) AS Total_Earnings
FROM Doctor d
LEFT JOIN Admission a ON d.Doctor_ID = a.Doctor_ID
GROUP BY d.Doctor_Name, d.Salary;