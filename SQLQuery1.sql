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

--Highest Death Continent.


SELECT location, MAX(CAST(total_deaths AS INT)) AS Country_Death_Count
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY Country_Death_Count DESC



--Showing Continents Death from Population Precentage


SELECT  location, MAX((total_deaths/population)*100) AS Continent_Death_Precentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL 
GROUP BY location
ORDER BY Continent_Death_Precentage DESC

-- 1. South America 3%    2. Europe 2.77%    3. North America 2.66%    




--Global Findings

--Find out the Total Death Precentage from the Total Cases


SET ARITHABORT OFF  --Turn OFF Devided by 0 ERROR
SET ANSI_WARNINGS OFF
SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS World_Death_Precentage
FROM portfolioproject.. coviddeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 4 DESC



SET ARITHABORT OFF  --Turn OFF Devided by 0 ERROR
SET ANSI_WARNINGS OFF
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS World_Death_Precentage
FROM portfolioproject.. coviddeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 3 DESC

--We can see that 0.9% of the Total Cases have been died.- World Wide.
