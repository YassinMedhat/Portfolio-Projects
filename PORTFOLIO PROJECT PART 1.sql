SELECT *
FROM CovidDeaths$
Where continent is not null
order by 3,4

--SELECT * 
--FROM CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
--likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From CovidDeaths$
Where location like '%Egypt%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as DiseasedPercentage
From CovidDeaths$
--Where location like '%Egypt%'
order by 1,2

--countires with highest infection rate compared to population
Select Location, max(total_cases) as TotalCases, population, max((total_cases/population)*100) as InfectedPercentagePerPopulation
From CovidDeaths$
GROUP BY location, population
ORDER BY InfectedPercentagePerPopulation DESC

--countries with highest death count
Select Location, max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths$
Where continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC

--continents with highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths$
Where continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

--global numbers
Select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as deathpercentage
From CovidDeaths$
where continent is not null
order by 1,2

--looking at  total population vs vaccination 
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as TotalVaccinationsPerCountry

from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 3

--using CTE
with CTE_VACvsPOP (continent, location, date, population, new_vaccinations, TotalVaccinationsPerCountry) 
as 
(
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as TotalVaccinationsPerCountry

from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

select *, (TotalVaccinationsPerCountry/population) *  100 
from CTE_VACvsPOP

--temp table
DROP TABLE IF EXISTS #VACvsPOP
create table #VACvsPOP (
date datetime,
continent nvarchar(255),
location nvarchar(255), 
population int,
newvaccinations int,
totalvaccinationspercountry int
)
insert into #VACvsPOP 
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as TotalVaccinationsPerCountry
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (TotalVaccinationsPerCountry/population) *  100 
from #VACvsPOP


-- Creating view to store data for later visualizations

Create View VACvsPOP as 
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as TotalVaccinationsPerCountry
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * 
from VACvsPOP









