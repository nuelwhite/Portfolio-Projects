/**
	* This my first Portfolio Project guided by a tutorial made by Alex Freberg. This is an analysis of the Coivd data
	since 2019 to 7/5/2023
**/

-- selecting everything from both tables to first check if contents are all there

select *
from covidDeaths



-- A. BREAKING THIS ANALYSIS DOWN BY LOCATION

-- selecting data that we will be using often
select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths
order by 1,2


-- 1. Looking at Total Cases vs Total Deaths

-- Total deaths for a country vs the percentage of deaths by those who were infected
-- shows the likelihood hood of dying if you contract the corona virus in your country
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage 
from covidDeaths
where location = 'ghana'
order by 1,2

--exec sp_help coviddeaths


-- 2. Looking at Total Cases vs Population
-- shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100  as InfectedPercentage 
from covidDeaths
--where location = 'ghana'
order by 1,2


-- 3. Looking at Deaths vs Population
select location, date, population, total_cases, total_deaths, (total_deaths/population)*100 as deathPercentage
from covidDeaths
order by 1,2


-- 4. Looking at Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestCountInfection, max((total_cases/population))*100 as InfectionRateOfPopulation
from covidDeaths
where location like '%united states'
group by location, population
order by HighestCountInfection desc


-- 5. Looking at countries with highest Death Count per country
select location, max(cast(total_deaths as int)) as HighestDeathCount
from covidDeaths
where continent is not null
group by location
order by HighestDeathCount desc



-- B. LET'S BREAK THE ANALYSIS DOWN BY CONTINENT

-- showing the continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Using The Vaccinations table
select *
from covidVacs


-- C. Looking at Total Populations vs Vaccinations

-- joining CovidDeaths and CovidVacs tables
select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from covidDeaths dea
join covidVacs vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join covidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVacs vac
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating views for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

