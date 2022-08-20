-- Covid 19 Data Exploration

-- Skills used: Joins, CTE's Windows Functions, Aggregate Functions, Converting Data types and Creating Views.

-- Viewing data from imported Covid Deaths data set and ordering by location and date
Select * 
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
order by 3,4

-- Viewing data from imported Covid Vaccinations data set and ordering by location and date
Select * 
from [Data Analyst Portfolio]..['CovidVaccinations$']
order by 3,4

-- Selecting data that we will be using
Select location, date, total_cases, new_cases, total_deaths, population
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
order by 1,2


-- Total cases vs Total deaths 
-- Shows likelihood of dying if you get covid in the UK
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
and location = 'United Kingdom'
order by 1,2

-- Creating view to store data for late visualisation.
Create view death_percentage as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
and location = 'United Kingdom'


-- Total cases vs population
-- Shows what percentage of of the population contracts covid in the UK
Select location, date, population, total_cases, (total_cases/population)*100 as covid_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
and location = 'United Kingdom'
order by 1,2

-- Creating view to store data for late visualisation.
Create view covid_percentage as
Select location, date, population, total_cases, (total_cases/population)*100 as covid_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
and location = 'United Kingdom'


-- Countries with the highest infection rate vs population
Select location, population, MAX(total_cases) as highest_infection_count , MAX((total_cases/population))*100 as covid_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
group by population, location
order by covid_percentage desc


-- Looking at countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
group by location
order by total_death_count desc


-- BREAKING DOWN BY CONTINENT

-- Looking at death count based on continent
Select continent, MAX(cast(total_deaths as int)) as total_death_count
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
group by continent
order by total_death_count desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
order by 1,2


-- Total number of cases and deaths in the United Kingdom
Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from [Data Analyst Portfolio]..['CovidDeaths$']
where continent is not null
and location = 'United Kingdom'
order by 1,2

-- Joining the deaths and vaccination tables
-- Looking at Total Population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From [Data Analyst Portfolio]..['CovidDeaths$'] dea
Join [Data Analyst Portfolio]..['CovidVaccinations$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- Using CTE to perform calulation on 'Partition by' (rolling_people_vaccinated) 
-- Calculating percentage of population who have received at least one Covid vaccine

With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From [Data Analyst Portfolio]..['CovidDeaths$'] dea
Join [Data Analyst Portfolio]..['CovidVaccinations$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as percentage_vaccinated
from pop_vs_vac
order by 2,3


-- Creating temp table to create view  to store data for later visualizations
DROP Table if exists percent_population_vaccinated
Create Table percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From [Data Analyst Portfolio]..['CovidDeaths$'] dea
Join [Data Analyst Portfolio]..['CovidVaccinations$'] vac
on dea.location = vac.location 
and dea.date = vac.date 

Select *, (rolling_people_vaccinated/population)*100
From percent_population_vaccinated


-- Creating View to store data for later visualizations

Create View percent_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From [Data Analyst Portfolio]..['CovidDeaths$'] dea
Join [Data Analyst Portfolio]..['CovidVaccinations$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
