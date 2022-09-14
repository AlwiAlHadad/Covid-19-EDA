select
	*
from
	Portofolio..coviddeaths
where
	continent is not null
order by
	3,4

--select
--	*
--from
--	Portofolio..covidvaccinations
--order by
--	3,4


--select data that we are going to be using

select
	location, 
	date, 
	total_cases, 
	new_cases,
	total_deaths, 
	population
from
	Portofolio..coviddeaths
order by
	1,2


-- looking at total cases vs total deaths
-- show likelihood of dying if you got covid in your country
select
	location, 
	date, 
	total_cases,
	total_deaths, 
	(total_deaths/total_cases)*100 as deathpercentage
from
	Portofolio..coviddeaths
where
	location like 'indonesia'
	and
	continent is not null
order by
	1,2


-- looking at total cases vs population
-- show what percentage of population got covid
select
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as percentpopulationinfected
from
	Portofolio..coviddeaths
where
	location like 'indonesia'
	and
	continent is not null
order by
	1,2


-- looking at country with highest infection rate compared to population

select
	location, 
	population, 
	max(total_cases) as highestinfectioncount, 
	max((total_cases/population))*100 as percentpopulationinfected
from
	Portofolio..coviddeaths
--where
--	location like 'indonesia'
--and
--	continent is not null
group by
	location,
	population
order by
	4 desc


-- showing countries with highest death count per population

-- LETS BREAK THINGS DOWN BY CONTINENT


select
	location, 
	max(cast(total_deaths as int)) as totaldeathcount
from
	Portofolio..coviddeaths
where
--	location like 'indonesia'
--and
	continent is not null
group by
	location
order by
	2 desc


-- showing continents with the highes death count per population

select
	continent, 
	max(cast(total_deaths as int)) as totaldeathcount
from
	Portofolio..coviddeaths
where
--	location like 'indonesia'
--and
	continent is not null
group by
	continent
order by
	2 desc




-- GLOBAL NUMBERS

select 
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
	--,
	--total_deaths, 
	--(total_deaths/total_cases)*100 as deathpercentage
from
	Portofolio..coviddeaths
where
--	location like 'indonesia'
--	and
	continent is not null
--group by
--	date
order by
	1,2




-- looking at total population vs vaccinations

select
	t1.continent,
	t1.location,
	t1.date,
	t1.population,
	t2.new_vaccinations,
	sum(cast(t2.new_vaccinations as int)) over (partition by t1.location order by t1.location, t1.date) as total_vaccination_perlocation
from
	Portofolio..CovidDeaths as t1
	join
	Portofolio..CovidVaccinations as t2
	on
	t1.location=t2.location
	and
	t1.date=t2.date
where
	t1.continent is not null
order by
	2,3


-- USE CTE

with popvsvac (continent,location,date,population,new_vaccination,total_vaccination_perlocation)
as
(
select
	t1.continent,
	t1.location,
	t1.date,
	t1.population,
	t2.new_vaccinations,
	sum(cast(t2.new_vaccinations as int)) over (partition by t1.location order by t1.location, t1.date) as total_vaccination_perlocation
from
	Portofolio..CovidDeaths as t1
	join
	Portofolio..CovidVaccinations as t2
	on
	t1.location=t2.location
	and
	t1.date=t2.date
where
	t1.continent is not null
--order by
--	2,3
)
select
	*,
	(total_vaccination_perlocation/population)*100 as total_vaccinated_percentage
from
	popvsvac





-- TEMP TABLE


drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_vaccination_perlocation numeric
	)


insert into
	#percentpopulationvaccinated
select
	t1.continent,
	t1.location,
	t1.date,
	t1.population,
	t2.new_vaccinations,
	sum(cast(t2.new_vaccinations as int)) over (partition by t1.location order by t1.location, t1.date) as total_vaccination_perlocation
from
	Portofolio..CovidDeaths as t1
	join
	Portofolio..CovidVaccinations as t2
	on
	t1.location=t2.location
	and
	t1.date=t2.date
--where
--	t1.continent is not null
--order by
--	2,3

select
	*,
	(total_vaccination_perlocation/population)*100 as total_vaccinated_percentage
from
	#percentpopulationvaccinated



-- creating view to store data for later vizualizations

create view percentpopulationvaccinated as
select
	t1.continent,
	t1.location,
	t1.date,
	t1.population,
	t2.new_vaccinations,
	sum(cast(t2.new_vaccinations as int)) over (partition by t1.location order by t1.location, t1.date) as total_vaccination_perlocation
from
	Portofolio..CovidDeaths as t1
	join
	Portofolio..CovidVaccinations as t2
	on
	t1.location=t2.location
	and
	t1.date=t2.date
where
	t1.continent is not null
--order by
	--2,3


-- create some more table view

create view deathpercentage as
select
	location, 
	date, 
	total_cases,
	total_deaths, 
	(total_deaths/total_cases)*100 as deathpercentage
from
	Portofolio..coviddeaths
where
	location like 'indonesia'
	and
	continent is not null
--order by
--	1,2