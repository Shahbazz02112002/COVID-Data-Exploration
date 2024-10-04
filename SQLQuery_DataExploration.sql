Select Location, date, total_cases, new_cases, total_deaths, population From PortfolioProject..CovidDeaths ORDER by 1, 2;

UPDATE CovidVaccinations SET new_cases = NULL WHERE new_cases = 0;

--Total cases vs total deaths in India and Pakistan
--chances of dying with covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage FROM PortfolioProject..CovidDeaths
WHERE Location IN ('India', 'Pakistan') ORDER BY 1, 2;

--Total cases vs Population in Bangladesh
--shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infectionpercentage FROM PortfolioProject..CovidDeaths
WHERE Location = 'Bangladesh' ORDER BY 1, 2;

--looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as Highestinfectedcount, (MAX(total_cases)/population)*100 as Percentagepopulationinfected FROM PortfolioProject..CovidDeaths
GROUP BY Location, population ORDER BY 4 DESC;

--showing countries with the highest death count

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL GROUP BY Location ORDER BY 2 DESC;


--showing countries with the highest death count per population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX(CAST(total_deaths AS int)) / Population*100 AS DeathsPerCapita
FROM PortfolioProject..CovidDeaths GROUP BY Location, population ORDER BY 3 DESC;

--breaking thing down by continent

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL GROUP BY continent ORDER BY 2 DESC;

--Global numbers

SELECT date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 
as Deathpercentage FROM PortfolioProject..CovidDeaths
GROUP BY date ORDER BY 1, 2;

--Looking at   Total population vs Vaccination

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated) as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent is not NULL)

SELECT *, (RollingPeopleVaccinated/population)*100  FROM PopvsVac

--Same thing using Temp tables

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated (Continent nvarchar(255), Location nvarchar(255), Date datetime,
Population numeric, New_Vaccination numeric, RollingPeopleVaccinated numeric)

INSERT INTO #PercentagePopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population)*100  FROM #PercentagePopulationVaccinated

--Views   

CREATE VIEW PercenPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent is not NULL