/*
	This a Data Exploration in SQL of the Covid19 Data accross the world.
*/

-- Selecting all from both datasets, Covid Vaccinations data and Covid Deaths
select * 
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVacs
order by 3,4

-- selecting the data that we are going to be using, and analyzing

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths in a country
-- shows the likelyhood of dying if u caught covid in the states

select location, date,
convert(decimal(15,3), total_deaths) as 'TotalDeaths',
convert(decimal(15,3), total_cases) as 'TotalCases',
convert(decimal(15,3), total_deaths)/convert(decimal(15,3), total_cases)*100 as 'DeathPercentage'
from PortfolioProject..CovidDeaths
where location like '%states%'and date like '%31%2020%' --death rate vs cases at the end of month in 2020
order by 1,2

/* 
	this is an ideal and simple syntax if all columns were integers, but they are nvarchar therefore gives error

--select Location, date, total_cases, total_deaths, 
--convert(total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--order by 1,2

*/

-- Looking at the Total Cases vs Population
-- shows what percentage of the population that got Covid

select location, date,total_cases, population,
(total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where population > 50000000
group by location, population
order by 4 desc

--Showing countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--and location = 'nigeria'
group by location
order by 2 desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by continent
order by 2 desc

-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
--as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacs vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 