--Looking into Death Table for Covid-19

select *
from PortfolioProject..CobidDeaths
where continent is not null AND continent like '%asia'
order by 2,3

--select *
--from PortfolioProject..CobidVacinations
--order by 2,3

--Selecting that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CobidDeaths
order by 1,2

-- Total Cases vurses Total Death
-- Shows the likelihood of dying if you contact with COVID-19

Select Location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Per
from PortfolioProject..CobidDeaths
where Location like '%Namibia%'
order by Death_Per Desc

-- Total Cases vurses Population
-- Shows what population percentange got covid-19
Select Location, date, total_cases, population, round((total_deaths/population)*100,2) as Population_Per
from PortfolioProject..CobidDeaths
where Location like '%Namibia%'
order by Population_Per Desc

--Looking at Countries with highest Infection rate compared to Population

Select Location,population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as Population_Per
from PortfolioProject..CobidDeaths
--where Location like '%Namibia%'
Group by Location, population
order by Population_Per Desc

-- Showing the countries with the highest Death count vs Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CobidDeaths
--where Location like '%Namibia%'
where continent is not null
Group by Location
order by TotalDeathCount Desc

-- Lest break things Down by continents

Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentange
from PortfolioProject..CobidDeaths
--where Location like '%Namibia%'
where continent is not null
--Group by date
order by 1,2


--Looking into Vacination Table for Covid-19

select * 
from PortfolioProject..CobidVacinations


--Joining tables on date and conti
-- looking at the total population versus vaccination
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacination
from PortfolioProject..CobidDeaths dea
join PortfolioProject..CobidVacinations vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVacination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacination
from PortfolioProject..CobidDeaths dea
join PortfolioProject..CobidVacinations vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3

)
select *, (RollingPeopleVacination/Population)*100 
from PopvsVac

--TEMPT TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacination numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacination
from PortfolioProject..CobidDeaths dea
join PortfolioProject..CobidVacinations vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVacination/Population)*100 
from #PercentPopulationVaccinated


-- Create View to store data for visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacination
from PortfolioProject..CobidDeaths dea
join PortfolioProject..CobidVacinations vacc
	on dea.location = vacc.location 
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated