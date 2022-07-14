-- COVID 19 DATA EXPLORATION --

SELECT location, CAST(date AS DATE) AS date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Total_cases vs Total_deaths 

SELECT location, date, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Altering date format

ALTER TABLE PortfolioProject..CovidDeaths$
ALTER COLUMN date DATE

-- Finding out the deathrate_percentage 
-- indicates the likelihood of death occuring due to Covid depending on location

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathrate_percentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Total Cases vs Population
-- Percent_Population_Infected indicates what percentage of population infected with Covid

SELECT Location, Date, Population, Total_Cases, (total_cases/population)*100 as Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, 
MAX(total_cases) AS Highest_Infection_Count, 
(MAX(total_cases)/Population)*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- Showing contintents with the highest death count per population

SELECT Continent, MAX(CAST(Total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY Total_Death_Count DESC

-- Total Population vs Vaccinations

SELECT Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations
, SUM(CONVERT(int,Vac.New_Vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.Date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ AS Dea
JOIN PortfolioProject..CovidVaccinations$ AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE Dea.Continent IS NOT NULL
ORDER BY 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations
, SUM(CONVERT(int,Vac.New_Vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location, Dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS Dea
JOIN PortfolioProject..CovidVaccinations$ AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM #PercentPopulationVaccinated



