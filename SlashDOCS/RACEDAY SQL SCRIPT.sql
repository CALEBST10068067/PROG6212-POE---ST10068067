IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    CREATE DATABASE RaceDayDB;
END;
GO

USE RaceDayDB;
GO

SELECT DB_NAME() AS CurrentDatabase;
GO

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'Racers';
GO

CREATE TABLE dbo.Roles (
    RoleID INT IDENTITY(1,1) NOT NULL,
    RoleName VARCHAR(50) NOT NULL,
    Description NVARCHAR(250) NULL,
    CONSTRAINT PK_Roles PRIMARY KEY CLUSTERED (RoleID),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);
GO

CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    RoleID INT NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID)
);
GO

CREATE TABLE dbo.Events (
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Date DATETIME2 NOT NULL,
    Location NVARCHAR(150) NOT NULL,
    Distance DECIMAL(6,2) NOT NULL,
    EventType VARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Events PRIMARY KEY CLUSTERED (EventID),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserID) REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
    CONSTRAINT CK_Events_Distance CHECK (Distance > 0)
);
GO

CREATE TABLE dbo.EventCategories (
    CategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    CategoryType VARCHAR(50) NOT NULL,
    CONSTRAINT PK_EventCategories PRIMARY KEY CLUSTERED (CategoryID),
    CONSTRAINT FK_EventCategories_Events FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.EventEnrollments (
    EnrollmentID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    ParticipantID INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_EventEnrollments PRIMARY KEY CLUSTERED (EnrollmentID),
    CONSTRAINT FK_EventEnrollments_Events FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID),
    CONSTRAINT FK_EventEnrollments_EventCategories FOREIGN KEY (CategoryID) REFERENCES dbo.EventCategories(CategoryID) ON DELETE CASCADE,
    CONSTRAINT FK_EventEnrollments_Users FOREIGN KEY (ParticipantID) REFERENCES dbo.Users(UserID),
    CONSTRAINT UQ_Enrollments_Event_Participant UNIQUE (EventID, ParticipantID)
);
GO

CREATE TABLE dbo.Results (
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrollmentID INT NOT NULL,
    FinishTime TIME(0) NOT NULL,
    Position INT NOT NULL,
    RecordedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT PK_Results PRIMARY KEY CLUSTERED (ResultID),
    CONSTRAINT FK_Results_EventEnrollments FOREIGN KEY (EnrollmentID) REFERENCES dbo.EventEnrollments(EnrollmentID) ON DELETE CASCADE,
    CONSTRAINT UQ_Results_EnrollmentID UNIQUE (EnrollmentID),
    CONSTRAINT CK_Results_Position CHECK (Position > 0)
);
GO

INSERT INTO dbo.Roles (RoleName, Description)
VALUES 
    ('Organiser', 'Event organiser with event management permissions'),
    ('Participant', 'Event participant');
GO

INSERT INTO dbo.Users (RoleID, Email, PasswordHash)
VALUES 
    (1, 'sipho.organiser@raceday.co.za', '$2a$11$DummyHashedPasswordSipho12345678901234567890'),
    (1, 'cheryl.events@raceday.co.za',   '$2a$11$DummyHashedPasswordCheryl123456789012345678'),
    (2, 'caleb.runner@testmail.co.za',   '$2a$11$DummyHashedPasswordCaleb1234567890123456789'),
    (2, 'thabo.cyclist@testmail.co.za',  '$2a$11$DummyHashedPasswordThabo1234567890123456789');
GO

INSERT INTO dbo.Events (OrganiserID, Name, Description, Date, Location, Distance, EventType)
VALUES 
    (1, 'Comrades Marathon', 'Durban to Pietermaritzburg ultramarathon.', '2027-06-13 05:30:00', 'Durban to Pietermaritzburg, KZN', 89.00, 'Run'),
    (1, 'Cape Town Cycle Tour', 'Scenic cycling race around the peninsula.', '2027-03-14 06:00:00', 'Cape Town, Western Cape', 109.00, 'Cycle'),
    (2, 'Soweto Marathon', 'Annual road marathon through Soweto.', '2026-11-01 06:00:00', 'Soweto, Gauteng', 42.20, 'Run');
GO

INSERT INTO dbo.EventCategories (EventID, Name, CategoryType)
VALUES 
    (1, 'Open Senior Men & Women', 'Age'),
    (1, 'Veterans 40-49', 'Age'),
    (2, 'Standard 109km Road Race', 'Distance'),
    (2, 'Short 42km Route', 'Distance'),
    (3, '42.2km Full Marathon', 'Distance'),
    (3, '21.1km Half Marathon', 'Distance'),
    (3, '10km Road Run & Walk', 'Distance');
GO

INSERT INTO dbo.EventEnrollments (EventID, CategoryID, ParticipantID)
VALUES 
    (3, 5, 3),
    (3, 5, 4),
    (2, 3, 3);
GO

INSERT INTO dbo.Results (EnrollmentID, FinishTime, Position)
VALUES 
    (1, '03:42:15', 142),
    (2, '04:10:02', 489);
GO



-- Table 1: Roles
SELECT RoleID, RoleName, Description 
FROM dbo.Roles;
GO

-- Table 2: Users
SELECT UserID, RoleID, Email, PasswordHash, CreatedAt 
FROM dbo.Users;
GO

-- Table 3: Events
SELECT EventID, OrganiserID, Name, Description, Date, Location, Distance, EventType, CreatedAt 
FROM dbo.Events;
GO

-- Table 4: EventCategories
SELECT CategoryID, EventID, Name, CategoryType 
FROM dbo.EventCategories;
GO

-- Table 5: EventEnrollments
SELECT EnrollmentID, EventID, CategoryID, ParticipantID, EnrolmentDate 
FROM dbo.EventEnrollments;
GO

-- Table 6: Results
SELECT ResultID, EnrollmentID, FinishTime, Position, RecordedAt 
FROM dbo.Results;
GO