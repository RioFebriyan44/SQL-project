select * from coviddeaths;
select * from covidvaccination c ;

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths 
order by 1,2;

alter table coviddeaths 
rename column population_density to population;

-- Looking at total cases vs total deaths
-- shows likehood of dying if you contract in your country
select location, date, total_cases, total_deaths, (total_cases/total_deaths) * 100 as DeathPercentage
from coviddeaths 
where location like '%state%' 
order by 1,2;

-- looking at total cases vs populatio
-- show what percentage of population got covid
select location, date, population, total_cases, (total_cases / population) * 100 as PopulationPercentage
from coviddeaths 
where location like '%state%'
order by 1,2 ;

-- looking at countries with Highest infection rate compared to population
select location, population, max(total_cases) as HighesInfectionCount ,
max(total_cases / population ) * 100 as PercentagePopulationInfected 
from coviddeaths
where location like '%states%';

-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths 
where continent is not null
group by location 
order by TotalDeathCount desc;

-- let's break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null 
group by continent 
order by TotalDeathCount desc;

-- Global numbers 
select date, sum(total_cases) as TotalCasesCount, sum(cast(total_deaths as int )) as TotalDeathsCount,
sum(cast(total_deaths as int)) / sum(total_cases) * 100 as TotalNewdeathPrecentage
from coviddeaths 
where continent is not null 
group by date 
order by 1,2;

-- Looking at Population vs Vaccination
select * from covidvaccination;

select dea.continent, dea.location, dea.date, dea.Population, 
sum(convert(vac.new_vaccinations, int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths as dea join covidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;


-- USE CTE 
select New_vaccinations from CovidVaccination;

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as (
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
sum(convert(vac.New_Vaccinations, int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from CovidDeaths as dea join CovidVaccination as vac on
dea.location = vac.location and dea.date = vac.date
where dea.Continent is not null
) select * from PopvsVac limit 200;

select *, (RollingPeopleVaccination/People) * 100 from PopvsVac

-- Temp Table 
drop table if Exists PercentPopulationVaccinated
create table PercentPopulationVaccinated 
(Continent varchar(255), Location varchar(255), date date, Population numeric, 
New_Vaccinations numeric, RollingPeopleVaccination numeric);

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths as dea join covidvaccination as vac 
on dea.location = vac.location and dea.date = vac.date;

select * from PercentPopulationVaccinated;

-- Creating View to store data for later visualization
create view PercentPopulationVaccinated2 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths as dea join covidvaccination as vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;

select * from PercentPopulationVaccinated2;





