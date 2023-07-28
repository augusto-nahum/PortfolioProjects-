select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- Shows the likelihood od dying if you get sick per country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%ntina%'
order by 1,2

-- Total cases vs Population
-- Percentage of population got covid
select location, date, total_cases,population, (total_cases/population)*100 as PercentPopulation
from PortfolioProject..CovidDeaths
--where location = 'Argentina'
order by 1,2

--Countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount,(MAX(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Argentina'
Group by location,population
order by PercentPopulationInfected desc


-- Countries with teh highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
--where location = 'Argentina'
where continent is not null
Group by location
order by TotalDeathsCount desc


--Lets break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

-- showing the continents with the highiest death count per population 

select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

-- Global numbers

select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Total population vs population

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE cte

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccionation numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
