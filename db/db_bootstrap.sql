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
    patientID int primary key NOT NULL AUTO_INCREMENT,
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

create table PaOrder (
    orderID int primary key NOT NULL AUTO_INCREMENT,
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
    RxID int primary key NOT NULL AUTO_INCREMENT,
    pharmacyID int,
    prescriberID int,
    patientID int,
    constraint RxPharmacy foreign key (pharmacyID) references Pharmacy(pharmacyID) ON UPDATE cascade ON DELETE cascade,
    constraint RxPrescriber foreign key (prescriberID) references Prescriber(prescriberID) ON UPDATE cascade ON DELETE cascade,
    constraint RxPatient foreign key (patientID) references Patient(patientID) ON UPDATE cascade ON DELETE cascade,
    medication varchar(80) NOT NULL,
    rxDate varchar(40) NOT NULL,
    quantity int NOT NULL,
    directions varchar(100) NOT NULL
);

create table OrderItem (
    orderItemID int primary key NOT NULL,
    orderID int,
    RxID int,
    constraint orderItemOrder foreign key (orderID) references PaOrder(orderID) ON UPDATE cascade ON DELETE cascade,
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
    shipmentID int primary key NOT NULL AUTO_INCREMENT,
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
GRANT SELECT, UPDATE, DELETE on pharmacy_db.PaOrder to 'patient'@'%'; -- user can cancel orders
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
GRANT UPDATE, INSERT, DELETE on pharmacy_db.PaOrder to 'pharmacy'@'%';
FLUSH PRIVILEGES;

-- making prescriber persona user
create USER 'prescriber'@'%' IDENTIFIED by 'ihavethegoodstuff';
GRANT SELECT, UPDATE on pharmacy_db.Prescriber to 'prescriber'@'%';
GRANT SELECT on pharmacy_db.Patient to 'prescriber'@'%';
GRANT SELECT, UPDATE, INSERT on pharmacy_db.ElectronicRx to 'prescriber'@'%';
GRANT SELECT, UPDATE on pharmacy_db.Hospital to 'prescriber'@'%';
GRANT SELECT, UPDATE, INSERT on pharmacy_db.Pharmacy to 'prescriber'@'%';
GRANT SELECT, UPDATE, INSERT on pharmacy_db.Patient to 'prescriber'@'%';
FLUSH PRIVILEGES;



-- SAMPLE DATA (~30 tuples EACH, For tables are more like invoice tables, aim for 80 - 90) --

insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (1, 'McKesson Contract Packaging', '432-833-4112', '22184 Schmedeman Avenue', 'Midland', 'Texas');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (2, 'Hannaford Brothers Company', '617-621-2565', '2256 Thompson Road', 'Boston', 'Massachusetts');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (3, 'Phillips Company', '504-692-9014', '403 Harbort Court', 'Metairie', 'Louisiana');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (4, 'HYVEE INC', '323-577-9199', '587 Merchant Alley', 'Los Angeles', 'California');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (5, 'Amneal-Agila, LLC', '920-802-3420', '12 Northwestern Alley', 'Appleton', 'Wisconsin');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (6, 'WOOIL C&TECH.CORP', '469-130-5249', '4 Schurz Park', 'Dallas', 'Texas');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (7, 'DOLGENCORP INC', '832-227-7225', '65141 3rd Crossing', 'Houston', 'Texas');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (8, 'Nelco Laboratories, Inc.', '803-554-5953', '8 Talisman Avenue', 'Aiken', 'South Carolina');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (9, 'AvKARE, Inc.', '512-385-5735', '01446 Menomonie Junction', 'Austin', 'Texas');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (10, 'REMEDYREPACK INC.', '602-768-9943', '7473 Namekagon Point', 'Phoenix', 'Arizona');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (11, 'REMEDYREPACK INC.', '504-472-7169', '40 Old Shore Terrace', 'New Orleans', 'Louisiana');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (12, 'Korea Ginseng Corporation', '615-125-1354', '4 Boyd Alley', 'Nashville', 'Tennessee');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (13, 'Nature''s Innovation, Inc.', '313-475-9743', '2 Surrey Drive', 'Dearborn', 'Michigan');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (14, 'Sam''s West Inc', '209-294-2149', '2 Grasskamp Hill', 'Fresno', 'California');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (15, 'Greenstone LLC', '916-565-6444', '953 Starling Crossing', 'Sacramento', 'California');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (16, 'Supervalu Inc', '419-252-5640', '557 Esch Way', 'Toledo', 'Ohio');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (17, 'REMEDYREPACK INC.', '412-919-7290', '01695 Katie Trail', 'Pittsburgh', 'Pennsylvania');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (18, 'Sandoz Inc', '410-286-3294', '12632 Pond Plaza', 'Baltimore', 'Maryland');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (19, 'Actavis Pharma, Inc.', '970-168-4434', '49728 Sunnyside Park', 'Fort Collins', 'Colorado');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (20, 'Ventura International LTD', '325-487-8776', '6303 Ludington Circle', 'Abilene', 'Texas');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (21, 'Uriel Pharmacy Inc.', '917-682-9646', '627 Oneill Alley', 'Bronx', 'New York');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (22, 'Apotex Corp', '615-374-9519', '796 Tony Junction', 'Nashville', 'Tennessee');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (23, 'Sanum Kehlbeck GmbH & Co. KG', '234-873-0000', '4668 Montana Trail', 'Akron', 'Ohio');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (24, 'Aidarex Pharmaceuticals LLC', '269-232-8789', '9 Bunting Park', 'Battle Creek', 'Michigan');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (25, 'Accord Healthcare, Inc.', '402-100-1170', '773 Summer Ridge Alley', 'Omaha', 'Nebraska');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (26, 'SHISEIDO AMERICA INC.', '208-263-9911', '5 Knutson Pass', 'Boise', 'Idaho');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (27, 'Major Pharmaceuticals', '586-766-5198', '72 Sage Street', 'Detroit', 'Michigan');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (28, 'Dispensing Solutions, Inc.', '901-466-4683', '72639 La Follette Avenue', 'Memphis', 'Tennessee');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (29, 'STAT RX USA LLC', '559-860-1992', '5 Bartelt Parkway', 'Visalia', 'California');
insert into Wholesaler (wholesalerID, name, phone, street, city, state) values (30, 'Clinical Solutions Wholesale', '925-193-3400', '06967 Monterey Street', 'Concord', 'California');

--
insert into Hospital (HID, name, street, city, state) values (1, 'Abbott, Littel and Schuster', '73 5th Parkway', 'Miami', 'Florida');
insert into Hospital (HID, name, street, city, state) values (2, 'White-Purdy', '5 Village Lane', 'Pueblo', 'Colorado');
insert into Hospital (HID, name, street, city, state) values (3, 'Leannon, McGlynn and Hintz', '99 Westport Trail', 'Minneapolis', 'Minnesota');
insert into Hospital (HID, name, street, city, state) values (4, 'Tromp-Yost', '1 Kipling Place', 'Crawfordsville', 'Indiana');
insert into Hospital (HID, name, street, city, state) values (5, 'Metz Inc', '11422 Crowley Center', 'Santa Barbara', 'California');
insert into Hospital (HID, name, street, city, state) values (6, 'Wehner, Spencer and Beatty', '679 Esch Pass', 'San Angelo', 'Texas');
insert into Hospital (HID, name, street, city, state) values (7, 'O''Kon-Reichert', '8 Waxwing Avenue', 'Modesto', 'California');
insert into Hospital (HID, name, street, city, state) values (8, 'Hirthe LLC', '2629 Eagle Crest Court', 'Dayton', 'Ohio');
insert into Hospital (HID, name, street, city, state) values (9, 'Goldner, Tillman and Oberbrunner', '84014 Mosinee Junction', 'Atlanta', 'Georgia');
insert into Hospital (HID, name, street, city, state) values (10, 'Wilderman-Bartell', '7 Northwestern Junction', 'Fort Lauderdale', 'Florida');
insert into Hospital (HID, name, street, city, state) values (11, 'Gislason and Sons', '8 Iowa Pass', 'Phoenix', 'Arizona');
insert into Hospital (HID, name, street, city, state) values (12, 'Gutmann-Stiedemann', '942 Miller Plaza', 'Jacksonville', 'Florida');
insert into Hospital (HID, name, street, city, state) values (13, 'Hilpert-Tillman', '8 Hoffman Street', 'Miami', 'Florida');
insert into Hospital (HID, name, street, city, state) values (14, 'Keebler-Haley', '6018 Lien Street', 'Cincinnati', 'Ohio');
insert into Hospital (HID, name, street, city, state) values (15, 'Orn-McDermott', '89 Pawling Place', 'New York City', 'New York');
insert into Hospital (HID, name, street, city, state) values (16, 'Goodwin, Gleichner and McClure', '528 Dottie Way', 'Fort Collins', 'Colorado');
insert into Hospital (HID, name, street, city, state) values (17, 'West, Kihn and Schroeder', '7399 Granby Center', 'Cincinnati', 'Ohio');
insert into Hospital (HID, name, street, city, state) values (18, 'Hessel, Kassulke and Williamson', '73407 Porter Avenue', 'Oklahoma City', 'Oklahoma');
insert into Hospital (HID, name, street, city, state) values (19, 'Nienow, Conn and Roberts', '1588 Killdeer Avenue', 'Melbourne', 'Florida');
insert into Hospital (HID, name, street, city, state) values (20, 'Mills, Deckow and Vandervort', '48 Sachtjen Way', 'Louisville', 'Kentucky');
insert into Hospital (HID, name, street, city, state) values (21, 'Prohaska, Hegmann and Quitzon', '5717 Pankratz Crossing', 'Brooklyn', 'New York');
insert into Hospital (HID, name, street, city, state) values (22, 'Green Group', '449 Florence Street', 'San Bernardino', 'California');
insert into Hospital (HID, name, street, city, state) values (23, 'Torphy, Gaylord and Lesch', '44 Corry Hill', 'Cincinnati', 'Ohio');
insert into Hospital (HID, name, street, city, state) values (24, 'Lang and Sons', '34 Ronald Regan Place', 'Birmingham', 'Alabama');
insert into Hospital (HID, name, street, city, state) values (25, 'King, Bins and Schmeler', '306 Gateway Plaza', 'Boston', 'Massachusetts');
insert into Hospital (HID, name, street, city, state) values (26, 'Carroll LLC', '3 North Center', 'Wichita', 'Kansas');
insert into Hospital (HID, name, street, city, state) values (27, 'Kub-Rohan', '3 Union Parkway', 'Morgantown', 'West Virginia');
insert into Hospital (HID, name, street, city, state) values (28, 'Emmerich-Fritsch', '6211 Trailsway Terrace', 'Santa Barbara', 'California');
insert into Hospital (HID, name, street, city, state) values (29, 'Boyer-Sporer', '714 Aberg Terrace', 'Louisville', 'Kentucky');
insert into Hospital (HID, name, street, city, state) values (30, 'Bogan and Sons', '4 Scott Pass', 'Tulsa', 'Oklahoma');
--

insert into Pharmacy (pharmacyID, street, phone, city, state) values (1, '987 Darwin Way', '805-224-3677', 'Oxnard', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (2, '41 Melody Pass', '818-458-9541', 'Los Angeles', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (3, '647 Hauk Trail', '312-968-8348', 'Chicago', 'Illinois');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (4, '35386 Bultman Lane', '504-424-5122', 'New Orleans', 'Louisiana');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (5, '23048 Thompson Street', '786-613-8311', 'Miami', 'Florida');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (6, '4 Norway Maple Road', '517-176-6960', 'Lansing', 'Michigan');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (7, '576 Carberry Hill', '408-239-5755', 'San Jose', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (8, '18447 Kropf Way', '402-849-7539', 'Omaha', 'Nebraska');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (9, '6 Algoma Center', '404-837-7208', 'Duluth', 'Georgia');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (10, '9 Hoepker Terrace', '205-618-1721', 'Birmingham', 'Alabama');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (11, '9 Myrtle Pass', '256-381-0505', 'Huntsville', 'Alabama');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (12, '1 Rowland Avenue', '801-187-2255', 'Salt Lake City', 'Utah');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (13, '4 Morrow Place', '859-178-4598', 'Lexington', 'Kentucky');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (14, '220 Summit Place', '916-305-1384', 'Sacramento', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (15, '93 Pawling Parkway', '954-381-4130', 'West Palm Beach', 'Florida');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (16, '2 Heath Circle', '202-201-0586', 'Washington', 'District of Columbia');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (17, '09718 Riverside Drive', '727-627-5700', 'Clearwater', 'Florida');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (18, '89106 Pankratz Road', '810-319-5974', 'Detroit', 'Michigan');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (19, '8 Anthes Hill', '801-578-6411', 'Salt Lake City', 'Utah');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (20, '593 Schlimgen Crossing', '509-890-2800', 'Spokane', 'Washington');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (21, '6610 Anniversary Trail', '847-783-4426', 'Palatine', 'Illinois');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (22, '623 Ludington Road', '208-561-3015', 'Pocatello', 'Idaho');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (23, '184 Northport Terrace', '916-103-8544', 'Sacramento', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (24, '64 Erie Road', '202-140-5946', 'Washington', 'District of Columbia');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (25, '5244 Pleasure Parkway', '951-488-9235', 'Riverside', 'California');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (26, '918 Blue Bill Park Road', '202-693-7983', 'Washington', 'District of Columbia');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (27, '823 Marquette Hill', '937-885-6924', 'Hamilton', 'Ohio');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (28, '85 Novick Park', '301-243-2787', 'Silver Spring', 'Maryland');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (29, '5081 Northridge Center', '407-362-3402', 'Kissimmee', 'Florida');
insert into Pharmacy (pharmacyID, street, phone, city, state) values (30, '9311 Namekagon Court', '914-920-6105', 'Staten Island', 'New York');

--

insert into Insurance (insuranceID, insuranceName, phone, email) values (1, 'Toy-Effertz', 'Carmencita', 'crawet0@paginegialle.it');
insert into Insurance (insuranceID, insuranceName, phone, email) values (2, 'Baumbach Inc', 'Cointon', 'clofthouse1@taobao.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (3, 'Prohaska, Parisian and Balistreri', 'Selina', 'sroyden2@blog.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (4, 'Walker Inc', 'Nickie', 'nkempton3@scribd.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (5, 'Wolf, Wolf and Bins', 'Con', 'csebley4@xrea.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (6, 'Volkman-Schroeder', 'Greer', 'gmoyce5@phoca.cz');
insert into Insurance (insuranceID, insuranceName, phone, email) values (7, 'Smith-Pagac', 'Lionello', 'lscamp6@jiathis.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (8, 'Denesik-Baumbach', 'Alyce', 'amorten7@google.de');
insert into Insurance (insuranceID, insuranceName, phone, email) values (9, 'Dicki-Abernathy', 'Pat', 'pdanilovic8@nydailynews.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (10, 'Witting, Herzog and Goldner', 'Melisande', 'mdeviney9@samsung.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (11, 'Kling and Sons', 'Audrey', 'acargona@php.net');
insert into Insurance (insuranceID, insuranceName, phone, email) values (12, 'Bernhard Inc', 'Ronalda', 'rvowlesb@epa.gov');
insert into Insurance (insuranceID, insuranceName, phone, email) values (13, 'Lockman Inc', 'Barrie', 'bpeirazzic@tmall.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (14, 'Fisher Group', 'Brok', 'bgyrgorwicxd@yahoo.co.jp');
insert into Insurance (insuranceID, insuranceName, phone, email) values (15, 'Goyette Group', 'Jami', 'jelloye@apache.org');
insert into Insurance (insuranceID, insuranceName, phone, email) values (16, 'Bartoletti, Kerluke and Denesik', 'Jaime', 'jfreynef@epa.gov');
insert into Insurance (insuranceID, insuranceName, phone, email) values (17, 'Conroy-Tremblay', 'Chloe', 'cfannong@wordpress.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (18, 'Hettinger-Wehner', 'Tadeas', 'tloadesh@naver.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (19, 'Lockman, Hand and Fadel', 'Sarah', 'sdibiaggii@1und1.de');
insert into Insurance (insuranceID, insuranceName, phone, email) values (20, 'Gutkowski, Nikolaus and Stark', 'Murvyn', 'mmacj@google.fr');
insert into Insurance (insuranceID, insuranceName, phone, email) values (21, 'Stark, Breitenberg and Wilderman', 'Archibaldo', 'adibbink@china.com.cn');
insert into Insurance (insuranceID, insuranceName, phone, email) values (22, 'Reilly, Gorczany and Macejkovic', 'Theda', 'tevershedl@wired.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (23, 'Schmeler Inc', 'Farleigh', 'fbanatm@hhs.gov');
insert into Insurance (insuranceID, insuranceName, phone, email) values (24, 'Herman, Brekke and Leannon', 'Jedd', 'jfreiburgern@fastcompany.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (25, 'Cremin and Sons', 'Marcelle', 'mmedlaro@free.fr');
insert into Insurance (insuranceID, insuranceName, phone, email) values (26, 'Rice-Tillman', 'Koren', 'kloftyp@zimbio.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (27, 'Brekke, Klocko and Reichel', 'Cate', 'cpriverq@mail.ru');
insert into Insurance (insuranceID, insuranceName, phone, email) values (28, 'Barrows-Lockman', 'Eryn', 'eoldallr@comsenz.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (29, 'Langosh Group', 'Odella', 'obushnells@answers.com');
insert into Insurance (insuranceID, insuranceName, phone, email) values (30, 'O''Conner, Hammes and Kulas', 'Milty', 'mgodsmarkt@redcross.org');

--

insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (1, 1, 'Linet', 'Fairney', 'Shreveport', 'Louisiana', 'lfairney0@noaa.gov', '318-321-1852');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (2, 2, 'Barbee', 'Brian', 'Trenton', 'New Jersey', 'bbrian1@pagesperso-orange.fr', '609-324-8516');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (3, 3, 'Sarene', 'Fishby', 'Indianapolis', 'Indiana', 'sfishby2@yelp.com', '317-749-0979');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (4, 4, 'Ruby', 'Partridge', 'San Diego', 'California', 'rpartridge3@ucoz.com', '619-117-6410');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (5, 5, 'Eamon', 'Henrot', 'Huntington Beach', 'California', 'ehenrot4@forbes.com', '714-539-6922');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (6, 6, 'Thaddeus', 'Evins', 'Petaluma', 'California', 'tevins5@tamu.edu', '707-431-6763');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (7, 7, 'Katya', 'Busek', 'Gary', 'Indiana', 'kbusek6@house.gov', '219-830-9693');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (8, 8, 'Caryl', 'Gerbel', 'Fort Wayne', 'Indiana', 'cgerbel7@shutterfly.com', '260-501-1225');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (9, 9, 'Gabriel', 'Woolens', 'Newark', 'Delaware', 'gwoolens8@baidu.com', '302-700-2717');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (10, 10, 'Coralyn', 'Cockrill', 'Charlotte', 'North Carolina', 'ccockrill9@ow.ly', '704-874-3093');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (11, 11, 'Lyle', 'Strippling', 'Dallas', 'Texas', 'lstripplinga@independent.co.uk', '469-431-7044');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (12, 12, 'Gerianna', 'Ramsden', 'Wichita Falls', 'Texas', 'gramsdenb@globo.com', '940-296-5459');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (13, 13, 'Sinclare', 'Jean', 'Miami', 'Florida', 'sjeanc@cyberchimps.com', '786-343-5155');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (14, 14, 'Loutitia', 'Ranscome', 'Charlotte', 'North Carolina', 'lranscomed@wired.com', '704-118-4910');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (15, 15, 'Flss', 'Inchan', 'Melbourne', 'Florida', 'finchane@archive.org', '321-751-3413');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (16, 16, 'Malvina', 'MacEveley', 'San Antonio', 'Texas', 'mmaceveleyf@skype.com', '210-558-4200');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (17, 17, 'Garry', 'Cockell', 'Richmond', 'California', 'gcockellg@ucoz.ru', '510-938-0334');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (18, 18, 'Randell', 'Major', 'Springfield', 'Illinois', 'rmajorh@rambler.ru', '217-446-2321');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (19, 19, 'Almira', 'Poli', 'Chicago', 'Illinois', 'apolii@sina.com.cn', '312-604-7413');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (20, 20, 'Karlen', 'Skrines', 'Oklahoma City', 'Oklahoma', 'kskrinesj@ocn.ne.jp', '405-260-6046');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (21, 21, 'Yuri', 'Cozzi', 'New York City', 'New York', 'ycozzik@domainmarket.com', '917-157-5580');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (22, 22, 'Ferrel', 'Stanyan', 'Seattle', 'Washington', 'fstanyanl@storify.com', '206-652-9357');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (23, 23, 'Cherianne', 'Cobden', 'Ann Arbor', 'Michigan', 'ccobdenm@domainmarket.com', '734-760-7511');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (24, 24, 'Verena', 'Pucknell', 'Charlotte', 'North Carolina', 'vpucknelln@timesonline.co.uk', '704-513-1763');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (25, 25, 'Pancho', 'Hadcock', 'Roanoke', 'Virginia', 'phadcocko@eepurl.com', '540-793-7644');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (26, 26, 'Johnnie', 'Petrelli', 'Scottsdale', 'Arizona', 'jpetrellip@live.com', '602-156-1566');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (27, 27, 'Guthrey', 'Stoaks', 'Monroe', 'Louisiana', 'gstoaksq@e-recht24.de', '318-216-5064');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (28, 28, 'Almira', 'Davidek', 'Kansas City', 'Kansas', 'adavidekr@oracle.com', '913-742-4258');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (29, 29, 'Gawen', 'Kenset', 'Phoenix', 'Arizona', 'gkensets@google.com.br', '602-541-6905');
insert into Prescriber (prescriberID, HID, firstName, lastName, city, state, email, phone) values (30, 30, 'Claudianus', 'Lilburne', 'Oklahoma City', 'Oklahoma', 'clilburnet@blogs.com', '405-966-1320');

--

insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (1, 1, 1, 'Gardie', 'Virgin', '35315 Garrison Lane', 'Fort Worth', 'Texas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (2, 2, 2, 'Tommi', 'Sudy', '8 Troy Avenue', 'Cleveland', 'Ohio');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (3, 3, 3, 'Kennie', 'Hame', '17 Del Mar Circle', 'Alexandria', 'Virginia');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (4, 4, 4, 'Ezmeralda', 'Abrey', '4 Independence Point', 'Englewood', 'Colorado');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (5, 5, 5, 'Fields', 'Mawd', '00 Farmco Drive', 'New Orleans', 'Louisiana');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (6, 6, 6, 'Harli', 'Eickhoff', '53 Merry Place', 'West Palm Beach', 'Florida');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (7, 7, 7, 'Eddi', 'Rubinivitz', '49 Starling Pass', 'North Hollywood', 'California');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (8, 8, 8, 'Isis', 'Forton', '746 Rieder Terrace', 'Trenton', 'New Jersey');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (9, 9, 9, 'Idaline', 'Orbine', '1585 Alpine Junction', 'Memphis', 'Tennessee');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (10, 10, 10, 'Welsh', 'Primarolo', '48693 Forest Run Point', 'Memphis', 'Tennessee');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (11, 11, 11, 'Bertrando', 'Iltchev', '20725 Becker Parkway', 'Birmingham', 'Alabama');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (12, 12, 12, 'Jillayne', 'Keelan', '1609 Spaight Lane', 'San Angelo', 'Texas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (13, 13, 13, 'Juli', 'Gowler', '05 Sunfield Trail', 'Houston', 'Texas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (14, 14, 14, 'Artur', 'Roseblade', '2 Ridgeview Drive', 'Montgomery', 'Alabama');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (15, 15, 15, 'Emmey', 'Menendes', '7726 Melody Park', 'Durham', 'North Carolina');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (16, 16, 16, 'Wendye', 'Jozaitis', '134 Marquette Plaza', 'Elmira', 'New York');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (17, 17, 17, 'Murvyn', 'Scholard', '0144 Tomscot Court', 'Warren', 'Ohio');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (18, 18, 18, 'Karena', 'Yetman', '538 American Ash Road', 'Albany', 'New York');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (19, 19, 19, 'Archie', 'Dinnage', '18 Mallory Point', 'Little Rock', 'Arkansas');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (20, 20, 20, 'Salvidor', 'Boyfield', '75 Hazelcrest Point', 'Des Moines', 'Iowa');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (21, 21, 21, 'Danette', 'Tolliday', '23163 Gina Lane', 'Tampa', 'Florida');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (22, 22, 22, 'Tandi', 'Nisius', '4319 Fulton Park', 'Orlando', 'Florida');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (23, 23, 23, 'Luciana', 'Marvell', '34003 Washington Terrace', 'Honolulu', 'Hawaii');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (24, 24, 24, 'Bank', 'Tayloe', '39878 Clarendon Road', 'Miami', 'Florida');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (25, 25, 25, 'Briggs', 'Gentric', '149 Westend Road', 'Denver', 'Colorado');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (26, 26, 26, 'Harrietta', 'Glyssanne', '5959 Pankratz Drive', 'Macon', 'Georgia');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (27, 27, 27, 'Ellery', 'Lamswood', '4594 Melody Pass', 'Syracuse', 'New York');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (28, 28, 28, 'Florry', 'Donoghue', '232 Dorton Parkway', 'Akron', 'Ohio');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (29, 29, 29, 'Nola', 'Geggus', '22 Comanche Drive', 'Raleigh', 'North Carolina');
insert into Patient (patientID, prescriberID, insuranceID, firstName, lastName, street, city, state) values (30, 30, 30, 'Freddie', 'Sever', '494 Esch Center', 'Sioux Falls', 'South Dakota');

--

insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (1, 15, 19, 8, 'nifedipine', '2022-01-05 00:45:43', 23, 'odio in hac habitasse');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (2, 16, 13, 9, 'Nortriptyline Hydrochloride', '2022-09-28 02:50:49', 18, 'eleifend donec ut');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (3, 11, 20, 3, 'Titanium Dioxide', '2022-02-27 14:20:17', 30, 'tempus sit amet');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (4, 10, 3, 25, 'OCTINOXATE, TITANIUM DIOXIDE', '2022-06-27 14:48:49', 48, 'lacinia nisi');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (5, 19, 27, 13, 'Influenzinum', '2022-02-11 00:27:07', 25, 'non lectus aliquam');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (6, 29, 11, 22, 'Lamotrigine', '2022-10-24 13:41:37', 24, 'ipsum integer a');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (7, 3, 16, 8, 'Nifedipine', '2022-04-26 17:57:05', 85, 'ipsum aliquam');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (8, 22, 7, 4, 'MANGANESE', '2022-10-05 13:34:04', 40, 'lacus at velit vivamus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (9, 5, 21, 5, 'Oxycodone and Acetaminophen', '2022-09-18 05:43:03', 4, 'convallis nulla neque');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (10, 7, 23, 13, 'TRICLOSAN', '2022-10-26 21:17:49', 73, 'eleifend pede libero quis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (11, 16, 26, 24, 'Plantain, English Plantago lanceolata', '2022-11-17 05:57:09', 60, 'turpis eget elit sodales');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (12, 16, 1, 4, 'benzalkonium chloride and lidocaine hydrochloride', '2022-04-25 19:16:29', 86, 'velit donec diam');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (13, 3, 25, 18, 'Surgical Hand Antiseptic', '2022-04-27 00:56:00', 28, 'nec euismod');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (14, 30, 25, 8, 'Sodium monofluorophosphate', '2022-05-15 09:02:38', 64, 'lacus morbi quis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (15, 8, 3, 18, 'Salicylic Acid', '2022-05-30 14:04:24', 60, 'elementum pellentesque quisque porta');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (16, 9, 23, 13, 'RISPERIDONE', '2021-12-31 20:47:38', 72, 'turpis nec');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (17, 24, 5, 19, 'Cetirizine Hydrochloride', '2022-10-23 15:56:15', 24, 'in lacus curabitur at');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (18, 20, 24, 16, 'aluminum hydroxide and magnesium carbonate', '2022-08-03 01:44:10', 96, 'nibh ligula');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (19, 21, 24, 22, 'Zidovudine', '2022-10-08 20:00:30', 8, 'aenean auctor gravida');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (20, 14, 4, 20, 'Berberis e fruct. 10% Special Order', '2022-08-30 13:17:42', 33, 'hac habitasse platea');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (21, 28, 29, 8, 'Bacitracin', '2022-04-23 12:44:30', 47, 'dictumst etiam');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (22, 13, 25, 30, 'isopropyl alcohol', '2022-02-22 08:20:41', 86, 'interdum mauris ullamcorper');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (23, 6, 6, 18, 'Filbert', '2021-12-19 12:16:03', 64, 'ut mauris eget massa');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (24, 20, 7, 17, 'HUMAN IMMUNOGLOBULIN G', '2022-08-24 02:12:25', 25, 'amet justo morbi');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (25, 9, 17, 15, 'Isoniazid', '2022-01-03 22:07:43', 96, 'ut tellus nulla ut');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (26, 11, 21, 11, 'Octinoxate and Titanium Dioxide', '2022-04-06 12:03:53', 48, 'justo morbi ut odio');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (27, 1, 28, 7, 'Oxygen', '2022-08-11 09:53:35', 44, 'ante ipsum primis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (28, 19, 15, 17, 'Oxcarbazepine', '2022-05-07 03:52:45', 83, 'potenti cras in purus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (29, 28, 7, 3, 'Isopropyl alcohol', '2022-10-17 05:49:10', 88, 'quis tortor');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (30, 28, 16, 3, 'Stavudine', '2022-08-04 10:49:57', 64, 'in felis donec');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (31, 5, 16, 10, 'Asparagus', '2022-07-28 01:50:00', 96, 'pede posuere nonummy integer');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (32, 12, 21, 17, 'Cimicifuga racemosa 6X', '2022-04-03 08:32:13', 11, 'non lectus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (33, 30, 4, 18, 'simethicone', '2022-02-10 14:48:29', 53, 'id mauris');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (34, 13, 1, 17, 'Echinacea, Lobelia Inflata, Antimonium Tartaricum, Aralia Racemosa, Drosera, Ipecacuanha, Kali Carbonicum', '2022-01-16 17:26:59', 79, 'nulla facilisi cras');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (35, 30, 16, 11, 'divalproex sodium', '2022-11-18 01:25:39', 38, 'in sagittis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (36, 24, 16, 10, 'Nitrogen', '2022-06-10 04:40:16', 96, 'proin at turpis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (37, 27, 29, 1, 'Ethyl Alcohol', '2022-07-25 06:44:59', 15, 'in blandit ultrices enim');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (38, 3, 22, 13, 'Naratriptan', '2021-12-17 16:47:33', 54, 'sollicitudin mi sit amet');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (39, 4, 28, 11, 'Amantadine Hydrochloride', '2022-03-17 02:47:39', 68, 'urna ut tellus nulla');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (40, 15, 9, 28, 'Levothyroxine Sodium', '2021-11-27 02:50:14', 21, 'convallis eget');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (41, 30, 29, 15, 'TITANIUM DIOXIDE, ZINC OXIDE', '2022-04-28 22:40:20', 69, 'in ante vestibulum ante');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (42, 22, 16, 7, 'BENZALKONIUM CHLORIDE AND PRAMOXINE HYDROCHLORIDE', '2022-01-03 15:47:14', 72, 'montes nascetur ridiculus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (43, 9, 9, 1, 'Magnesium Sulfate', '2022-09-20 07:04:18', 45, 'mattis egestas metus aenean');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (44, 21, 26, 19, 'ZINC OXIDE', '2022-02-14 13:03:07', 89, 'erat fermentum');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (45, 14, 11, 14, 'Octinoxate and Oxybenzone', '2022-05-17 03:52:04', 13, 'pharetra magna vestibulum');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (46, 17, 22, 23, 'Furosemide', '2022-01-29 09:14:40', 36, 'aliquet massa');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (47, 14, 3, 19, 'ONION, CALCIUM SULFIDE', '2021-11-29 18:51:42', 65, 'at feugiat non pretium');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (48, 12, 16, 14, 'Gabapentin', '2021-12-06 02:24:10', 82, 'quam a odio in');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (49, 14, 3, 7, 'Treatment Set TS332487', '2022-03-28 22:40:01', 98, 'tempus vel pede');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (50, 9, 1, 27, 'KETOTIFEN FUMARATE', '2022-04-09 21:44:18', 20, 'rutrum neque');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (51, 12, 17, 29, 'Captopril', '2022-09-09 19:17:59', 96, 'montes nascetur ridiculus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (52, 7, 9, 25, 'Warfarin Sodium', '2022-06-17 16:35:39', 95, 'vel nisl');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (53, 5, 2, 11, 'Acetaminophen, Diphenhydramine Citrate', '2022-02-17 00:06:17', 98, 'sodales scelerisque mauris sit');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (54, 14, 28, 4, 'Carbidopa, Levodopa, and Entacapone', '2022-04-17 03:16:55', 79, 'lacinia sapien');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (55, 24, 8, 1, 'FENTANYL', '2022-11-02 17:27:04', 77, 'sem fusce consequat nulla');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (56, 14, 2, 19, 'propionibacterium acnes', '2022-07-29 20:29:46', 64, 'odio porttitor id');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (57, 2, 7, 22, 'Topiramate', '2022-02-14 08:22:10', 59, 'diam nam tristique tortor');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (58, 14, 2, 17, 'DL-Camphor, L-Menthol, Methylsalicylate', '2022-06-21 14:23:55', 33, 'hac habitasse platea');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (59, 16, 6, 18, 'midazolam hydrochloride', '2022-06-17 06:05:55', 7, 'ridiculus mus etiam vel');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (60, 24, 18, 2, 'Neomycin sulfate, Polymyxin B Sulfate and Dexamethasone', '2022-05-13 21:49:01', 27, 'id pretium iaculis diam');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (61, 16, 19, 20, 'midodrine hydrochloride', '2022-05-30 19:59:27', 79, 'proin eu mi');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (62, 2, 2, 29, 'White Petrolatum', '2022-08-06 03:10:49', 91, 'bibendum felis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (63, 2, 15, 26, 'Aminocaproic Acid', '2022-01-27 12:13:40', 94, 'nullam porttitor lacus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (64, 13, 13, 26, 'Acetazolamide', '2022-11-19 19:27:16', 76, 'quam suspendisse potenti');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (65, 14, 24, 26, 'Western (Sierra) Juniper', '2022-06-13 23:11:28', 43, 'curae nulla dapibus');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (66, 12, 22, 6, 'Montelukast Sodium', '2022-10-07 23:46:14', 61, 'primis in');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (67, 14, 13, 1, 'OCTINOXATE, OXYBENZONE, PADIMATE O', '2022-08-12 12:52:29', 68, 'rhoncus sed vestibulum');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (68, 4, 28, 6, 'desogestrel and ethinyl estradiol', '2022-09-29 10:16:46', 67, 'interdum mauris');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (69, 14, 4, 3, 'Esterified Estrogens and Methyltestosterone', '2022-08-05 11:59:08', 78, 'mattis egestas metus aenean');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (70, 21, 1, 27, 'fluticasone propionate', '2022-05-13 11:10:29', 86, 'quis tortor');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (71, 23, 12, 2, 'Octinoxate', '2022-02-20 14:31:55', 7, 'enim leo rhoncus sed');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (72, 12, 18, 20, 'Primidone', '2022-05-28 11:17:06', 51, 'laoreet ut');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (73, 11, 23, 12, 'Ibuprofen', '2022-06-22 23:37:48', 77, 'eu pede');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (74, 14, 13, 20, 'morphine sulfate', '2021-12-21 19:15:10', 99, 'in hac habitasse');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (75, 3, 12, 13, 'Oxygen', '2022-03-15 22:43:37', 34, 'hac habitasse platea dictumst');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (76, 26, 28, 4, 'Cefdinir', '2022-03-01 23:25:01', 22, 'integer tincidunt ante vel');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (77, 25, 20, 25, 'Diphenhydramine HCl', '2022-05-19 09:50:55', 30, 'magna vulputate luctus cum');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (78, 13, 27, 16, 'glipizide', '2022-04-17 07:44:51', 93, 'amet sapien dignissim');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (79, 17, 14, 15, 'sertraline hydrochloride', '2022-09-23 01:36:08', 78, 'egestas metus aenean');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (80, 18, 4, 13, 'Octinoxate and Titanium Dioxide', '2022-09-27 07:06:54', 62, 'eget eros');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (81, 8, 5, 2, 'Fexofenadine', '2022-03-30 00:33:14', 81, 'felis eu');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (82, 25, 29, 29, 'Lidocaine Hydrochloride', '2022-03-31 03:58:50', 71, 'donec quis orci');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (83, 6, 1, 18, 'ETHYL ALCOHOL', '2022-02-20 03:31:48', 95, 'luctus et ultrices posuere');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (84, 21, 13, 11, 'Diazepam', '2022-05-30 06:19:04', 86, 'nulla sed');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (85, 21, 19, 5, 'SOYBEAN OIL, EGG PHOSPHOLIPIDS, and GLYCERIN', '2022-04-30 17:36:16', 12, 'nec euismod scelerisque');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (86, 22, 10, 27, 'rivaroxaban', '2022-03-10 08:16:25', 64, 'luctus cum sociis');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (87, 21, 13, 11, 'atorvastatin calcium', '2022-11-11 19:49:38', 100, 'venenatis non sodales sed');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (88, 21, 27, 14, 'Paricalcitol', '2022-03-27 15:33:00', 16, 'diam neque vestibulum');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (89, 25, 11, 27, 'Red Snapper', '2022-01-06 14:51:43', 2, 'ligula sit amet');
insert into ElectronicRx (RxID, pharmacyID, prescriberID, patientID, medication, rxDate, quantity, directions) values (90, 3, 7, 1, 'Glycerin', '2021-12-12 01:51:40', 85, 'morbi quis tortor');

--

insert into PaEmails (email, patientID) values ('abadini0@unicef.org', 1);
insert into PaEmails (email, patientID) values ('kcutford1@moonfruit.com', 2);
insert into PaEmails (email, patientID) values ('jshields2@state.tx.us', 3);
insert into PaEmails (email, patientID) values ('dsandyfirth3@mlb.com', 4);
insert into PaEmails (email, patientID) values ('rsouch4@com.com', 5);
insert into PaEmails (email, patientID) values ('lmilner5@nih.gov', 6);
insert into PaEmails (email, patientID) values ('jjull6@wired.com', 7);
insert into PaEmails (email, patientID) values ('trobichon7@nps.gov', 8);
insert into PaEmails (email, patientID) values ('dmebs8@github.com', 9);
insert into PaEmails (email, patientID) values ('cliepina9@goodreads.com', 10);
insert into PaEmails (email, patientID) values ('ayaldena@webs.com', 11);
insert into PaEmails (email, patientID) values ('iwellerb@nhs.uk', 12);
insert into PaEmails (email, patientID) values ('rgreatbanksc@nymag.com', 13);
insert into PaEmails (email, patientID) values ('mmccaughand@bloglovin.com', 14);
insert into PaEmails (email, patientID) values ('yenglefielde@hostgator.com', 15);
insert into PaEmails (email, patientID) values ('cstuckfordf@com.com', 16);
insert into PaEmails (email, patientID) values ('mpopovg@pinterest.com', 17);
insert into PaEmails (email, patientID) values ('tadcockh@1und1.de', 18);
insert into PaEmails (email, patientID) values ('wpantecosti@ask.com', 19);
insert into PaEmails (email, patientID) values ('dfrekej@craigslist.org', 20);
insert into PaEmails (email, patientID) values ('iangelok@paypal.com', 21);
insert into PaEmails (email, patientID) values ('kpurchonl@gmpg.org', 22);
insert into PaEmails (email, patientID) values ('ngreenhousem@hhs.gov', 23);
insert into PaEmails (email, patientID) values ('lbriston@g.co', 24);
insert into PaEmails (email, patientID) values ('lsantoo@vimeo.com', 25);
insert into PaEmails (email, patientID) values ('dfominovp@statcounter.com', 26);
insert into PaEmails (email, patientID) values ('gjackettsq@goo.ne.jp', 27);
insert into PaEmails (email, patientID) values ('mmassowr@github.io', 28);
insert into PaEmails (email, patientID) values ('cjoiceys@rambler.ru', 29);
insert into PaEmails (email, patientID) values ('gpitkinst@multiply.com', 30);
insert into PaEmails (email, patientID) values ('aquarlisu@ask.com', 1);
insert into PaEmails (email, patientID) values ('srannaldv@china.com.cn', 2);
insert into PaEmails (email, patientID) values ('klindenblattw@youku.com', 3);
insert into PaEmails (email, patientID) values ('gtumayanx@answers.com', 4);
insert into PaEmails (email, patientID) values ('mtrappey@ezinearticles.com', 5);

--
insert into PaPhoneNumbers (number, patientID) values ('873-476-1087', 1);
insert into PaPhoneNumbers (number, patientID) values ('437-618-2162', 2);
insert into PaPhoneNumbers (number, patientID) values ('553-222-0385', 3);
insert into PaPhoneNumbers (number, patientID) values ('626-990-3556', 4);
insert into PaPhoneNumbers (number, patientID) values ('687-294-2801', 5);
insert into PaPhoneNumbers (number, patientID) values ('416-901-6144', 6);
insert into PaPhoneNumbers (number, patientID) values ('562-877-2796', 7);
insert into PaPhoneNumbers (number, patientID) values ('789-988-1318', 8);
insert into PaPhoneNumbers (number, patientID) values ('405-773-9023', 9);
insert into PaPhoneNumbers (number, patientID) values ('791-989-4551', 10);
insert into PaPhoneNumbers (number, patientID) values ('399-468-6661', 11);
insert into PaPhoneNumbers (number, patientID) values ('257-103-6096', 12);
insert into PaPhoneNumbers (number, patientID) values ('808-881-9897', 13);
insert into PaPhoneNumbers (number, patientID) values ('448-808-9845', 14);
insert into PaPhoneNumbers (number, patientID) values ('264-230-7789', 15);
insert into PaPhoneNumbers (number, patientID) values ('410-532-3414', 16);
insert into PaPhoneNumbers (number, patientID) values ('237-582-7759', 17);
insert into PaPhoneNumbers (number, patientID) values ('240-693-5509', 18);
insert into PaPhoneNumbers (number, patientID) values ('203-314-0858', 19);
insert into PaPhoneNumbers (number, patientID) values ('838-398-1291', 20);
insert into PaPhoneNumbers (number, patientID) values ('546-319-8837', 21);
insert into PaPhoneNumbers (number, patientID) values ('507-734-2117', 22);
insert into PaPhoneNumbers (number, patientID) values ('916-618-4387', 23);
insert into PaPhoneNumbers (number, patientID) values ('809-310-6923', 24);
insert into PaPhoneNumbers (number, patientID) values ('981-889-0951', 25);
insert into PaPhoneNumbers (number, patientID) values ('811-538-5460', 26);
insert into PaPhoneNumbers (number, patientID) values ('953-902-2343', 27);
insert into PaPhoneNumbers (number, patientID) values ('386-737-1610', 28);
insert into PaPhoneNumbers (number, patientID) values ('432-981-6355', 29);
insert into PaPhoneNumbers (number, patientID) values ('225-191-4020', 30);
insert into PaPhoneNumbers (number, patientID) values ('968-595-3668', 1);
insert into PaPhoneNumbers (number, patientID) values ('208-627-3244', 2);
insert into PaPhoneNumbers (number, patientID) values ('857-592-4731', 3);
insert into PaPhoneNumbers (number, patientID) values ('692-374-8620', 4);
insert into PaPhoneNumbers (number, patientID) values ('581-294-3116', 5);

--

insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (1, 18, 26, 1, '2022-06-14 08:23:33', 'ready');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (2, 10, 25, 2, '2022-08-27 09:43:29', 'amet');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (3, 9, 19, 3, '2022-05-02 16:31:01', 'nulla');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (4, 12, 14, 4, '2022-05-13 11:45:22', 'ready');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (5, 12, 27, 5, '2022-04-11 12:30:54', 'lectus');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (6, 14, 6, 6, '2022-10-30 07:12:30', 'non');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (7, 3, 30, 7, '2022-10-20 16:22:28', 'proin');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (8, 1, 16, 8, '2022-04-11 07:38:08', 'ready');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (9, 26, 23, 9, '2022-07-11 06:51:26', 'etiam');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (10, 13, 28, 10, '2022-05-10 06:10:12', 'at');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (11, 26, 21, 11, '2022-01-26 07:06:10', 'nec');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (12, 22, 22, 12, '2022-03-24 11:29:56', 'aliquam');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (13, 18, 28, 13, '2022-09-23 01:39:27', 'nulla');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (14, 21, 3, 14, '2022-04-25 23:42:37', 'ultrices');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (15, 22, 28, 15, '2022-06-22 08:17:05', 'dui');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (16, 16, 23, 16, '2022-11-14 15:34:14', 'est');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (17, 2, 1, 17, '2021-12-05 17:32:04', 'sapien');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (18, 2, 29, 18, '2021-12-08 23:25:07', 'lobortis');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (19, 5, 26, 19, '2021-12-26 18:44:45', 'interdum');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (20, 29, 1, 20, '2022-09-20 05:27:50', 'bibendum');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (21, 29, 16, 21, '2022-09-06 07:38:29', 'mauris');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (22, 24, 14, 22, '2022-02-21 14:00:48', 'in');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (23, 29, 18, 23, '2022-01-19 11:41:16', 'nisl');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (24, 18, 8, 24, '2022-03-13 14:03:20', 'donec');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (25, 23, 6, 25, '2022-01-12 16:03:07', 'amet');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (26, 2, 29, 26, '2022-11-13 05:24:21', 'ready');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (27, 14, 30, 27, '2022-11-12 22:07:38', 'natoque');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (28, 15, 16, 28, '2022-11-11 13:39:51', 'mauris');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (29, 11, 23, 29, '2022-10-29 05:31:19', 'proin');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (30, 15, 13, 30, '2021-12-15 04:54:01', 'sit');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (31, 16, 7, 31, '2022-11-01 17:14:50', 'varius');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (32, 22, 5, 32, '2022-09-06 06:30:06', 'suscipit');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (33, 30, 8, 33, '2022-10-20 10:10:59', 'libero');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (34, 26, 24, 34, '2022-09-04 09:32:47', 'faucibus');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (35, 12, 9, 35, '2022-10-27 11:46:12', 'pede');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (36, 18, 7, 36, '2022-06-21 18:39:41', 'bibendum');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (37, 18, 25, 37, '2022-09-21 14:28:27', 'lacinia');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (38, 16, 16, 38, '2022-08-29 09:30:49', 'quam');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (39, 3, 7, 39, '2022-09-01 08:41:56', 'orci');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (40, 13, 13, 40, '2022-08-16 06:21:45', 'id');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (41, 11, 1, 41, '2021-12-13 22:04:00', 'molestie');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (42, 12, 2, 42, '2022-01-23 16:55:51', 'cubilia');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (43, 2, 12, 43, '2022-06-25 04:43:38', 'consequat');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (44, 15, 9, 44, '2022-04-04 04:41:04', 'ante');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (45, 4, 17, 45, '2022-03-12 21:45:41', 'augue');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (46, 17, 16, 46, '2022-04-03 21:52:18', 'velit');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (47, 10, 25, 47, '2022-06-26 22:00:56', 'nunc');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (48, 5, 15, 48, '2022-11-11 23:28:50', 'curae');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (49, 26, 17, 49, '2022-02-26 14:16:15', 'id');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (50, 14, 6, 50, '2022-03-14 04:55:27', 'dolor');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (51, 19, 20, 51, '2022-08-31 17:48:22', 'mauris');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (52, 24, 8, 52, '2022-01-22 08:31:01', 'maecenas');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (53, 30, 7, 53, '2022-09-01 11:30:04', 'lobortis');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (54, 15, 13, 54, '2022-10-01 04:16:59', 'vestibulum');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (55, 24, 10, 55, '2021-12-22 00:05:31', 'aliquet');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (56, 16, 14, 56, '2022-11-13 08:16:46', 'quis');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (57, 17, 30, 57, '2022-06-09 19:45:40', 'praesent');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (58, 24, 29, 58, '2022-07-06 01:47:39', 'cras');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (59, 24, 13, 59, '2022-06-08 11:56:24', 'maecenas');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (60, 11, 28, 60, '2022-03-01 02:42:14', 'justo');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (61, 15, 16, 61, '2022-10-26 15:25:14', 'nulla');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (62, 29, 8, 62, '2022-08-31 20:00:48', 'amet');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (63, 4, 8, 63, '2022-01-06 00:11:03', 'vel');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (64, 7, 1, 64, '2022-06-09 02:08:54', 'eleifend');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (65, 5, 30, 65, '2022-03-03 01:03:24', 'consequat');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (66, 24, 8, 66, '2022-05-28 18:02:41', 'vehicula');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (67, 24, 4, 67, '2022-06-02 15:14:21', 'non');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (68, 5, 14, 68, '2022-07-05 05:03:59', 'at');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (69, 20, 26, 69, '2022-05-23 02:41:29', 'primis');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (70, 17, 16, 70, '2022-08-25 09:26:43', 'lacinia');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (71, 25, 24, 71, '2022-10-04 12:12:55', 'nulla');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (72, 9, 21, 72, '2022-07-20 17:50:19', 'neque');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (73, 28, 7, 73, '2022-07-15 17:53:59', 'id');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (74, 4, 24, 74, '2021-12-11 21:08:16', 'mauris');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (75, 5, 2, 75, '2022-04-18 04:46:40', 'lorem');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (76, 30, 27, 76, '2022-06-10 02:34:53', 'nulla');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (77, 3, 14, 77, '2022-09-13 00:25:13', 'nunc');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (78, 14, 18, 78, '2022-01-02 15:56:04', 'hac');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (79, 1, 13, 79, '2022-04-12 13:25:12', 'id');
insert into PaOrder (orderID, patientID, insuranceID, pharmacyID, orderDate, orderStatus) values (80, 28, 25, 80, '2022-05-23 06:00:03', 'leo');

--

insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (1, 1, 'Graphical User Interface', 'Sheilah', 'Symms', 'Largo', 'Florida');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (2, 2, 'algorithm', 'Maurita', 'Nelhams', 'Brooklyn', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (3, 3, 'analyzing', 'Emilia', 'Rodman', 'Orlando', 'Florida');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (4, 4, 'Secured', 'Elizabet', 'Aseef', 'Saginaw', 'Michigan');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (5, 5, 'Profit-focused', 'Tarra', 'Clute', 'Macon', 'Georgia');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (6, 6, 'object-oriented', 'Hildy', 'Clohisey', 'Loretto', 'Minnesota');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (7, 7, 'Grass-roots', 'Raddy', 'Sives', 'Harrisburg', 'Pennsylvania');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (8, 8, 'reciprocal', 'Paul', 'Dorrian', 'Fayetteville', 'North Carolina');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (9, 9, 'Visionary', 'Nichole', 'Patton', 'Harrisburg', 'Pennsylvania');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (10, 10, 'zero administration', 'Horatia', 'Corrado', 'Los Angeles', 'California');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (11, 11, 'Robust', 'Elonore', 'Carbett', 'Mobile', 'Alabama');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (12, 12, 'Multi-lateral', 'Dru', 'Trundler', 'Washington', 'District of Columbia');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (13, 13, 'Networked', 'Merrilee', 'Berrington', 'Punta Gorda', 'Florida');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (14, 14, 'leading edge', 'Ambrose', 'Pitts', 'New York City', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (15, 15, 'installation', 'Renate', 'Gaish', 'Jamaica', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (16, 16, 'Re-engineered', 'Perceval', 'Wissbey', 'Tucson', 'Arizona');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (17, 17, 'artificial intelligence', 'Eugenio', 'Dight', 'Miami', 'Florida');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (18, 18, 'firmware', 'Jozef', 'Meade', 'Augusta', 'Georgia');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (19, 19, 'didactic', 'Eugene', 'Papaccio', 'New York City', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (20, 20, 'multi-state', 'Quill', 'Balbeck', 'Flushing', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (21, 21, 'Decentralized', 'Lowell', 'Huggen', 'Washington', 'District of Columbia');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (22, 22, 'capacity', 'Claudelle', 'Antognetti', 'Pocatello', 'Idaho');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (23, 23, 'Inverse', 'Gaye', 'Gilburt', 'Bakersfield', 'California');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (24, 24, 'Versatile', 'Quill', 'Thombleson', 'Visalia', 'California');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (25, 25, 'next generation', 'Bunnie', 'Madigan', 'Toledo', 'Ohio');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (26, 26, 'intangible', 'Adriena', 'Hamblyn', 'New Orleans', 'Louisiana');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (27, 27, 'firmware', 'Ainslee', 'Seaton', 'New York City', 'New York');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (28, 28, 'Pre-emptive', 'Korry', 'Hinz', 'Hagerstown', 'Maryland');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (29, 29, 'Mandatory', 'Rube', 'Rassell', 'Indianapolis', 'Indiana');
insert into PharmacyEmployee (phEmployeeID, pharmacyID, certification, firstName, lastName, city, state) values (30, 30, 'Multi-layered', 'Joyce', 'Sarjant', 'Kansas City', 'Missouri');

--

insert into EmPhoneNumbers (number, phEmployeeID) values ('310-803-2693', 1);
insert into EmPhoneNumbers (number, phEmployeeID) values ('719-498-2400', 2);
insert into EmPhoneNumbers (number, phEmployeeID) values ('741-922-8910', 3);
insert into EmPhoneNumbers (number, phEmployeeID) values ('441-383-4458', 4);
insert into EmPhoneNumbers (number, phEmployeeID) values ('108-378-2817', 5);
insert into EmPhoneNumbers (number, phEmployeeID) values ('451-463-9145', 6);
insert into EmPhoneNumbers (number, phEmployeeID) values ('251-672-5618', 7);
insert into EmPhoneNumbers (number, phEmployeeID) values ('931-492-2738', 8);
insert into EmPhoneNumbers (number, phEmployeeID) values ('321-185-7578', 9);
insert into EmPhoneNumbers (number, phEmployeeID) values ('706-925-1367', 10);
insert into EmPhoneNumbers (number, phEmployeeID) values ('878-466-5491', 11);
insert into EmPhoneNumbers (number, phEmployeeID) values ('725-441-3014', 12);
insert into EmPhoneNumbers (number, phEmployeeID) values ('260-817-8229', 13);
insert into EmPhoneNumbers (number, phEmployeeID) values ('313-478-1565', 14);
insert into EmPhoneNumbers (number, phEmployeeID) values ('973-799-1906', 15);
insert into EmPhoneNumbers (number, phEmployeeID) values ('296-104-9240', 16);
insert into EmPhoneNumbers (number, phEmployeeID) values ('997-894-7071', 17);
insert into EmPhoneNumbers (number, phEmployeeID) values ('555-278-0787', 18);
insert into EmPhoneNumbers (number, phEmployeeID) values ('600-593-5380', 19);
insert into EmPhoneNumbers (number, phEmployeeID) values ('130-304-0711', 20);
insert into EmPhoneNumbers (number, phEmployeeID) values ('876-251-0769', 21);
insert into EmPhoneNumbers (number, phEmployeeID) values ('500-246-3719', 22);
insert into EmPhoneNumbers (number, phEmployeeID) values ('672-186-8133', 23);
insert into EmPhoneNumbers (number, phEmployeeID) values ('101-978-8737', 24);
insert into EmPhoneNumbers (number, phEmployeeID) values ('298-179-8149', 25);
insert into EmPhoneNumbers (number, phEmployeeID) values ('170-627-6135', 26);
insert into EmPhoneNumbers (number, phEmployeeID) values ('625-101-6047', 27);
insert into EmPhoneNumbers (number, phEmployeeID) values ('220-835-5459', 28);
insert into EmPhoneNumbers (number, phEmployeeID) values ('989-607-6530', 29);
insert into EmPhoneNumbers (number, phEmployeeID) values ('141-586-7617', 30);
insert into EmPhoneNumbers (number, phEmployeeID) values ('502-225-4473', 1);
insert into EmPhoneNumbers (number, phEmployeeID) values ('622-924-8851', 2);
insert into EmPhoneNumbers (number, phEmployeeID) values ('556-332-4431', 3);
insert into EmPhoneNumbers (number, phEmployeeID) values ('873-801-2466', 4);
insert into EmPhoneNumbers (number, phEmployeeID) values ('271-470-3812', 5);

--

insert into EmEmails (email, phEmployeeID) values ('ledmundson0@mediafire.com', 1);
insert into EmEmails (email, phEmployeeID) values ('gdalgety1@elpais.com', 2);
insert into EmEmails (email, phEmployeeID) values ('jgoublier2@usatoday.com', 3);
insert into EmEmails (email, phEmployeeID) values ('tcaile3@ucsd.edu', 4);
insert into EmEmails (email, phEmployeeID) values ('fbillson4@nba.com', 5);
insert into EmEmails (email, phEmployeeID) values ('ahigford5@va.gov', 6);
insert into EmEmails (email, phEmployeeID) values ('gkempson6@topsy.com', 7);
insert into EmEmails (email, phEmployeeID) values ('cescala7@ft.com', 8);
insert into EmEmails (email, phEmployeeID) values ('ldymocke8@spotify.com', 9);
insert into EmEmails (email, phEmployeeID) values ('rcarlile9@w3.org', 10);
insert into EmEmails (email, phEmployeeID) values ('awenningtona@biglobe.ne.jp', 11);
insert into EmEmails (email, phEmployeeID) values ('pdwireb@dailymail.co.uk', 12);
insert into EmEmails (email, phEmployeeID) values ('pmeelandc@yolasite.com', 13);
insert into EmEmails (email, phEmployeeID) values ('mstogglesd@pbs.org', 14);
insert into EmEmails (email, phEmployeeID) values ('fgarnalle@elpais.com', 15);
insert into EmEmails (email, phEmployeeID) values ('bbutlerf@craigslist.org', 16);
insert into EmEmails (email, phEmployeeID) values ('cgreenhillg@yahoo.co.jp', 17);
insert into EmEmails (email, phEmployeeID) values ('tafieldh@spiegel.de', 18);
insert into EmEmails (email, phEmployeeID) values ('adyei@usatoday.com', 19);
insert into EmEmails (email, phEmployeeID) values ('tstranksj@storify.com', 20);
insert into EmEmails (email, phEmployeeID) values ('adavenportk@google.ca', 21);
insert into EmEmails (email, phEmployeeID) values ('rmathysl@com.com', 22);
insert into EmEmails (email, phEmployeeID) values ('lnailm@paypal.com', 23);
insert into EmEmails (email, phEmployeeID) values ('ddufaurn@lycos.com', 24);
insert into EmEmails (email, phEmployeeID) values ('dcopestakeo@livejournal.com', 25);
insert into EmEmails (email, phEmployeeID) values ('nplaydonp@moonfruit.com', 26);
insert into EmEmails (email, phEmployeeID) values ('drobensq@ucsd.edu', 27);
insert into EmEmails (email, phEmployeeID) values ('hcolesr@nytimes.com', 28);
insert into EmEmails (email, phEmployeeID) values ('mgarnuls@slashdot.org', 29);
insert into EmEmails (email, phEmployeeID) values ('jmitfordt@bing.com', 30);
insert into EmEmails (email, phEmployeeID) values ('rmapotheru@home.pl', 1);
insert into EmEmails (email, phEmployeeID) values ('gcarinev@marketwatch.com', 2);
insert into EmEmails (email, phEmployeeID) values ('ctubblew@nps.gov', 3);
insert into EmEmails (email, phEmployeeID) values ('aluxonx@bravesites.com', 4);
insert into EmEmails (email, phEmployeeID) values ('scudiffy@about.com', 5);

--

insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (1, 1, 1, 'Etoposide', 41.59, 52);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (2, 2, 2, 'telmisartan and hydrochlorothiazide', 9.68, 48);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (3, 3, 3, 'digoxin', 20.96, 31);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (4, 4, 4, 'Calcium Carbonate', 23.89, 69);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (5, 5, 5, 'Bay Leaf', 19.07, 48);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (6, 6, 6, 'benzethonium chloride and zinc oxide cream', 61.79, 34);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (7, 7, 7, 'ASPERGILLUS NIGER VAR. NIGER', 14.05, 84);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (8, 8, 8, 'Mometasone Furoate', 11.69, 49);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (9, 9, 9, 'SODIUM FLUORIDE', 51.55, 25);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (10, 10, 10, 'Minocycline Hydrochloride', 80.78, 13);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (11, 11, 11, 'ATORVASTATIN CALCIUM', 3.6, 60);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (12, 12, 12, 'Byronia, Chamomilla, Gelsemium Sempervirens, Passiflora', 84.36, 40);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (13, 13, 13, 'TITANIUM DIOXIDE, OCTINOXATE', 75.21, 15);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (14, 14, 14, 'Lamotrigine', 94.09, 25);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (15, 15, 15, 'Papaya', 91.64, 27);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (16, 16, 16, 'Indomethacin', 55.87, 70);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (17, 17, 17, 'Triamcinolone Acetonide', 85.88, 89);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (18, 18, 18, 'TITANIUM DIOXIDE', 24.98, 73);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (19, 19, 19, 'Acetaminophen, Dextromethorphan', 12.23, 30);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (20, 20, 20, 'Lombardy Poplar', 65.92, 75);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (21, 21, 21, 'Epicoccum nigrum', 68.0, 70);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (22, 22, 22, 'Clonidine HYDROCHLORIDE', 80.94, 62);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (23, 23, 23, 'Rosuvastatin calcium', 85.98, 27);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (24, 24, 24, 'TITANIUM DIOXIDE and ZINC OXIDE', 69.53, 37);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (25, 25, 25, 'Perindopril Erbumine', 42.06, 71);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (26, 26, 26, 'hydrocortisone', 84.61, 38);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (27, 27, 27, 'Neomycin sulfate, Polymyxin B Sulfate and Hydrocortisone', 26.06, 69);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (28, 28, 28, 'California Mugwort', 96.67, 91);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (29, 29, 29, 'Sodium Fluoride', 62.78, 66);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (30, 30, 30, 'TRICLOCARBAN', 87.19, 92);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (31, 31, 31, 'Bacitracin Zinc, Neomycin Sulfate, Polymyxin B', 75.6, 73);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (32, 32, 32, 'Galantamine hydrobromide', 55.32, 48);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (33, 33, 33, 'OCTINOXATE and TITANIUM DIOXIDE', 85.4, 65);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (34, 34, 34, 'Octinoxate and Titanium Dioxide', 2.62, 51);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (35, 35, 35, 'Metformin Hydrochloride', 2.0, 97);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (36, 36, 36, 'ACTIVATED CHARCOAL', 2.61, 34);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (37, 37, 37, 'Tolnaftate', 9.86, 45);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (38, 38, 38, 'Cocklebur', 84.25, 77);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (39, 39, 39, 'atropine sulfate', 58.22, 67);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (40, 40, 40, 'ALLANTOIN', 54.21, 62);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (41, 41, 41, 'THYROID', 65.2, 13);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (42, 42, 42, 'Lidocaine Hydrochloride', 90.29, 65);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (43, 43, 43, 'Arnica Montana, Calcium Sulfide', 91.07, 94);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (44, 44, 44, 'Potassium Chloride', 50.24, 38);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (45, 45, 45, 'silver sulfadiazine', 66.69, 79);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (46, 46, 46, 'Benzonatate', 59.67, 2);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (47, 47, 47, 'Echinacea Thuja', 96.7, 77);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (48, 48, 48, 'miconazole nitrate', 59.9, 90);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (49, 49, 49, 'CITRUS CYDONIA 5%', 41.58, 37);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (50, 50, 50, 'diphenhydramine citrate, ibuprofen', 24.15, 47);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (51, 51, 51, 'Loxapine Succinate', 90.63, 5);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (52, 52, 52, 'fluorescein sodium', 84.16, 30);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (53, 53, 53, 'cilostazol', 65.23, 30);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (54, 54, 54, 'Triclosan', 24.13, 78);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (55, 55, 55, 'MENTHOL', 32.43, 94);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (56, 56, 56, 'mucor racemosus ', 22.99, 28);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (57, 57, 57, 'Ondansetron Hydrochloride', 51.62, 13);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (58, 58, 58, 'Cantaloupe', 84.84, 18);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (59, 59, 59, 'Divalproex Sodium', 73.59, 87);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (60, 60, 60, 'mebendazole', 29.6, 54);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (61, 61, 61, 'Dextromethorphan HBr, Guaifenesin', 90.71, 61);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (62, 62, 62, 'ACETAMINOPHEN', 36.32, 53);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (63, 63, 63, 'Zidovudine', 23.14, 18);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (64, 64, 64, 'Camphor (Natural)', 42.65, 9);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (65, 65, 65, 'Sulfamethoxazole and Trimethoprim', 32.66, 49);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (66, 66, 66, 'DIMENHYDRINATE', 65.67, 19);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (67, 67, 67, 'Benzocaine, Zinc Chloride', 84.16, 14);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (68, 68, 68, 'Metoclopramide', 95.19, 70);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (69, 69, 69, 'IFOSFAMIDE', 76.02, 31);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (70, 70, 70, 'Metoclopramide', 37.69, 72);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (71, 71, 71, 'Acetaminophen', 50.66, 3);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (72, 72, 72, 'Miconazole Nitrate', 71.82, 58);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (73, 73, 73, 'Risperidone', 34.02, 48);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (74, 74, 74, 'alcohol', 82.18, 11);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (75, 75, 75, 'Miconazole Nitrate', 67.18, 40);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (76, 76, 76, 'Granisetron Hydrochloride', 87.0, 92);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (77, 77, 77, 'Undecylenic Acid', 98.83, 20);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (78, 78, 78, 'doxorubicin hydrochloride', 33.99, 66);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (79, 79, 79, 'Titanium Dioxide', 70.04, 88);
insert into OrderItem (orderItemID, orderID, RxID, name, price, quantity) values (80, 80, 80, 'Anacardium orientale, Antimon.', 93.49, 70);

--

insert into Product (productID, wholesalerID, name, price) values (1, 1, 'Octinoxate and Titanium Dioxide', 43.27);
insert into Product (productID, wholesalerID, name, price) values (2, 2, 'DEXTROSE MONOHYDRATE', 21.77);
insert into Product (productID, wholesalerID, name, price) values (3, 3, 'Oxygen', 23.83);
insert into Product (productID, wholesalerID, name, price) values (4, 4, 'Ibuprofen', 92.95);
insert into Product (productID, wholesalerID, name, price) values (5, 5, 'DIPHENHYDRAMINE HYDROCHLORIDE', 44.02);
insert into Product (productID, wholesalerID, name, price) values (6, 6, 'Salicylic Acid', 17.91);
insert into Product (productID, wholesalerID, name, price) values (7, 7, 'Bacitracin Zinc, Neomycin Sulfate, Polymyxin B Sulfate, and Pramoxine Hydrochloride', 23.88);
insert into Product (productID, wholesalerID, name, price) values (8, 8, 'Aceticum acidum, Colchicum autumnale, Lacticum acidum', 27.31);
insert into Product (productID, wholesalerID, name, price) values (9, 9, 'Enalapril Maleate', 56.37);
insert into Product (productID, wholesalerID, name, price) values (10, 10, 'HYDROCODONE BITARTRATE AND ACETAMINOPHEN', 96.47);
insert into Product (productID, wholesalerID, name, price) values (11, 11, 'Furosemide', 83.82);
insert into Product (productID, wholesalerID, name, price) values (12, 12, 'PETROLATUM', 65.19);
insert into Product (productID, wholesalerID, name, price) values (13, 13, 'Penicillin V Potassium', 75.14);
insert into Product (productID, wholesalerID, name, price) values (14, 14, 'Tramadol Hydrochloride', 4.18);
insert into Product (productID, wholesalerID, name, price) values (15, 15, 'Benzocaine', 90.67);
insert into Product (productID, wholesalerID, name, price) values (16, 16, 'LIDOCAINE', 33.04);
insert into Product (productID, wholesalerID, name, price) values (17, 17, 'Diethylpropion hydrochloride', 64.06);
insert into Product (productID, wholesalerID, name, price) values (18, 18, 'Aethusa cynapium, Allium sativum, Baptisia tinctoria', 7.71);
insert into Product (productID, wholesalerID, name, price) values (19, 19, 'Venlafaxine Hydrochloride', 51.29);
insert into Product (productID, wholesalerID, name, price) values (20, 20, 'Clonazepam', 27.28);
insert into Product (productID, wholesalerID, name, price) values (21, 21, 'nifedipine', 71.36);
insert into Product (productID, wholesalerID, name, price) values (22, 22, 'cetirizine hydrochloride', 71.02);
insert into Product (productID, wholesalerID, name, price) values (23, 23, 'Acyclovir and Hydrocortisone', 85.68);
insert into Product (productID, wholesalerID, name, price) values (24, 24, 'ALLIUM CEPA, EUPHRASIA OFFICINALIS, STICTA', 39.12);
insert into Product (productID, wholesalerID, name, price) values (25, 25, 'Lovastatin', 80.66);
insert into Product (productID, wholesalerID, name, price) values (26, 26, 'Propoxyphene Hydrochloride', 74.03);
insert into Product (productID, wholesalerID, name, price) values (27, 27, 'Titanium Dioxide, Zinc Oxide', 80.3);
insert into Product (productID, wholesalerID, name, price) values (28, 28, 'Citalopram', 40.2);
insert into Product (productID, wholesalerID, name, price) values (29, 29, 'Arnica Montana', 53.4);
insert into Product (productID, wholesalerID, name, price) values (30, 30, 'SODIUM CHLORIDE', 34.93);

--

insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (1, 1, '2022-07-01 03:38:03', 'amet lobortis sapien sapien non');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (2, 2, '2021-12-15 22:08:02', 'fusce consequat nulla nisl');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (3, 3, '2022-02-21 16:45:45', 'blandit nam nulla integer');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (4, 4, '2022-07-18 11:21:04', 'erat curabitur gravida nisi at');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (5, 5, '2022-06-03 23:35:18', 'pede libero quis orci nullam');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (6, 6, '2022-04-07 13:07:57', 'justo in blandit ultrices enim');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (7, 7, '2022-04-11 06:47:29', 'vel pede morbi porttitor lorem');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (8, 8, '2022-07-14 07:43:41', 'tortor sollicitudin mi sit amet');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (9, 9, '2022-07-10 14:52:09', 'donec vitae nisi nam ultrices');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (10, 10, '2022-08-13 03:09:30', 'condimentum neque sapien placerat ante');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (11, 11, '2022-07-14 23:40:51', 'nulla mollis molestie lorem');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (12, 12, '2022-06-15 13:56:09', 'interdum venenatis turpis enim');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (13, 13, '2022-03-14 15:17:26', 'auctor sed tristique in');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (14, 14, '2022-11-08 03:25:25', 'risus auctor sed tristique in');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (15, 15, '2022-02-28 05:25:42', 'lacus purus aliquet at');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (16, 16, '2022-10-29 07:01:55', 'nunc donec quis orci eget');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (17, 17, '2021-11-23 04:56:25', 'lacus morbi sem mauris laoreet');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (18, 18, '2022-07-22 23:48:22', 'molestie lorem quisque ut');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (19, 19, '2022-01-26 11:41:07', 'nisl venenatis lacinia aenean');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (20, 20, '2021-11-26 02:50:40', 'habitasse platea dictumst aliquam');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (21, 21, '2022-10-16 08:44:31', 'ipsum dolor sit amet');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (22, 22, '2022-04-02 08:24:44', 'integer a nibh in');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (23, 23, '2022-08-12 17:47:10', 'ut massa volutpat convallis morbi');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (24, 24, '2022-07-14 09:08:45', 'consequat varius integer ac leo');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (25, 25, '2022-11-17 06:58:44', 'sit amet erat nulla');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (26, 26, '2022-07-24 10:45:02', 'eu magna vulputate luctus');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (27, 27, '2022-07-30 10:08:58', 'dolor quis odio consequat');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (28, 28, '2022-01-16 10:42:03', 'augue a suscipit nulla elit');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (29, 29, '2022-10-11 16:08:47', 'sodales sed tincidunt eu');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (30, 30, '2022-05-31 13:16:33', 'quam sapien varius ut');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (31, 31, '2022-06-18 01:12:41', 'pellentesque at nulla suspendisse');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (32, 32, '2022-10-08 21:03:59', 'luctus et ultrices posuere');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (33, 33, '2022-04-04 16:49:53', 'non interdum in ante');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (34, 34, '2022-08-09 03:56:03', 'curae donec pharetra magna vestibulum');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (35, 35, '2022-05-21 00:34:24', 'vel accumsan tellus nisi');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (36, 36, '2022-03-21 22:12:24', 'vestibulum ac est lacinia nisi');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (37, 37, '2021-12-09 03:57:20', 'augue luctus tincidunt nulla mollis');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (38, 38, '2022-07-28 12:48:42', 'nunc proin at turpis');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (39, 39, '2022-08-30 14:30:59', 'in felis eu sapien');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (40, 40, '2022-02-24 09:50:58', 'duis bibendum morbi non');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (41, 41, '2022-10-24 21:00:10', 'leo maecenas pulvinar lobortis');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (42, 42, '2022-10-04 10:39:31', 'eleifend luctus ultricies eu');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (43, 43, '2022-10-29 05:19:48', 'nunc vestibulum ante ipsum');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (44, 44, '2022-04-23 19:45:19', 'eu tincidunt in leo');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (45, 45, '2022-06-13 17:29:46', 'odio in hac habitasse platea');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (46, 46, '2022-03-20 21:44:30', 'at velit eu est');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (47, 47, '2022-10-30 02:09:36', 'consequat metus sapien ut nunc');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (48, 48, '2022-06-13 16:09:51', 'quisque ut erat curabitur');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (49, 49, '2022-01-29 17:10:05', 'justo sit amet sapien');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (50, 50, '2022-10-16 14:27:48', 'tristique fusce congue diam');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (51, 51, '2022-03-20 11:29:25', 'pretium iaculis justo in');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (52, 52, '2022-05-14 01:33:54', 'nulla facilisi cras non velit');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (53, 53, '2021-12-16 17:12:54', 'ac diam cras pellentesque');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (54, 54, '2022-04-17 10:32:48', 'parturient montes nascetur ridiculus');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (55, 55, '2022-09-21 14:12:46', 'massa id lobortis convallis tortor');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (56, 56, '2022-08-12 09:40:57', 'rutrum rutrum neque aenean auctor');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (57, 57, '2022-11-19 05:48:54', 'id luctus nec molestie');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (58, 58, '2022-08-19 17:31:40', 'sed lacus morbi sem mauris');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (59, 59, '2021-12-30 07:01:03', 'varius nulla facilisi cras non');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (60, 60, '2022-06-15 10:40:02', 'sit amet nulla quisque arcu');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (61, 61, '2022-09-08 20:12:03', 'volutpat sapien arcu sed');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (62, 62, '2022-08-13 20:14:48', 'amet diam in magna');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (63, 63, '2022-05-20 23:11:30', 'morbi quis tortor id nulla');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (64, 64, '2022-10-10 22:27:37', 'et eros vestibulum ac');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (65, 65, '2022-07-02 21:47:25', 'morbi odio odio elementum eu');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (66, 66, '2022-07-17 00:09:08', 'posuere nonummy integer non velit');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (67, 67, '2022-04-15 15:29:08', 'odio justo sollicitudin ut');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (68, 68, '2022-03-10 19:21:33', 'maecenas tristique est et tempus');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (69, 69, '2022-10-08 08:05:57', 'accumsan tortor quis turpis');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (70, 70, '2022-01-31 19:01:17', 'ut nunc vestibulum ante');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (71, 71, '2021-12-10 13:09:50', 'nulla integer pede justo');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (72, 72, '2022-10-29 15:09:09', 'vivamus metus arcu adipiscing');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (73, 73, '2022-02-17 11:41:35', 'convallis nunc proin at turpis');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (74, 74, '2022-01-19 05:30:59', 'pede malesuada in imperdiet et');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (75, 75, '2022-01-06 12:49:03', 'sapien placerat ante nulla justo');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (76, 76, '2022-07-17 01:09:21', 'placerat ante nulla justo aliquam');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (77, 77, '2022-05-04 23:46:05', 'arcu adipiscing molestie hendrerit at');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (78, 78, '2022-07-02 00:30:30', 'orci vehicula condimentum curabitur in');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (79, 79, '2022-04-30 16:47:10', 'amet sapien dignissim vestibulum vestibulum');
insert into Shipment (shipmentID, pharmacyID, shipDate, shipStatus) values (80, 80, '2022-03-02 08:45:21', 'ut erat curabitur gravida nisi');

--

insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (1, 1, 1, 'Warfarin Sodium', 74.21, 69);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (2, 2, 2, 'Propranolol Hydrochloride', 7.46, 60);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (3, 3, 3, 'Duloxetine hydrochloride', 21.67, 64);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (4, 4, 4, 'NAFTIFINE HYDROCHLORIDE', 16.4, 17);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (5, 5, 5, 'Diphenhydramine HCl', 72.97, 80);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (6, 6, 6, 'Leucovorin Calcium', 49.46, 15);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (7, 7, 7, 'DEXTROMETHORPHAN HYDROBROMIDE, GUAIFENESIN', 93.24, 59);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (8, 8, 8, 'topiramate', 64.8, 63);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (9, 9, 9, 'OCTINOXATE', 84.13, 46);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (10, 10, 10, 'Clopidogrel Bisulfate', 96.39, 12);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (11, 11, 11, 'THUJA OCCIDENTALIS LEAFY TWIG', 6.87, 63);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (12, 12, 12, 'bisacodyl', 9.66, 83);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (13, 13, 13, 'Dopamine Hydrochloride', 70.52, 56);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (14, 14, 14, 'House Dust', 63.99, 100);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (15, 15, 15, 'Cefuroxime Axetil', 48.82, 57);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (16, 16, 16, 'HYDROCODONE BITARTRATE AND ACETAMINOPHEN', 22.98, 74);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (17, 17, 17, 'OXYCODONE HYDROCHLORIDE AND ACETAMINOPHEN', 10.87, 15);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (18, 18, 18, 'losartan potassium', 65.14, 100);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (19, 19, 19, 'Octinoxate, Octisalate', 72.16, 60);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (20, 20, 20, 'Diphenhydramine HCl', 88.13, 91);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (21, 21, 21, 'fenofibrate', 51.95, 22);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (22, 22, 22, 'Fentanyl Citrate', 25.52, 16);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (23, 23, 23, 'montelukast sodium', 58.52, 32);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (24, 24, 24, 'Atovaquone and Proguanil Hydrochloride', 9.22, 93);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (25, 25, 25, 'Ergocalciferol', 75.34, 13);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (26, 26, 26, 'DOCUSATE SODIUM', 44.34, 54);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (27, 27, 27, 'HYDROCODONE BITARTRATE AND ACETAMINOPHEN', 9.7, 98);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (28, 28, 28, 'Naproxen sodium', 29.02, 42);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (29, 29, 29, 'Topiramate', 88.94, 35);
insert into ShipmentItem (shipmentItemID, shipmentID, productID, name, price, quantity) values (30, 30, 30, 'ALCOHOL', 81.09, 88);