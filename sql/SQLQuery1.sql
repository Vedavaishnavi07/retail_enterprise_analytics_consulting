CREATE DATABASE RetailEnterprise;
GO

USE RetailEnterprise;
GO

--CREATING TABLES
--Customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    city VARCHAR(50),
    join_date DATE,
    loyalty_status VARCHAR(20)
);

--Suppliers
CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    lead_time_days INT,
    city VARCHAR(50)
);

--Products
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    brand VARCHAR(50),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

--Stores
CREATE TABLE Stores (
    store_id INT PRIMARY KEY,
    city VARCHAR(50),
    store_size_sqft INT,
    opening_date DATE
);

--Orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    store_id INT,
    discount DECIMAL(5,2),
    payment_mode VARCHAR(20),
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES Stores(store_id)
);

--Order_Items
CREATE TABLE Order_Items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

--Inventory
CREATE TABLE Inventory (
    store_id INT,
    product_id INT,
    stock_available INT,
    reorder_level INT,
    FOREIGN KEY (store_id) REFERENCES Stores(store_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

--IMPORTING TABLES
--Customers
BULK INSERT Customers
FROM 'C:\Retail_Data\Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--Suppliers
BULK INSERT Suppliers
FROM 'C:\Retail_Data\Suppliers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--Products
BULK INSERT Products
FROM 'C:\Retail_Data\Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--Stores
BULK INSERT Stores
FROM 'C:\Retail_Data\Stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--Orders
BULK INSERT Orders
FROM 'C:\Retail_Data\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--Order_Items
BULK INSERT Order_Items
FROM 'C:\Retail_Data\Order_Items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
--Inventory
BULK INSERT Inventory
FROM 'C:\Retail_Data\Inventory.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT 
(SELECT COUNT(*) FROM Customers) AS Customers_Count,
(SELECT COUNT(*) FROM Suppliers) AS Suppliers_Count,
(SELECT COUNT(*) FROM Products) AS Products_Count,
(SELECT COUNT(*) FROM Stores) AS Stores_Count,
(SELECT COUNT(*) FROM Orders) AS Orders_Count,
(SELECT COUNT(*) FROM Order_Items) AS OrderItems_Count,
(SELECT COUNT(*) FROM Inventory) AS Inventory_Count;


--KPI's = It is a measurable value that shows how well a business is performing.Basically they are Business health indicators
--Total Revenue
--Total Orders
--Average Order Value
--Revenue per Store
--Top Customers
--Sales Velocity
--Profit Margin

--Revenue = Quantity × UnitPrice
SELECT 
SUM(oi.Quantity * oi.unit_price) AS Total_Revenue
FROM Order_Items oi;
--Total number of orders
SELECT COUNT(*) AS Total_Orders
FROM Orders;
--Average Order Value(AOV) = Total Revenue ÷ Total Orders
SELECT 
SUM(oi.Quantity * oi.unit_price) / COUNT(DISTINCT o.order_id) AS Average_Order_Value
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
--the answer generates moderate-high ticket retail behavior.
--Why we used count Distinct?
--Orders table = 15,000 rows
--Order_Items has multiple rows per order
--If we used COUNT(*), it would count line items, not orders.
--Because Order_Items is a line-level fact table, and an order can have multiple rows. 
--So I used COUNT(DISTINCT OrderID) to avoid inflating the denominator.”

--Revenue per Store
--This tells - Which stores are performing best?
--Which stores are underperforming?
--Where should we invest more?
SELECT 
s.city,
SUM(oi.Quantity * oi.unit_price) AS Store_Revenue
FROM Order_Items oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Stores s ON o.store_id = s.store_id
GROUP BY s.city
ORDER BY Store_Revenue DESC; --HYD 
--Hyderabad is the top-performing store.
--Difference between Hyderabad and Chennai: 4.1 million revenue gap.
--How did you analyze store performance?
--I joined transaction fact table with store dimension and aggregated revenue grouped by store to evaluate contribution and ranking

--Why HYD is Highest?
-- Is it Higher Order Volume?
SELECT 
s.city,
COUNT(DISTINCT o.order_id) AS Total_Orders
FROM Orders o
JOIN Stores s ON o.store_id = s.store_id
GROUP BY s.city
ORDER BY Total_Orders DESC;
--hyd has highest order volume

--Is It Higher Average Order Value?
SELECT 
s.city,
SUM(oi.Quantity * oi.unit_price) / COUNT(DISTINCT o.order_id) AS Store_AOV
FROM Order_Items oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Stores s ON o.store_id = s.store_id
GROUP BY s.city
ORDER BY Store_AOV DESC;
--Mumbai is highest and hyd is second highest

--Is It Higher Customer Base?
SELECT 
s.city,
COUNT(DISTINCT o.customer_id) AS Unique_Customers
FROM Orders o
JOIN Stores s ON o.store_id = s.store_id
GROUP BY s.city
ORDER BY Unique_Customers DESC;
--yes hyd has higher customer base than bnglr by 2 cus

--Is It Product Mix?
SELECT 
s.city,
p.category,
SUM(oi.Quantity * oi.unit_price) AS Category_Revenue
FROM Order_Items oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Stores s ON o.store_id = s.store_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY s.city, p.category
ORDER BY s.city, Category_Revenue DESC;
--Hyderabad leads in revenue primarily due to higher order volume combined with 
--balanced performance across all product categories.While Mumbai has a higher average order value, 
--its lower transaction volume limits overall revenue. 
--Hyderabad benefits from both strong customer participation and consistent multi-category contribution.

--TOP Customers
--Revenue Per Customer
SELECT 
o.customer_id,
SUM(oi.Quantity * oi.unit_price) AS Customer_Revenue
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY Customer_Revenue DESC;
--Top 10 Customers
SELECT TOP 10
o.customer_id,
SUM(oi.Quantity * oi.unit_price) AS Customer_Revenue
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY Customer_Revenue DESC;
--Top 10–20% customers often generate 60–80% revenue. 
--This is called: Pareto Principle (80/20 Rule).
--1 Customer = CustomerID 2469 = 43,959.62
--10 Customer = CustomerID 2277 = 35,161.07
--Difference between #1 and #10:
--43,959.62 − 35,161.07 = ₹8,798.55 
--THEREFORE 20% diff, means No extreme outlier, Revenue is relatively well distributed among top buyers, No single customer dominating
--Out of total revenue = (38,650,538.95), How much % is contributed by Top 10 customers?
SELECT 
SUM(Customer_Revenue) AS Top10_Revenue
FROM (
    SELECT TOP 10
    o.customer_id,
    SUM(oi.Quantity * oi.unit_price) AS Customer_Revenue
    FROM Orders o
    JOIN Order_Items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    ORDER BY Customer_Revenue DESC
) t;
--(382,350.55÷38,650,538.95)×100 = 0.99% which means Top 10 customers contribute ONLY ~1%, This is EXTREMELY LOW
--Revenue is highly distributed
--Is your business dependent on high-value customers?
--No. Top 10 customers contribute only 1% of total revenue, indicating a highly diversified and 
--stable revenue base driven by large customer volume rather than concentration risk.
--% does Top 100 customers contribution?
SELECT 
SUM(Customer_Revenue) AS Top100_Revenue
FROM (
    SELECT TOP 100
    o.customer_id,
    SUM(oi.Quantity * oi.unit_price) AS Customer_Revenue
    FROM Orders o
    JOIN Order_Items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    ORDER BY Customer_Revenue DESC
) t;
--(3,037,886.97÷38,650,538.95)×100 = 7.86% STILL VERY LOW CONTRIBUTION

--Sales Velocity tells How fast products are moving
--Sales Velocity = Total Quantity Sold
SELECT 
SUM(Quantity) AS Total_Units_Sold
FROM Order_Items;

--Profit Margin
SELECT 
SUM(oi.Quantity * oi.unit_price) AS Revenue,
SUM(oi.Quantity * p.cost_price) AS COGS,
SUM(oi.Quantity * (oi.unit_price - p.cost_price)) AS Profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id;
--Profit Margin = (Profit÷Revenue)×100 = 22.90%

-- NEXT PHASE - Product & Category Performance Analysis.
--What drives revenue?, What drives profit?, Where are margins strong or weak?, Which products matter most?
--Which category generates the most revenue? Revenue=Quantity×SellingPrice
SELECT 
    p.category,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
--Profit by Category? --Profit = Money left after removing cost
--Profit=(SellingPrice−CostPrice)×Quantity
SELECT 
    p.category,
    SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;
--Profit Margin % by Category(Some categories generate high revenue but low margin
--Profit Margin=(Profit÷Revenue)×100
SELECT 
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS profit,
    
    (SUM(oi.quantity * (oi.unit_price - p.cost_price)) * 100.0 /
     SUM(oi.quantity * oi.unit_price)) AS profit_margin_percent
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY profit_margin_percent DESC;
--Where should we focus growth?
--Option 1 – Revenue Growth Strategy - Increase Pharma and Clothing volume.
--Option 2 – Profit Maximization Strategy - Increase Electronics sales.

--Revenue by Sub-Category
SELECT 
    p.category,
    p.sub_category,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY revenue DESC;
--Grocery = Sub3 - 3,951,304.81 (Highest overall) Sub2 - 3,412,526.21 Sub1 - 2,152,946.59 (Weakest in Grocery)
--Pharma = Sub1 - 3,785,516.20 Sub3 - 3,649,381.62 Sub2 - 2,544,145.72 (Lowest in Pharma)
--Electronics = Sub2 - 3,600,423.09 Sub3 - 3,275,255.92 - Sub1 - 2,500,027.62 (Lowest in Electronics)
--Clothing = Sub3 - 3,599,915.46 Sub1 - 3,425,729.26 Sub2 - 2,753,366.45 (Lowest in Clothing)
--No extreme domination.
--All sub-categories in each category are for Promotion, Pricing review, Stock optimization,Display placement review
--“Where should we focus category strategy?”
--Protect Grocery Sub3 (core volume engine).
--Push Electronics Sub2 (high margin + strong revenue).
--Review low-performing sub-categories for optimization.

--Profit by Sub-Category
SELECT 
    p.category,
    p.sub_category,
    SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY profit DESC;
--Comparing Both (Revenue by Sub-Category and Profit by Sub-Category)
--1)Volume Drivers = Grocery Sub3 and Pharma Sub1 (PTOTECT AND EXPAND)
--2)Profit Maximizers = Clothing Sub3 and Electronics Sub2 (MAINTAIN AND OPTIMIZE)
--3)Weak Segments = Grocery Sub1 and Pharma Sub2 (REVIEW AND FIX)

--Top 10 Products by revenue
SELECT TOP 10
    p.product_id,
    p.category,
    p.sub_category,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.category, p.sub_category
ORDER BY total_revenue DESC;

--Top 10 Products by Profit
SELECT TOP 10
    p.product_id,
    p.category,
    p.sub_category,
    SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.category, p.sub_category
ORDER BY total_profit DESC;

--Low-Performing Products
SELECT TOP 10
    p.product_id,
    p.category,
    p.sub_category,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.category, p.sub_category
ORDER BY total_revenue ASC;
--Product 212 is both:Highest revenue,Highest profit and even 216 is dng great
--170, 228, 142, 160 = Low demand, Low contribution, Shelf-space waste
--So we can Bundle with high sellers, Discount to clear stock, Remove from catalog, Replace with new SKU
--Protect  (212, 163), Review pricing for weak ones, Analyze demand patterns before discontinuing

--NEXT PHASE - DATA QUALITY & CLEANING PIPELINE
--Data Quality Checklist
--NULL CHECKS (We don’t know who placed the order)
SELECT COUNT(*) AS Null_Customer_IDs
FROM Orders
WHERE customer_id IS NULL;
--in orderitems
SELECT COUNT(*) AS Null_Product_IDs
FROM Order_Items
WHERE product_id IS NULL;
-- CHECKING DUPLICATE ORDERS (If order_id appears twice in Orders:Revenue gets double counted)
SELECT order_id, COUNT(*)
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;
--REFERENTIAL INTEGRITY CHECK (Orders referencing non-existing customers fr example Order has customer_id = 9999) 
SELECT COUNT(*) 
FROM Orders o
LEFT JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
--NEGATIVE OR ZERO CHECKS (Negative quantity = impossible, Zero price = revenue distortion)
SELECT COUNT(*) 
FROM Order_Items
WHERE quantity <= 0 OR unit_price <= 0;
--SELLING PRICE LOWER THAN COST
SELECT COUNT(*)
FROM Products
WHERE selling_price < cost_price;