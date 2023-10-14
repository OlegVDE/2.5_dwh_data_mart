-- создаем таблицу с информацией о магазинах (их названия и идентификаторы)
CREATE TABLE IF NOT EXISTS shops (
    shop_id SERIAL PRIMARY KEY,
    shop_name varchar(100) NOT NULL,
    shop_tablename varchar(100) NOT NULL
);


-- создание таблицу для витрины
CREATE TABLE IF NOT EXISTS sales_statistics (
    shop_name VARCHAR(100),
    product_name VARCHAR(255),
    sales_fact INT,
    sales_plan INT,
    sales_fact_sales_plan NUMERIC(100, 2),
    income_fact INT,
    income_plan INT,
    income_fact_income_plan NUMERIC(100, 2)
);


-- доблавляем id-шники для магазинов
ALTER TABLE shop_dns ADD COLUMN IF NOT EXISTS shop_id int DEFAULT 1;

ALTER TABLE shop_mvideo ADD COLUMN IF NOT EXISTS shop_id int DEFAULT 2;

ALTER TABLE shop_sitilink ADD COLUMN IF NOT EXISTS shop_id int DEFAULT 3;


-- сливаем данные всех магазинов во временную таблицу
CREATE TEMP TABLE all_sales AS
select * from shop_dns
UNION
select * from shop_mvideo
UNION
select * from shop_sitilink;


-- запрос создающий данные для витрины
SELECT sh.shop_name, p.product_name, SUM(sales.sales_cnt) sales_fact, SUM(p.plan_cnt) sales_plan, (sales_fact / sales_plan) as 'sales_fact/sales_plan',
	(sales_fact * p.price) income_fact,  (sales_plan * p.price) income_plan, (income_fact / income_plan) as 'income_fact/income_plan'
FROM all_sales as sales
LEFT JOIN shops as sh ON  sales.shop_id = sh.shop_id
LEFT JOIN products as p ON sales.product_id = p.product_id
RIGHT JOIN plan as p ON p.shop_id = sales.shop_id and p.product_id = sales.product_id
GROUP BY (date_trunc('month', "date"), product_id, shop_id)