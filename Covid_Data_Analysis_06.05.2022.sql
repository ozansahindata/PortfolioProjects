Select *
From PortfolioProject..CovidDeaths
where continent != location
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Selecting data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths
--Shows likelyhood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%Turkey'
Order by 1,2

--Looking at total_cases vs Population
--Shows what pecentage of Population got covid
Select Location, date, Population,total_cases, (total_cases/Population)*100 as Percent_of_population_infected
From PortfolioProject..CovidDeaths
Where location like '%Turkey'
Order by 1,2

-- Looking at Countries with highest infection rate compared to Population

Select Location, Population,Max(total_cases) as highest_infection_count, Max((total_cases/Population))*100 as percent_of_population_infected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by 4 desc

-- Showing Countries with the highest death count per population

Select Location, Max(CAST(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths
--where location like '%Turkey%'
Where continent != location -- Excluding continents from location section
Group by Location
Order by Total_death_count desc


-- Showing Results with continents
-- Showing continents with the highest death count per population
Select location, Max(CAST(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths
--where location like '%Turkey%'
Where continent is null and location not Like '%income%' -- Excluding continents from location section
Group by location 
Order by Total_death_count desc

--Global Numbers

Select  date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date,population,CAST(vac.new_vaccinations as float),
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as rolling_people_vaccinated -- We are rolling over country here
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using Cte 

With PopvsVac (continent, location, date, Population,new_vaccinations,rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date,population,vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as rolling_people_vaccinated -- We are rolling over country here
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.location Like '%Turkey%'
)

Select *, (rolling_people_vaccinated/population)*100 -- if the percentage is over 100 that means people are vaccinated for the second time
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as rolling_people_vaccinated -- We are rolling over country here
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order 2,3 

Select *, (rolling_people_vaccinated/population)*100 as rolling_people_percentage
From #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as rolling_people_vaccinated -- We are rolling over country here
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order 2,3 


Select *
From PercentPopulationVaccinated