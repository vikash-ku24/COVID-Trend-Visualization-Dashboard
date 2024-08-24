--ContinentLocationVsHighestDeathCount
SELECT location, MAX(CAST(new_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;


--TotalCasesVsTotalDeaths
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2; 


--LocationVsPopulationHighestInfection
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population) * 100) AS percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;


--LocationVsDatePopulationHighestInfection
SELECT location, population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases/population) * 100) AS percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY 5 DESC;