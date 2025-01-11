SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL;

SELECT * FROM PortfolioProject..CovidVaccinations$;

--SELECt data that we are going to be using

SELECT Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
Order By 1,2;


--Looking at the total cases vs total deaths 
--Shows the likelihood of dying if you contract covid in your country
SELECT Location,date, total_cases,  total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE location= 'India' and continent IS NOT NULL
Order By 1,2 


--Looking at the total cases vs population
--Shows the percentage of population affected
SELECT Location,date, population, total_cases,  total_deaths, (total_cases/population)*100 as InfPercentage
From PortfolioProject..CovidDeaths$
WHERE location= 'India' and continent IS NOT NULL
Order By 1,2 

--looking at countries with highest infection rate vs population
SELECT Location,population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
Order By InfectedPercentage Desc 

--showing the countries with highest death count per population
SELECT Location,  MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
Order By TotalDeathCount Desc 

--Lets breakdown by continenet

SELECT continent,  MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
Order By TotalDeathCount Desc 

--Showing the continents with highest death count

--Global numbers
select date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths as int)) TotalDeaths, ((SUM(CAST(new_deaths as int))/SUM(new_cases))*100) AS GlobalDeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  RollingPplVaccinated
from PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
with PopVsVac(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  RollingPplVaccinated
from PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopVsVac

--TEmp tables
DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPplVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  RollingPplVaccinated
from PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPplVaccinated/Population)*100 FROM #PercentPopulationVaccinated


--create view to store data for later visualizations
USE PortfolioProject
DROP VIEW IF EXISTS PercentPopulationVaccinated
Go
CREATE VIEW PercentPopulationVaccinated
as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)  RollingPplVaccinated
from PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
Go


