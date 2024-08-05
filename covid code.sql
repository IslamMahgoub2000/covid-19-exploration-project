
-- estimation of total deaths relative to total cases of covid in egypt
select location,date,[total cases],total_deaths,(convert(float,total_deaths)/nullif (convert(float,[total cases]),0))*100 as deathspercentage
from projectportfolio.dbo.covido
where location like '%egypt%'
order by 5 desc
--estimation of total deaths of covid relative to population in egypt
select location,date,total_deaths,population,(convert(float,total_deaths)/nullif (convert(float,population),0))*100 as deathspercent
from projectportfolio.dbo.covido
where location like '%egypt%'
order by 5 desc
--the highest death rate reached in egypt during the pandemic
select max (convert(float,total_deaths)/nullif (convert(float,population),0))*100 as deathspercent
from projectportfolio.dbo.covido
where location like '%egypt%'
--  the highest death count relative to population during the period of corona around the world
SELECT continent, location, population, MAX(total_deaths) as hightestDeathCount, MAX(convert( float,total_deaths) /nullif 
(convert(float,population),0))*100 as percentpopulationdied
FROM projectportfolio.dbo.covido
WHERE Continent is not NULL
Group by continent, location, population
order by 4 desc
-- the highest death count around the world
select location, max(cast(total_deaths as int)) as totaldeathcount
from projectportfolio.dbo.covido
where continent !=''
group by location
order by totaldeathcount desc

-- the continent that include the highest death count of pandemic around the world
SELECT continent, sum (cast(new_deaths as bigint)) as deaths,sum(cast(population as bigint)) as populations
FROM projectportfolio.dbo.covido
WHERE continent!=''
Group by continent
order by 2 desc
--measuring the number of people got vaccinated relative to the whole population of each country
--USE CTE
 with PopVsVac (continent,location,date,population,new_vaccination,rollingpeoplecountvaccinated)
as
( 
select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,sum(cast(new_vaccinations as bigint))
over(partition by cov.location order by cov.location,cov.date)as rollingpeoplecountvaccinated
--,(RollingpeoplecountVaccinated/population) * 100 

from projectportfolio.dbo.covido cov
join projectportfolio.dbo.vaccination vac
on cov.location=vac.location and cov.date=vac.date
where cov.continent is not null
--order by 2,3 
)
SELECT*,(convert(float,RollingpeoplecountVaccinated )/nullif (convert(float,population),0)) * 100 as percentofvaccinated
FROM PopVsVac
--TEMP TABLE

create table #pep
(
continent numeric,
location numeric,
time datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplecountvaccinated numeric
)
insert into #pep
select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,sum(cast(new_vaccinations as bigint))
over(partition by cov.location order by cov.location,cov.date)as rollingpeoplecountvaccinated
--,(RollingpeoplecountVaccinated/population) * 100 

from projectportfolio.dbo.covido cov
join projectportfolio.dbo.vaccination vac
on cov.location=vac.location and cov.date=vac.date
where cov.continent is not null
--order by 2,3 
SELECT*,(convert(float,RollingpeoplecountVaccinated )/nullif (convert(float,population),0)) * 100 as percentofvaccinated
FROM #pep


