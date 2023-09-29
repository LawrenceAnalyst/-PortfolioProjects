-- My Portfolio Project Using Covid-19 data
--'Lawrence' THE ANALYST

--select all the data 
select *
from PortfolioProject..covidDeaths
order by 3,4

--select all the data for covid Vaccintions
Select *
from PortfolioProject..Covidvaccinations

--select data that we are going to be using 
select location, date, total_cases, new_cases, Total_deaths, Population 
From portfolioproject..CovidDeaths 
order by 1,2


--looking at the Total Cases vs Total Deaths 
select location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From portfolioproject..CovidDeaths 
order by 1,2

--show likelihood of dying if you have covid in Canada by percentage 
select location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From portfolioproject..CovidDeaths 
where location like '%canada%'
order by 1,2
 
 --show likelihood of dying if you have covid in United states by percentage 
select location, date, total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From portfolioproject..CovidDeaths 
where location like '%states%'
order by 1,2

--total cases vs population 
--shows what percentage of population got covid 
select location, date, total_cases, Total_deaths, population, (total_deaths/population )*100 as DeathPercentage 
From portfolioproject..CovidDeaths 
where location like '%canada%'
order by 1,2


-- looking at Countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population ))*100 as PercentPopulationInfected 
From portfolioproject..CovidDeaths 
group by location, population 
order by PercentPopulationInfected desc


-- showing countries with the highest death count per population NB adding 'cast(td as int)'function is to convert the values in 
--total deaths to interger to allow the function process.
select location, Max(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc

--LET BREAK IT DOWN BY CONTINENT 
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc

--LET BREAK IT DOWN BY CONTINENT a better way of doing it 
select Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
where Continent is null
group by Location
order by TotalDeathCount desc



--LOOKING AT GLOBAL NUMBERS grouped by date accross the world 
select  date, sum(new_cases)as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths 
where continent is not null
group by date
order by 1,2 

-- Total number of cases and death around the world 
select sum(new_cases)as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths 
where continent is not null
--group by date
order by 1,2 

--lets look into the covid vaccination table 
select *
from portfolioproject..covidvaccinations 


-- here we join the covid death and covid vaccination table  
--with date and location 
select *
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date

--looking at the Total population vs Vaccinationsselect *
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations 
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date
where death.continent  is not null
order by 1,2,3

-- try something new 
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) OVER (partition by death.location order by death.location,
death.date) as rollingnumberOFpeoplevaccintaed 
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date
where death.continent  is not null
order by 1,2,3

--- as you can observe add this (rollingnumberOFpeoplevaccintaed/population)*100  will give an error
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) OVER (partition by death.location order by death.location,
death.date) as rollingnumberOFpeoplevaccintaed 
(rollingnumberOFpeoplevaccintaed/population)*100
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date
where death.continent  is not null
order by 1,2,3
-- so i will create a CTE 

 --use CTE 
 WITH PopvsVacc (Continent, location, date, population, new_vaccinations, rollingnumberOFpeoplevaccintaed)
 as
 (
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) OVER (partition by death.location order by death.location,
death.date) as rollingnumberOFpeoplevaccintaed 
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date
where death.continent  is not null
)
select *
from PopvsVacc

--now lets insert (rollingnumberOFpeoplevaccintaed/population)*100
 WITH PopvsVacc (Continent, location, date, population, new_vaccinations, rollingnumberOFpeoplevaccintaed)
 as
 (
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) OVER (partition by death.location order by death.location,
death.date) as rollingnumberOFpeoplevaccintaed 
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date
where death.continent  is not null
)
select *, (rollingnumberOFpeoplevaccintaed/population)*100 as percentageByvaccinationpopulation 
from PopvsVacc
   


--TEMP TABLE 
Drop table if exists #PercentgePopulationVaccinated
create table #PercentgePopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
rollingnumberOFpeoplevaccintaed numeric
)


insert into #PercentgePopulationVaccinated 
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) OVER (partition by death.location order by death.location,
death.date) as rollingnumberOFpeoplevaccintaed 
from portfolioproject..coviddeaths death
join PortfolioProject..covidvaccinations vacc 
on death.location = vacc.location 
and death.date = vacc.date
where death.continent  is not null
select *, (rollingnumberOFpeoplevaccintaed/population)*100 as percentageByvaccinationpopulation 
from #PercentgePopulationVaccinated

---Creating view to store data for visualizations
 create view TotalDeathCount as
 select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths 
where continent is not null
group by continent

--now the created view is now a table that can be qury 

Select *
from totaldeathcount 








 












