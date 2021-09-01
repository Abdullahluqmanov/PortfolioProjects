--select * from
--PortfolioProject..Covid_Deaths
--WHERE continent is not NULL;


--select * from
--PortfolioProject..COVID_Vaccinations


--select data that we are going to be using:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
ORDER BY 1,2;

--Look at the Total cases VS Total deaths
--It shows the likelihood of dying if you contrct covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_Percentage
FROM PortfolioProject..Covid_Deaths
Where location like '%Australia%'
AND continent is not NULL
ORDER BY 1,2;


--Look at Total cases VS Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_Percentage
FROM PortfolioProject..Covid_Deaths
--Where location like '%Australia%'
ORDER BY 1,2;

--Looking at countries has Highest infection rate compare to the Population

SELECT location, population, max(total_cases) AS highest_Infection_Count, (max(total_cases)/population)*100 AS infection_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE continent is not NULL
Group by Location, population
ORDER BY infection_Percentage DESC;

--Showing countries with the Highest Death Count per population

SELECT location, MAX(CAST(Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is not NULL
Group by Location
ORDER BY TotalDeathCount DESC;

-- Showing the continents with the highest death counts

SELECT continent, MAX(CAST(Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is NOT NULL
Group by continent 
ORDER BY TotalDeathCount DESC;

--Global Numbers
---Total numbers globally

SELECT SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_rate--, total_deaths, (total_deaths/total_cases)*100 AS death_Percentage
FROM PortfolioProject..Covid_Deaths
where continent is not NULL
ORDER BY 1,2;

-- Total numbers globally group by date

SELECT date, SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_rate--, total_deaths, (total_deaths/total_cases)*100 AS death_Percentage
FROM PortfolioProject..Covid_Deaths
where continent is not NULL
group by date
ORDER BY 1,2;

--Look at Total Population vs Vaccination ( How many people in the world got vaccinated)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS rolling_People_Vaccinated
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


--Use CTE

WITH CTE_PopVSVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS rolling_People_Vaccinated
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM CTE_PopVSVac;

-- Using Temp Table to represent the same thing above ( percent people vaccinated)

CREATE TABLE #Percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO #Percentpeoplevaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS rolling_People_Vaccinated
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #Percentpeoplevaccinated;

-- Creating view for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS rolling_People_Vaccinated
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated;