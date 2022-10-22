/*
Queries used for Tableau Project
*/

## Convert date from String to date format
UPDATE `OwidCovid`
SET `date` = str_to_date( `date`, '%d/%m/%Y' );

-- 1.
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From OwidCovid
where continent is not null
#Group By date
order by 1,2;

-- 2.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(new_deaths) as TotalDeathCount
From OwidCovid
Where continent is null
and location not in ('World', 'European Union', 'International')
AND location NOT like '%income'
Group by location
order by TotalDeathCount desc;

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From OwidCovid
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4.
##output as CSV for Tableau to read better
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From OwidCovid
Group by Location, Population, date
order by PercentPopulationInfected desc;
