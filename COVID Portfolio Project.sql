Select *
from Project..CovidDeaths
where continent is not null
order by 3,4



Select *
from Project..CovidVaccinations
order by 3,4


-- SELECT DATA THAT WE ARE GOING TO BE USING

Select location, date ,total_cases, total_deaths, population, (total_deaths/total_cases) * 100 as DeathPercentage
from Project..CovidDeaths
where location like '%key%' and continent is not null
order by 1,2


--- Looking at Total cases and Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Project..CovidDeaths
where location like '%key%'
and continent is not null
order by 1,2



--- Looking at Total cases vs Population
--- Shows wha percentage of population got Covid

Select location, date,population,total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from Project..CovidDeaths
--where location like '%key%'
where continent is not null
order by 1,2





-- Looking at Countries with Highest Infection Rate compare to population

Select location,population,MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population)) * 100 as PercentPopulationInfected
from Project..CovidDeaths
--where location like '%key%'
where continent is not null
GROUP BY location,population
order by PercentPopulationInfected desc



--Showing Countries with Highest Death Count Per Population

Select location, MAX(cast(total_deaths as int )) as TotalDeathCount
from Project..CovidDeaths
--where location like '%key%'
where continent is not null
GROUP BY location
order by TotalDeathCount desc


-- Let's Break Things Down By Continent

Select continent, MAX(cast(total_deaths as int )) as TotalDeathCount
from Project..CovidDeaths
--where location like '%key%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Showing The Continent With The Highest Death Per Population

Select continent, MAX(cast(total_deaths as int )) as TotalDeathCount
from Project..CovidDeaths
--where location like '%key%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) AS TOTA_CASES, SUM(CAST(new_deaths AS FLOAT)) AS TOTAL_DEATHS, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT)) * 100 as DeathPercentage
from Project..CovidDeaths
--where location like '%key%'
where continent is not null
--group by date
order by 1,2



-- looking at Total Population vs Vaccinations

SELECT dea.continent, DEA.location,DEA.date, DEA.population, vac.new_vaccinations,
       SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated, ---(RollingPeopleVaccinated/population)
FROM PROJECT..CovidDeaths DEA
JOIN PROJECT..CovidVaccinations VAC
    ON DEA.location  = VAC.location
    AND DEA.date = VAC.date
where DEA.continent is not null
order by 2,3




--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



---- Temp Table
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date nvarchar(255),
    population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
---where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View To Store Data For Later Visualatizions

CREATE VIEW PercentPopulationVaccinated AS
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated