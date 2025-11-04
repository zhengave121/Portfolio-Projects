--- Covid19 data exploration ---

Select *
From dapp-476506.covid.covid_deaths
where continent is not null
order by 3,4

--Select *
--From dapp-476506.covid.covid_vaccinations
--order by 3,4
--limit 10

--Select data that I will be using 
Select location, date, total_cases, new_cases, total_deaths, population
From dapp-476506.covid.covid_deaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of people dying if they get covid from United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From dapp-476506.covid.covid_deaths
Where lower(location) like '%states%'
and continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population in United States infected with covid
Select location, date, population,total_cases, (total_cases/population)*100 as percent_population_infected
From dapp-476506.covid.covid_deaths
Where lower(location) like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected
From dapp-476506.covid.covid_deaths
--Where lower(location) like '%states%'
group by location, population
order by percent_population_infected desc

--Showing countries with highest death count per population
Select location, max(total_deaths) as total_death_count
From dapp-476506.covid.covid_deaths
Where continent is not null
group by location
order by total_death_count desc

--FILTERING BY CONTINENT
--Showing continents with the highest death count per population
Select continent, max(total_deaths) as total_death_count
From dapp-476506.covid.covid_deaths
Where continent is not null
group by continent
order by total_death_count desc

-- GLOBAL NUMBERS
-- Global numbers of total new cases, total new deaths, and death percentage
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
From dapp-476506.covid.covid_deaths
--Where lower(location) like '%states%'
Where continent is not null
--group by date
order by 1,2

--Joining covid_deaths and covid_vaccinations tables
Select *
From dapp-476506.covid.covid_deaths as dea
join dapp-476506.covid.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date

-- Total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From dapp-476506.covid.covid_deaths as dea
join dapp-476506.covid.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE to perform calculation on partition by in the previous query
With PopvsVac as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From dapp-476506.covid.covid_deaths as dea
join dapp-476506.covid.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100 as rolling_people_vaccinated_percentage
From PopvsVac

--Total death count by continent filtering where location is not World, European Union, and International
Select location, sum(new_deaths) as total_death_count
From dapp-476506.covid.covid_deaths
Where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by total_death_count desc

-- Queries for visualization
Select location, population, date, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected
From dapp-476506.covid.covid_deaths
--Where lower(location) like '%states%'
group by location, population, date
order by percent_population_infected desc
