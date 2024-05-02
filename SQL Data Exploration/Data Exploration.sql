SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL

--SELECT *
--FROM CovidVaccination

-- SELECT DATA THAT WE ARE GOING TO BE USE

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES VS POPULATION
-- shows what % of population got covid

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION


SELECT location,population,max(total_cases) AS HighestInfectionCount,(max(total_cases)/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATHCOUNT PER POPULATION

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LETS BREAK THING DOWN BY CONTINENT

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- showing continents with highest death count

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as INT)) AS total_deaths,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS


SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


WITH PopVsVac (continent,location,date,population,new_vaccinations,rollingPeoplevaccinated)
as
(SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *,(rollingPeoplevaccinated/population)*100
FROM PopVsVac


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated