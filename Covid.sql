SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

----SELECT *
----FROM PortfolioProject..CovidVaccinations
----ORDER BY 3,4

---- select data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

---- looking at total cases vs total deaths
--- Shows likelihood of dying if you contract covind in your country
SELECT Location, Date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location Like '%India%'
order by 1,2

--- Looking at total cases vs population
-- Shows what percentage of population has gotten covid
SELECT Location, Date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where Location Like '%india%'
order by 1,2

--- Looking at countries with highest infection rate compared to population
SELECT Location, Population, max(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where Location Like '%india%'
GROUP BY Location, Population
order by PercentPopulationInfected desc

---Showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as BIGINT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location Like '%india%'
WHERE continent is not NULL
GROUP BY Location
order by TotalDeathCount desc


--- BREAK THINGS DOWN BY CONTINENT
--correct
SELECT location, MAX(cast(total_deaths as BIGINT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location Like '%india%'
WHERE continent is NULL
GROUP BY location
order by TotalDeathCount desc

--- showing continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as BIGINT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location Like '%india%'
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE 

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



---TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--- CREATE View to store data for later visualizations

create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated