
CREATE ROLE [Client] AUTHORIZATION [db_owner]; 
GRANT SELECT ON Models TO [Client];
GRANT SELECT ON Equipments TO [Client];
GRANT SELECT ON Engines TO [Client];
GRANT SELECT, INSERT, UPDATE ON Cars TO [Client];
GRANT INSERT, UPDATE, DELETE ON CustomerOrders TO [Client];

CREATE ROLE [Employee] AUTHORIZATION [db_owner]; 
GRANT SELECT, INSERT, DELETE, UPDATE ON Models TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON Equipments TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON Engines TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON Cars TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON CustomerOrders TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON CarFromTheClient TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON GuaranteeCases TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON Sales TO [Employee];
GRANT SELECT ON Producers TO [Employee];
GRANT SELECT ON Employees TO [Employee];
GRANT SELECT, INSERT, DELETE, UPDATE ON Clients TO [Employee];

CREATE ROLE [Admin] AUTHORIZATION [db_owner]; 
GRANT SELECT, INSERT, DELETE, UPDATE ON Models TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Equipments TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Engines TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Cars TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON CustomerOrders TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON CarFromTheClient TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON GuaranteeCases TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Sales TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Producers TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Employees TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON EmployeeCompensations TO [Admin];
GRANT SELECT, INSERT, DELETE, UPDATE ON Clients TO [Admin];

CREATE LOGIN [Client_log]  
    WITH PASSWORD = 'qwerty1!';  

CREATE USER [clientdb] FOR LOGIN [Client_log]   
    WITH DEFAULT_SCHEMA = [Client_log];

ALTER ROLE [Client] ADD MEMBER [clientdb];


CREATE LOGIN [Employee]  
    WITH PASSWORD = 'qwerty1!';  

CREATE USER [employeedb] FOR LOGIN [Employee]   
    WITH DEFAULT_SCHEMA = [Employee];

ALTER ROLE [Employee] ADD MEMBER [employeedb];


CREATE LOGIN [Admin]  
    WITH PASSWORD = 'qwerty1!';  

CREATE USER [admindb] FOR LOGIN [Admin]   
    WITH DEFAULT_SCHEMA = [Admin];

ALTER ROLE [Admin] ADD MEMBER [admindb];