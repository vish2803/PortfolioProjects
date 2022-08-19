select * from Portfolio_project..covid_deaths$
select * from Portfolio_project..covid_vaccinations$

select location, date, total_cases, new_cases, total_deaths, population 
from Portfolio_project..covid_deaths$
order by 1,2

-- looking at Total cases vs Total Deaths 
-- shows likelihood of dying if you contract covid in your country

use "Portfolio_project" ;
go
create view TotalCasesVSTotalDeaths as
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as Death_Percentage
from Portfolio_project..covid_deaths$
where location like '%india%'
and continent is not null
--order by 1,2
go

-- looking at Total cases vs Population 
-- shows what percentage of population got covid

use "Portfolio_project" ;
go
create view TotalCasesVSPopulation as
select location, date, total_cases, population, (total_cases / population) * 100 as cases_Percentage
from Portfolio_project..covid_deaths$
where location like '%india%'
and continent is not null
--order by 1,2
go

-- looking at countries with highest infection rate with respect to population 
-- shows what percentage of population got covid***

use "Portfolio_project" ;
go
create view CountriesWithHighestInfectionRate as
select location,  population, max (total_cases) as HighestInfectionCount, max ( (total_cases / population) * 100) as PercentPopulationInfected
from Portfolio_project..covid_deaths$
--where location like '%india%'
where continent is not null
group by location, population
--order by PercentPopulationInfected DESC
go

-- showing countries with highest death count per population

use "Portfolio_project" ;
go
create view CountriesWithHighestDeathCount as
select location,  max (cast (total_deaths as int)) as TotalDeathcount
from Portfolio_project..covid_deaths$
--where location like '%india%'`
where continent is not null
group by location
--order by TotalDeathcount DESC
go

-- showing continents with highest death count per population

use "Portfolio_project" ;
go
create view ContinentsWithHighestDeathCount as
select continent,  max (cast (total_deaths as int)) as TotalDeathcount
from Portfolio_project..covid_deaths$
--where location like '%india%'`
where continent is not null
group by continent
--order by TotalDeathcount DESC
go

-- Global Numbers (Daily case count, death count and death percentage globally)

use "Portfolio_project" ;
go
create view GlobalNumbersForDailyCasesDeathsPercentage as
select date, sum(new_cases) as totaldaycases, sum(cast(new_deaths as int)) as totaldaydeaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as totaldaydeathpercent
from Portfolio_project..covid_deaths$
--where location like '%india%'
where continent is not null
group by date
--order by 1,2
go


-- Total cases, deaths, deathpercent across the world

use "Portfolio_project" ;
go
create view GlobalNumbersForTotalCasesDeathsPercentage as
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as totaldeathpercent
from Portfolio_project..covid_deaths$
--where location like '%india%'
where continent is not null
--order by 1,2
go

-- Total population vs Vaccination daily

select  dea.continent, dea.location,dea.date, population, new_vaccinations
from Portfolio_project..covid_deaths$ dea
join Portfolio_project..covid_vaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Total population vs Vaccination (rolling count)

select  dea.continent, dea.location,dea.date, population, new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_project..covid_deaths$ dea
join Portfolio_project..covid_vaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- To find total vaccination count of the total population 

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location,dea.date, population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_project..covid_deaths$ dea
join Portfolio_project..covid_vaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as percentpeoplevaccinated from PopvsVac


--USE TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select  dea.continent, dea.location,dea.date, population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_project..covid_deaths$ dea
join Portfolio_project..covid_vaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as percentpeoplevaccinated from #PercentPopulationVaccinated


-- Creating views

use "Portfolio_project" ;
go
create view PercentPopulationVaccinated as
select  dea.continent, dea.location,dea.date, population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_project..covid_deaths$ dea
join Portfolio_project..covid_vaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
go

select * from RollingPeopleVaccinated where location like '%lebanon%'