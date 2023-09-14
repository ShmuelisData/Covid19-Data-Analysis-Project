--Summary- The purpose of this COVID-19 project is to shed some light and insights about the virus and how it affects the World. In the project, I examined the COVID-19 consciences of different countries 
-- as well as different calculations that show - The chances of dying from the virus if you already got infected- in different countries.  -The percentage of the country's population which got infected->
can tell how well the country protects itself from the virus.
--Next, I calculated which country had the most deaths compared to its population. 
--Then, I added a new Table with Data about Vaccinations and started to calculate the countries that had the most vaccinations for people.

SELECT * fROM PortfolioProject..CovidDEATH

--Starting with some simple Queris for Testing

SELECT DISTINCT location, population, total_cases, MAX(total_cases/population)*100 AS CaseFromPopuPresentage FROM PortfolioProject..coviddeath
GROUP BY location, population, total_cases
ORDER BY CaseFromPopuPresentage DESC

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.. coviddeath
ORDER BY  date desc

--Looking at Total cases VS Total Deaths

SELECT  location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS Deaths_Cases_Precent
FROM portfolioproject.. coviddeath
ORDER BY  1, 2 DESC

--Show the chances of dying if you contract COVID in a specific Country
--A column with a NULL value in continent represents the continent in the Location. Therefore we will use WHERE continent IS NOT NULL to exclude the continents.

SELECT location, MAX(date) AS latest_date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS Chances_to_Die_Percentage
FROM portfolioproject..coviddeath
WHERE new_cases > 0 AND new_deaths > 0
GROUP BY location
ORDER BY Chances_to_Die_Percentage DESC;

--As we can see the Top countries are located in Africa. and the Total_Cases and Total_Deaths are very low--> very low Covid19 tests. 
--#Regarding these insights, using these calculations arent accurate.

--1. Yemen- 19%   2. Sudan 9.8%   3. Niger 8.55%   4. Liberia   5. Palau 6.8%   6. Gambia 6.8%  


--Looking at Total Cases vs. Population
--Shows the percentage of the Population that got Covid

SELECT  location, date, total_cases,  population, (total_cases/population)*100 AS Case_Popul_Precent
FROM portfolioproject.. coviddeath
--WHERE location LIKE 'israel'
ORDER BY Case_Popul_Precent DESC 

--Which Countries got the Highest Cases rates
SELECT  location, population, Max(total_cases) AS Highest_Country_Cases, 
MAX((total_cases/population))*100 AS Cases_Pupulation_precent
FROM portfolioproject.. coviddeath
GROUP BY location, population
ORDER BY  Cases_Pupulation_precent desc

--Seems that 1. Cyprus 73.7% Cases of it Population. 2. San Marino with 72% 3.Brunei with 68%. 
--4. Austria with 68% and 5. Faeroe Islands 65.2%

--Next will be the Countries with the Highest Death count.

SELECT location, MAX(CAST(total_deaths AS INT)) AS Country_Death_Count
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Country_Death_Count DESC

--1. USA 1.12M  2. Brazil 0.7M  3. India 0.53M 4.Russia 0.4M  5. Mexico 0.33M

--Highest Death from Population in Percentage

SELECT  location, MAX((total_deaths/population)*100) AS Country_Death_Precentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Country_Death_Precentage DESC

--Time to Analyze in terms of continents

--Highest Death Continent.s
SELECT location, SUM(CAST(new_deaths AS INT)) AS Continent_Death_Count
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
AND location not in ('world', 'European Union', 'International', 'high income', 'Upper middle income', 'Lower middle income', 'Low income' )
GROUP BY location
ORDER BY Continent_Death_Count DESC

SELECT TOP 1 location,  MAX(total_deaths) AS World_Total_Deaths
FROM PortfolioProject..CovidDeath
WHERE location LIKE 'World' AND total_deaths IS NOt NULL
GROUP BY location, date
ORDER BY date DESC 

--Showing Continents Death from Population Percentage

SELECT  continent, MAX((total_deaths/population)*100) AS Continent_Death_Precentage
FROM PortfolioProject..CovidDeath
WHERE continent IS not NULL 
GROUP BY continent
ORDER BY Continent_Death_Precentage DESC
  
--Global Findings

--Find out the World Death percentage from the Total Cases

SET ARITHABORT OFF  --Turn OFF Divided by 0 ERROR
SET ANSI_WARNINGS OFF
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS World_Death_Precentage
FROM portfolioproject.. coviddeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 3 DESC

--We can see that 0.9% of the World's Total Cases have died.

--Working on both Death, Vaccination Tables

SELECT * FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date

--Looking at the number of New Vaccinations per day in each country

SELECT death.location, death.date, death.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent IS NOT NULL and new_vaccinations IS NOT NULL
ORDER BY location

--Summarize the Vaccinations per Country
WITH Pop_Vac (continent, location, date, population, new_vaccinations, Total_People_Vac ) -- Include all Column that were in the original Query
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Total_People_Vac --Adding an ORDER BY showing the new_vac Sum.
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE new_vaccinations IS NOT NULL AND  death.continent IS NOT NULL
)
SELECT *,(Total_People_Vac/population)*100 AS Vac_Pop_Precent
FROM Pop_Vac
ORDER BY location, Vac_Pop_Precent DESC


--Showing the countries which made most vaccinations
SELECT death.location, SUM(CAST(vac.new_vaccinations AS BIGINT)) AS total_vaccinations
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
GROUP BY death.location
ORDER BY total_vaccinations DESC;

--1. China with 3,407,595,000 vaccinations.  2. India with 2,111,987,623  3. USA 676,683,162

--Showing the percentage of Vaccinations from the country's population.
SELECT death.location, SUM(CAST(vac.new_vaccinations AS BIGINT)) / MAX(death.population)*100 AS Vaccination_Percentage
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations vac
    ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
GROUP BY death.location
ORDER BY Vaccination_Percentage DESC;

--Here we can see that the vaccinations per person is between 0 to 3 in different countries.














