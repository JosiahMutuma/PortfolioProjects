Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4

-- Select Data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
and Location like '%states%'
order by 1,2

-- Looking at total cases vs Population
-- Population percentage that has Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
and Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection rate compared to Population (descending)
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by TotalCasesPercentage desc

-- Showing Countries with Highest Death count (descending)
Select Location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--FILTERING BY CONTINENT
Select Location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Filtering total global numbers by date
Select date, SUM(New_cases) as Total_cases, SUM(cast (New_Deaths as int)) as Total_Deaths, SUM(cast (New_Deaths as int))/ SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2 

-- Joins: Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
order by 1,2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
order by 1,2,3

-- Using CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) as
(
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
-- order by 1,2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- TEMPORARY TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric) 

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
-- order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- Creating View For visualization in PowerBI
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
-- order by 1,2,3

-- Viewing the changes
Select * 
From PercentPopulationVaccinated
