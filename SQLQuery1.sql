select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4


--select *
--from [Portfolio Project]..CovidVaccinations
--where continent is not null
--order by 3,4

select location , date , total_cases , total_deaths  , (total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--where location like '%Africa%'
order by 1,2



select location , date , total_cases , population  , (total_cases/population)*100 as infection_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--where location like '%Africa%'
order by 1,2



--look at the location with the highest infection rate compared with the population 

select location, population  , Max(total_cases)   , Max((total_cases/population))*100 as Max_infection_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by Max_infection_percentage DESC


--the locations with the highest number of deaths related to the population 

select location, population  , Max(total_deaths) maxdeaths, Max(total_deaths / population )*100 as Maxpercengtageofdeaths 
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
order by Maxpercengtageofdeaths  DESC

--by continent 

select continent  , Max(total_deaths) maxdeaths, Max(total_deaths / population )*100 as Maxpercengtageofdeaths 
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by Maxpercengtageofdeaths  DESC

--across the world 

select date sum(cast(new_deaths as int )) as totdeaths,sum(new_cases) as totcases ,  (sum(cast(new_deaths as int ))/sum(new_cases))*100
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date 
order by 1 DESC

--looking at the total population vs vaccinations

select dea.continent , dea.date , dea.location , dea.population, vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date ) rolling_people_vaccinated 
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 3,2


with PopvsVac (continent,date,location,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent , dea.date , dea.location , dea.population, vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date ) rolling_people_vaccinated 
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 3,2
)

select * , (rolling_people_vaccinated/population)*100 as rolling_people_vaccinated_percentage
from PopvsVac



drop table if exists #PercentagePopulationVaccinated

create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentagePopulationVaccinated

select dea.continent , dea.date , dea.location , dea.population, vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date ) rolling_people_vaccinated 
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 3,2

select * , (rolling_people_vaccinated/population)*100 as rolling_people_vaccinated_percentage
from #PercentagePopulationVaccinated


create view PercentagePopulationVaccinated as
select dea.continent , dea.date , dea.location , dea.population, vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date ) rolling_people_vaccinated 
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 3,2
select *
from PercentagePopulationVaccinated