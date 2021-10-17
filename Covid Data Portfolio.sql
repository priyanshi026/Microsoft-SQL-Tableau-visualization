use PORTFOLIO;
--select * from deaths;
--select * from  vaccination;
--select location,date,total_cases,new_cases,total_deaths, population from deaths order by 1,2;
-- chances of death as per country mentioned
select location,date,total_cases,total_deaths, population,(total_deaths/total_cases)*100 as "Death percentage" from deaths  Where location like '%india';

--total cases vs population, shows what percentage of opulation gor covid
select location,date,total_cases,total_deaths, population,(total_cases/population)*100 as "Contamination percetage" from deaths  Where location like '%india';

--countries with highest infectin rate as compared to population
select location,population,max(total_cases)as 'Highest infection count of a country', max(total_cases/population)*100 as 'Percentage infection' from deaths
group by location,population order by 3 desc;                    -- here population of whch locati will show up is confused but gruping helps as population is kept constant otheris=wise diffrent cases with different populatio would have popped up

select location,date,max(total_cases)as 'Highest infection count of a country', max(total_cases/population)*100 as 'Percentage infection' from deaths
group by location,population,date order by 3 desc;                    -- here population of whch locati will show up is confused but gruping helps as population is kept constant otheris=wise diffrent cases with different populatio would have popped up


--coutries with highest death count vs population
select location,max(cast(total_deaths as int))as 'Total death count of a country', max(total_deaths/population)*100 as 'Percentage death' from deaths
where continent is not null group by location order by 2 desc ;

--breaking by continents
--Showing the continets with hihgest death count

select location,max(cast(total_deaths as int))as 'Total death count of a country', max(total_deaths/population)*100 as 'Percentage death' from deaths
where continent is null group by location order by 2 desc ;

select continent,max(cast(total_deaths as int))as 'Total death count of a country', max(total_deaths/population)*100 as 'Percentage death' from deaths
where continent is not null group by continent order by 2 desc ;

--global cases and deaths and death percentage of world on particular date from 2020
select date,sum(new_cases) as 'Daily world cases', sum(cast(new_deaths as int)) as 'Daily world deaths', (sum(cast(new_deaths as int))/sum(new_cases))*100 as 'World death percentage' from deaths
where continent is not null group by date order by date;

--global total
select sum(new_cases) as 'Daily world cases', sum(cast(new_deaths as int)) as 'Daily world deaths', (sum(cast(new_deaths as int))/sum(new_cases))*100 as 'World death percentage' from deaths
where continent is not null ;

select sum(new_cases) as 'Daily world cases', sum(cast(new_deaths as int)) as 'Daily world deaths', (sum(cast(new_deaths as int))/sum(new_cases))*100 as 'World death percentage' from deaths
where continent is not null group by continent ;



--everthing of vacinations
select * from vaccination;

--joiing
select * from deaths D,vaccination V where D.location=V.location and D.date=V.date; 

--lokking total vaccination vs population dalily report
select D.continent,D.location,D.population,D.date,V.new_vaccinations from deaths D,vaccination V where D.location=V.location and D.date=V.date and D.continent is not null order by   D.continent ,D.location,D.date; 

--partition and roll over sum
select D.continent,D.location,D.population,D.date,V.new_vaccinations,sum(convert(int,V.new_vaccinations)) Over (partition by D.location order by D.location,D.date) as'rolling people vaccinated' from deaths D,vaccination V where D.location=V.location and D.date=V.date and D.continent is not null order by   D.continent ,D.location,D.date; 

--use the rolling sum number of a particular location nad get the maximum value which will be the vlaue f the latest date and get the percentge of people vaccinated in thatbcountry
--select D.continent,D.location,D.population,D.date,V.new_vaccinations,sum(convert(int,V.new_vaccinations)) Over (partition by D.location order by D.location,D.date) as'rolling people vaccinated',(max('rolling people vaccinated')/D.population)*100 as 'percentage people vacinated till date' from deaths D,vaccination V where D.location=V.location and D.date=V.date and D.continent is not null group by D.continent,D.location order by   D.continent ,D.location,D.date ; 

--using the column alias of rolling people vaccinated for further operations in further coclumns we are using CTE(order by giving error here and any new column name can be given here but the number of columns must match and also the names should be respective corresponding column )
with popvsvac (Continent,Location,Date,Population,New_Vacinations,Rolled_over)--these are the new column names and table is saved as it is with these anmes now use these names for further operations
as
(
select D.continent,D.location,D.date,D.population,V.new_vaccinations,sum(convert(int,V.new_vaccinations)) Over (partition by D.location order by D.location,D.date) as'Rolling_people_vaccinated' from deaths D,vaccination V where D.location=V.location and D.date=V.date and D.continent is not null
)
--select * from  popvsvac;

--now u can use rolling column in operations further and also that full table is now stored in popvsvac and further column can be added and you dont need to repaet all those columns again

select *,(Rolled_over/Population)*100 as 'percentage vaccnination'from popvsvac; --write column names properly
-- two select statements having popvsvac doeasnt run togteher so i had to comment one of them and also run the whole bloack of code from CTE






--- temp table 
drop table if exists #poppulationVSvaccination     --if you make any changes to the main query of this temp table then run all over again then shows error as already a diffrent table with same name is present in the memory so dro table here is used to delete the prevois one evertime we need to change the query of the temp table
create table #poppulationVSvaccination    --temporary table name created
(
continent nvarchar(255), --new column names of the table
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,  --changing datattype here as it was casted for use
rolled numeric

)
insert into #poppulationVSvaccination   --order by not used here also
select D.continent,D.location,D.date,D.population,V.new_vaccinations,sum(convert(int,V.new_vaccinations)) Over (partition by D.location order by D.location,D.date) as'Rolling_people_vaccinated' from deaths D,vaccination V where D.location=V.location and D.date=V.date and D.continent is not null

select *,(rolled/population)*100 as 'percentage vaccnination'from #poppulationVSvaccination; --write column names properly



-- Create view to store data for visualization
 Create view PercentPopulationVaccinated as
 select D.continent,D.location,D.date,D.population,V.new_vaccinations,sum(convert(int,V.new_vaccinations)) Over (partition by D.location order by D.location,D.date) as'Rolling_people_vaccinated' from deaths D,vaccination V where D.location=V.location and D.date=V.date and D.continent is not null

 --view is permanet its not like temp table
 select * from PercentPopulationVaccinated




 ---creat some more views for creating visualization with TABLEAU