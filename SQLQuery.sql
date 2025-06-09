USE vrushabhdb;
drop table df_orders;



CREATE TABLE dbo.df_orders (
    [order id]      INT             NOT NULL PRIMARY KEY,
    [order date]    DATE            NULL,
    [ship mode]     VARCHAR(MAX)    NULL,
    segment         VARCHAR(MAX)    NULL,
    country         VARCHAR(MAX)    NULL,
    city            VARCHAR(MAX)    NULL,
    state           VARCHAR(MAX)    NULL,
    [postal code]   VARCHAR(20)     NULL,
    region          VARCHAR(MAX)    NULL,
    category        VARCHAR(MAX)    NULL,
    [sub category]  VARCHAR(MAX)    NULL,
    [product id]    VARCHAR(MAX)    NULL,
    quantity        INT             NULL,
    discount        DECIMAL(5,2)    NULL,
    [sale price]    DECIMAL(10,2)   NULL,
    profit          DECIMAL(10,2)   NULL
);

SELECT * FROM df_orders;
 

 --find top 10 highest revenue generating product
 select top 10 [product id] ,SUM([sale price]) as sales
 from df_orders
 group by [product id]
 order by sales desc

 --Find Top 5 Highest Selling Product In Each Region
 
--select distinct [region] from df_orders
WITH city AS (
    SELECT 
        region,
        [product id],
        SUM([sale price]) AS sales
    FROM df_orders
    GROUP BY region, [product id]
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM city
) AS A
WHERE rn <= 5;


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        YEAR([order date]) AS order_year,
        MONTH([order date]) AS order_month,
        SUM([sale price]) AS sales
    FROM df_orders
    GROUP BY YEAR([order date]), MONTH([order date])
)

SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY order_month
ORDER BY order_month;


----for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        FORMAT([order date], 'yyyyMM') AS order_year_month,
        SUM([sale price]) AS sales
    FROM df_orders
    GROUP BY category, FORMAT([order date], 'yyyyMM')
)

SELECT category, order_year_month, sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;


--which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        [sub category],
        YEAR([order date]) AS order_year,
        SUM(profit) AS total_profit
    FROM df_orders
    GROUP BY [sub category], YEAR([order date])
),
cte2 AS (
    SELECT 
        [sub category],
        SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM cte
    GROUP BY [sub category]
)
SELECT TOP 1 *,
       (profit_2023 - profit_2022) AS profit_growth
FROM cte2
ORDER BY profit_growth DESC;

