# Size of table
select count(*)
from car_sales_data;

# Analyzing columns and their values
select * 
from car_sales_data
limit 5;

# Changing date column to datetype
alter table car_sales_data
modify column Dates date;

-- 1. Revenue and Commission Aggregation:
-- What are the aggregate totals of sales and commissions by car make, car models, and time period? How do these totals inform business strategy?

-- Grouping the total sales value and average commission earned by Year, Months, Car_Make and Car_Models
select extract(year from Dates) as Years,
		extract(month from Dates) as Months,
		Car_Make,
        Car_Model,
        sum(Sale_Price) as Total_Sales,
        avg(Commission_Earned) as Avg_Commission_Earned
from car_sales_data
group by Years,
		Months,
		Car_Make, 
        Car_Model
order by Years asc, Months asc;


-- 2. Year-over-Year Performance Comparison:
-- How does sales performance (total sales, average sale price) compare across different years? Are there significant year-over-year changes?

-- Firstly, extracted the year from Date column to find if the Total Sales and average sales having year-on_year changes like uptrend and downtrend
select extract(year from Dates) as Years,
		sum(Sale_Price) as Total_Sales,
        avg(Sale_Price) as Average_Sale_Price
from car_sales_data
group by Years
order by Years asc;

/* 
Insights: There is an sudden decreasing in sales (2023) compare to previous year (2022) of almost more than 50%.
			 Basically it means there was some schemes in 2022 that reulted us in sudden growth in sales which is closed,
			 or maybe there is some negative impacting schemes in year 2023 which resulted in sudden downfall of company 
			 which we have to address 
*/


-- 3. Sales Efficiency Metrics:
-- What is the average commission per sale and per salesperson? How does this efficiency vary by car make or model?

# Using CTE
# Average Commission, Commission Rate and Sales per transaction or salesperson
with avg_comm_per_sale  as (
		select avg(Commission_Earned) as Avg_Commission_perSale,
				avg(Commission_Rate) as Avg_CommissionRate,
				avg(Sale_Price) as Sale_Price
		from car_sales_data
),

# # Average Commission, Commission Rate and Sales grouped by Car Make
avg_CommissionBY_CarMake as (
		select Car_Make,
				avg(Commission_Earned) as avgCommission,
                avg(Commission_Rate) as avgCommissionRate,
                avg(Sale_Price) as avgSales
        from car_sales_data
        group by Car_Make
        order by Car_Make asc
),

# # Average Commission, Commission Rate and Sales grouped by Car Model
avg_CommissionBy_CarModel as (
		select Car_Model,
				avg(Commission_Earned) as avgCommission,
                avg(Commission_Rate) as avgCommissionRate,
                avg(Sale_Price) as avgSales
        from car_sales_data
        group by Car_Model
        order by Car_Model asc
)

# Printing final results 
select *
from avg_CommissionBY_CarModel

union all

select *
from avg_CommissionBY_CarMake;

/* 
Insights: The data shows that whether we look at avg values by sales or salesperson, individual car models or grouped car 
			 makes, the average commission and commission rates do not vary significantly. This suggests that the commission 
             structure is likely standardized and does not discriminate between different models or makes. Since the commission 
             amounts and rates are uniform, focus could be placed on increasing overall sales volume rather than adjusting the 
             commission structure. Ensuring that high-value transactions are targeted and optimized could improve overall revenue 
             and, consequently, total commissions.
*/


-- 4. High-Value Transactions:
-- What percentage of total sales come from high-value transactions? How do these transactions impact overall revenue and commission distribution?

# Let's assume the high value transactions is between 35000 to 50000 because the lowest amount is 10000 and higest amount is 50000
# Maximum and Minimum transactions
with max_min_transact as (
		select max(Sale_Price) as highest_transaction,
		min(Sale_Price) as lowest_transaction
from car_sales_data
),

# Total Sales for all Transactions
total_sales_all as (
		select sum(Sale_Price) as total_sales
        from car_sales_data
        order by total_sales asc
),

# Total Sales for all High Value Transactions
totalHighValueSales as (
		select sum(Sale_Price) as Total_Sales
        from car_sales_data
        where Sale_Price between 35000 and 50000        
),

# Percentage of High Value Transactions / Sales
percentageHighValTrans as (
		select (sum(case when Sale_Price between 35000 and 50000 then Sale_Price else 0 end) /
				sum(Sale_Price)) * 100 as PercentofHighValTransactions
        from car_sales_data
),

# Total Commissions for all Transactions
total_commission_all as (
		select sum(Commission_Earned) as Total_Commission
        from car_sales_data
),

# Total Commissions for High Value Transactions
totalHighValCommission as (
		select sum(Commission_Earned) as total_Commission
        from car_sales_data
        where Sale_Price between 35000 and 50000
),

# Percentage of High Value Transactions / Commissions
percentHighValCommission as (
		select (sum(case when Sale_Price between 35000 and 50000 then Commission_Earned else 0 end) / 
				sum(Commission_Earned)) * 100 as percentHighValCommission
        from car_sales_data
),

# Comparing both percentage of High Value Sales and High Value Commissions to gain the insights
compare as (
		select (sum(case when Sale_Price between 35000 and 50000 then Sale_Price else 0 end) / 
				sum(Sale_Price)) * 100 as percentHighValSales,
                (sum(case when Sale_Price between 35000 and 50000 then Commission_Earned else 0 end) /
				sum(Commission_Earned)) * 100 as percentHighValCommission
        from car_sales_data
)

# Printing Final Result
select *
from compare;

/*
 Equal Impact: High-value transactions contribute 53% of both total sales and total commissions. 
                  This indicates that high-value transactions are not only significant in terms of 
                  revenue but also proportionately impactful on commission payments. This balance 
                  suggests that the commission structure aligns well with the high-value transactions,
                  without disproportionately rewarding or penalizing based on transaction value.
                  With high-value transactions accounting for 53% of total sales, these transactions 
                  are a major revenue driver for the business. This suggests that focusing on high-value
                  transactions could be a strategic approach to maximizing revenue. Since high-value 
                  transactions account for 53% of commissions as well, it implies that the compensation 
                  system is fairly proportional to the revenue generated from these transactions. This 
                  consistency can be a positive indicator of a fair and motivating commission structure
                  for sales personnel 
*/


-- 5. Sales Trends by Car Model:
-- How do sales and revenue trends vary by car model over time? Are certain models becoming more or less popular?

# Using CTE
# Aggregating Average Sales by Month and Car Models
with monthly_sales as (
		select extract(month from Dates) as Months,
				Car_Model,
				avg(Sale_Price) as Average_sales
		from car_sales_data
        group by Months, Car_Model
        order by Months asc
),

# Aggregating Average Sales by Years and Car Models
yearly_sales as (
		select extract(year from Dates) as Years,
				Car_Model,
                sum(Sale_Price) as Total_Sales
        from car_sales_data
        group by Years, Car_Model
        order by Years asc
),

# Aggregating Average Sales by Month, Year and Car Models
combine_sales as (
		select extract(year from Dates) as Years,
				extract(month from Dates) as Months,
                Car_Model,
                sum(Sale_Price) as Total_Sales
        from car_sales_data
        group by Years, Months, Car_Model
        order by Years asc, Months asc
)

# Printing final result
select *
from combine_sales;

/*
Insights: From above aggregation, the insight shows that there is not a very big change in sales by car models in the first year(2022).
		  But the sales dropped very drastically in year 2023, it dropped for almost more than 50 percent for all car models. Basically 
          it means that in 2023 something disastrous happened that affected company in very negative manner like any political events,
          social event, economical event, global event, environmental event,etc.
*/

-- 6. Salesperson Performance Benchmarks:
-- How do individual salesperson performance metrics compare against each other? What are the benchmarks for top-performing salespeople?

# Using CTE
# Aggregating Salesperson Performance Metrics
with SalesPerson_performance as (
		select Salesperson,
				count(*) as total_deals,
                sum(Sale_Price) as total_sales,
                avg(Commission_Rate) as avg_commission_rate,
                sum(Commission_Earned) as total_commissionEarned
        from car_sales_data
        group by Salesperson
        order by total_deals asc
),

# Ranking Salespeople based on Total Sales and Total Commission
ranked_salespeople as (
		select Salesperson,
				total_deals,
                total_sales,
                avg_commission_rate,
                total_commissionEarned,
                rank() over (order by total_sales desc) as sales_rank,
                rank() over (order by total_commissionEarned desc) as commission_rank
        from SalesPerson_performance
)

# Printing Final Performance Metrics and Benchmark
select Salesperson,
		total_deals,
        total_sales,
        avg_commission_rate,
        total_commissionEarned,
        sales_rank,
        commission_rank
from ranked_salespeople
order by sales_rank asc, commission_rank asc;


-- 7. Commission Rate Analysis:
-- How does the commission rate vary by car make, model, or year? Are there patterns or discrepancies in commission rates?

# By Using CTE
# Aggregated average commissions by Car Model
with commission_rateBy_CarMake as (
		select Car_Make,
				avg(Commission_Rate) as Commission_Rate
        from car_sales_data
        group by Car_Make
        order by Commission_Rate asc
),

# Aggregated average commissions by Car Model
commission_rateBy_CarModel as (
		select Car_Model,
				avg(Commission_Rate) as Commission_Rate
        from car_sales_data
        group by Car_Model
        order by Commission_Rate asc
),

# Aggregated average commissions by year
commission_rateBy_Year as (
		select extract(Year from Dates) as Years,
				avg(Commission_Rate) as Commission_Rate
        from car_sales_data
        group by Years
        order by Commission_Rate asc
)

# Printing Final Values by combining all CTE's table
select "By Car Model" as Attribute,
		Car_Model as Attribute2, 
        Commission_Rate
from commission_rateBy_CarModel

union all 

select "By Car Make" as Attribute,
		Car_Make, 
        Commission_Rate
from commission_rateBy_CarMake

union all

select "By Year" as Attribute,
		Years, 
        Commission_Rate
from commission_rateBy_Year;

/*
Insights: There is not any pattern and discrepancies. The average commission rates is almost similar for all filters like by years
		  Car Models and Car Make.
*/

-- 8. Customer Purchase Frequency:
-- How frequently do repeat customers make purchases? What is the average time between purchases for returning customers?

# Identifying Repeat Customers
with Repeat_Customers as (
		select Customer_Name
        from car_sales_data
        group by Customer_Name
        having count(*) > 1
),

# Calculating Purchase Intervals for Repeat Customers
Customer_Purchase_Intervals as (
		select s1.Customer_Name,
				s1.Dates,
                lead(s1.Dates) over (partition by s1.Customer_Name order by s1.Dates) as Next_Purchase_Date
        from car_sales_data s1
        join Repeat_Customers rc
        on
        s1.Customer_Name = rc.Customer_Name
),

# Calculating Time Intervals and Average Time Between Purchases
Purchase_Intervals as (
		select Customer_Name,
				Dates,
                Next_Purchase_Date,
                extract(day from (Next_Purchase_Date - Dates)) as Days_Between_Purchases
                from Customer_Purchase_Intervals
                WHERE Next_Purchase_Date IS NOT NULL
)

# Calculating Time Intervals and Average Time Between Purchases
select Customer_Name,
		avg(Days_Between_Purchases) as avg_day_intervals
from Purchase_Intervals
group by Customer_Name;


-- 9. Profit Margins by Car Make:
-- What are the profit margins associated with each car make? How do these margins influence overall profitability?

# Using CTE
# Calculating profit margin for each sale
with profit_margin as (
		select Car_Make,
				Sale_Price,
                Commission_Earned,
                (Sale_Price - Commission_Earned) / Sale_Price * 100 as Profit_Margin
        from car_sales_data
),

# Calculating aggregated profit margin by car make
aggregated_margin as (
		select Car_Make,
				sum(Sale_Price) as total_sales,
                sum(Sale_Price - Commission_Earned) as total_profit,
                avg(Profit_Margin) as avg_profit_margin
        from profit_margin
        group by Car_Make
),

# Calculating Overall Profitability
overall_profitability as (
		select sum(total_profit) as overall_total_profit,
				sum(total_sales) as overall_total_sales,
                sum(total_profit) / sum(total_sales) * 100 as overall_profit_margin
			
        from aggregated_margin
)

# Printing aggregated results
select Car_Make,
		total_sales
		total_profit,
        avg_profit_margin
from aggregated_margin
order by avg_profit_margin desc;


# Printing overall profitability results
select overall_total_profit,
		overall_total_sales,
        overall_profit_margin
from overall_profitability;


-- 10. Sales and Commission by Day of the Week:
-- How do sales and commission figures vary by day of the week? Are there specific days with higher or lower sales activity?

 # Using CTE
 # Calculating total sales and total commissions on based of the day week
 with sales_by_day as (
		select dayname(Dates) as day_of_week,
				sum(Sale_Price) as total_sales,
                sum(Commission_Earned) as total_commission
        from car_sales_data
        group by day_of_week
 )
 
 # Printing final results
 select day_of_week,
		total_sales,
        total_commission
 from sales_by_day
 order by field(day_of_week, "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday");
 
 /*
 Insights: "Analysis of Sales and Commission Trends Reveals Increased Activity on Mondays and Sundays:
			Our analysis shows a significant increase in both sales and commission figures on Mondays and Sundays compared to other
            weekdays. This trend suggests that these days are particularly strong for car sales, possibly due to increased customer 
            availability or strategic promotional efforts.
			On Mondays, customers might be taking advantage of new week promotions or incentives, while Sundays could benefit from 
            higher foot traffic as people have more free time to visit dealerships. The elevated commission earnings on these days 
            indicate that salespeople are also experiencing heightened performance, which may be linked to specific incentives or 
            increased customer interactions.
 */
 
 
 /*
 Overall Summary Insights: In 2023, our sales experienced a dramatic decline of over 50% compared to 2022. This sharp decrease suggests
						   that factors such as the cessation of effective promotional schemes from 2022 or the introduction of negative 
                           impacting schemes in 2023 may have significantly affected our performance. It is crucial to investigate these 
                           changes and address the underlying issues to mitigate further losses.

						   Despite this downturn, our analysis of commission data reveals that both average commissions and commission rates
                           remain consistent across different car models and makes. This uniformity indicates a standardized commission 
                           structure, which means our focus should shift towards increasing overall sales volume rather than modifying the 
                           commission system. High-value transactions are crucial, representing 53% of both total sales and total commissions,
                           highlighting their importance in our revenue stream. The alignment of commissions with high-value transactions 
                           suggests that our compensation system effectively rewards significant sales without causing disproportionate variances.

						   Furthermore, the consistency in sales performance across car models in 2022 contrasted with the severe drop in 2023 
                           points to external factors, such as political, economic, or global events, as potential causes for the downturn. 
                           Addressing these external influences and recalibrating our strategies could help in reversing the negative trend 
                           and stabilizing the company’s performance.
 */
