DROP DATABASE IF Exists cs_store;
CREATE DATABASE CS_Store;
USE CS_Store;
CREATE TABLE Customers(
        birth_day DATE,
        first_name VARCHAR(20),
        last_name VARCHAR(20),
        c_id INT,
        CONSTRAINT PK_Customers PRIMARY KEY (c_id)
);
CREATE TABLE Employees(
        birth_day DATE,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    e_id INT,
    CONSTRAINT PK_Employees PRIMARY KEY(e_id)
);
CREATE TABLE Transactions(
        e_id INT,
    c_id INT,
    date DATE,
    t_id INT,
    CONSTRAINT PK_Employees PRIMARY KEY(t_id),
    CONSTRAINT FK_Employees FOREIGN KEY (e_id) REFERENCES Employees(e_id),
        CONSTRAINT FK_Customers FOREIGN KEY (c_id) REFERENCES Customers(c_id)
     );
CREATE TABLE Items(
        price_for_each_amount INT,
		amount INT,
    name VARCHAR(20),
    CONSTRAINT PK_Items PRIMARY KEY (name)
    );
CREATE TABLE Promotions(
        discount INT,
    p_id INT,
    CONSTRAINT PK_Promotions PRIMARY KEY (p_id)
    );
CREATE TABLE ItemsInPromotions(
        name VARCHAR(20),
    p_id INT,
    amount INT,
    CONSTRAINT FK_ItemsInPromotions FOREIGN KEY (name) REFERENCES Items(name),
    CONSTRAINT FK_ItemsInPromotions2 FOREIGN KEY (p_id) REFERENCES Promotions(p_id)
    );
CREATE TABLE ItemsInTransactions(
        name VARCHAR(20),
    t_id INT,
    amount INT,
    CONSTRAINT FK_ItemsInTransactions FOREIGN KEY (name) references Items(name),
    CONSTRAINT FK_ItemsInTransactions2 FOREIGN KEY (t_id) references Transactions(t_id)
    );
CREATE VIEW DavidSoldTo AS (
        SELECT DISTINCT
                Customers.birth_day, Customers.first_name, Customers.last_name
        FROM Employees
        INNER JOIN Transactions ON Employees.e_id = Transactions.e_id
        INNER JOIN Customers on Transactions.c_id = Customers.c_id
        WHERE Employees.first_name = 'David'
        ORDER BY Customers.birth_day ASC
    );
CREATE VIEW CustomerInShop AS (
        SELECT DISTINCT
        Customers.birth_day, Customers.first_name, Customers.last_name
        FROM Transactions
    INNER JOIN Customers on Transactions.c_id = Customers.c_id
        WHERE Transactions.date = '2020-9-07'
);
CREATE VIEW EmployeeInShop AS (
    SELECT DISTINCT
        Employees.birth_day,
        Employees.first_name,
        Employees.last_name
    FROM
        Transactions
	INNER JOIN
        Employees ON Transactions.e_id = Employees.e_id
    WHERE
        (Transactions.date = '2020-9-07'));
CREATE VIEW PeopleInShop AS (
		SELECT *
		FROM CustomerInShop
		UNION
		SELECT *
		FROM EmployeeInShop
		ORDER BY birth_day
	);
CREATE VIEW ItemsLeft AS (
		SELECT DISTINCT
		Items.name, (Items.amount- SUM(ItemsInTransactions.amount)) AS amount_left
		FROM ItemsInTransactions
		INNER JOIN Items on Items.name = ItemsInTransactions.name
        GROUP BY Items.name
	);
CREATE VIEW PromotionItemsSatisfiedByTransactions AS (
		SELECT DISTINCT
        ItemsInTransactions.t_id, ItemsInPromotions.p_id, ItemsInTransactions.name, FLOOR(ItemsInTransactions.amount / ItemsInPromotions.amount) AS number_of_times
        FROM ItemsInPromotions
		INNER JOIN ItemsInTransactions on ItemsInTransactions.name = ItemsInPromotions.name
		ORDER BY ItemsInTransactions.t_id, ItemsInPromotions.p_id, ItemsInTransactions.name
	);
CREATE VIEW PriceOfTransactionBeforeDiscount AS (
		SELECT DISTINCT
        ItemsInTransactions.t_id, SUM(Items.price_for_each_amount* (ItemsInTransactions.amount)) AS total_cost_before_discount
        FROM ItemsInTransactions
        INNER JOIN Items on Items.name = ItemsInTransactions.name
        GROUP BY ItemsInTransactions.t_id
        ORDER BY ItemsInTransactions.t_id
	);
CREATE VIEW DiscountOfPromotionItems AS (
		SELECT DISTINCT
        PromotionItemsSatisfiedByTransactions.t_id, ((PromotionItemsSatisfiedByTransactions.number_of_times) * (Promotions.discount)) AS promo_discount
        FROM PromotionItemsSatisfiedByTransactions
        INNER JOIN Promotions on Promotions.p_id = PromotionItemsSatisfiedByTransactions.p_id
        GROUP BY PromotionItemsSatisfiedByTransactions.t_id
        ORDER BY PromotionItemsSatisfiedByTransactions.t_id
	);
CREATE VIEW PriceOfTransaction AS (
		SELECT DISTINCT
		PriceOfTransactionBeforeDiscount.t_id, (PriceOfTransactionBeforeDiscount.total_cost_before_discount - DiscountOfPromotionItems.promo_discount) AS total_cost
		FROM DiscountOfPromotionItems
		INNER JOIN PriceOfTransactionBeforeDiscount on PriceOfTransactionBeforeDiscount.t_id = DiscountOfPromotionItems.t_id
		ORDER BY PriceOfTransactionBeforeDiscount.t_id
);


-- Data for Customers(birth_day, first_name, last_name, c_id)
INSERT INTO Customers VALUES ('1993-07-11','Victor','Davis',1);
INSERT INTO Customers VALUES ('2001-03-28','Katarina','Williams',2);
INSERT INTO Customers VALUES ('1965-12-11','David','Jones',3);
INSERT INTO Customers VALUES ('1980-10-10','Evelyn','Lee',4);
-- Data for Employees(birth_day, first_name, last_name, e_id)
INSERT INTO Employees VALUES ('1983-09-02','David','Smith',1);
INSERT INTO Employees VALUES ('1990-07-23','Olivia','Brown',2);
INSERT INTO Employees VALUES ('1973-05-11','David','Johnson',3);
INSERT INTO Employees VALUES ('1999-11-21','Mia','Taylor',4);
-- Data for Transactions(e_id*, c_id*, date, t_id)
INSERT INTO Transactions VALUES (1,1,'2020-8-11',1);
INSERT INTO Transactions VALUES (3,1,'2020-8-15',2);
INSERT INTO Transactions VALUES (1,4,'2020-9-01',3);
INSERT INTO Transactions VALUES (2,2,'2020-9-07',4);
INSERT INTO Transactions VALUES (4,3,'2020-9-07',5);
-- Data for Items(price_for_each, amount, name)
INSERT INTO Items VALUES (110,22,'2l of milk');
INSERT INTO Items VALUES (99,30,'6 cans of lemonade');
INSERT INTO Items VALUES (150,20,'Pack of butter');
INSERT INTO Items VALUES (450,13,'Roast chicken');
INSERT INTO Items VALUES (99,30,'Pack of rice');
INSERT INTO Items VALUES (20,50,'Banana');
INSERT INTO Items VALUES (200,30,'3kg sugar');
INSERT INTO Items VALUES (150,15,'Toast bread');
INSERT INTO Items VALUES (150,18,'Earl Grey tea');
-- Data for Promotions(discount, p_id)
INSERT INTO Promotions VALUES (99,1);
INSERT INTO Promotions VALUES (200,2);
INSERT INTO Promotions VALUES (150,3);
INSERT INTO Promotions VALUES (150,4);
-- Data for ItemsInPromotions(name*, p_id*, amount)
INSERT INTO ItemsInPromotions VALUES ('6 cans of lemonade',1,2);
INSERT INTO ItemsInPromotions VALUES ('Roast chicken',2,1);
INSERT INTO ItemsInPromotions VALUES ('Pack of rice',2,1);
INSERT INTO ItemsInPromotions VALUES ('Pack of butter',3,1);
INSERT INTO ItemsInPromotions VALUES ('Toast bread',3,2);
INSERT INTO ItemsInPromotions VALUES ('2l of milk',4,2);
INSERT INTO ItemsInPromotions VALUES ('Banana',4,3);
INSERT INTO ItemsInPromotions VALUES ('3kg sugar',4,2);
-- Data for ItemsInTransactions(name*, t_id*, amount)
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',1,1);
INSERT INTO ItemsInTransactions VALUES ('Roast chicken',1,1);
INSERT INTO ItemsInTransactions VALUES ('Pack of butter',1,1);
INSERT INTO ItemsInTransactions VALUES ('Toast bread',1,1);
INSERT INTO ItemsInTransactions VALUES ('2l of milk',1,2);
INSERT INTO ItemsInTransactions VALUES ('Banana',1,3);
INSERT INTO ItemsInTransactions VALUES ('3kg sugar',1,1);
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',2,5);
INSERT INTO ItemsInTransactions VALUES ('Pack of rice',2,1);
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',3,3);
INSERT INTO ItemsInTransactions VALUES ('Roast chicken',3,2);
INSERT INTO ItemsInTransactions VALUES ('Pack of rice',3,1);
INSERT INTO ItemsInTransactions VALUES ('Pack of butter',3,1);
INSERT INTO ItemsInTransactions VALUES ('2l of milk',4,5);
INSERT INTO ItemsInTransactions VALUES ('Banana',4,20);
INSERT INTO ItemsInTransactions VALUES ('3kg sugar',4,8);
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',5,10);
INSERT INTO ItemsInTransactions VALUES ('Roast chicken',5,10);
INSERT INTO ItemsInTransactions VALUES ('Pack of rice',5,10);
INSERT INTO ItemsInTransactions VALUES ('Pack of butter',5,10);
INSERT INTO ItemsInTransactions VALUES ('Toast bread',5,10);
INSERT INTO ItemsInTransactions VALUES ('2l of milk',5,10);
INSERT INTO ItemsInTransactions VALUES ('Banana',5,10);
INSERT INTO ItemsInTransactions VALUES ('3kg sugar',5,10);
INSERT INTO ItemsInTransactions VALUES ('Earl Grey tea',5,10);