-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Dec 05, 2017 at 05:06 PM
-- Server version: 5.5.57-0ubuntu0.14.04.1
-- PHP Version: 5.5.9-1ubuntu4.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `Sprint4`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`sdilly`@`%` PROCEDURE `AddFeatureToCar`(IN `vin` INT(20), IN `feature` INT(100))
    SQL SECURITY INVOKER
BEGIN

INSERT INTO `Car_Features`(`VIN`, `feature_id`) VALUES (vin,feature);

END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `AddInventory`(IN `makename` VARCHAR(20), IN `modelname` VARCHAR(20), IN `vin` INT(20), IN `carcondition` ENUM('New','Used'), IN `miles` DECIMAL(10), IN `addedby` INT(20), IN `time` DATETIME, IN `cardescription` VARCHAR(10), IN `carprice` INT(20))
    SQL SECURITY INVOKER
BEGIN

IF Exists(Select * from MakeModel where MakeModel.model_name=modelname) Then

INSERT INTO `Car_Detail`(`Vehicle_Identification_Number`, `YEAR`, `Model`, `Mileage`, `Car_condition`, `Added_by`) 
VALUES (vin,time,modelname,miles,carcondition,addedby);
INSERT INTO `Inventory`(`Vehicle_Identification_Number`, `Price`, `Description`) 
VALUES (vin,carprice,cardescription);

Else


INSERT INTO `MakeModel`(`model_name`, `make_name`) VALUES (modelname,makename);
INSERT INTO `Car_Detail`(`Vehicle_Identification_Number`, `YEAR`, `Model`, `Mileage`, `Car_condition`, `Added_by`) 
VALUES (vin,time,modelname,miles,carcondition,addedby);
INSERT INTO `Inventory`(`Vehicle_Identification_Number`, `Price`, `Description`) 
VALUES (vin,carprice,cardescription);

end if;

END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `AddInvMan`(IN `first` VARCHAR(20), IN `mid` VARCHAR(20), IN `last` VARCHAR(20), IN `sal` INT(100), IN `social` VARCHAR(100), IN `ema` VARCHAR(20), IN `hpw` INT(10), IN `comm` INT(10))
    SQL SECURITY INVOKER
BEGIN

Select @num := (MAX(Emp_id) + 1) From Employee;
INSERT INTO `Employee`(`Emp_id`, `First_Name`, `Middle_Name`, `Last_Name`, `Email`, `SSN`, `Salary`, `Hours_per_week`) VALUES (@num,first,mid,last,ema,social,sal,hpw);

Insert into Inventory_Manager(commission_percentage,inventory_manager_id,Reports_to)
Values (comm,@num,1);

END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `AddSalesman`(IN `first` VARCHAR(20), IN `mid` VARCHAR(20), IN `last` VARCHAR(20), IN `sal` INT(100), IN `social` VARCHAR(100), IN `ema` VARCHAR(20), IN `hpw` INT(10), IN `comm` INT(10), IN `rep` INT(10))
    SQL SECURITY INVOKER
BEGIN

Select @num := (MAX(Emp_id) + 1) From Employee;
INSERT INTO `Employee`(`Emp_id`, `First_Name`, `Middle_Name`, `Last_Name`, `Email`, `SSN`, `Salary`, `Hours_per_week`) VALUES (@num,first,mid,last,ema,social,sal,hpw);

Insert into Salesman(commission_percentage,salesman_id,Reports_to)
Values (comm,@num,rep);

END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `AddServiceMan`(IN `first` VARCHAR(20), IN `mid` VARCHAR(20), IN `last` VARCHAR(20), IN `sal` INT(100), IN `social` VARCHAR(100), IN `ema` VARCHAR(20), IN `hpw` INT(10), IN `reports` INT(10))
    SQL SECURITY INVOKER
BEGIN

Select @num := (MAX(Emp_id) + 1) From Employee;
INSERT INTO `Employee`(`Emp_id`, `First_Name`, `Middle_Name`, `Last_Name`, `Email`, `SSN`, `Salary`, `Hours_per_week`) VALUES (@num,first,mid,last,ema,social,sal,hpw);

Insert into Serviceman(serviceman_id,Reports_to)
Values (@num,reports);

END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `AddServManager`(IN `first` VARCHAR(20), IN `mid` VARCHAR(20), IN `last` VARCHAR(20), IN `sal` INT(100), IN `social` VARCHAR(100), IN `ema` VARCHAR(20), IN `hpw` INT(10))
    SQL SECURITY INVOKER
BEGIN

Select @num := (MAX(Emp_id) + 1) From Employee;
INSERT INTO `Employee`(`Emp_id`, `First_Name`, `Middle_Name`, `Last_Name`, `Email`, `SSN`, `Salary`, `Hours_per_week`) VALUES (@num,first,mid,last,ema,social,sal,hpw);

Insert into Service_Manager(service_manager_id,Reports_to)
Values (@num,1);

END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `BuyCar`(IN `car_vin` INT(100), IN `cust_id` INT(10), IN `pricesold` INT(20), IN `selldate` DATE, IN `salesman_id` INT(100))
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
	DECLARE price1 INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	Begin
	Show errors;
	End;


	Select `Price` into price1 from `Inventory` where `Vehicle_Identification_Number` = car_vin;
    
    IF pricesold <= price1 then
    Delete from `Car_Features` Where `VIN`=car_vin;
    Delete from `Inventory` Where `Vehicle_Identification_Number` = car_vin;
    Insert into `Car_sold`(`Vehicle_Identification_Number`, `Price_sold`, `Sold_on`, `Sold_by`, `Customer_id`) 
	VALUES (car_vin,pricesold,selldate,salesman_id,cust_id);
    END IF;
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `FireEmployee`(IN `empid` INT(20))
    SQL SECURITY INVOKER
BEGIN

Update Employee e
set Status = 'Fired'
Where e.Emp_id=empid;


END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `GetCarServiceHistory`(IN `car_vin` INT(100))
    SQL SECURITY INVOKER
BEGIN
	Select Invoice_ID as InvoiceNumber, concat(Year(YEAR),' ',m.make_name,' ',cd.Model) as Car, s.service_name as Service, Price, Service_Date, Concat(First_Name,' ',Last_Name) as 	Serviceman from Service_History	
Inner Join Employee e on e.Emp_id=Service_History.Serviced_by
Inner Join Service_List s on s.service_id=Service_History.service_id
Inner Join Car_Detail cd on cd.Vehicle_Identification_Number= Service_History.Vehicle_Identification_Number
Left Join MakeModel m on m.model_name=cd.Model
Where Service_History.Vehicle_Identification_Number = car_vin;
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `GetCarSoldInfo`(IN `car_vin` INT(20))
    SQL SECURITY INVOKER
BEGIN
  SELECT m.make_name as Make,Model,Price_sold,Concat(e.First_name, ' ',e.Last_name) as Salesman,Sold_on,Concat(c.First_Name,' ',c.Last_Name) as Customer FROM Car_sold
	Inner join Car_Detail on Car_Detail.Vehicle_Identification_Number=Car_sold.Vehicle_Identification_Number
	Inner join Employee e on e.Emp_id=Car_sold.Sold_by
	Inner join Customer c on c.customer_id=Car_sold.Customer_id
	Left Join MakeModel m on m.model_name=Car_Detail.Model
	Where Car_sold.Vehicle_Identification_Number = car_vin;
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `GetCustomerPurchaseHistory`(IN `cust_id` INT(20))
    SQL SECURITY INVOKER
BEGIN
  SELECT m.make_name as Make,Model,Price_sold,Concat(e.First_name, ' ',e.Last_name) as Salesman,Sold_on,Concat(c.First_Name,' ',c.Last_Name) as Customer FROM Car_sold
	Inner join Car_Detail on Car_Detail.Vehicle_Identification_Number=Car_sold.Vehicle_Identification_Number
	Inner join Employee e on e.Emp_id=Car_sold.Sold_by
	Inner join Customer c on c.customer_id=Car_sold.Customer_id
	Left join MakeModel m on m.model_name=Car_Detail.Model
	Where Car_sold.Customer_id = cust_id;
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `GetCustomerServiceHistory`(IN `cust_id` INT(10))
    SQL SECURITY INVOKER
BEGIN
Select Invoice_ID as InvoiceNumber, concat(Year(YEAR),' ',m.make_name,' ',cd.Model) as Car, s.service_name as Service, Price, Service_Date, Concat(First_Name,' ',Last_Name) as Serviceman from Service_History						 
Inner Join Employee e on e.Emp_id=Service_History.Serviced_by
Inner Join Service_List s on s.service_id=Service_History.service_id
Inner Join Car_Detail cd on cd.Vehicle_Identification_Number= Service_History.Vehicle_Identification_Number
Left Join MakeModel m on m.model_name=cd.Model
Where Customer_id = cust_id;
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `GetSpecificInventory`(IN `car_vin` INT(20))
    SQL SECURITY INVOKER
BEGIN
   SELECT YEAR,m.make_name as Make,Model,Description,Price,Added_by FROM Inventory
	Inner join Car_Detail on 	Car_Detail.Vehicle_Identification_Number=Inventory.Vehicle_Identification_Number
	Left join MakeModel m on m.model_name=Car_Detail.Model
	Where Inventory.Vehicle_Identification_Number = car_vin;
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `RegisterCustomer`(IN `first` VARCHAR(50), IN `mid` VARCHAR(50), IN `last` VARCHAR(50), IN `em` VARCHAR(50), IN `a1` VARCHAR(100), IN `a2` VARCHAR(100), IN `ci` VARCHAR(50), IN `st` VARCHAR(50), IN `zi` VARCHAR(20))
    NO SQL
    SQL SECURITY INVOKER
BEGIN
  	INSERT INTO `Customer`(`First_Name`, `Middle_Name`, `Last_Name`, `Email`, `Addr_Line1`, `Addr_Line2`, `City`, `State`, `ZIP`) VALUES 
	(first,mid,last,em,a1,a2,ci,st,zi);
    
END$$

CREATE DEFINER=`sdilly`@`%` PROCEDURE `UpdateServiceHistory`(IN `car_vin` INT(11), IN `date` DATE, IN `cost` DECIMAL(20,0), IN `servicedby` INT(20), IN `serviceid` INT(10), IN `cust_id` INT(10))
    SQL SECURITY INVOKER
BEGIN

INSERT INTO Service_History(`Vehicle_Identification_Number`, `Service_Date`, `Price`, `Serviced_by`, `service_id`, `Customer_id`) 
VALUES 
(car_vin,date,cost,servicedby,serviceid,cust_id);
 
END$$

--
-- Functions
--
CREATE DEFINER=`sdilly`@`%` FUNCTION `calculateCommission`(`salesmanid` INT(100), `price_sold` INT(20)) RETURNS decimal(24,4)
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
	DECLARE commission_percent Decimal(4,2);
	DECLARE commission1 DECIMAL(24,4);
	set commission1 = 0;
	set commission_percent = 0;
	select `commission_percentage` into commission_percent from `Salesman` where `salesman_id` = salesmanid;
	select `commission` into commission1 from Commission_Earned where `salesman_id` =  salesmanid;
	set commission1=commission_percent*price_sold;
	RETURN (commission1/100);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Car_Detail`
--

CREATE TABLE IF NOT EXISTS `Car_Detail` (
  `Vehicle_Identification_Number` int(20) NOT NULL,
  `YEAR` date NOT NULL,
  `Model` varchar(20) DEFAULT NULL,
  `Mileage` decimal(9,2) DEFAULT NULL,
  `Car_condition` enum('New','Used') NOT NULL,
  `Added_by` int(100) NOT NULL,
  PRIMARY KEY (`Vehicle_Identification_Number`),
  UNIQUE KEY `Vehicle_Identification_Number` (`Vehicle_Identification_Number`),
  KEY `fk_car` (`Added_by`),
  KEY `Car_Condition` (`Car_condition`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Car_Detail`
--

INSERT INTO `Car_Detail` (`Vehicle_Identification_Number`, `YEAR`, `Model`, `Mileage`, `Car_condition`, `Added_by`) VALUES
(1, '2018-01-01', 'i8', '0.00', 'New', 2),
(2, '2017-01-01', 'AMG-GT', '0.00', 'New', 4),
(3, '2016-01-01', 'RS5', '0.00', 'New', 3),
(4, '2015-01-01', 'Granturismo', '0.00', 'New', 4),
(5, '2017-01-01', 'Escalade', '0.00', 'New', 3),
(6, '2018-01-01', '750i xDrive', '0.00', 'New', 3),
(7, '2016-01-01', '325ci', '25000.00', 'Used', 3),
(8, '2012-01-01', 'A7', '125000.00', 'Used', 3),
(9, '2010-01-01', '911', '103345.00', 'Used', 2),
(10, '2017-01-01', '911', '0.00', 'New', 4),
(11, '2013-01-01', 'Santa Fe', '45567.00', 'Used', 2),
(12, '2017-01-01', 'Model X 100D', '0.00', 'New', 2),
(13, '2015-01-01', 'Model S 70D', '41938.00', 'Used', 4),
(14, '1997-01-01', 'Corvette', '76812.00', 'Used', 4),
(15, '2017-01-01', 'Model 3', '0.00', 'New', 2),
(16, '1958-01-01', 'California', '103345.00', 'Used', 2),
(17, '1923-01-01', 'Model J', '165000.00', 'Used', 4),
(34, '2017-12-01', 'GL-450', '0.00', 'New', 2),
(76, '2017-12-05', 'x5', '0.00', 'New', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Car_Features`
--

CREATE TABLE IF NOT EXISTS `Car_Features` (
  `VIN` int(20) NOT NULL,
  `feature_id` int(100) NOT NULL,
  PRIMARY KEY (`VIN`,`feature_id`),
  UNIQUE KEY `VIN_FID` (`VIN`,`feature_id`),
  KEY `carf_f2_fid` (`feature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Car_Features`
--

INSERT INTO `Car_Features` (`VIN`, `feature_id`) VALUES
(10, 1),
(34, 1),
(17, 10),
(16, 11),
(10, 12),
(16, 13),
(17, 14);

-- --------------------------------------------------------

--
-- Table structure for table `Car_sold`
--

CREATE TABLE IF NOT EXISTS `Car_sold` (
  `Vehicle_Identification_Number` int(100) NOT NULL,
  `Price_sold` int(20) NOT NULL,
  `Sold_on` date NOT NULL,
  `Sold_by` int(100) NOT NULL,
  `Customer_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`Vehicle_Identification_Number`),
  UNIQUE KEY `Vehicle_Identification_Number` (`Vehicle_Identification_Number`),
  KEY `fk_cust_num` (`Customer_id`),
  KEY `FK_salesman` (`Sold_by`),
  KEY `SoldBy_CustomerId` (`Sold_by`,`Customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Car_sold`
--

INSERT INTO `Car_sold` (`Vehicle_Identification_Number`, `Price_sold`, `Sold_on`, `Sold_by`, `Customer_id`) VALUES
(1, 199999, '2017-11-17', 15, 9),
(2, 1000, '2017-12-25', 15, 2),
(3, 1000, '2017-12-25', 15, 3),
(4, 10000, '2017-12-05', 14, 1),
(6, 1000, '2017-12-08', 15, 2),
(7, 16500, '2016-12-19', 14, 1),
(8, 23405, '2017-11-01', 14, 7),
(9, 21304, '2016-02-12', 15, 6),
(11, 9999, '2015-09-18', 15, 2),
(12, 114000, '2017-04-01', 16, 3),
(13, 38952, '2017-10-20', 16, 4),
(14, 12999, '2010-08-11', 17, 5),
(15, 37875, '2017-11-01', 18, 7);

--
-- Triggers `Car_sold`
--
DROP TRIGGER IF EXISTS `afterCarSold`;
DELIMITER //
CREATE TRIGGER `afterCarSold` AFTER INSERT ON `Car_sold`
 FOR EACH ROW BEGIN
Declare commision Decimal(24,4);
Declare curCom Decimal(24,4);
select (calculateCommission( NEW.Sold_by,NEW.Price_sold)) into commision from dual;
select Commission_Earned.commission into curCom from Commission_Earned where Commission_Earned.salesman_id=NEW.Sold_by;

IF curCom is not null Then
Update Commission_Earned 
Set Commission_Earned.commission=curCom+commision
Where salesman_id=NEW.Sold_by;
Else
insert into `Commission_Earned`(`commission`,`salesman_id`) values (commision, NEW.Sold_by);
END if;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Commission_Earned`
--

CREATE TABLE IF NOT EXISTS `Commission_Earned` (
  `salesman_id` int(100) NOT NULL DEFAULT '0',
  `commission` decimal(24,4) DEFAULT '0.0000',
  PRIMARY KEY (`salesman_id`),
  UNIQUE KEY `SaleManId` (`salesman_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Commission_Earned`
--

INSERT INTO `Commission_Earned` (`salesman_id`, `commission`) VALUES
(14, '510.0000'),
(15, '100.0000');

-- --------------------------------------------------------

--
-- Table structure for table `Customer`
--

CREATE TABLE IF NOT EXISTS `Customer` (
  `customer_id` int(100) NOT NULL AUTO_INCREMENT,
  `First_Name` varchar(50) NOT NULL,
  `Middle_Name` varchar(50) DEFAULT NULL,
  `Last_Name` varchar(50) NOT NULL,
  `Email` varchar(50) NOT NULL,
  `Addr_Line1` varchar(100) NOT NULL,
  `Addr_Line2` varchar(100) DEFAULT NULL,
  `City` varchar(50) NOT NULL,
  `State` varchar(50) NOT NULL,
  `ZIP` varchar(20) NOT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `CustId` (`customer_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

--
-- Dumping data for table `Customer`
--

INSERT INTO `Customer` (`customer_id`, `First_Name`, `Middle_Name`, `Last_Name`, `Email`, `Addr_Line1`, `Addr_Line2`, `City`, `State`, `ZIP`) VALUES
(1, 'Jon', NULL, 'Beason', 'jb@gmail.com', '5017 Darby Chase', NULL, 'Charlotte', 'NC', '28277'),
(2, 'Mike', NULL, 'Adams', 'mike@gmail.com', '12135 Darby Chase', NULL, 'Charlotte', 'NC', '28277'),
(3, 'Sean', NULL, 'Tupp', 'sup@yahoo.com', '501 Petunia Dr', NULL, 'Charlotte', 'NC', '28210'),
(4, 'Jason', NULL, 'Marx', 'jason@yahoo.com', '301 N Tryon St', NULL, 'Charlotte', 'NC', '28110'),
(5, 'Alex', 'Richard', 'Pink', 'ap@yahoo.com', '110 Orchard Dr', NULL, 'Waxhaw', 'NC', '28203'),
(6, 'Michael', NULL, 'Norse', 'michaelnorse@yahoo.com', '5017 Munich Dr', NULL, 'Greenville', 'SC', '28216'),
(7, 'Rich', NULL, 'Door', 'rd@yahoo.com', '10234 Outpost Dr', NULL, 'Matthews', 'NC', '28211'),
(9, 'Sharat', 'C', 'Vyas', 'svyas7@uncc.edu', '10837 Oxford St', NULL, 'Charlotte', 'NC', '28194');

-- --------------------------------------------------------

--
-- Table structure for table `Dealership_Manager`
--

CREATE TABLE IF NOT EXISTS `Dealership_Manager` (
  `dealership_manager_id` int(100) NOT NULL,
  `start_date` date NOT NULL,
  PRIMARY KEY (`dealership_manager_id`),
  UNIQUE KEY `DealMan_Id` (`dealership_manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Dealership_Manager`
--

INSERT INTO `Dealership_Manager` (`dealership_manager_id`, `start_date`) VALUES
(1, '2017-11-14');

-- --------------------------------------------------------

--
-- Table structure for table `Employee`
--

CREATE TABLE IF NOT EXISTS `Employee` (
  `Emp_id` int(100) NOT NULL AUTO_INCREMENT,
  `First_Name` varchar(50) NOT NULL,
  `Middle_Name` varchar(50) DEFAULT NULL,
  `Last_Name` varchar(50) NOT NULL,
  `Email` varchar(50) NOT NULL,
  `SSN` varchar(20) NOT NULL,
  `Salary` int(20) DEFAULT NULL,
  `Hours_per_week` int(10) DEFAULT NULL,
  `Status` enum('Working','Fired') DEFAULT 'Working',
  PRIMARY KEY (`Emp_id`),
  UNIQUE KEY `Emp_Id` (`Emp_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

--
-- Dumping data for table `Employee`
--

INSERT INTO `Employee` (`Emp_id`, `First_Name`, `Middle_Name`, `Last_Name`, `Email`, `SSN`, `Salary`, `Hours_per_week`, `Status`) VALUES
(1, 'Michael', 'Duke', 'Scott', 'michaelscott@cars.com', '123456789', 50000, 40, 'Working'),
(2, 'Cameron', 'Jerrell', 'Newton', 'cameronnewton@cars.com', '132465798', 42000, 45, 'Working'),
(3, 'Jack', 'Sean', 'Dorsett', 'jackdorsett@cars.com', '963258741', 28000, 40, 'Working'),
(4, 'Peter', 'Mac', 'Jackson', 'peterjackson@cars.com', '987654321', 35000, 40, 'Working'),
(5, 'David', 'Sean', 'Harris', 'davidharris@cars.com', '1092837456', 31000, 40, 'Working'),
(6, 'Han', 'Andy', 'Zhang', 'hanzhang@cars.com', '1056924738', 46000, 40, 'Working'),
(7, 'Luke', 'Matthew', 'Kuechly', 'lukekuechly@cars.com', '6574839201', 40000, 45, 'Working'),
(8, 'Michael', 'Jim', 'Smith', 'michaelsmith@cars.com', '84769876', 36700, 40, 'Working'),
(9, 'Todd', 'Dob', 'Vez', 'toddvez@cars.com', '11119956', 28960, 35, 'Working'),
(10, 'Ben', 'Sean', 'Stone', 'benstone@cars.com', '54250172', 33000, 40, 'Working'),
(11, 'Sean', 'Nick', 'Toon', 'seantoon@cars.com', '12135012', 35000, 40, 'Working'),
(12, 'Mike', 'Dean', 'Ditka', 'mikeditka@cars.com', '19736874', 38000, 45, 'Working'),
(13, 'Marty', 'McFly', 'Williams', 'martywilliams@cars.com', '19687201', 40000, 45, 'Working'),
(14, 'Thomas', 'Peter', 'Davis', 'thomasdavis@cars.com', '48979875', 40000, 40, 'Working'),
(15, 'Kawann', 'Warwick', 'Short', 'kawannshort@cars.com', '48960986', 38000, 40, 'Working'),
(16, 'Kurt', 'Don', 'Von', 'kurtvon@cars.com', '11112119', 39000, 40, 'Working'),
(17, 'Josh', 'Vick', 'Dunn', 'joshdunn@cars.com', '10220111', 39000, 40, 'Working'),
(18, 'Mike', 'Peter', 'Griffin', 'mikegriffin@cars.com', '20330245', 40000, 40, 'Working'),
(19, 'Sharat', 'C', 'Vyas', 'svyas7@uncc.edu', '11024322486', 65000, 40, 'Fired'),
(20, 'Ron', 'Riverboat', 'Rivera', 'riverboat@gmail.com', '19517674', 45000, 35, 'Working'),
(21, 'Christian', 'C', 'McCaffery', 'chris@gmail.com', '16189235', 56000, 40, 'Working'),
(22, 'Jason', 'Charles', 'Smith', 'jason@yahoo.com', '9628349028', 38000, 39, 'Working');

-- --------------------------------------------------------

--
-- Table structure for table `Feature_List`
--

CREATE TABLE IF NOT EXISTS `Feature_List` (
  `feature_id` int(100) NOT NULL AUTO_INCREMENT,
  `feature_name` varchar(200) NOT NULL,
  PRIMARY KEY (`feature_id`),
  UNIQUE KEY `Feature_Id` (`feature_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;

--
-- Dumping data for table `Feature_List`
--

INSERT INTO `Feature_List` (`feature_id`, `feature_name`) VALUES
(1, 'Lane-Keep Assist'),
(2, 'Road-Side Assistance'),
(3, '4-Wheel Drive'),
(4, 'Luxury Seating Package'),
(5, 'Extended Warranty'),
(6, 'Park Assist'),
(7, 'Rear-Seat Entertainment Package'),
(8, 'Wireless Charging Pad'),
(9, 'Gesture Control'),
(10, 'Sport Exhaust Package'),
(11, 'Sports Chrono Package'),
(12, 'Fully Restored'),
(13, 'Rossa Corsa Paint'),
(14, 'Refinished Chrome');

-- --------------------------------------------------------

--
-- Table structure for table `Inventory`
--

CREATE TABLE IF NOT EXISTS `Inventory` (
  `Vehicle_Identification_Number` int(100) NOT NULL,
  `Price` int(20) DEFAULT NULL,
  `Description` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`Vehicle_Identification_Number`),
  UNIQUE KEY `Inv_Veh_Id_Num` (`Vehicle_Identification_Number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Inventory`
--

INSERT INTO `Inventory` (`Vehicle_Identification_Number`, `Price`, `Description`) VALUES
(5, 100000, 'Fast and Furious!'),
(10, 109872, 'One of the finest greatest sports car'),
(16, 475000, 'One of a kind!'),
(17, 987234, 'Fully Restored Collectors Edition'),
(34, 100000, 'Fast and Furious!'),
(76, 14000, 'Blue ');

-- --------------------------------------------------------

--
-- Table structure for table `Inventory_Manager`
--

CREATE TABLE IF NOT EXISTS `Inventory_Manager` (
  `inventory_manager_id` int(100) NOT NULL,
  `commission_percentage` decimal(4,2) DEFAULT '0.00',
  `Reports_to` int(100) NOT NULL,
  PRIMARY KEY (`inventory_manager_id`),
  UNIQUE KEY `Invt_Man` (`inventory_manager_id`),
  KEY `Inventory_Manager_ibfk_2` (`Reports_to`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Inventory_Manager`
--

INSERT INTO `Inventory_Manager` (`inventory_manager_id`, `commission_percentage`, `Reports_to`) VALUES
(2, '6.50', 1),
(3, '9.50', 1),
(4, '7.50', 1),
(5, '19.00', 1),
(19, '5.00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `MakeModel`
--

CREATE TABLE IF NOT EXISTS `MakeModel` (
  `model_name` varchar(50) NOT NULL,
  `make_name` varchar(50) NOT NULL,
  PRIMARY KEY (`model_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `MakeModel`
--

INSERT INTO `MakeModel` (`model_name`, `make_name`) VALUES
('325ci', 'BMW'),
('750i xDrive', 'BMW'),
('911', 'Porsche'),
('A7', 'Audi'),
('AMG-GT', 'Mercedes-Benz'),
('California', 'Ferrari'),
('Corvette', 'Chevrolet'),
('Escalade', 'Cadillac'),
('GL-450', 'Mercedes-Benz'),
('Granturismo', 'Maserati'),
('i8', 'BMW'),
('Model 3', 'Tesla'),
('Model J', 'Duesenberg'),
('Model S 70D', 'Tesla'),
('Model X 100D', 'Tesla'),
('RS5', 'Audi'),
('Santa Fe', 'Hyundai'),
('x5', 'BMW');

-- --------------------------------------------------------

--
-- Table structure for table `Salesman`
--

CREATE TABLE IF NOT EXISTS `Salesman` (
  `salesman_id` int(100) NOT NULL,
  `commission_percentage` decimal(4,2) DEFAULT '0.00',
  `Reports_to` int(100) NOT NULL,
  PRIMARY KEY (`salesman_id`),
  UNIQUE KEY `SaleMan_Id` (`salesman_id`),
  KEY `Salesman_ibfk_2` (`Reports_to`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Salesman`
--

INSERT INTO `Salesman` (`salesman_id`, `commission_percentage`, `Reports_to`) VALUES
(14, '5.10', 2),
(15, '5.00', 2),
(16, '4.80', 3),
(17, '4.00', 3),
(18, '5.50', 4),
(20, '12.00', 5);

-- --------------------------------------------------------

--
-- Table structure for table `Serviceman`
--

CREATE TABLE IF NOT EXISTS `Serviceman` (
  `serviceman_id` int(100) NOT NULL,
  `Reports_to` int(100) NOT NULL,
  PRIMARY KEY (`serviceman_id`),
  UNIQUE KEY `Serviceman_Id` (`serviceman_id`),
  KEY `Servicemn_Manager_ibfk_2` (`Reports_to`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Serviceman`
--

INSERT INTO `Serviceman` (`serviceman_id`, `Reports_to`) VALUES
(8, 5),
(9, 5),
(10, 6),
(11, 6),
(12, 7),
(13, 7),
(22, 21);

-- --------------------------------------------------------

--
-- Table structure for table `Service_History`
--

CREATE TABLE IF NOT EXISTS `Service_History` (
  `Vehicle_Identification_Number` int(100) NOT NULL,
  `Service_Date` date NOT NULL,
  `Invoice_ID` int(100) NOT NULL AUTO_INCREMENT,
  `Price` decimal(20,0) DEFAULT NULL,
  `Serviced_by` int(100) NOT NULL,
  `service_id` int(100) NOT NULL,
  `Customer_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`Invoice_ID`),
  KEY `fk_sh_vin` (`Vehicle_Identification_Number`),
  KEY `fk_sh_sb` (`Serviced_by`),
  KEY `Service_History_fk_4` (`service_id`),
  KEY `fk_cust_id` (`Customer_id`),
  KEY `ServiceId_His` (`service_id`),
  KEY `ServiceBy_His` (`Serviced_by`),
  KEY `VIN_His` (`Vehicle_Identification_Number`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=21 ;

--
-- Dumping data for table `Service_History`
--

INSERT INTO `Service_History` (`Vehicle_Identification_Number`, `Service_Date`, `Invoice_ID`, `Price`, `Serviced_by`, `service_id`, `Customer_id`) VALUES
(7, '2017-11-01', 1, '200', 8, 1, 1),
(7, '2017-02-12', 2, '30', 9, 2, 1),
(7, '2017-06-05', 3, '500', 8, 3, 1),
(7, '2017-10-19', 4, '20', 9, 4, 1),
(9, '2017-07-07', 5, '200', 10, 5, 6),
(9, '2017-04-15', 6, '800', 11, 3, 6),
(11, '2016-05-11', 7, '20', 12, 2, 2),
(11, '2017-08-12', 8, '40', 13, 6, 2),
(12, '2017-10-31', 9, '50', 13, 6, 3),
(13, '2017-10-31', 10, '20', 11, 7, 4),
(14, '2011-01-20', 11, '370', 9, 8, 5),
(14, '2012-02-28', 12, '20', 10, 4, 5),
(14, '2013-10-31', 13, '700', 13, 9, 5),
(14, '2014-07-11', 14, '400', 12, 3, 5),
(14, '2015-03-14', 15, '20', 11, 4, 5),
(14, '2016-07-07', 16, '380', 13, 9, 5),
(15, '2017-11-04', 17, '20', 12, 4, 7),
(8, '2017-11-05', 18, '15', 11, 4, 7),
(7, '2017-12-03', 19, '100', 10, 5, 1),
(2, '2017-12-31', 20, '100', 8, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `Service_List`
--

CREATE TABLE IF NOT EXISTS `Service_List` (
  `service_id` int(100) NOT NULL AUTO_INCREMENT,
  `service_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`service_id`),
  UNIQUE KEY `ServiceID` (`service_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `Service_List`
--

INSERT INTO `Service_List` (`service_id`, `service_name`) VALUES
(1, 'Service A'),
(2, 'Oil Change'),
(3, 'Tire Change'),
(4, 'Car Wash'),
(5, 'AC Fluid Replacement'),
(6, 'Wiper Fluid Refill'),
(7, 'Tires Rotated'),
(8, 'Repair Engine Oil Leak'),
(9, 'Engine Servicing');

-- --------------------------------------------------------

--
-- Table structure for table `Service_Manager`
--

CREATE TABLE IF NOT EXISTS `Service_Manager` (
  `service_manager_id` int(100) NOT NULL,
  `Reports_to` int(100) NOT NULL,
  PRIMARY KEY (`service_manager_id`),
  UNIQUE KEY `ServMan_Id` (`service_manager_id`),
  KEY `Service_Manager_ibfk_2` (`Reports_to`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Service_Manager`
--

INSERT INTO `Service_Manager` (`service_manager_id`, `Reports_to`) VALUES
(5, 1),
(6, 1),
(7, 1),
(21, 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `viewCustList`
--
CREATE TABLE IF NOT EXISTS `viewCustList` (
`Name` varchar(101)
,`Email` varchar(50)
,`Address` varchar(224)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `viewEmployees`
--
CREATE TABLE IF NOT EXISTS `viewEmployees` (
`EmployeeID` int(100)
,`Name` varchar(101)
,`Email` varchar(50)
,`SSN` varchar(20)
,`Salary` int(20)
,`Hours_per_week` int(10)
,`Role` varchar(18)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `viewInventory`
--
CREATE TABLE IF NOT EXISTS `viewInventory` (
`Car` varchar(76)
,`Car_condition` enum('New','Used')
,`Price` int(20)
,`Description` varchar(200)
,`Features` text
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `viewNewInventory`
--
CREATE TABLE IF NOT EXISTS `viewNewInventory` (
`Car` varchar(76)
,`Car_condition` enum('New','Used')
,`Price` int(20)
,`Description` varchar(200)
,`Features` text
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `viewUsedInventory`
--
CREATE TABLE IF NOT EXISTS `viewUsedInventory` (
`Car` varchar(76)
,`Car_condition` enum('New','Used')
,`Price` int(20)
,`Description` varchar(200)
,`Features` text
);
-- --------------------------------------------------------

--
-- Structure for view `viewCustList`
--
DROP TABLE IF EXISTS `viewCustList`;

CREATE ALGORITHM=UNDEFINED DEFINER=`sdilly`@`%` SQL SECURITY INVOKER VIEW `viewCustList` AS select concat(`Customer`.`First_Name`,' ',`Customer`.`Last_Name`) AS `Name`,`Customer`.`Email` AS `Email`,concat(`Customer`.`Addr_Line1`,' ',`Customer`.`City`,', ',`Customer`.`State`,' ',`Customer`.`ZIP`) AS `Address` from `Customer`;

-- --------------------------------------------------------

--
-- Structure for view `viewEmployees`
--
DROP TABLE IF EXISTS `viewEmployees`;

CREATE ALGORITHM=UNDEFINED DEFINER=`sdilly`@`%` SQL SECURITY INVOKER VIEW `viewEmployees` AS select `e`.`Emp_id` AS `EmployeeID`,concat(`e`.`First_Name`,' ',`e`.`Last_Name`) AS `Name`,`e`.`Email` AS `Email`,`e`.`SSN` AS `SSN`,`e`.`Salary` AS `Salary`,`e`.`Hours_per_week` AS `Hours_per_week`,(case when `e`.`Emp_id` in (select `Dealership_Manager`.`dealership_manager_id` from `Dealership_Manager`) then 'Dealership Manager' when `e`.`Emp_id` in (select `Inventory_Manager`.`inventory_manager_id` from `Inventory_Manager`) then 'Inventory Manager' when `e`.`Emp_id` in (select `Service_Manager`.`service_manager_id` from `Service_Manager`) then 'Service Manager' when `e`.`Emp_id` in (select `Serviceman`.`serviceman_id` from `Serviceman`) then 'Serviceman' when `e`.`Emp_id` in (select `Salesman`.`salesman_id` from `Salesman`) then 'Salesman' end) AS `Role` from `Employee` `e` where (`e`.`Status` = 'Working');

-- --------------------------------------------------------

--
-- Structure for view `viewInventory`
--
DROP TABLE IF EXISTS `viewInventory`;

CREATE ALGORITHM=UNDEFINED DEFINER=`sdilly`@`%` SQL SECURITY INVOKER VIEW `viewInventory` AS select concat(year(`cd`.`YEAR`),' ',`m`.`make_name`,' ',`cd`.`Model`) AS `Car`,`cd`.`Car_condition` AS `Car_condition`,`i`.`Price` AS `Price`,`i`.`Description` AS `Description`,group_concat(concat(`fl`.`feature_name`) separator ',') AS `Features` from ((((`Car_Detail` `cd` join `Inventory` `i` on((`cd`.`Vehicle_Identification_Number` = `i`.`Vehicle_Identification_Number`))) left join `MakeModel` `m` on((`m`.`model_name` = `cd`.`Model`))) left join `Car_Features` `cf` on((`cd`.`Vehicle_Identification_Number` = `cf`.`VIN`))) left join `Feature_List` `fl` on((`fl`.`feature_id` = `cf`.`feature_id`))) group by `cd`.`Vehicle_Identification_Number`;

-- --------------------------------------------------------

--
-- Structure for view `viewNewInventory`
--
DROP TABLE IF EXISTS `viewNewInventory`;

CREATE ALGORITHM=UNDEFINED DEFINER=`sdilly`@`%` SQL SECURITY INVOKER VIEW `viewNewInventory` AS select concat(year(`cd`.`YEAR`),' ',`m`.`make_name`,' ',`cd`.`Model`) AS `Car`,`cd`.`Car_condition` AS `Car_condition`,`i`.`Price` AS `Price`,`i`.`Description` AS `Description`,group_concat(concat(`fl`.`feature_name`) separator ',') AS `Features` from ((((`Car_Detail` `cd` join `Inventory` `i` on((`cd`.`Vehicle_Identification_Number` = `i`.`Vehicle_Identification_Number`))) left join `MakeModel` `m` on((`m`.`model_name` = `cd`.`Model`))) left join `Car_Features` `cf` on((`cd`.`Vehicle_Identification_Number` = `cf`.`VIN`))) left join `Feature_List` `fl` on((`fl`.`feature_id` = `cf`.`feature_id`))) where (`cd`.`Car_condition` = 'New') group by `cd`.`Vehicle_Identification_Number`;

-- --------------------------------------------------------

--
-- Structure for view `viewUsedInventory`
--
DROP TABLE IF EXISTS `viewUsedInventory`;

CREATE ALGORITHM=UNDEFINED DEFINER=`sdilly`@`%` SQL SECURITY INVOKER VIEW `viewUsedInventory` AS select concat(year(`cd`.`YEAR`),' ',`m`.`make_name`,' ',`cd`.`Model`) AS `Car`,`cd`.`Car_condition` AS `Car_condition`,`i`.`Price` AS `Price`,`i`.`Description` AS `Description`,group_concat(concat(`fl`.`feature_name`) separator ',') AS `Features` from ((((`Car_Detail` `cd` join `Inventory` `i` on((`cd`.`Vehicle_Identification_Number` = `i`.`Vehicle_Identification_Number`))) left join `MakeModel` `m` on((`m`.`model_name` = `cd`.`Model`))) left join `Car_Features` `cf` on((`cd`.`Vehicle_Identification_Number` = `cf`.`VIN`))) left join `Feature_List` `fl` on((`fl`.`feature_id` = `cf`.`feature_id`))) where (`cd`.`Car_condition` = 'Used') group by `cd`.`Vehicle_Identification_Number`;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Car_Detail`
--
ALTER TABLE `Car_Detail`
  ADD CONSTRAINT `Car_Detail_ibfk_1` FOREIGN KEY (`Added_by`) REFERENCES `Inventory_Manager` (`inventory_manager_id`);

--
-- Constraints for table `Car_Features`
--
ALTER TABLE `Car_Features`
  ADD CONSTRAINT `carf_f1_vin` FOREIGN KEY (`VIN`) REFERENCES `Inventory` (`Vehicle_Identification_Number`),
  ADD CONSTRAINT `carf_f2_fid` FOREIGN KEY (`feature_id`) REFERENCES `Feature_List` (`feature_id`);

--
-- Constraints for table `Car_sold`
--
ALTER TABLE `Car_sold`
  ADD CONSTRAINT `carsold_csvin_vin` FOREIGN KEY (`Vehicle_Identification_Number`) REFERENCES `Car_Detail` (`Vehicle_Identification_Number`),
  ADD CONSTRAINT `fk_cust_num` FOREIGN KEY (`Customer_id`) REFERENCES `Customer` (`customer_id`),
  ADD CONSTRAINT `FK_salesman` FOREIGN KEY (`Sold_by`) REFERENCES `Salesman` (`salesman_id`);

--
-- Constraints for table `Commission_Earned`
--
ALTER TABLE `Commission_Earned`
  ADD CONSTRAINT `commission_earned_ibfk_1` FOREIGN KEY (`salesman_id`) REFERENCES `Salesman` (`salesman_id`);

--
-- Constraints for table `Dealership_Manager`
--
ALTER TABLE `Dealership_Manager`
  ADD CONSTRAINT `Dealership_Manager_ibfk_1` FOREIGN KEY (`dealership_manager_id`) REFERENCES `Employee` (`Emp_id`);

--
-- Constraints for table `Inventory`
--
ALTER TABLE `Inventory`
  ADD CONSTRAINT `Inventory_ibfk_1` FOREIGN KEY (`Vehicle_Identification_Number`) REFERENCES `Car_Detail` (`Vehicle_Identification_Number`);

--
-- Constraints for table `Inventory_Manager`
--
ALTER TABLE `Inventory_Manager`
  ADD CONSTRAINT `Inventory_Manager_ibfk_1` FOREIGN KEY (`inventory_manager_id`) REFERENCES `Employee` (`Emp_id`),
  ADD CONSTRAINT `Inventory_Manager_ibfk_2` FOREIGN KEY (`Reports_to`) REFERENCES `Dealership_Manager` (`dealership_manager_id`);

--
-- Constraints for table `Salesman`
--
ALTER TABLE `Salesman`
  ADD CONSTRAINT `Salesman_ibfk_1` FOREIGN KEY (`salesman_id`) REFERENCES `Employee` (`Emp_id`),
  ADD CONSTRAINT `Salesman_ibfk_2` FOREIGN KEY (`Reports_to`) REFERENCES `Inventory_Manager` (`inventory_manager_id`);

--
-- Constraints for table `Serviceman`
--
ALTER TABLE `Serviceman`
  ADD CONSTRAINT `serviceman_ibfk_1` FOREIGN KEY (`serviceman_id`) REFERENCES `Employee` (`Emp_id`),
  ADD CONSTRAINT `Servicemn_Manager_ibfk_2` FOREIGN KEY (`Reports_to`) REFERENCES `Service_Manager` (`service_manager_id`);

--
-- Constraints for table `Service_History`
--
ALTER TABLE `Service_History`
  ADD CONSTRAINT `fk_cust_id` FOREIGN KEY (`Customer_id`) REFERENCES `Customer` (`customer_id`),
  ADD CONSTRAINT `Service_History_fk_4` FOREIGN KEY (`service_id`) REFERENCES `Service_List` (`service_id`),
  ADD CONSTRAINT `Service_History_ibfk_1` FOREIGN KEY (`Vehicle_Identification_Number`) REFERENCES `Car_sold` (`Vehicle_Identification_Number`),
  ADD CONSTRAINT `Service_History_ibfk_2` FOREIGN KEY (`Serviced_by`) REFERENCES `Serviceman` (`serviceman_id`);

--
-- Constraints for table `Service_Manager`
--
ALTER TABLE `Service_Manager`
  ADD CONSTRAINT `Service_Manager_ibfk_1` FOREIGN KEY (`service_manager_id`) REFERENCES `Employee` (`Emp_id`),
  ADD CONSTRAINT `Service_Manager_ibfk_2` FOREIGN KEY (`Reports_to`) REFERENCES `Dealership_Manager` (`dealership_manager_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
