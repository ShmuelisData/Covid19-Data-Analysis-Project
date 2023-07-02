SELECT * fROM PortfolioProject..CovidDEATH

--Starting with some simple Queris for Testing

select DISTINCT location, population, (total_cases/population)*100 AS CaseFromPopuPresentage FROM PortfolioProject..coviddeath
ORDER BY CaseFromPopuPresentage DESC

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.. coviddeath
ORDER BY  1,2

--Looking at Total cases VS Total Deaths
--Show the chanses of dying if you contract covid in a specific Country

SELECT  location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS Deaths_Cases_Precent
FROM portfolioproject.. coviddeath
ORDER BY  1, 2 DESC 



--Looking at Total Cases vs Population
--Shows the precentage of Population that got Covid

SELECT  location, date, total_cases,  population, (total_cases/population)*100 AS Case_Popul_Precent
FROM portfolioproject.. coviddeath
--WHERE location LIKE 'israel'
ORDER BY  1, 2 DESC 

--Which Countries got the Highest Cases rates

SELECT DISTINCT location, date, total_cases,  population, (total_cases/population)*100 AS Case_Popul_Precent
FROM portfolioproject.. coviddeath
ORDER BY  5 DESC 


SELECT  location, population, Max(total_cases) AS Highest_Country_Cases, 
MAX((total_cases/population))*100 AS Cases_Pupulation_precent
FROM portfolioproject.. coviddeath
GROUP BY location, population
ORDER BY  Cases_Pupulation_precent desc

--Seems that 1. Cyprus 73.7% Cases of it Population. 2. San Marino with 72% 3.Brunei with 68%. 
--4. Austria with 68% and 5. Faeroe Islands 65.2%


SELECT location, population, date, MAX(total_cases) AS Highest_Infected_Count, Max((Total_cases/population))*100 AS Precent_Population_Infected
FROM PortfolioProject..CovidDeath
GROUP BY location, population, date
ORDER BY Precent_Population_Infected DESC



--Next will be the Countries with Highest Deaths count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Country_Death_Count
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Country_Death_Count DESC


--1. USA 1.12M  2. Brazil 0.7M  3. India 0.53M 4.Russia 0.4M  5. Mexico 0.33M


--Highest Death from Population in Precentage

SELECT  location, MAX((total_deaths/population)*100) AS Country_Death_Precentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Country_Death_Precentage DESC

`

--CONTINENTS TIME

--Highest Death Continent.s


SELECT location, SUM(CAST(new_deaths AS INT)) AS Continent_Death_Count
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
AND location not in ('world', 'European Union', 'International', 'high income', 'Upper middle income', 'Lower middle income', 'Low income' )
GROUP BY location
ORDER BY Continent_Death_Count DESC



--Sum of World Corona Deaths with new Table
DROP TABLE IF EXISTS #WorldCovidDeaths
CREATE TABLE #WorldCovidDeaths
(

continent varchar(250),
total_deaths numeric,
Total_Continent_Deaths numeric

)
INSERT INTO #WorldCovidDeaths
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Continent_Death_Count, SUM(CAST(total_deaths AS INT)) AS Total_Continent_Deaths 
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Continent_Death_Count DESC

SELECT SUM(Total_Continent_Deaths ) AS World_Total_Deaths
FROM #WorldCovidDeaths

--WorldTotalDeath look not accurate with this calculation.


--Showing Continents Death from Population Precentage


SELECT  continent, MAX((total_deaths/population)*100) AS Continent_Death_Precentage
FROM PortfolioProject..CovidDeath
WHERE continent IS not NULL 
GROUP BY continent
ORDER BY Continent_Death_Precentage DESC






--Global Findings

--Find out the World Death Precentage from the Total Cases


SET ARITHABORT OFF  --Turn OFF Devided by 0 ERROR
SET ANSI_WARNINGS OFF
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS World_Death_Precentage
FROM portfolioproject.. coviddeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 3 DESC

--We can see that 0.9% of the World Total Cases have been died.



--Working on both Death, Vaccination Tables

SELECT * FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date



--Looking at number of New Vaccinations per day at each country

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent IS NOT NULL


--Summarize the Vaccinations per Country

SET ARITHABORT OFF  
SET ANSI_WARNINGS OFF  --Turn OFF ANSI Warnings
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Total_VAC_Country --Adding an ORDER BY showing the new_vac Sum.
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE new_vaccinations IS NOT NULL AND  death.continent IS NOT NULL


--Looking at number of vac from total country population
--USE CTE


--SET ARITHABORT OFF  
--SET ANSI_WARNINGS OFF  --Turn OFF ANSI Warnings
WITH Pop_Vac (continent, location, date, population, new_vaccinations, Total_People_Vac ) -- Include all Column that were in the original Query
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Total_People_Vac --Adding an ORDER BY showing the new_vac Sum.
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE new_vaccinations IS NOT NULL AND  death.continent IS NOT NULL
)
SELECT *,(Total_People_Vac/population)*100 AS Vac_Pop_Precent
FROM Pop_Vac
ORDER BY location, Vac_Pop_Precent DESC


--TEMP TABLE
DROP TABLE IF EXISTS #PrecentPopulationVaccinated  -- Add this if you want to make changes in the new Table.
CREATE TABLE #PrecentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar (250),
date datetime,
population numeric,
new_vaccinations numeric,
Total_People_Vac numeric
)

INSERT INTO #PrecentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Total_People_Vac --Adding an ORDER BY showing the new_vac Sum.
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE new_vaccinations IS NOT NULL AND  death.continent IS NOT NULL

SELECT *,(Total_People_Vac/population)*100 AS Vac_Pop_Precent
FROM #PrecentPopulationVaccinated

--Same results diffrent way..


--Creating a VIEW store data for later
CREATE VIEW PrecentPopulationVaccinated AS

--SET ARITHABORT OFF  
--SET ANSI_WARNINGS OFF  --Turn OFF ANSI Warnings
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Total_VAC_Country --Adding an ORDER BY showing the new_vac Sum.
FROM PortfolioProject..CovidDeath death
JOIN PortfolioProject..CovidVaccinations Vac
ON death.location = vac.location
AND death.date = vac.date
WHERE new_vaccinations IS NOT NULL AND  death.continent IS NOT NULL


SET ARITHABORT OFF  
SET ANSI_WARNINGS OFF  --Turn OFF ANSI Warnings
SELECT * 
FROM PrecentPopulationVaccinated