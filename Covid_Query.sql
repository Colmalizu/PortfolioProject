SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..covidVaccination
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at the Total cases vs Total deaths
--Shows likelihood  of dying if you contract covid

SELECT location, date, total_cases, total_deaths, (CONVERT(decimal,total_deaths) / CONVERT(decimal,total_cases)) *100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Loking at the Total cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CONVERT(decimal,total_cases) / CONVERT(decimal,population)) *100 AS PercentagePopulationImfected
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Looking at  Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(decimal,total_cases) / CONVERT(decimal,population))) *100 AS PercentagePopulationImfected
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationImfected DESC


--Showing countries with the highest Death Count Per Population

SELECT location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT

SELECT continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) As Rolling_PeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeople_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) As RollingPeople_Vaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *,(RollingPeople_Vaccinated / Population) * 100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulatonVaccinated

CREATE TABLE #PercentPopulatonVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeople_Vaccinated numeric
)
INSERT INTO #PercentPopulatonVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) As RollingPeople_Vaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
    ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
SELECT *,(RollingPeople_Vaccinated / Population) * 100
FROM #PercentPopulatonVaccinated

--Creating view to store Data for later visualization


