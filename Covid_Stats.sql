Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Selecting the data that we are going to use

Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Comparring total cases with total deaths (Death Percentage)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 2 Desc

--Comparing total cases with Population (Percentage pf population got effected) in pakistan

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%pakistan%'
Order by 5 Desc

--Finding the country with highest infection rate

Select location, population, max(total_cases) as MaximumTotalCases, max((total_cases/population))*100 as MaxCasePercentage
From PortfolioProject..CovidDeaths
Group by location, population
Order by population Desc

--Countries with highest deaTH count

Select location, max(cast(total_deaths as int)) as totaldeaths
From PortfolioProject..CovidDeaths
where continent is not null --we did this so that it will not pull the whole continents in the resulted data
Group by location
Order by totaldeaths Desc

--Continents with highest deaTH count

Select location, max(cast(total_deaths as int)) as totaldeaths
From PortfolioProject..CovidDeaths
where continent is null --we did this so that it will only pull the whole continents in the resulted data (Check the original table for context)
Group by location
Order by totaldeaths Desc

--Death counts in countries w.r.t continent

Select location, max(cast(total_deaths as int)) as totaldeaths
From PortfolioProject..CovidDeaths
where continent like '%Europe%'
Group by location
Order by totaldeaths Desc

--Global Numbers

Select date, sum(total_cases) as TotalCases, sum(cast(total_deaths as int))  as TotalDeaths, (sum(cast(total_deaths as int))/sum(total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1

--WORKING ON THE SECOND TABLE

Select *
From PortfolioProject..CovidVaccinations

--Joining two tables
Select *
From PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date

--Total population vs. Vacinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Getting the total number of vaccinations in each country by summing the every next vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use of Common Table Expression (CTE) to do calculations with PeopleVaccinated coloumn as cannot do it normaly because it is an alias (look above for the context)
With PopVsVac (Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (PeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From PopVsVac

--Temp Table (function almost same as CTE) and it is used for temporary storage of data and manipulations
Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
( --defining the coloumns in the table and their data types
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3
Select *, (PeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From PercentPopulationVaccinated

--Creating View For using it later for visualizations
Create View TotalPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


