/*
Covid 19 Data Exploration
Tools: MYSQL, Data Grip
Skills used: Joins, CTE, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Source of Dataset: https://ourworldindata.org/covid-deaths
Data has been cleaned and have not been updated since 25th April 2021
*/

SELECT *
FROM CovidDeaths
ORDER BY 3,4;

# select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

# changing data from string to date
UPDATE `CovidDeaths`
SET `date` = str_to_date( `date`, '%d/%m/%Y' );
UPDATE `CovidVaccinations`
SET `date` = str_to_date( `date`, '%d/%m/%Y' );

# looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
-- My focus in Australia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
    AS death_rate
FROM CovidDeaths
    WHere location = 'Australia'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases,(total_cases/CovidDeaths.population)*100 AS contraction_rate
FROM CovidDeaths
    WHere location = 'Australia'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
##Group By date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidVaccinations AS vac
Join CovidDeaths AS dea
    USING (location, date)
WHERE dea.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
## (RollingPeopleVaccinated/population)*100
From CovidVaccinations AS vac
Join CovidDeaths AS dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
##order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
## (RollingPeopleVaccinated/population)*100
From CovidVaccinations AS vac
Join CovidDeaths AS dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
##order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
## (RollingPeopleVaccinated/population)*100
From CovidVaccinations AS vac
Join CovidDeaths AS dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
