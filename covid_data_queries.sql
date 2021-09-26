-- Checking data uploaded to tables

Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

Select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3, 4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
and Location like 'South Africa' 
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of the population contracted covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--and Location like 'South Africa' 
order by 1, 2

-- Looking at Countries with the Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as MaxTotalCases, MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc


-- Looking at Countries with the Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


-- Breaking it down by continent

-- Showing continents with the Highest Death Count per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Previous query excludes total death count per continent. 
-- For example, North America exluded Canada
-- Let's correct this.

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by Location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalNewCases, 
			SUM(cast(new_deaths as int)) as TotalNewDeaths,
			SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--and Location like 'South Africa' 
group by date
order by 1, 2

-- Total global percentage of new deaths vs new cases to date (single number returned)

Select SUM(new_cases) as TotalNewCases, 
		SUM(cast(new_deaths as int)) as TotalNewDeaths,
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--and Location like 'South Africa' 
order by 1, 2

-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Looking at Rolling Percentage of People Vaccinated 


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccination/Population)*100 as PercentRollingPeopleVaccination
from PopvsVac


-- USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccination/Population)*100 as PercentRollingPeopleVaccination
from #PercentPopulationVaccinated


-- Create view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * 
from PercentPopulationVaccinated