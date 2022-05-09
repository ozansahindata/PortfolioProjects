
-- Meeting with the database and exploring
Select Entity as Country, Code as Country_Code, Year, [Electricity from fossil fuels (TWh)]
From PortfolioProject..WorldEnergyData
Where Code is not null and Code!='OWID_WRL'
order by 4 desc

-- Creating a Temporary Table just with Countries and with Valid Country_Code

DROP Table if exists #ElectricityFromFossilFuel

Create Table #ElectricityFromFossilFuel
(
Country nvarchar(255),
country_code nvarchar(255),
Year int,
efff numeric,
)

Insert into #ElectricityFromFossilFuel
Select Entity as Country, Code as Country_Code, Year, [Electricity from fossil fuels (TWh)]
From PortfolioProject..WorldEnergyData
Where Code is not null and Code!='OWID_WRL'
order by 4 desc

-- Finding the Total Energy Produced using fossil fuels by country

Select Country,SUM(efff) as Total_Energy_Produced
From #ElectricityFromFossilFuel
Group by Country
order by 2 desc

-- Avg energy produced using fossil fuels (GLOBALLY)
Select Country, AVG(cast(efff as int)) as Avg_Energy_Produced
From #ElectricityFromFossilFuel
Group By Country
order by 2 desc

-- Total Energy produced per year in United States (tWh)
Select Country,Year, efff
From #ElectricityFromFossilFuel
Where country Like '%States'
order by 2 desc

-- Total Energy produced per year in China (tWh)
Select Country,Year, efff
From #ElectricityFromFossilFuel
Where country Like '%China'
order by 2 desc







