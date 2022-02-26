-- Querying full Data and ordering by 3 & 4th column
Select * From PortfolioProjects..CovidDeaths
Order By 3,4

-- Querying full Data and ordering by 3 & 4th column
Select * From PortfolioProjects..CovidVaccinations$
Order By 3,4

-- Querying specific columns
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths$
order by 1,2


-- Total cases vs Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where location LIKE '%India%'
order by 1,2


--Now we are looking at Total cases vs population 
-- Shows what percentage of population got covid f=grouping by location
Select location, date, population, total_cases,  (total_cases/population)*100 as CovidaffectedPercentage
From PortfolioProjects..CovidDeaths$
Where location LIKE '%India%'
order by 1,2


-- Looking at highest country with Infection rate
Select location, population, MAX(total_cases) as HighestInfectionrate,  MAX((total_cases/population))*100 as Percentperpopulation
From PortfolioProjects..CovidDeaths$
Group by location, population
order by Percentperpopulation DESC


-- We found that there are few locations which are named after continents so we are excluding them for now
Select * From PortfolioProjects..CovidDeaths
Where continent is not null

-- Showing countries with highest death count per population
Select location, MAX(Cast(total_deaths as int)) as Totaldeathcount    # We are using casting because some of the rows of total_deadths has "null" values
From PortfolioProjects..CovidDeaths$
Where continent is not null					     
Group by location, population
order by Totaldeathcount DESC

-- Breaking things by continent
Select continent, MAX(Cast(total_deaths as int)) as Totaldeathcount
From PortfolioProjects..CovidDeaths
Where continent is not null
Group by continent
order by Totaldeathcount DESC

-- These are the correct number of deadths after excluding continents with "Null" Values
Select location, MAX(Cast(total_deaths as int)) as Totaldeathcount
From PortfolioProjects..CovidDeaths$
Where continent is null
Group by location
order by Totaldeathcount DESC

-- Showing continents with the highest death counts
Select continent, MAX(Cast(total_deaths as int)) as Totaldeathcount
From PortfolioProjects..CovidDeaths$
Where continent is not null
Group by continent
order by Totaldeathcount DESC


-- Global numbers
Select SUM(new_cases) as Totalcases, SUM(CAST(new_deaths as INT)) as TotalDeadths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Deadthpercentage From PortfolioProjects..CovidDeaths 
Where continent is not null
order by 1,2


-- Looking at both Covid Deadths and Covid Vaccination by Joining them by location and date columns 
Select * From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date

-- Looking at total population vs vaccination
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date
Where dea.continent is not null
Group by dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
order by 2,3

-- Using CTE (Common table expressions)

WITH PopvsVac (Continent, location, date, population, new_vaccination, Rollingpeoplevaccinated)
AS
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date
Where dea.continent is not null
Group by dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
)
SELECT * FROM PopvsVac


WITH PopvsVac1 (Continent, location, date, population, new_vaccination, Rollingpeoplevaccinated)
AS
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date
Where dea.continent is not null AND dea.location = 'India'
--Group by dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
)
SELECT *, (Rollingpeoplevaccinated/population)*100 FROM PopvsVac1
-- CTE can be used to make calculations (Rollingpeoplevaccinated/population)*100 with calculated columns in the select statement(Rollingpeoplevaccinated)



-- Creating Views for future visualizations
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac. location
	AND dea.date = vac.date
Where dea.continent is not null
--Group by dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations


select * From PercentPopulationVaccinated
