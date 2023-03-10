/*
Data Drawn from https://ourworldindata.org/covid-deaths on 2/20/2023
Then split into 2 CSVs in Microsoft Excel: covid_vax.csv and covid_deaths.csv
CSVs were further edited (formatting date and removing apostrophe from "Cote D'Ivoire")
-and imported into MySQL for querying
Queries run from DataGrip 2022.3.3
Companion Visualization on Tableau - https://public.tableau.com/app/profile/jin.yu7677/viz/GlobalCOVID22023/Dashboard1
*/

select * from world.covid_deaths
order by 3,4;

select * from world.covid_vax
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from world.covid_deaths
order by 1,2;

# Looking at Total Cases v Total Deaths
# Shows  likelihood of dying if you contract covid in your country (US)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from world.covid_deaths
where location like '%states%'
order by 1,2;

#  Looking at total cases v population
select location, date, total_cases, population, (total_cases/population)*100 DeathPercentage
from world.covid_deaths
where location like '%states%'
order by 1,2;

# Looking at countries with highest infection rate compared to population
select location, max(total_cases) max_cases, population, max((total_cases/population))*100 PercentPopulationInfected
from world.covid_deaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;

#2 Looking at countries with highest death rate compared to population
select location, sum(total_deaths) totaldeathcount
from world.covid_deaths
where continent is null and location not in ('World', 'High income','Upper middle income','Lower middle income','European Union','Low income','International')
group by location
order by totaldeathcount desc;

# Looking at continents with highest death count per population
select continent, max(total_deaths) totaldeathcount
from world.covid_deaths
where continent is not null
group by continent
order by totaldeathcount desc;

#1 Global Numbers -- totals
select sum(new_cases) totalcases, sum(new_deaths) totaldeaths, (sum(new_deaths)/sum(new_cases))*100 deathpercentage#, total_deaths, (total_deaths/total_cases)*100 deathpercentage
from world.covid_deaths
where continent is not null
order by 1,2;

# Total Populations v Vax per day
WITH popvvax (
 d.continent, v.location, v.date, v.population, rolling_count
)
    as (select v.location, v.continent, v.date, v.population, v.new_vaccinations,
        (sum(v.new_vaccinations) OVER (partition by v.location order by v.location, v.date)) rolling_count
            from world.covid_vax v
join world.covid_deaths d on v.location = d.location
and v.date = d.date
where v.continent is not null
#order by 1,2,3
)
select * from popvvax;

WITH PopvVax as (
 select v.location, v.continent, v.date, v.population, v.new_vaccinations,
        (sum(v.new_vaccinations) OVER (partition by v.location order by v.location, v.date)) rolling_count
            from world.covid_vax v
            )
select *, (rolling_count/population)*100 from PopvVax
where continent is not null;

select v.location, v.continent, v.date, v.population, v.new_vaccinations,
        (sum(v.new_vaccinations) OVER (partition by v.location order by v.location, v.date)) rolling_count
            from world.covid_vax v
join world.covid_deaths d on v.location = d.location
and v.date = d.date
where v.continent is not null
#order by 1,2,3
;

#3 Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) highestinfectioncount,  max((total_cases/population))*100 PercentPopulationInfected
from world.covid_deaths
group by location, population
order by PercentPopulationInfected desc;

#4
select location, population, date, max(total_cases) highestinfectioncount,  max((total_cases/population))*100 PercentPopulationInfected
from world.covid_deaths
group by location, population, date
order by PercentPopulationInfected desc;
