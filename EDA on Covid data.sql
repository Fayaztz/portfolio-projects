select * from [portfolio project]..covid_deaths
order by 3,4

select * from [portfolio project]..covid_vaccination
order by 3,4


--Select Data needed
select location, date, total_cases, new_cases, total_deaths, population from [portfolio project]..covid_deaths
order by 1,2


--Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from [portfolio project]..covid_deaths 


--Looking at total cases vs Population
--shows what population of people got covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
from [portfolio project]..covid_deaths 
where location like '%india%'


--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as MaxCases, max((total_cases/population))*100 as MaxInfectedPercentage 
from [portfolio project]..covid_deaths 
group by location, population
order by MaxInfectedPercentage desc


--countries with highest death count 
select location, max(cast(total_deaths as int)) as MaxDeath
from [portfolio project]..covid_deaths 
where continent is not null
group by location
order by MaxDeath desc


--Continents with highest death count 
select location, max(cast(total_deaths as int)) as MaxDeath
from [portfolio project]..covid_deaths 
where continent is null and location not like '%income%'
group by location
order by MaxDeath desc

--global numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases)) *100 as DeathPercentage 
from [portfolio project]..covid_deaths 
where continent is not null
group by date
order by 1,2 


select * from [portfolio project]..covid_deaths as dea
join [portfolio project]..covid_vaccination as vac
on dea.location = vac.location and dea.date = vac.date


--Looking at total population and vaccinations in india
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from [portfolio project]..covid_deaths as dea
join [portfolio project]..covid_vaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and dea.location like '%india%'
order by 2,3

--Looking at Vaccinations vs Total population 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio project]..covid_deaths as dea
join [portfolio project]..covid_vaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Use CTE

with VacVsPop(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio project]..covid_deaths as dea
join [portfolio project]..covid_vaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100 from VacVsPop


--Using temp table
drop table if exists #PercentagePopulationVaccinat
create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date  datetime,
population numeric,
new_vaccinations  numeric, 
RollingPeopleVaccinated  numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio project]..covid_deaths as dea
join [portfolio project]..covid_vaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 from #PercentagePopulationVaccinated