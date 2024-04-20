select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeathsinfo
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in yoyur country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 Deathpercentage
--(CONVERT(float,total_deaths)/NULLIF (CONVERT(Float,total_cases),0))* 100 as Deathpercentage
from PortfolioProject..CovidDeathsinfo
where location like '%states%'
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid
select location, date,population, total_cases, (total_cases/population)*100 as Percentpopulationinfected
--(CONVERT(float,total_cases)/NULLIF (CONVERT(Float,population),0))* 100 as Percentpopulationinfected
from PortfolioProject..CovidDeathsinfo
where location like '%states%'
order by 1,2

--looking at countries with the highest infection rate compared to location
select location, population, max(cast(total_cases as int)) as Highestinfectioncount, max(total_cases/population)*100 Percentpopulationinfected
--MAX((CONVERT(float,total_cases)/NULLIF (CONVERT(Float,population),0)))* 100 as Percentpopulationinfected
from PortfolioProject..CovidDeathsinfo
group by location, population
order by Percentpopulationinfected desc


--showing countries with highest death count per population
select location, MAX(cast (total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeathsinfo
where continent is not null
group by location
order by totaldeathcount desc

--LETS BREAK THINGS DOWN BY CONTINENT
--showing the continents with the highest death counts
select continent, MAX(cast (total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeathsinfo
where continent is not null
group by continent
order by totaldeathcount desc

--GLOBAL NUMBERS
select date, sum(new_cases) as totalnewcases, sum(cast (new_deaths as int)) as totalnewdeaths, 
sum(cast (new_deaths as int))/sum(new_cases)*100  as Deathpercentage
from PortfolioProject..CovidDeathsinfo
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeathsinfo dea
join PortfolioProject..CovidVaccinationsinfo vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	--LETS CREATE A CTE so we can use rollinpeoplevaccinated
with PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeathsinfo dea
join PortfolioProject..CovidVaccinationsinfo vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	select *, (CONVERT(float,RollingPeopleVaccinated)/NULLIF (CONVERT(Float,Population),0))* 100
	from PopvsVac


--use TEMP TABLES
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeathsinfo dea
join PortfolioProject..CovidVaccinationsinfo vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,6


	select *, (RollingPeopleVaccinated /population)* 100
	from #PercentPopulationVaccinated



--creating views to store data for later visualizations
create view PercentPopulationvaccinatedsecond as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeathsinfo dea
join PortfolioProject..CovidVaccinationsinfo vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3


	select *
	from PercentPopulationvaccinatedsecond

