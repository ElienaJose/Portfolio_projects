SELECT *
FROM
Portfolio_project.dbo.covid_deaths
ORDER BY 3,4;

SELECT * 
FROM
Portfolio_project.dbo.covid_vaccination
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases,total_deaths, new_deaths ,population 
FROM
Portfolio_project.dbo.covid_deaths
ORDER BY 1,2

--Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths,ROUND((total_deaths/NULLIF(total_cases,0))*100 ,2) AS death_percentage
FROM
Portfolio_project.dbo.covid_deaths
ORDER BY 1,2

--Looking at total cases vs total deaths for United States
SELECT location, date, total_cases, total_deaths,ROUND((total_deaths/NULLIF(total_cases,0))*100 ,2) AS death_percentage
FROM
Portfolio_project.dbo.covid_deaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT DISTINCT(location)
FROM
Portfolio_project.dbo.covid_deaths

--Lookin at new cases vs population
SELECT location, date, total_cases, population,ROUND((total_cases/population)*100 ,2) AS infected_percentage
FROM
Portfolio_project.dbo.covid_deaths
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project.dbo.covid_deaths
--Where location like '%states%'
Group by location, population

order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_project.dbo.covid_deaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_project.dbo.covid_deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(New_Cases),0)*100 as DeathPercentage
From Portfolio_project.dbo.covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


WITH PopVSVac
AS

(SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations,0) AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date,dea.location) AS Rolling_count_vaccinated
FROM 
Portfolio_project.dbo.covid_deaths dea 
JOIN 
Portfolio_project.dbo.covid_vaccination vac
ON 
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT * ,CONCAT(CAST(ROUND(Rolling_count_vaccinated/population *100 ,2) AS VARCHAR),'%') AS vaccinated_percentage
FROM 
PopVSVac
ORDER BY location,date;

--Using Temp table


DROP TABLE IF EXISTS #RolloingPeopleVaccinated
CREATE TABLE #RolloingPeopleVaccinated
(
 location VARCHAR(255),
 Date DATETIME,
 population numeric,
 new_vaccinations numeric,
 rolling_count_vaccinated bigint
 )

INSERT INTO #RolloingPeopleVaccinated
SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations,0) AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date,dea.location) AS Rolling_count_vaccinated
FROM 
Portfolio_project.dbo.covid_deaths dea 
JOIN 
Portfolio_project.dbo.covid_vaccination vac
ON 
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * ,CONCAT(CAST(ROUND(Rolling_count_vaccinated/population *100 ,2) AS VARCHAR),'%') AS vaccinated_percentage
FROM 
#RolloingPeopleVaccinated
ORDER BY location,date;

--Creating View

CREATE VIEW RolloingPeopleVaccinated 
AS
SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(ISNULL(vac.new_vaccinations,0) AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date,dea.location) AS Rolling_count_vaccinated
FROM 
Portfolio_project.dbo.covid_deaths dea 
JOIN 
Portfolio_project.dbo.covid_vaccination vac
ON 
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * ,CONCAT(CAST(ROUND(Rolling_count_vaccinated/population *100 ,2) AS VARCHAR),'%') AS vaccinated_percentage
FROM 
RolloingPeopleVaccinated
ORDER BY location,date;



