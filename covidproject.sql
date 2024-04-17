
-- Retrieve all data from the coviddeaths table and order by date and location
SELECT *
FROM PortfolioProject..coviddeaths
ORDER BY 3, 4;

-- Retrieve all data from the covidvac table and order by date and location
SELECT *
FROM PortfolioProject..covidvac
ORDER BY 3, 4;

-- Retrieve location, date, total_cases, new_cases, total_deaths, and population from the coviddeaths table, ordered by location and date
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM PortfolioProject..coviddeaths
ORDER BY 1, 2;

--looking for Total cases vs Total deaths 
-- Calculate the likelihood of dying based on total cases and total deaths in India
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%india%'
ORDER BY 1, 2;

--- Calculate total cases vs population
SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS percentpopulationinfected
FROM PortfolioProject..coviddeaths
ORDER BY 1, 2;

-- Find the highest infected country along with its population
SELECT
    location,
    population,
    MAX(total_cases),
    MAX(total_cases / population) * 100 AS percentpopulationinfected
FROM PortfolioProject..coviddeaths
GROUP BY location, population
ORDER BY percentpopulationinfected DESC;
-- Show countries with the highest death count per population
SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS totaldeathcount 
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

-- Find the continent with the highest death count
SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS totaldeathcount 
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY totaldeathcount DESC;
-- Calculate global numbers: total cases, total deaths, and death percentage by date
SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;
-- Calculate global total number of cases, total deaths, and death percentage
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

----- now im joining the covid death table with the vacination table

select * from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvac vac
on dea.date=vac.date----dea.location=vac.location
and dea.location=vac.location

--- now im looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location) as rollingpeoplevaccinated  from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvac vac
on dea.date=vac.date----dea.location=vac.location
and dea.location=vac.location
where dea.continent is not null
order by 2,3
----using cte
with  popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as

(
select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over (partition by dea.location) as rollingpeoplevaccinated  from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvac vac
on dea.date=vac.date----dea.location=vac.location
and dea.location=vac.location
where dea.continent is not null
)
select*,(rollingpeoplevaccinated/population)*100
from popvsvac
-- Create the temporary table
drop table if exists percentpopulationvaccinated 
CREATE TABLE #percentpopulationvaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    newvaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
)

-- Populate the temporary table
INSERT INTO #percentpopulationvaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS rollingpeoplevaccinated
FROM
    PortfolioProject..coviddeaths dea
JOIN
    PortfolioProject..covidvac vac ON dea.date = vac.date
                                    AND dea.location = vac.location
WHERE
    dea.continent IS NOT NULL

-- Calculate the percentage of population vaccinated
SELECT
    *,
    (rollingpeoplevaccinated / population) * 100 AS percent_population_vaccinated
FROM
    #percentpopulationvaccinated

-- Create a view named percentpopulationvaccinated

	create view percentpopulationvaccinated as
	SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS rollingpeoplevaccinated
FROM
    PortfolioProject..coviddeaths dea
JOIN
    PortfolioProject..covidvac vac ON dea.date = vac.date
                                    AND dea.location = vac.location
WHERE
    dea.continent IS NOT NULL





















