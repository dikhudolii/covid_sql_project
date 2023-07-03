/*
Queries used for Tableau Project
*/



-- 1.

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_Cases)*100 AS death_percentage
FROM covid_deaths
where continent is not null
order by 1,2;



-- 2.

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;


-- 3.

SELECT location, population, MAX(total_cases) AS highest_infection_count,  Max((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- 4.

SELECT location, population, date, MAX(total_cases) AS highest_infection_count,  Max((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;



