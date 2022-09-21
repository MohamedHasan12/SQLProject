select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
--Shows Likelyhood of dying if you contract covid in your contry 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentageInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2


-- Loooking at Countries with highest infection rate compared to population 

Select location, population, MAX(total_cases) as HighestInfectedCount, Max((total_cases/population))*100 AS HighestPopulationInfected 
From PortfolioProject..CovidDeaths
Group by location, population
Order By HighestPopulationInfected desc

-- Looking at Countries with highest death count / population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order By TotalDeathCount desc


-- Continent with highest death count 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
Order By TotalDeathCount desc


--Global data

Select date, SUM(new_cases) AS total_cases, sum(cast(new_deaths as int)) As total_deaths, sum(cast(new_deaths as int))/SUM(new_cases) AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order By 1,2

-- Total number Global data
Select SUM(new_cases) AS total_cases, sum(cast(new_deaths as int)) As total_deaths, sum(cast(new_deaths as int))/SUM(new_cases) AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Joining Death data and Vax data
Select * From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaxx Vaxx
	on Death.location = vaxx.location
	and Death.date = vaxx.date

-- Looking at US Total population vs vaccinations
Select  Death.continent, Death.location, Death.date, Death.population, Vaxx.new_vaccinations
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaxx Vaxx
	on Death.location = vaxx.location
	and Death.date = vaxx.date
Where Death.location like '%states%'
order by location

-- Looking at Global Total population vs vaccination
-- with CTE
with PopulationVsVax (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVax)
as 
(
	Select  Death.continent, Death.location, Death.date, Death.population, Vaxx.new_vaccinations, SUM(Cast(vaxx.new_vaccinations as bigint)) OVER (Partition by Death.location Order by death.location, death.date) as RollingTotalVax 
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaxx Vaxx
	on Death.location = vaxx.location
	and Death.date = vaxx.date
Where death.continent is not null
--order by 2,3
)

Select *,(RollingTotalVax/Population)*100 as RollingPerVax
From PopulationVsVax

-- Temp Table 

Drop Table if exists #PercentPopulationVaxx
Create Table #PercentPopulationVaxx (
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
New_vaccincations numeric,
RollingTotalVax numeric)


Insert into #PercentPopulationVaxx
Select  Death.continent, Death.location, Death.date, Death.population, Vaxx.new_vaccinations, SUM(Cast(vaxx.new_vaccinations as bigint)) OVER (Partition by Death.location Order by death.location, death.date) as RollingTotalVax
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaxx Vaxx
	on Death.location = vaxx.location
	and Death.date = vaxx.date
--Where death.continent is not null
order by 2,3

Select *,(RollingTotalVax/Population)*100 as RollingPerVax
From #PercentPopulationVaxx


-- Creating View to store data for visualizations 

Use [PortfolioProject] -- to store it in our database!
Go

Create view PercentPopulationVacc as
Select  Death.continent, Death.location, Death.date, Death.population, Vaxx.new_vaccinations, SUM(Cast(vaxx.new_vaccinations as bigint)) OVER (Partition by Death.location Order by death.location, death.date) as RollingTotalVax
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaxx Vaxx
	on Death.location = vaxx.location
	and Death.date = vaxx.date
Where death.continent is not null

Select * From PercentPopulationVacc

