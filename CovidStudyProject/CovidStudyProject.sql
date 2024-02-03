Tableau Dashboard:

1. COVID-19 Cases & Deaths: https://public.tableau.com/app/profile/tinajcyeh/viz/CovidStudy-2_17068703413070/Dashboard1-CasesDeaths?publish=yes
2. Global COVID-19 Vaccinations: https://public.tableau.com/app/profile/tinajcyeh/viz/CovidStudy-1/Dashboard1-Vaccination?publish=yes



/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, 

*/

USE Covid_study;
SELECT * FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, dates;


# Select key data for the project

SELECT location, dates, total_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, dates;


# Total Cases vs Total Deaths (example of the United States)
SELECT location, dates, total_cases, total_deaths, (CONVERT(total_deaths, FLOAT)/NULLIF(CONVERT(total_cases, FLOAT),0))*100 AS deaths_percentage
FROM coviddeaths
WHERE location LIKE "%states%" AND continent IS NOT NULL
ORDER BY location, dates;


# Total Cases vs Population in daily variation
SELECT location, dates, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM coviddeaths
-- WHERE location LIKE "%states%"
ORDER BY location, dates;


# Countries with the Highest infection rate compared to the population
SELECT 
	location, 
    population, 
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases/population))*100 AS population_infection_rate
FROM coviddeaths
GROUP BY location, population
ORDER BY population_infection_rate DESC;


# Countries with the Highest Death Count per population
SELECT 
	location, 
    MAX(total_deaths) AS total_deaths_count    
FROM coviddeaths
WHERE NOT (continent = "")
GROUP BY location
ORDER BY total_deaths_count DESC;


-- Cases study by Continent 
# Continents with the highest death count per population
SELECT 
	continent, 
    MAX(total_deaths) AS total_deaths_count    
FROM coviddeaths
WHERE NOT (continent = '')
GROUP BY continent
ORDER BY total_deaths_count DESC;


# Countries with highest deaths count per population
SELECT 
	location, 
    MAX(total_deaths) AS total_deaths_count    
FROM coviddeaths
WHERE NOT (continent = "")
GROUP BY location
ORDER BY total_deaths_count DESC;


-- Global Numbers Overview
# Countries with highest deaths count per population
SELECT 
	SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases)*100 AS deaths_percentage
FROM coviddeaths
WHERE NOT (continent = "");


# Total Population vs vaccination (Percentage of population who received at least 1 vaccine doses)

SELECT
	cd.continent AS continent,
    cd.location AS location,
    cd.dates AS dates,
    cd.population AS population,
    cv.new_vaccinations_smoothed AS new_vaccinations,
    SUM(cv.new_vaccinations_smoothed) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.dates) AS rolling_sum_vaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv USING (location, dates)
WHERE NOT (cd.continent = "")
ORDER BY location, dates;


-- Using CTE to compute the percentage of vaccination rolling sum against population
# Total Population vs vaccination (Percentage of population who received at least 1 vaccine doses)

WITH PopVac (continent, location, dates, population, new_vaccinations, rolling_sum_vaccination)
AS 
(SELECT
	cd.continent AS continent,
    cd.location AS location,
    cd.dates AS dates,
    cd.population AS population,
    cv.new_vaccinations_smoothed AS new_vaccinations,
    SUM(cv.new_vaccinations_smoothed) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.dates) AS rolling_sum_vaccination
FROM coviddeaths cd
JOIN covidvaccinations cv USING (location, dates)
WHERE NOT (cd.continent = "")
)
SELECT *, CONCAT(FORMAT((rolling_sum_vaccination / population) * 100, 2),'%') AS accumlated_vaccination_percentage
FROM PopVac;



-- Using TEMP Table to run Calculation on Partition By in previous query

DROP TABLE IF EXISTS PeopleVaccinatedRatio;
CREATE TABLE PeopleVaccinatedRatio
(continent VARCHAR(255),
 location VARCHAR(255),
 dates date,
 population NUMERIC,
 new_vaccinations NUMERIC,
 rolling_sum_vaccinated NUMERIC
 );
 
INSERT INTO PeopleVaccinatedRatio
SELECT
	cd.continent AS continent,
    cd.location AS location,
    cd.dates AS dates,
    cd.population AS population,
    cv.new_vaccinations_smoothed AS new_vaccinations,
    SUM(cv.new_vaccinations_smoothed) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.dates) AS rolling_sum_vaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv USING (location, dates)
WHERE NOT (cd.continent = "");


SELECT *, CONCAT(FORMAT((rolling_sum_vaccinated / population) * 100, 2),'%') AS accumlated_vaccination_percentage
FROM PeopleVaccinatedRatio;



-- Using CTE to calculate people fully vaccinated ratio against total population by years
# People fully vaccinated vs Total Population

WITH PopFVac (continent, location, years, population, pop_fully_vaccinated)
AS 
(SELECT
	cd.continent AS continent,
    cd.location AS location,
    YEAR(cd.dates) AS years,
    cd.population AS population,
    MAX(cv.people_fully_vaccinated) AS pop_fully_vaccinated
        
FROM coviddeaths cd
JOIN covidvaccinations cv USING (location, dates)
WHERE NOT (cd.continent = "")
GROUP BY cd.continent, cd.location, years, cd.population
)
SELECT 
	*,
	concat(FORMAT((pop_fully_vaccinated / population) * 100, 2),'%') AS fully_vaccination_percentage
FROM PopFVac
ORDER BY location, years;



-- Creating a View to store data for visualizations
CREATE VIEW PeopleVaccinatedPercentage AS
SELECT
	cd.continent AS continent,
    cd.location AS location,
    cd.dates AS dates,
    cd.population AS population,
    cv.new_vaccinations_smoothed AS new_vaccinations,
    SUM(cv.new_vaccinations_smoothed) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.dates) AS rolling_people_vaccinated
	
FROM coviddeaths cd
JOIN covidvaccinations cv USING (location, dates)
WHERE NOT (cd.continent = "");



 
