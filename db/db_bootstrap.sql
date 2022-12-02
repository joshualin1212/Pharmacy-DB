-- This file is to bootstrap a database for the CS3200 project. 

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith 
-- data source creation.
create database pharmacy_db;
-- create USER 'webapp'@'%' IDENTIFIED by 'abc123';
-- grant ALL PRIVILEGES on pharmacy_db.* to 'webapp'@'%';
-- FLUSH PRIVILEGES;


-- Via the Docker Compose file, a special user called webapp will 
-- be created in MySQL. We are going to grant that user 
-- all privilages to the new database we just created. 
-- TODO: If you changed the name of the database above, you need 
-- to change it here too.
grant all privileges on pharmacy_db.* to 'webapp'@'%';
flush privileges;

-- Move into the database we just created.
-- TODO: If you changed the name of the database above, you need to
-- change it here too. 
use pharmacy_db;

-- NAMING CONVENTIONS to follow:
-- Table name: PascalCase
-- attributes: camelCase
create table Pharmacy (
    pharmacyID int primary key NOT NULL,
    street varchar(40) NOT NULL,
    phone varchar(20) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL
);
create table Insurance (
    insuranceID int primary key NOT NULL,
    insuranceName varchar(40) NOT NULL,
    phone varchar(20) NOT NULL,
    email varchar(40) NOT NULL
);

-- bottom left prescriber section
create table Hospital (
    HID int primary key NOT NULL,
    name varchar(40) NOT NULL,
    street varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL
);
create table Prescriber (
    prescriberID int primary key NOT NULL,
    HID int,
    constraint prescriberHospital foreign key (HID) references Hospital(HID) ON UPDATE cascade ON DELETE cascade,
    firstName varchar(40) NOT NULL,
    lastName varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL,
    email varchar(40) NOT NULL,
    phone varchar(20) NOT NULL
);
-- top left patient section
create table Patient (
    patientID int primary key NOT NULL,
    prescriberID int,
    insuranceID int,
    constraint patientPrescriber foreign key (prescriberID) references Prescriber(prescriberID) ON UPDATE cascade ON DELETE cascade,
    constraint patientInsurance foreign key (insuranceID) references Insurance(insuranceID) ON UPDATE cascade ON DELETE cascade,
    firstName varchar(40) NOT NULL,
    lastName varchar(40) NOT NULL,
    street varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL
);

create table PaEmails (
    email varchar(40) primary key NOT NULL,
    patientID int NOT NULL,
    constraint paEmailsPatient foreign key (PatientID) references Patient(PatientID) ON UPDATE cascade ON DELETE cascade
);
create table PaPhoneNumbers (
    number varchar(20) primary key NOT NULL,
    patientID int NOT NULL,
    constraint paPhoneNumbersPatient foreign key (PatientID) references Patient(PatientID) ON UPDATE cascade ON DELETE cascade
);
--

create table `Order` (
    orderID int primary key NOT NULL,
    patientID int,
    insuranceID int,
    pharmacyID int,
    constraint orderPatient foreign key (patientID) references Patient(patientID) ON UPDATE cascade ON DELETE cascade,
    constraint orderInsurance foreign key (insuranceID) references Insurance(insuranceID) ON UPDATE cascade ON DELETE cascade,
    constraint orderPharmacy foreign key (pharmacyID) references Pharmacy(pharmacyID) ON UPDATE cascade ON DELETE cascade,
    orderDate varchar(40) NOT NULL,
    orderStatus varchar(40) NOT NULL
);

create table PharmacyEmployee (
    phEmployeeID int primary key NOT NULL,
    pharmacyID int,
    constraint pharmacyEmployeePharmacy foreign key (pharmacyID) references Pharmacy(pharmacyID) ON UPDATE cascade ON DELETE cascade,
    certification varchar(40) NOT NULL,
    firstName varchar(40) NOT NULL,
    lastName varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL
);
create table EmPhoneNumbers (
    number varchar(20) primary key NOT NULL,
    phEmployeeID int NOT NULL,
    constraint phoneEmployee foreign key (phEmployeeID) references PharmacyEmployee(phEmployeeID) ON UPDATE cascade ON DELETE cascade
);
create table EmEmails (
    email varchar(40) primary key NOT NULL,
    phEmployeeID int NOT NULL,
    constraint emailEmployee foreign key (phEmployeeID) references PharmacyEmployee(phEmployeeID) ON UPDATE cascade ON DELETE cascade
);

create table ElectronicRx (
    RxID int primary key NOT NULL,
    pharmacyID int,
    prescriberID int,
    patientID int,
    constraint RxPharmacy foreign key (pharmacyID) references Pharmacy(pharmacyID) ON UPDATE cascade ON DELETE cascade,
    constraint RxPrescriber foreign key (prescriberID) references Prescriber(prescriberID) ON UPDATE cascade ON DELETE cascade,
    constraint RxPatient foreign key (patientID) references Patient(patientID) ON UPDATE cascade ON DELETE cascade,
    medication varchar(40) NOT NULL,
    rxDate varchar(40) NOT NULL,
    quantity int NOT NULL,
    directions varchar(100) NOT NULL
);

create table OrderItem (
    orderItemID int primary key NOT NULL,
    orderID int,
    RxID int,
    constraint orderItemOrder foreign key (orderID) references `Order`(orderID) ON UPDATE cascade ON DELETE cascade,
    constraint orderItemRx foreign key (RxID) references ElectronicRx(RxID) ON UPDATE cascade ON DELETE cascade,
    name varchar(80) NOT NULL,
    price decimal NOT NULL,
    quantity int NOT NULL
);

-- top right wholesaler section
create table Wholesaler (
    wholesalerID int primary key NOT NULL,
    name varchar(40) NOT NULL,
    phone varchar(20) NOT NULL,
    street varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL
);

create table Product (
    productID int primary key NOT NULL,
    wholesalerID int NOT NULL,
    constraint productWholesaler foreign key (wholesalerID) references Wholesaler(wholesalerID) ON UPDATE cascade ON DELETE cascade,
    name varchar(80) NOT NULL,
    price decimal NOT NULL
);

create table Shipment (
    shipmentID int primary key NOT NULL,
    pharmacyID int NOT NULL,
    constraint shipmentPharmacy foreign key (pharmacyID) references Pharmacy(pharmacyID) ON UPDATE cascade ON DELETE cascade,
    shipDate varchar(40) NOT NULL,
    shipStatus varchar(40) NOT NULL
);

create table ShipmentItem (
    shipmentItemID int primary key NOT NULL,
    shipmentID int,
    productID int,
    constraint shipmentItemShipment foreign key (shipmentID) references Shipment(shipmentID) ON UPDATE cascade ON DELETE cascade,
    constraint shipmentItemProduct foreign key (productID) references Product(productID) ON UPDATE cascade ON DELETE cascade,
    name varchar(80) NOT NULL,
    price decimal NOT NULL,
    quantity int NOT NULL
);

-- making patient persona user
create USER 'patient'@'%' IDENTIFIED by 'ineedmeds';
GRANT SELECT, UPDATE on pharmacy_db.Patient to 'patient'@'%';
GRANT SELECT on pharmacy_db.Insurance to 'patient'@'%';
GRANT SELECT on pharmacy_db.Prescriber to 'patient'@'%';
GRANT SELECT, DELETE on pharmacy_db.`Order` to 'patient'@'%'; -- user can cancel orders
GRANT SELECT on pharmacy_db.OrderItem to 'patient'@'%'; 
GRANT SELECT on pharmacy_db.Pharmacy to 'patient'@'%';
GRANT SELECT on pharmacy_db.Hospital  to 'patient'@'%';
FLUSH PRIVILEGES;

-- making pharmacy persona user
create USER 'pharmacy'@'%' IDENTIFIED by 'wearepharmers';
GRANT SELECT on pharmacy_db.* to 'pharmacy'@'%'; -- let them see everything
GRANT UPDATE on pharmacy_db.Pharmacy to 'pharmacy'@'%';
GRANT UPDATE, INSERT on pharmacy_db.Shipment to 'pharmacy'@'%';
GRANT UPDATE, INSERT on pharmacy_db.PharmacyEmployee to 'pharmacy'@'%';
GRANT UPDATE, INSERT, DELETE on pharmacy_db.`Order` to 'pharmacy'@'%';
FLUSH PRIVILEGES;

-- making prescriber persona user
create USER 'prescriber'@'%' IDENTIFIED by 'ihavethegoodstuff';
GRANT SELECT, UPDATE on pharmacy_db.Prescriber to 'prescriber'@'%';
patient hoaspital ElectronicRx, ;pharmacy
GRANT SELECT, UPDATE, INSERT, DELETE pharmacy_db.ElectronicRx to 'prescriber'@'%';
GRANT SELECT, UPDATE pharmacy_db.Hospital to 'prescriber'@'%';
GRANT SELECT, UPDATE, INSERT pharmacy_db.Pharmacy to 'prescriber'@'%';
GRANT SELECT, UPDATE, INSERT pharmacy_db.Patient to 'prescriber'@'%';
FLUSH PRIVILEGES;

-- SAMPLE DATA (10 ROWS EACH) --

insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (1, 'Washington Homeopathic Products', '859-873-4338', '935 Twin Pines Road', 'Lexington', 'Kentucky');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (2, 'EDWARDS PHARMACEUTICALS, INC.', '215-811-5865', '2493 Independence Way', 'Philadelphia', 'Pennsylvania');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (3, 'Insys Therapeutics, Inc.', '816-865-0867', '96299 Anhalt Court', 'Kansas City', 'Missouri');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (4, 'Cardinal Health', '512-630-8495', '29504 Hazelcrest Road', 'Austin', 'Texas');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (5, 'The Fuller Brush Company', '619-513-3298', '62 Everett Center', 'San Diego', 'California');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (6, 'Procter & Gamble Manufacturing Company', '402-634-8736', '66002 Crowley Court', 'Omaha', 'Nebraska');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (7, 'L''Oreal USA Products Inc', '401-938-6124', '849 Toban Plaza', 'Providence', 'Rhode Island');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (8, 'Pharmaceutical Associates, Inc.', '971-538-9147', '60195 Jackson Junction', 'Portland', 'Oregon');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (9, 'Northwind Pharmaceuticals,LLC', '917-170-1263', '251 Haas Lane', 'Bronx', 'New York');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (10, 'WALGREEN CO.', '510-723-6851', '5887 Schlimgen Plaza', 'Oakland', 'California');

--

insert into Hospital (HID, name, street, city, state) values (1, 'Carter, Reichert and Reichert', '79182 Morningstar Court', 'Milwaukee', 'Wisconsin');
insert into Hospital (HID, name, street, city, state) values (2, 'Reichert-Hessel', '4 Namekagon Circle', 'Charleston', 'West Virginia');
insert into Hospital (HID, name, street, city, state) values (3, 'Shanahan-Zieme', '739 Corry Parkway', 'Olympia', 'Washington');
insert into Hospital (HID, name, street, city, state) values (4, 'Rodriguez LLC', '2405 Corry Trail', 'Fort Pierce', 'Florida');
insert into Hospital (HID, name, street, city, state) values (5, 'McDermott LLC', '29 Eagle Crest Crossing', 'Miami', 'Florida');
insert into Hospital (HID, name, street, city, state) values (6, 'Luettgen and Sons', '9 North Place', 'Hartford', 'Connecticut');
insert into Hospital (HID, name, street, city, state) values (7, 'Jast, Bashirian and Conn', '521 Hallows Alley', 'Atlanta', 'Georgia');
insert into Hospital (HID, name, street, city, state) values (8, 'Hayes, DuBuque and Conn', '6361 Merchant Point', 'Winter Haven', 'Florida');
insert into Hospital (HID, name, street, city, state) values (9, 'Senger, Schulist and Torphy', '6304 Declaration Road', 'Cincinnati', 'Ohio');
insert into Hospital (HID, name, street, city, state) values (10, 'Cruickshank-Pagac', '6 Russell Point', 'San Antonio', 'Texas');
--

insert into Pharmacy (pharmacyID, street, phone, city, state) values (1, '814 Maryland Point', '919-538-5470', 'Raleigh', 'North Carolina');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (2, '5 Melvin Junction', '561-480-7043', 'Lake Worth', 'Florida');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (3, '4 Starling Circle', '817-166-3053', 'Denton', 'Texas');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (4, '1 Florence Pass', '619-352-6158', 'San Diego', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (5, '8 Dapin Way', '570-315-9967', 'Wilkes Barre', 'Pennsylvania');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (6, '4981 Marcy Place', '404-475-8080', 'Atlanta', 'Georgia');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (7, '5 Carey Way', '831-890-7665', 'Salinas', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (8, '123 Golf Course Plaza', '815-654-7878', 'Joliet', 'Illinois');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (9, '24012 Pepper Wood Point', '513-913-1207', 'Cincinnati', 'Ohio');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (10, '0427 Vernon Court', '210-467-8061', 'San Antonio', 'Texas');
--

insert into Insurance (insuranceID, insuranceName, phone, email) values (1, 'Tessi', '815-654-7878', 'tborzoni0@abc.net.au');
insert into Insurance (insuranceID, insuranceName, phone, email) values (2, 'Honor', '513-913-1207', 'hfigurski1@1688.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (3, 'Neysa', '210-467-8061', 'nperryn2@time.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (4, 'Jennee', '831-890-7665', 'jogara3@cbslocal.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (5, 'Ashlie', '404-475-8080', 'ajanecek4@google.es');
insert into Insurance (insuranceID, insuranceName, phone, email) values (6, 'Benson', '570-315-9967', 'bolcot5@cocolog-nifty.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (7, 'Calli', '619-352-6158', 'cpasticznyk6@tinypic.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (8, 'Eldin', '817-166-3053', 'ezincke7@wp.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (9, 'Flory', '561-480-7043', 'fdehaven8@wufoo.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (10, 'Goldia', '919-538-5470', 'gbromilow9@hatena.ne.jp');

--

insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (1, 1, 'Jayme', 'Karlowicz', 'Buffalo', 'New York', 'jkarlowicz0@cocolog-nifty.com', '716-515-7766');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (2, 2, 'Idell', 'Merfin', 'Springfield', 'Massachusetts', 'imerfin1@theguardian.com', '413-977-9881');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (3, 3, 'Carmina', 'Calleja', 'Toledo', 'Ohio', 'ccalleja2@spiegel.de', '419-278-0494');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (4, 4, 'Alberto', 'Czaja', 'Springfield', 'Massachusetts', 'aczaja3@yahoo.co.jp', '413-305-6425');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (5, 5, 'Samuele', 'Gerok', 'Escondido', 'California', 'sgerok4@engadget.com', '760-504-1043');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (6, 6, 'Manuel', 'Pinson', 'New Castle', 'Pennsylvania', 'mpinson5@nhs.uk', '724-687-3054');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (7, 7, 'Nolan', 'Lambertazzi', 'Orange', 'California', 'nlambertazzi6@cloudflare.com', '714-475-7520');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (8, 8, 'Shalna', 'Ottee', 'San Francisco', 'California', 'sottee7@youtu.be', '415-806-3245');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (9, 9, 'Kevon', 'Andrault', 'Cleveland', 'Ohio', 'kandrault8@tripadvisor.com', '216-439-9940');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (10, 10, 'Junette', 'Jearum', 'Jamaica', 'New York', 'jjearum9@google.co.uk', '718-614-7549');

--

insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (1, 1, 1, 'Marci', 'Spadollini', '95478 Morningstar Parkway', 'Dayton', 'Ohio');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (2, 2, 2, 'Zora', 'Happel', '44890 Rockefeller Way', 'Abilene', 'Texas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (3, 3, 3, 'Daisey', 'Burnhard', '7 Harbort Trail', 'Petaluma', 'California');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (4, 4, 4, 'Hogan', 'Janning', '4057 Lake View Crossing', 'Albany', 'New York');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (5, 5, 5, 'Ronni', 'Chessil', '51 Spohn Road', 'Albany', 'New York');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (6, 6, 6, 'Margalo', 'Matyasik', '3 Memorial Street', 'Katy', 'Texas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (7, 7, 7, 'Renee', 'Playle', '3 Debs Avenue', 'Wichita', 'Kansas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (8, 8, 8, 'Kurtis', 'Gayton', '53255 Clove Road', 'Saint Louis', 'Missouri');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (9, 9, 9, 'Palm', 'Brabin', '5660 Westerfield Road', 'Houston', 'Texas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (10, 10, 10, 'Kevyn', 'Tennison', '39302 Donald Way', 'Saint Paul', 'Minnesota');

--

insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (1, 1, 1, 'Iohexol', '2022-07-09 17:38:53', 2, 'nunc proin at turpis a');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (2, 2, 2, 'Cetirizine Hydrochloride', '2022-04-16 10:10:31', 17, 'mattis odio donec vitae');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (3, 3, 3, 'Benzocaine and Resorcinol', '2021-12-19 11:13:37', 22, 'aliquet at feugiat non');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (4, 4, 4, 'nifedipine', '2022-08-04 15:56:06', 65, 'ac enim in tempor turpis');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (5, 5, 5, 'METHYL SALICYLATE', '2022-03-14 16:50:15', 53, 'pellentesque at nulla suspendisse potenti');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (6, 6, 6, 'Lansoprazole', '2022-08-21 14:15:33', 54, 'eget elit sodales scelerisque mauris');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (7, 7, 7, 'Adrenalinum, Tarentula.a', '2022-01-22 03:35:02', 58, 'massa quis augue luctus tincidunt');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (8, 8, 8, 'Triclosan', '2022-09-09 17:16:12', 84, 'orci mauris lacinia sapien');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (9, 9, 9, 'Zinc Oxide', '2022-05-07 07:23:47', 73, 'mi in porttitor pede justo');
insert into ElectronicRx (RxID, pharmacyID, patientID, medication, rxDate, quantity, directions) values (10, 10, 10, 'Calendula Officinalis Flower Extract', '2022-02-02 06:17:30', 4, 'sapien varius ut blandit non');

--

insert into PaEmails (email, patientID) values ('tgambrell0@sogou.com', 1);
insert into PaEmails (email, patientID) values ('fgarrison1@feedburner.com', 2);
insert into PaEmails (email, patientID) values ('lcouttes2@imdb.com', 3);
insert into PaEmails (email, patientID) values ('pmacquaker3@wix.com', 4);
insert into PaEmails (email, patientID) values ('speck4@mediafire.com', 5);
insert into PaEmails (email, patientID) values ('mbilbrooke5@newyorker.com', 6);
insert into PaEmails (email, patientID) values ('gtring6@businessinsider.com', 7);
insert into PaEmails (email, patientID) values ('tportwain7@disqus.com', 8);
insert into PaEmails (email, patientID) values ('matyea8@cbsnews.com', 9);
insert into PaEmails (email, patientID) values ('mbleythin9@nhs.uk', 10);

--
insert into PaPhoneNumbers (number, patientID) values ('637-491-0790', 1);
insert into PaPhoneNumbers (number, patientID) values ('621-918-4556', 2);
insert into PaPhoneNumbers (number, patientID) values ('943-493-4901', 3);
insert into PaPhoneNumbers (number, patientID) values ('147-350-6964', 4);
insert into PaPhoneNumbers (number, patientID) values ('117-182-9868', 5);
insert into PaPhoneNumbers (number, patientID) values ('249-873-8293', 6);
insert into PaPhoneNumbers (number, patientID) values ('161-971-7398', 7);
insert into PaPhoneNumbers (number, patientID) values ('289-355-1739', 8);
insert into PaPhoneNumbers (number, patientID) values ('868-835-8669', 9);
insert into PaPhoneNumbers (number, patientID) values ('845-941-9610', 10);

--

insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (1, 1, 1, 1, '2022-11-05 15:31:07', 'quam nec dui luctus rutrum');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (2, 2, 2, 2, '2021-12-16 18:33:12', 'tellus in sagittis dui');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (3, 3, 3, 3, '2022-04-20 11:50:35', 'pulvinar lobortis est phasellus sit');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (4, 4, 4, 4, '2022-07-16 06:13:09', 'turpis nec euismod scelerisque');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (5, 5, 5, 5, '2022-05-06 23:46:02', 'vel augue vestibulum rutrum');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (6, 6, 6, 6, '2022-11-18 21:51:51', 'vivamus in felis eu sapien');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (7, 7, 7, 7, '2022-08-09 21:37:50', 'maecenas leo odio condimentum');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (8, 8, 8, 8, '2022-06-03 11:55:20', 'morbi ut odio cras');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (9, 9, 9, 9, '2022-06-23 20:03:45', 'sed vestibulum sit amet cursus');
insert into `Order` (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (10, 10, 10, 10, '2022-10-03 17:06:05', 'at nulla suspendisse potenti cras');

--

insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (1, 1, 'incremental', 'Hyatt', 'Swire', 'Springfield', 'Virginia');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (2, 2, 'Ameliorated', 'Bartolomeo', 'Allon', 'Newport News', 'Virginia');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (3, 3, '24-7', 'Leonard', 'Verny', 'Syracuse', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (4, 4, 'initiative', 'Ryley', 'Tenbrug', 'Fayetteville', 'North Carolina');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (5, 5, 'optimal', 'Oran', 'Tremblett', 'Omaha', 'Nebraska');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (6, 6, 'Innovative', 'Dionis', 'Alloway', 'Amarillo', 'Texas');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (7, 7, 'coherent', 'Oliviero', 'Clemencon', 'Honolulu', 'Hawaii');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (8, 8, 'grid-enabled', 'Darda', 'MacGinley', 'Kingsport', 'Tennessee');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (9, 9, 'Polarised', 'Shayna', 'Brach', 'New York City', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (10, 10, 'zero tolerance', 'Vittorio', 'Sterricks', 'Lubbock', 'Texas');

--

insert into EmPhoneNumbers (number, phEmployeeID) values ('584-313-5299', 1);
insert into EmPhoneNumbers (number, phEmployeeID) values ('975-550-9879', 2);
insert into EmPhoneNumbers (number, phEmployeeID) values ('551-725-8784', 3);
insert into EmPhoneNumbers (number, phEmployeeID) values ('448-833-7090', 4);
insert into EmPhoneNumbers (number, phEmployeeID) values ('901-280-6509', 5);
insert into EmPhoneNumbers (number, phEmployeeID) values ('805-890-5606', 6);
insert into EmPhoneNumbers (number, phEmployeeID) values ('890-974-3954', 7);
insert into EmPhoneNumbers (number, phEmployeeID) values ('377-320-2285', 8);
insert into EmPhoneNumbers (number, phEmployeeID) values ('214-762-9482', 9);
insert into EmPhoneNumbers (number, phEmployeeID) values ('666-948-1395', 10);

--

insert into EmEmails (email, phEmployeeID) values ('pleveret0@miitbeian.gov.cn', 1);
insert into EmEmails (email, phEmployeeID) values ('cstamps1@google.com', 2);
insert into EmEmails (email, phEmployeeID) values ('sosherin2@answers.com', 3);
insert into EmEmails (email, phEmployeeID) values ('vcardoo3@bravesites.com', 4);
insert into EmEmails (email, phEmployeeID) values ('shadny4@wix.com', 5);
insert into EmEmails (email, phEmployeeID) values ('shandy5@dropbox.com', 6);
insert into EmEmails (email, phEmployeeID) values ('asmiz6@buzzfeed.com', 7);
insert into EmEmails (email, phEmployeeID) values ('wwhitcombe7@goo.ne.jp', 8);
insert into EmEmails (email, phEmployeeID) values ('mrapier8@cbc.ca', 9);
insert into EmEmails (email, phEmployeeID) values ('tsurgeoner9@dagondesign.com', 10);

--

insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (1, 1, 1, 'lisinopril and hydrochlorothiazide', 30.45, 64);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (2, 2, 2, 'Levonorgestrel and Ethinyl Estradiol', 67.23, 19);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (3, 3, 3, 'Megestrol Acetate', 93.19, 43);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (4, 4, 4, 'Dapsone', 29.73, 65);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (5, 5, 5, 'Oral Pain Reliever', 65.31, 69);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (6, 6, 6, 'Cetirizine HCl', 70.97, 6);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (7, 7, 7, 'Guaifenesin and DEXTROMETHORPHAN HYDROBROMIDE', 75.38, 94);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (8, 8, 8, 'Diflunisal', 76.4, 31);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (9, 9, 9, 'SULFUR', 15.14, 77);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (10, 10, 10, 'Triclosan', 3.71, 68);

--

insert into Product (productID, wholesalerID, name, price) values (1, 1, 'Octocrylene,Zinc Oxide, Avobenzone, Ensulizone, Titanium Dioxide', 6.58);
insert into Product (productID, wholesalerID, name, price) values (2, 2, 'Donepezil Hydrochloride', 61.5);
insert into Product (productID, wholesalerID, name, price) values (3, 3, 'tropicamide', 61.6);
insert into Product (productID, wholesalerID, name, price) values (4, 4, 'acetaminophen and codeine phosphate', 22.29);
insert into Product (productID, wholesalerID, name, price) values (5, 5, 'Triclosan', 36.99);
insert into Product (productID, wholesalerID, name, price) values (6, 6, 'Aluminum Zirconium Trichlorohydrex Gly', 93.28);
insert into Product (productID, wholesalerID, name, price) values (7, 7, 'Atenolol', 37.72);
insert into Product (productID, wholesalerID, name, price) values (8, 8, 'Dexamethasone Sodium Phosphate', 49.79);
insert into Product (productID, wholesalerID, name, price) values (9, 9, 'SIMETHICONE', 15.11);
insert into Product (productID, wholesalerID, name, price) values (10, 10, 'aprepitant', 98.42);

--

insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (1, 1, '2022-07-19 17:04:47', 'placerat praesent blandit nam');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (2, 2, '2022-07-23 13:57:49', 'id ligula suspendisse ornare');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (3, 3, '2022-07-15 11:54:47', 'volutpat sapien arcu sed');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (4, 4, '2022-10-01 13:27:10', 'sollicitudin vitae consectetuer eget');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (5, 5, '2022-05-11 21:29:21', 'ultrices posuere cubilia curae mauris');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (6, 6, '2022-03-13 11:59:29', 'lacus morbi sem mauris laoreet');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (7, 7, '2022-05-02 14:34:17', 'et commodo vulputate justo in');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (8, 8, '2022-02-20 01:32:26', 'erat id mauris vulputate');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (9, 9, '2022-06-29 21:18:09', 'odio curabitur convallis duis consequat');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (10, 10, '2022-09-14 03:49:04', 'ac consequat metus sapien ut');

--

insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (1, 1, 1, 'Triamterene and Hydrochlorothiazide', 96.15, 75);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (2, 2, 2, 'Amoxicillin', 26.83, 35);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (3, 3, 3, 'sumatriptan succinate', 1.16, 92);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (4, 4, 4, 'Furosemide', 21.99, 54);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (5, 5, 5, 'Chelidonium Majus, Phytolacca Decandra, Arnica Montana, Nitricum Acidum', 8.1, 53);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (6, 6, 6, 'Bisacodyl', 2.65, 99);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (7, 7, 7, 'Avobenzone, Octinoxate, Octisalate, Oxybenzone', 11.21, 29);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (8, 8, 8, 'Sertraline Hydrochloride', 21.9, 46);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (9, 9, 9, 'Spiny Pigweed', 8.75, 6);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (10, 10, 10, 'Clindamycin Hydrochloride', 85.96, 13);