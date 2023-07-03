/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM covid_deaths
WHERE continent is not null
order by 3,4;

SELECT *
FROM covid_vaccinations
order by 3,4;



-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent is not null
order by 1,2;



-- Looking at Total cases VS Total Deaths

-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent is not null
-- WHERE location ILIKE '%states'
order by 1,2;



-- Looking at Total Cases VS Population

-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS infected_percentage
FROM covid_deaths
WHERE continent is not null
-- WHERE location ILIKE '%states'
order by 1,2;



-- Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population) * 100) AS infected_percentage
FROM covid_deaths
WHERE continent is not null
-- WHERE location ILIKE '%states'
Group by location, population
order by infected_percentage desc;



-- Showing countries with the highest Death Count per Population
SELECT location, MAX(cast (total_deaths as int)) as max_deaths_count
FROM covid_deaths
WHERE continent is not null
-- WHERE location ILIKE '%states'
Group by location
order by max_deaths_count desc;



-- Breaking things down by continent

-- Showing continents with the highest Death Count per Population
SELECT continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM covid_deaths
--Where location ILIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
--WHERE location ILIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;



-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       -- This line is creating a sum of 'new_vaccinations' from 'covid_vaccinations', converted to integer, for each location.
       -- This is done using a window function, which allows calculations across sets of rows that are related to the current query row.
       -- In this case, the sum is performed for all rows with the same location.
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
           dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;



-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
    (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
           dea.date) AS rolling_people_vaccinated  -- This line is creating a sum of 'new_vaccinations' from 'covid_vaccinations', converted to integer, for each location.
       -- This is done using a window function, which allows calculations across sets of rows that are related to the current query row.
       -- In this case, the sum is performed for all rows with the same location.
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated/population) * 100 AS people_percentage_vaccinated
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS percent_population_vaccinated;

CREATE TEMPORARY TABLE percent_population_vaccinated
(
    continent text,
    location text,
    date date,
    population numeric,
    new_vaccinations numeric,
    rolling_people_vaccinated numeric
);

INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, TO_DATE(dea.date, 'YYYY-MM-DD'), dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, TO_DATE(dea.date, 'YYYY-MM-DD')) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
    ON dea.location = vac.location
    and TO_DATE(dea.date, 'YYYY-MM-DD') = TO_DATE(vac.date, 'YYYY-MM-DD')
--WHERE dea.continent IS NOT NULL;

SELECT *, (rolling_people_vaccinated/population) * 100 AS people_percentage_vaccinated
FROM percent_population_vaccinated;


-- Creating View to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_deaths AS dea
Join covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

