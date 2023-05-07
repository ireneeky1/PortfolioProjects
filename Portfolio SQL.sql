select * from[dbo].[CovidDeaths$]
where continent is not null
order by 3,4

select * from [dbo].[CovidVaccinations$]
order by 3,4


select location, date, total_cases,total_deaths, new_cases, population
from [dbo].[CovidDeaths$]
order by 1,2

--Looking at Total Cases vs Total Deaths 
-- This Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
where location like '%Niger%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got covid

select location, date, total_cases,population , (total_cases/population)*100 as PopulationPercentage
from [dbo].[CovidDeaths$]
where location like '%States%'
order by 1,2

--Looking at countries with highest infection rate compared to Population 

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationPercentageInfected
from [dbo].[CovidDeaths$]
--where location like '%States%'
group by population, location
order by PopulationPercentageInfected desc

--Looking at the Locations with the Highest Death Count to population

select location, max(cast(total_deaths as int)) as TotalDeathCounts
from [dbo].[CovidDeaths$]
--where location like '%States%'
where continent is not null
group by location
order by TotalDeathCounts desc

--LET'S BREAK THINGS BY CONTINENT

select LOCATION, max(cast(total_deaths as int)) as TotalDeathCounts
from [dbo].[CovidDeaths$]
--where location like '%States%'
where continent is null
group by location
order by TotalDeathCounts desc

--Showing the continent with the Highest Death Count to population
select CONTINENT, max(cast(total_deaths as int)) as TotalDeathCounts
from [dbo].[CovidDeaths$]
--where location like '%States%'
where continent is NOT null
group by CONTINENT
order by TotalDeathCounts desc

--Global Numbers 

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from [dbo].[CovidDeaths$]
where continent is not null
group by date
order by 1,2 desc

--Looking at Total Population vs Vaccinations 

select * from [dbo].[CovidVaccinations$] as vac
join [dbo].[CovidDeaths$]  as dea
    on vac.date=dea.date and vac.location = dea.location

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ as Dea
join [dbo].[CovidVaccinations$]  as Vac
    on vac.date=dea.date and vac.location = dea.location
where Dea.continent is not null
order by 2,3

--Looking for Percentage of People vaccinated 

with PopvsVac (Continent, Location,Date,Population, new_vaccinations,RollingPeopleVaccinated)
as (
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ as Dea
join [dbo].[CovidVaccinations$]  as Vac
    on vac.date=dea.date and vac.location = dea.location
where Dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccination
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ as Dea
join [dbo].[CovidVaccinations$]  as Vac
    on vac.date=dea.date and vac.location = dea.location
--where Dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccination
from #PercentPopulationVaccinated 

--Creating View to store data forlater visualizations 

Create View PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ as Dea
join [dbo].[CovidVaccinations$]  as Vac
    on vac.date=dea.date and vac.location = dea.location
where Dea.continent is not null
--order by 2,3












