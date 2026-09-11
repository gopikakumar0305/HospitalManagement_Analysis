CREATE DATABASE hospital_management;
USE hospital_management;
DESCRIBE bills;
ALTER TABLE bills 
CHANGE COLUMN `ï»¿BillID` BillID VARCHAR(20);
DESCRIBE patients;
ALTER TABLE patients 
CHANGE COLUMN `ï»¿PatientID` PatientID VARCHAR(20);
DESCRIBE doctors;
ALTER TABLE doctors 
CHANGE COLUMN `ï»¿DoctorID` DoctorID VARCHAR(20);
DESCRIBE hospitals;
ALTER TABLE hospitals 
CHANGE COLUMN `ï»¿HospitalID` HospitalID VARCHAR(20);
DESCRIBE appointments;
ALTER TABLE appointments 
CHANGE COLUMN `ï»¿AppointmentID` AppointmentID VARCHAR(20);
DESCRIBE insurance;
ALTER TABLE insurance 
CHANGE COLUMN `ï»¿InsuranceID` InsuranceID VARCHAR(20);
DESCRIBE lab_reports;
ALTER TABLE lab_reports 
CHANGE COLUMN `ï»¿ReportID` LabReportID VARCHAR(20);
DESCRIBE medicine_inventory;
ALTER TABLE medicine_inventory 
CHANGE COLUMN `ï»¿HospitalID` HospitalID VARCHAR(20);
DESCRIBE nurses;
ALTER TABLE nurses 
CHANGE COLUMN `ï»¿HospitalID` HospitalID VARCHAR(20);
DESCRIBE ward_occupancy;
ALTER TABLE ward_occupancy 
CHANGE COLUMN `ï»¿WardRecordID` WardRecord VARCHAR(20);
-- Fix bills table data types (y-m-d)
ALTER TABLE bills 
MODIFY COLUMN AdmissionDate DATE,
MODIFY COLUMN DischargeDate DATE,
MODIFY COLUMN RoomCharges DECIMAL(10,2),
MODIFY COLUMN TreatmentCharges DECIMAL(10,2),
MODIFY COLUMN TotalAmount DECIMAL(10,2);
-- Fix data types
ALTER TABLE patients
MODIFY COLUMN Age INT;
ALTER TABLE doctors
MODIFY COLUMN ExperienceYears INT;
ALTER TABLE appointments
MODIFY COLUMN AppointmentDate DATE,
MODIFY COLUMN ConsultationFee DECIMAL(10,2);
ALTER TABLE insurance
MODIFY COLUMN ClaimAmount DECIMAL(10,2),
MODIFY COLUMN PolicyEndDate DATE;
ALTER TABLE medicine_inventory
MODIFY COLUMN StockQuantity INT,
MODIFY COLUMN UnitPrice DECIMAL(15,2);
ALTER TABLE nurses
MODIFY COLUMN ExperienceYears INT;
ALTER TABLE ward_occupancy
MODIFY COLUMN TotalBeds INT,
MODIFY COLUMN OccupiedBeds INT,
MODIFY COLUMN AvailableBeds INT;

-- Task 2: Top Revenue-Generating Hospitals
SELECT h.HospitalName, SUM(b.TotalAmount) AS TotalRevenue
FROM bills b
JOIN hospitals h ON b.HospitalID = h.HospitalID
GROUP BY h.HospitalName
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Task 3: Average Length of Stay per Department
SELECT Department,
AVG(DATEDIFF(DischargeDate, AdmissionDate)) AS AvgStayDays
FROM bills
GROUP BY Department;

-- Task 4: Doctor Appointment Load Query
SELECT d.DoctorName, COUNT(*) AS TotalAppointments
FROM appointments a
JOIN doctors d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Completed'
GROUP BY d.DoctorName
ORDER BY TotalAppointments DESC;

-- Task 5: Insurance Claim Pending Analysis
SELECT Provider, Status, COUNT(*) AS ClaimCount
FROM insurance
GROUP BY Provider, Status;

SELECT PolicyEndDate,
       CASE 
           WHEN PolicyEndDate < CURDATE() THEN 'Expired'
           WHEN PolicyEndDate <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'Expiring Soon'
           ELSE 'Valid'
       END AS AgingStatus
FROM insurance;

-- Task 6: Ward Capacity Alert Query
SELECT WardType, HospitalName,
       (OccupiedBeds / TotalBeds) * 100 AS OccupancyPercent
FROM ward_occupancy
HAVING OccupancyPercent > 85;

-- Task 7: Patient Visit History (Subquery/CTE)
WITH VisitSummary AS (
    SELECT PatientID, COUNT(*) AS TotalAppointments
    FROM appointments
    GROUP BY PatientID
)
SELECT p.PatientName, v.TotalAppointments
FROM patients p
JOIN VisitSummary v ON p.PatientID = v.PatientID;

-- Task 8: Low Stock Medicine Report
SELECT HospitalName, MedicineName, StockQuantity
FROM medicine_inventory
WHERE StockQuantity < 100
ORDER BY StockQuantity ASC;

-- Task 9: Lab Test Abnormality Trends
SELECT TestName, Result, COUNT(*) AS Total
FROM lab_reports
GROUP BY TestName, Result
ORDER BY TestName;

-- Task 10: Window Function Ranking
SELECT NurseName, Department, ExperienceYears,
       RANK() OVER (PARTITION BY Department ORDER BY ExperienceYears DESC) AS ExpRank
FROM nurses;