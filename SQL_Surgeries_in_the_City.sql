USE master;  
GO  
IF DB_ID (N'Surgeries_in_the_City') IS NOT NULL
DROP DATABASE Surgeries_in_the_City;
GO
CREATE DATABASE Surgeries_in_the_City
ON ( NAME = Surgeries, FILENAME =
"C:\data5\surgeries.mdf",
SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Surgeries_log, FILENAME = "C:\data5\surgerieslog.ldf",
SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO
USE Surgeries_in_the_City; 

CREATE TABLE Surgical_operation (
surgical_operation_ID         int       PRIMARY KEY,                               --can't be null
price                         money     null,
surgery_type                  char(50)  not null unique,                                --alternate key
surgeries_per_month           int       null     check (surgeries_per_month >= 0),
contraindications             char(150) null     default 'no contraindications',
success_surgeries_per_month   int       null     check (success_surgeries_per_month >= 0)
);

ALTER TABLE Surgical_operation ADD demises_per_month as surgeries_per_month - success_surgeries_per_month

CREATE TABLE Patients (
patient_ID    int      PRIMARY KEY,
full_name     char(60) not null,
data_of_birth date     not null,
SNILS         char(15) not null unique
);

ALTER TABLE Patients ADD phone_number char(25) not null

CREATE TABLE Hospital (
hospital_ID         int               PRIMARY KEY,
hospital_name       char(60) not null, 
hospital_address    char(60) not null, 
capacity_beds_count int      null     check (capacity_beds_count >= 0),
unique(hospital_name, hospital_address)
);

CREATE TABLE Doctors (
doctor_ID           int      PRIMARY KEY,
full_name           char(60) not null,
data_of_birth       date     not null,
phone_number        char(15) null,
years_of_experience int      null check (years_of_experience >= 0),
hospital_ID         int CONSTRAINT FK_HOSPITAL_doctors_ID FOREIGN KEY(hospital_ID) REFERENCES Hospital --если удаляется больница, то удаляются и все врачи в ней
                                         -- ON DELETE cascade ON UPDATE CASCADE
);

CREATE TABLE Appointment (
appointment_ID          int       PRIMARY KEY,
patient_ID              int       CONSTRAINT FK_APPOINTMENT_patient_ID FOREIGN KEY(patient_ID) REFERENCES Patients,               --automatically not null
                                           --ON DELETE cascade ON UPDATE CASCADE,
surgical_operation_ID   int       CONSTRAINT FK_APPOINTMENT_surgical_op_ID FOREIGN KEY(surgical_operation_ID) REFERENCES Surgical_operation,
                                           --ON DELETE cascade ON UPDATE CASCADE,
surgery_time            smalldatetime      not null,
surgery_lasting_minutes int                not null check (surgery_lasting_minutes >= 0),
cabinet_number          int                not null check (cabinet_number >= 0)
);

ALTER TABLE Appointment ADD UNIQUE (patient_ID, surgical_operation_ID, surgery_time)
ALTER TABLE Appointment ADD result char(200) not null default 'Surgery was not performed yet'

CREATE TABLE Connection_surgery_doctor (
appointment_ID int CONSTRAINT FK_CONNECTION_appointment_ID FOREIGN KEY(appointment_ID) REFERENCES Appointment,
													--ON DELETE cascade ON UPDATE CASCADE,
doctor_ID      int CONSTRAINT FK_CONNECTION_doctor_ID FOREIGN KEY(doctor_ID) REFERENCES Doctors,
unique(appointment_ID, doctor_ID)
													--ON DELETE cascade ON UPDATE CASCADE
);

/*Primary keys always need to be unique, foreign keys need to allow non-unique values if the table is a one-to-many 
relationship. It is perfectly fine to use a foreign key as the primary key if the table is connected by a one-to-one 
relationship, not a one-to-many relationship. */


INSERT into Surgical_operation  
   (surgical_operation_ID, price, surgery_type, surgeries_per_month, contraindications,  success_surgeries_per_month)  
VALUES  
   (1, 60000.00, 'Brain biopsy', 8, 'Neuropathy, systemic infection, excessive patient anxiety, mental illness, and anatomic distortion', 7),
   (2, 50000.00, 'Free skin graft', 13, 'Infected recipient site, Deep wounds with missing subdermal tissue or muscle lead to poor aesthetic outcome', 13),
   (3, 95000.00, 'Bariatric surgery', 3, 'heart failure, unstable coronary artery disease, end-stage lung disease, active cancer treatment', 3);
   --surgical removal of parts of the stomach and small intestines to induce weight loss.
--select * from Surgical_operation 

INSERT Patients
   (patient_ID, full_name, data_of_birth, SNILS, phone_number)
VALUES
   (1, 'Allen Walker', '1985-12-17', '176-261-996 02', '8-999-856-29-94'),
   (2, 'Oscar Wilde', '1954-10-16', '173-211-876 01', '8-909-378-21-90'),
   (3, 'Alister Crouli', '1967-05-12', '456-871-123 76', '8-923-723-54-23');

--select * from Patients 

INSERT Hospital
   (hospital_ID, hospital_name, hospital_address, capacity_beds_count)
VALUES
   (1, 'State hospital for adults', '2-Ya Baumanskaya Ulitsa, h.5,  Moscow, 105005', 200),
   (2, 'State hospital #356', 'Izmailovskij Prospect, h.73/2, Moscow, 105043', 90),
   (3, 'Clinic of plastic surgery', 'Nevskij Prospect, h.18, Moscow, 110983', 300),
   (4, 'Private clinic of brain researches', 'Nahimovskaja Street, h.7, Moscow, 108922', 150);

INSERT Doctors
   (doctor_ID, full_name, data_of_birth, phone_number, years_of_experience, hospital_ID)
VALUES
   (1, 'Doctor Kovalski', '1968.12.26', '8-923-654-76-87', 2, 1),
   (2, 'Doctor Menschikov', '1963.09.13', '8-543-862-23-63', 1, 1),
   (3, 'Doctor Polskij', '1981.04.09', '8-234-667-09-11', 4, 1),
   (4, 'Doctor Kuzmina', '1975.10.19', '8-965-126-12-23', 3, 4),
   (5, 'Doctor Minscij', '1966.02.23', '8-976-110-44-75', 2, 4);

INSERT Appointment
   (appointment_ID, patient_ID, surgical_operation_ID, surgery_time, surgery_lasting_minutes, cabinet_number)
VALUES
   (1, 2, 1, '2019.01.12 13:00:00', 45, 5),
   (2, 3, 2, '2018.12.11 15:30:00', 60, 3),
   (3, 1, 3, '2017.09.10 10:00:00', 30, 120);

UPDATE Appointment SET result = 'Surgery was performed successfully'  WHERE appointment_ID in (2,3)
create nonclustered index my_index on Appointment(surgery_time desc) include (surgery_lasting_minutes)
SELECT a.patient_ID AS patient, a.surgery_time as sur_time FROM Appointment as a where a.surgery_lasting_minutes > 50
DELETE FROM Hospital WHERE hospital_ID = 3
select * from Hospital 

INSERT INTO Connection_surgery_doctor(appointment_ID)   --каждая операция кем-то проводится
	SELECT appointment_ID FROM Appointment
UPDATE Connection_surgery_doctor SET doctor_ID = 4  WHERE appointment_ID = 1
UPDATE Connection_surgery_doctor SET doctor_ID = 3  WHERE appointment_ID = 2
UPDATE Connection_surgery_doctor SET doctor_ID = 1  WHERE appointment_ID = 3

IF OBJECT_ID ('new_view', 'V') IS NOT NULL  
   DROP VIEW new_view;  
GO

CREATE VIEW new_view AS    
select p.patient_ID, p.full_name, s.surgery_type FROM dbo.Patients as p, dbo.Surgical_operation as s
where (select appointment_ID from dbo.Appointment where p.patient_ID=patient_ID) in
      (select appointment_ID from dbo.Appointment where s.surgical_operation_ID=surgical_operation_ID )
GO

SELECT * FROM new_view 
SELECT COUNT(doctor_ID) as how_many_doctors_work_there, hospital_ID FROM Doctors group by hospital_ID 
having  COUNT(doctor_ID) < 3 ORDER BY COUNT(doctor_ID) ASC;     --в каком госпитале нехватка докторов!!! Надо нанимать новых срочно

IF OBJECT_ID ('new_view2', 'V') IS NOT NULL  
   DROP VIEW new_view2;  
GO

CREATE VIEW new_view2 AS   
select a.patient_ID, d.full_name FROM dbo.Appointment as a,dbo.Doctors as d
where (select doctor_ID from dbo.Connection_surgery_doctor where a.appointment_ID=appointment_ID) in
      (select doctor_ID from dbo.Connection_surgery_doctor where d.doctor_ID=doctor_ID) 
GO

SELECT * FROM new_view2

IF OBJECT_ID ('new_view3', 'V') IS NOT NULL  
   DROP VIEW new_view3;  
GO

CREATE VIEW new_view3 AS 
select a.patient_ID, a.full_name as patient, a.surgery_type as surgery, d.full_name as doctor FROM dbo.new_view as a,dbo.new_view2 as d
where a.patient_ID=d.patient_ID
GO

SELECT * FROM new_view3


if OBJECT_ID('dbo.ages', 'FN') is not null
    drop function dbo.ages;
go
create function dbo.ages(@compare_year date)
    returns int
    as
    begin
        declare @retval int
        set @retval = year(getdate())-year(@compare_year)
        return @retval;
    end
go

IF OBJECT_ID ('my_proc', 'P' ) IS NOT null
DROP PROCEDURE my_proc;
GO
CREATE PROCEDURE my_proc as
	select doctor_ID, full_name, dbo.ages(Doctors.data_of_birth) as ages, phone_number from Doctors 
	where dbo.ages(Doctors.data_of_birth)>40                      --врачи, кот-ым больше 40 лет
go
execute my_proc
go

select Doctors.doctor_ID, Doctors.full_name, Doctors.data_of_birth, Hospital.hospital_name from Doctors inner join Hospital
	on Hospital.hospital_ID = Doctors.hospital_ID

SELECT Doctors.doctor_ID, Doctors.full_name
FROM Doctors

union                                                --intersect  выведет одинаковые записи, их нет, а except все записи из 
													 --первой выборки, не включая вторую выборку, в моём случае то же самое как и при union
													 --UNION removes duplicate rows.
                                                     --UNION ALL does not remove duplicate rows.
SELECT Hospital.hospital_ID, Hospital.hospital_name
FROM Hospital

ORDER BY doctor_ID desc;

if OBJECT_ID('dbo.upd_doctor', 'TR') is not null
	drop trigger dbo.upd_doctor
go
create trigger dbo.upd_doctor
	on dbo.Doctors
	instead of update
	as
		if update(doctor_ID)
		begin 
			raiserror( '[UPDATE DOCTORS TRIGGER]: cannot update primary key ', 16, 1)
		end 
		else if update(hospital_ID) begin
		if exists (select hospital_ID from inserted where hospital_ID not in (select hospital_ID from Hospital))
			begin
				RAISERROR('[UPDATE DOCTORS TRIGGER]: reference to parental entry was not found!', 16, 1);
			end
		else
			begin
				update Doctors
				set
				hospital_ID = (select hospital_ID from inserted where inserted.doctor_ID = Doctors.doctor_ID)
				where doctor_ID = (select doctor_ID from inserted where inserted.doctor_ID = Doctors.doctor_ID)
			end
		end
		else
		BEGIN
			update Doctors
				set
				full_name = (select full_name from inserted where inserted.doctor_ID = Doctors.doctor_ID),
				data_of_birth  = (select data_of_birth from inserted where inserted.doctor_ID = Doctors.doctor_ID),
				phone_number = (select phone_number from inserted where inserted.doctor_ID = Doctors.doctor_ID),
				years_of_experience = (select years_of_experience from inserted where inserted.doctor_ID = Doctors.doctor_ID)
				where doctor_ID = (select doctor_ID from inserted where inserted.doctor_ID = Doctors.doctor_ID)
		 END
go

UPDATE Doctors SET full_name = 'doctor kek' WHERE doctor_ID = 2
select * from Doctors 

if OBJECT_ID('dbo.del_doctor', 'TR') is not null
	drop trigger dbo.del_doctor
go
create trigger dbo.del_doctor
	on dbo.Doctors
	instead of delete
	as
		begin
		delete from Connection_surgery_doctor
			where doctor_ID in (select doctor_ID from deleted)
		delete from Doctors
			where doctor_ID in (select doctor_ID from deleted)
		end
go

if OBJECT_ID('ins_doctor', 'TR') is not null
    drop trigger ins_doctor
go
create trigger ins_doctor
	on Doctors
	instead of insert
	as
	begin
		if exists (select hospital_ID from inserted where hospital_ID not in (select hospital_ID from Hospital))
			begin
				RAISERROR('[INSERT DOCTORS TRIGGER]: reference to parental entry was not found!', 16, 1);
			end
		else
			begin
				insert into Doctors 
					select * from inserted
			end
	end
go
select * from Doctors

--insert into Doctors values (1, 'Doctor Kovalski2323', '1968.12.26', '8-923-654-76-87', 2, 3)

--select * from Doctors
--select * from Hospital


if OBJECT_ID('dbo.upd_hospital', 'TR') is not null
	drop trigger dbo.upd_hospital
go
create trigger dbo.upd_hospital
	on dbo.Hospital
	instead of update
	as
		if update(hospital_ID)
		begin 
			raiserror( '[UPDATE HOSPITAL TRIGGER]: cannot update primary key ', 16, 1)
		end 
		else
		BEGIN
			update Hospital
				set 
				hospital_name = (select hospital_name from inserted where inserted.hospital_ID = Hospital.hospital_ID),
				hospital_address  = (select hospital_address from inserted where inserted.hospital_ID = Hospital.hospital_ID),
				capacity_beds_count = (select capacity_beds_count from inserted where inserted.hospital_ID = Hospital.hospital_ID)
				where hospital_ID = (select hospital_ID from inserted where inserted.hospital_ID = Hospital.hospital_ID)
		 END
go

select * from Hospital
UPDATE Hospital SET capacity_beds_count = 3  WHERE hospital_ID = 2
select * from Hospital

if OBJECT_ID('dbo.del_hospital', 'TR') is not null
	drop trigger dbo.del_hospital
go
create trigger dbo.del_hospital
	on dbo.Hospital
	instead of delete
	as
		begin
		delete from Doctors
			where hospital_ID in (select hospital_ID from deleted)
		delete from Hospital where hospital_id in (select hospital_ID from deleted)
		end
go

--delete from Hospital where hospital_ID=1

if OBJECT_ID('dbo.del_patient', 'TR') is not null
	drop trigger dbo.del_patient
go
create trigger dbo.del_patient
	on dbo.Patients
	instead of delete
	as
		begin
		delete from Appointment
			where patient_ID in (select patient_ID from deleted)
		delete from Patients where patient_id in (select patient_ID from deleted)
		end
go

if OBJECT_ID('dbo.del_sur_op', 'TR') is not null
	drop trigger dbo.del_sur_op
go
create trigger dbo.del_sur_op
	on dbo.Surgical_operation
	instead of delete
	as
		begin
		delete from Appointment
			where surgical_operation_ID in (select surgical_operation_ID from deleted)
		delete from Surgical_operation where surgical_operation_ID in (select surgical_operation_ID from deleted)
		end
go

--normal insert for both Surgical_operation and Patients

if OBJECT_ID('dbo.upd_patients', 'TR') is not null
	drop trigger dbo.upd_patients
go
create trigger dbo.upd_patients
	on dbo.Patients
	instead of update
	as
		if update(patient_ID)
		begin 
			raiserror( '[UPDATE PATIENTS TRIGGER]: cannot update primary key', 16, 1)
		end 
		else
		BEGIN
			update Patients
				set 
				full_name = (select full_name from inserted where inserted.patient_ID = Patients.patient_ID),
				data_of_birth  = (select data_of_birth from inserted where inserted.patient_ID = Patients.patient_ID),
				SNILS = (select SNILS from inserted where inserted.patient_ID = Patients.patient_ID),
				phone_number = (select phone_number from inserted where inserted.patient_ID = Patients.patient_ID)
				where patient_ID = (select patient_ID from inserted where inserted.patient_ID = Patients.patient_ID)
		END
go

if OBJECT_ID('dbo.upd_sur_op', 'TR') is not null
	drop trigger dbo.upd_sur_op
go
create trigger dbo.upd_sur_op
	on dbo.Surgical_operation
	instead of update
	as
		if update(surgical_operation_ID) or update(surgery_type)
		begin 
			raiserror( '[UPDATE SURGICAL_OPERATION TRIGGER]: cannot update primary key or unique value ', 16, 1)
		end 
		else
		BEGIN
			update Surgical_operation
				set 
				surgeries_per_month = (select surgeries_per_month from inserted where inserted.surgical_operation_ID = Surgical_operation.surgical_operation_ID),
				contraindications  = (select contraindications from inserted where inserted.surgical_operation_ID = Surgical_operation.surgical_operation_ID),
				success_surgeries_per_month  = (select success_surgeries_per_month from inserted where inserted.surgical_operation_ID = Surgical_operation.surgical_operation_ID)
				where surgical_operation_ID = (select surgical_operation_ID from inserted where inserted.surgical_operation_ID = Surgical_operation.surgical_operation_ID)
 END
go
select * from Surgical_operation
UPDATE Surgical_operation SET surgeries_per_month = 80  WHERE surgical_operation_ID = 2
select * from Surgical_operation

if OBJECT_ID('ins_appointment', 'TR') is not null
    drop trigger ins_appointment
go
create trigger ins_appointment
	on Appointment
	instead of insert
	as
	begin
		if exists (select appointment_ID from inserted where patient_ID not in (select patient_ID from Appointment))
			begin
				RAISERROR('[INSERT APPOINTMENT1 TRIGGER]: reference to parental entry in Patients was not found!', 16, 1);
			end
		else if exists (select appointment_ID from inserted where surgical_operation_ID not in (select surgical_operation_ID from Appointment))
			begin
				RAISERROR('[INSERT APPOINTMENT2 TRIGGER]: reference to parental entry in Surgical_operation was not found!', 16, 1);
			end
		else
			begin
				insert into Appointment 
					select * from inserted
			end
	end
go

if OBJECT_ID('dbo.del_appointment', 'TR') is not null
	drop trigger dbo.del_appointment
go
create trigger dbo.del_appointment
	on dbo.Appointment
	instead of delete
	as
		begin
		delete from Connection_surgery_doctor
			where appointment_ID in (select appointment_ID from deleted)
		delete from Appointment where appointment_ID in (select appointment_ID from deleted)
		end
go

if OBJECT_ID('dbo.upd_appointment', 'TR') is not null
	drop trigger dbo.upd_appointment
go
create trigger dbo.upd_appointment
	on dbo.Appointment
	instead of update
	as
		if update(appointment_ID)
			begin 
				raiserror( '[UPDATE APPOINTMENT TRIGGER]: cannot update primary key ', 16, 1)
			end 
		else if update(surgical_operation_ID) 
		begin
		if exists (select surgical_operation_ID from inserted where surgical_operation_ID not in (select surgical_operation_ID from Surgical_operation))
			begin
				RAISERROR('[UPDATE1 APPOINTMENT TRIGGER]: reference to parental entry in Surgery_operation was not found!', 16, 1);
			end else
			begin
				update Appointment
				set
				surgical_operation_ID = (select surgical_operation_ID from inserted where inserted.appointment_ID = Appointment.appointment_ID)
				where appointment_ID = (select appointment_ID from inserted where inserted.appointment_ID = Appointment.appointment_ID)
			end
		end
		else if update(patient_ID)
		begin
		if exists (select patient_ID from inserted where patient_ID not in (select patient_ID from Patients))
			begin
				RAISERROR('[UPDATE2 APPOINTMENT TRIGGER]: reference to parental entry in Patients was not found!', 16, 1);
			end else
			begin
				update Appointment
				set
				patient_ID = (select patient_ID from inserted where inserted.appointment_ID = Appointment.appointment_ID)
				where appointment_ID = (select appointment_ID from inserted where inserted.appointment_ID = Appointment.appointment_ID)
			end
		end
		else
			begin
				update Appointment
				set
				surgery_time = (select surgery_time from inserted where inserted.appointment_ID = Appointment.appointment_ID),
				cabinet_number = (select cabinet_number from inserted where inserted.appointment_ID = Appointment.appointment_ID),
				surgery_lasting_minutes = (select surgery_lasting_minutes from inserted where inserted.appointment_ID = Appointment.appointment_ID),
				result = (select result from inserted where inserted.appointment_ID = Appointment.appointment_ID)
				where appointment_ID = (select appointment_ID from inserted where inserted.appointment_ID = Appointment.appointment_ID)
			end
go

--select * from Appointment
--UPDATE Appointment SET patient_ID = 2  WHERE surgical_operation_ID = 2
--select * from Appointment

--simple delete for Connection

if OBJECT_ID('dbo.upd_connection', 'TR') is not null
	drop trigger dbo.upd_connection
go
create trigger dbo.upd_connection
	on dbo.Connection_surgery_doctor
	instead of update
	as
	if update(appointment_ID) 
		begin
		if exists (select appointment_ID from inserted where appointment_ID not in (select appointment_ID from Appointment))
			begin
				RAISERROR('[UPDATE1 CONNECTION TRIGGER]: reference to parental entry in Appointment was not found!', 16, 1);
			end else
			begin
				update Connection_surgery_doctor
				set
				appointment_ID = (select appointment_ID from inserted where inserted.appointment_ID = Connection_surgery_doctor.appointment_ID)
			end
		end
		else if update(doctor_ID)
		begin
		if exists (select doctor_ID from inserted where doctor_ID not in (select doctor_ID from Doctors))
			begin
				RAISERROR('[UPDATE2 CONNECTION TRIGGER]: reference to parental entry in Doctors was not found!', 16, 1);
			end else
			begin
				update Connection_surgery_doctor
				set
				doctor_ID = (select doctor_ID from inserted where inserted.appointment_ID = Connection_surgery_doctor.appointment_ID)
			end
		end
go

select * from Doctors
select * from Connection_surgery_doctor
--UPDATE Connection_surgery_doctor SET doctor_ID = 7  WHERE doctor_ID = 3
select * from Connection_surgery_doctor

if OBJECT_ID('dbo.ins_connection', 'TR') is not null
	drop trigger dbo.ins_connection
go
create trigger dbo.ins_connection
	on dbo.Connection_surgery_doctor
	instead of insert
	as
	begin
		if exists (select appointment_ID from inserted where appointment_ID not in (select appointment_ID from Appointment))
			begin
				RAISERROR('[INSERT CONNECTION1 TRIGGER]: reference to parental entry in Appointment was not found!', 16, 1);
			end
		else if exists (select doctor_ID from inserted where doctor_ID not in (select doctor_ID from Doctors))
			begin
				RAISERROR('[INSERT CONNECTION2 TRIGGER]: reference to parental entry in Doctors was not found!', 16, 1);
			end
		else
			begin
				insert into Connection_surgery_doctor 
					select * from inserted
			end
	end
go

select * from Appointment
select * from Doctors
select * from Connection_surgery_doctor
insert into Connection_surgery_doctor values (1, 567)
select * from Connection_surgery_doctor

--The LEFT JOIN keyword returns all records from the left table (table1), 
--and the matched records from the right table (table2). The result is NULL from the right side, if there is no match.

--(INNER) JOIN: Returns records that have matching values in both tables
--LEFT (OUTER) JOIN: Return all records from the left table, and the matched records from the right table
--RIGHT (OUTER) JOIN: Return all records from the right table, and the matched records from the left table
--FULL (OUTER) JOIN: Return all records when there is a match in either left or right table























