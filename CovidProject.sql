
--select *
--from CovidDeaths
--order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Selecting Data that we are going to be using
--select location, date, total_cases, total_deaths
--from CovidDeaths
--order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Show the tendency of dying if you contact covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/CONVERT(float, total_cases))*100  as death_percentage
from CovidDeaths
--where location like '%United States%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--Shows what % population of the country got COVID
select location, date, total_cases, population, (total_cases/population)*100 as '% people_infected'
from CovidDeaths
--where location = '%afgh%'
order by 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, max(CONVERT(float, total_cases)) as highest_infected_count, MAX((CONVERT(float, total_cases)/population))*100 as 
	'% population_infected'
from CovidDeaths
group by location, population
order by  4 desc

--LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location, population, MAX(CONVERT(float, total_deaths)) as highest_death_count, 
	MAX(CAST(total_deaths AS int)/population)*100 as '% death_count_per_population'
from CovidDeaths
where continent is not null
group by location, population
order by highest_death_count desc

--LOOKING AT TABLE BY CONTINENT (correct procedure)
select location, MAX(CAST(total_deaths as int)) as total_deaths_per_continent
from CovidDeaths
where continent is null
group by location
order by total_deaths_per_continent desc

-- BY CONTINENT
select continent, MAX(CAST(total_deaths as int)) as total_deaths_per_continent
from CovidDeaths
where continent is not null
group by continent
order by total_deaths_per_continent desc

--GLOBAL NUMBERS (per day)
select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, nullif(sum(cast(new_deaths as int)), 0) / nullif(sum(new_cases), 0) as death_percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--GLOBAL NUMBERS 
select sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, nullif(sum(cast(new_deaths as int)), 0) / nullif(sum(new_cases), 0)*100 as death_percentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--JOINING THE TWO TABLE COVID DEATHS AND VACCINATION
select  [Result] = IIF( 5 > 6, 'TRUE', 'FALSE' )
from CovidDeaths as cd
Join CovidVaccinations as cv 
	on cd.location = cv.location and cd.date = cv.date 



--LOOKING AT TOTAL POPULATION VS VACCINATION
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as new_people_vaccinated
from CovidDeaths as cd
Join CovidVaccinations as cv 
	on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null
order by 2,3

--WITH ABOVE STATEMENT
--USING CTE TO GET THE PERCENTAGE OF PEOPLE VACCINATED IN A GIVEN POPULATION (NEW_PEOPLE_VACCINATED/POPULATION)
WITH CTE_pop_vac(Continent, Location, Date, Population, New_Vaccination, New_People_Vaccinated)
AS
(
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as new_people_vaccinated
	from CovidDeaths as cd
	Join CovidVaccinations as cv 
	on cd.location = cv.location and cd.date = cv.date 
	where cd.continent is not null
)
SELECT *, (New_People_Vaccinated/Population)*100 as percentageVaccinated --, [status] = IIF(New_Vaccination > 5000, 'OK', 'Not OK')
FROM CTE_pop_vac
order by 2,3


--CREATING THE ABOVE WITH TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
New_People_Vaccinated numeric,
)
INSERT INTO #PercentagePopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as new_people_vaccinated
	from CovidDeaths as cd
	Join CovidVaccinations as cv 
	on cd.location = cv.location and cd.date = cv.date 
	where cd.continent is not null

SELECT * from #PercentagePopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW vTOTAL_DEATH_COUNT_PER_CONTINENT
AS
select continent, MAX(CAST(total_deaths as int)) as total_deaths_per_continent
from CovidDeaths
where continent is not null
group by continent
--order by total_deaths_per_continent desc

CREATE VIEW VIEW_PercentagePopulationVaccinated
AS
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location, cd.date) as new_people_vaccinated
from CovidDeaths as cd
Join CovidVaccinations as cv 
	on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null
