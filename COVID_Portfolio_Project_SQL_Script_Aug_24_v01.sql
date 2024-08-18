SELECT *
FROM CovidDeaths;

--SELECT TOP 1000 *
--FROM PortfolioProject..CovidVaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

--Total Cases vs Total Deaths for Death Percentage
SELECT location, date, total_cases, total_deaths, ((total_deaths / total_cases) * 100) AS death_percent
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2;

--Total Cases vs Population
SELECT location, date, population, total_cases, ((total_cases/population) * 100) AS infection_percent
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2;
 
 --Highest Infection rate
SELECT location, population, MAX(total_cases) as total_cases, MAX((total_cases/population) * 100) AS infection_percent
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

--Countries with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths DESC;

--ConTINENTS with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths DESC;

--Per day new cases vs Per day new deaths
SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS INT)) AS NewDeath, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

--Total Population vs Vaccination
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc_sum
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

--Using CTE to find the population got vaccinated
WITH PopVsVacc(continent, location, date, population, new_vaccinations, rolling_vacc_sum)
AS (
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc_sum
	FROM CovidDeaths d
	JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL
--ORDER BY 2, 3;
)
SELECT *, (rolling_vacc_sum/population)*100 AS percent_population_vaccinated
FROM PopVsVacc;


--Using TEMP Table to find the population got vaccinated
DROP table IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated(
	continent NVARCHAR(255), 
	location NVARCHAR(255),
	date NVARCHAR(255),
	population NVARCHAR(255),
	new_vaccinations NVARCHAR(255),
	rolling_vacc_sum NVARCHAR(255)
	)

INSERT INTO #PercentPopVaccinated
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc_sum
	FROM CovidDeaths d
	JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL

SELECT *, (rolling_vacc_sum/population)*100 AS percent_population_vaccinated
FROM #PercentPopVaccinated;

--Creating View for later visualization

CREATE VIEW PercentPopulationVaccinated AS
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vacc_sum
	FROM CovidDeaths d
	JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated


--