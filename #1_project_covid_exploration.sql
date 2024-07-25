-- SEEING WHAT COLUMNS ARE IN THE TABLE
select * from covid_deaths;
select * from covid_vaccinations;

-- SEEING HOW MANY LOCATION ARE THERE IN THOSE TWO TABLES 
select dea.location 
from covid_deaths dea
JOIN covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
group by dea.location 
order by dea.location asc;

-- CHOOSE A FEW COLUMNS
select dea.location, dea.date, dea.new_cases, dea.new_deaths, dea.total_cases, 
	dea.total_deaths, vac.total_vaccinations, vac.people_vaccinated,
	vac.people_fully_vaccinated, vac.total_boosters, 
	vac.daily_vaccinations, vac.daily_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
order by location asc, date asc;

-- MAKE A TEMP TABLE WITH THOSE INFORMATIONS
drop table if exists covid_information;
create temporary table covid_information as
select dea.location, dea.date, dea.new_cases, dea.new_deaths, dea.total_cases, 
	dea.total_deaths, vac.total_vaccinations, vac.people_vaccinated,
	vac.people_fully_vaccinated, vac.total_boosters, 
	vac.daily_vaccinations, vac.daily_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
order by location asc, date asc;



-- SHOW A TEMP TABLE
select location from covid_information where location in ('World','Asia','Africa', 'Australia', 'Europe', 
	'North America', 'Oceania','South America', 'High income','Upper middle income',
	'Lower middle income','Low income') group by location;
SELECT * FROM covid_information where location ilike '%world%';



-- BY CONTINENT
-- CASES VS DEATHS (WEEKLY)
select location, date, new_cases, new_deaths, 
	(new_deaths/new_cases)*100 as percent_deaths
from covid_information
where location in ('Africa', 'Asia', 'Australia', 'Europe', 'North America', 
	'Oceania','South America') and new_cases != 0
order by location, date;

-- DAILY VACCINATIONS
select location, date, daily_vaccinations, daily_people_vaccinated
from covid_information
where location in ('Africa', 'Asia', 'Australia', 'Europe', 'North America', 
	'Oceania','South America');

-- CASES VS VACCINATIONS
select location, date, total_cases, people_vaccinated
from covid_informations
where location in ('Africa', 'Asia', 'Australia', 'Europe', 'North America', 
	'Oceania','South America') and new_cases != 0;



-- BY INCOME
-- CASES VS DEATHS (WEEKLY)
select location, date, new_cases, new_deaths, 
	(new_deaths/new_cases)*100 as percent_deaths
from covid_information
where location in ('High income','Upper middle income','Lower middle income',
	'Low income') and new_cases != 0
order by location, date;

-- DAILY VACCINATIONS
select location, date, daily_vaccinations, daily_people_vaccinated
from covid_information
where location in ('High income','Upper middle income','Lower middle income',
	'Low income');

-- CASES VS VACCINATIONS
select location, date, total_cases, people_vaccinated
from covid_informations
where location in ('High income','Upper middle income','Lower middle income',
	'Low income') and new_cases != 0;



-- ASEAN
-- CASES VS DEATHS (WEEKLY)
select location, date, new_cases, new_deaths, 
	(new_deaths/new_cases)*100 as percent_deaths
from covid_information
where location in ('Indonesia','Malaysia','Singapore','Timor','Thailand','Myanmar',
	'Philippines','Vietnam','Laos','Brunei','Cambodia') and new_cases != 0
order by location, date;

-- DAILY VACCINATIONS
select location, date, daily_vaccinations, daily_people_vaccinated
from covid_information
where location in ('Indonesia','Malaysia','Singapore','Timor','Thailand','Myanmar',
	'Philippines','Vietnam','Laos','Brunei','Cambodia');

-- CASES VS VACCINATIONS
select location, date, total_cases, people_vaccinated
from covid_informations
where location in ('Indonesia','Malaysia','Singapore','Timor','Thailand','Myanmar',
	'Philippines','Vietnam','Laos','Brunei','Cambodia') and new_cases != 0;



-- WORLD'S AVG
select avg(daily_vaccinations), avg(daily_people_vaccinated) 
from covid_information
where location not in ('World', 'Africa', 'Asia', 'Australia', 'Europe', 
	'North America', 'Oceania','South America', 'High income','Upper middle income',
	'Lower middle income','Low income', 'European Union')


	
-- COUNTRY WITH AVG_DAILY OVER THE WORLD'S AVG
with global_avg_daily_vaccinations as 
	(select location, avg(daily_vaccinations) daily_vaccinations, 
		avg(daily_people_vaccinated) daily_people_vaccinated
	from covid_vaccinations
	where location not in ('World', 'Africa', 'Asia', 'Australia', 'Europe', 
		'North America', 'Oceania','South America', 'High income',
		'Upper middle income','Lower middle income','Low income', 'European Union')
	group by location) 
select location, daily_vaccinations as avg_daily_vaccinations, 
		daily_people_vaccinated as avg_daily_people_vaccinated
	from global_avg_daily_vaccinations
	where daily_vaccinations > (select avg(daily_vaccinations) 
	from covid_information 
		where location not in ('World', 'Africa', 'Asia', 'Australia', 
			'Europe', 'North America', 'Oceania','South America', 'High income',
			'Upper middle income','Lower middle income','Low income', 
			'European Union')) 
	and daily_people_vaccinated > (select avg(daily_people_vaccinated) 
	from covid_information 
		where location not in ('World', 'Africa', 'Asia', 'Australia', 'Europe', 
			'North America', 'Oceania','South America', 'High income',
			'Upper middle income','Lower middle income','Low income', 
			'European Union'))
	order by 2 desc,3 desc;



-- BY DATE
create or replace function by_date(awal date, akhir date)
returns table(tanggal date, new_cases numeric, 
new_deaths numeric, daily_vaccinations numeric, daily_people_vaccinated numeric) 
as $$
	begin
		return query 
		select infor.date, sum(infor.new_cases), sum(infor.new_deaths), 
		sum(infor.daily_vaccinations), sum(infor.daily_people_vaccinated)
		from covid_information infor
		where infor.date between awal and akhir
		and location not in ('World', 'Africa', 'Asia', 'Australia', 'Europe', 
			'North America', 'Oceania','South America', 'High income',
			'Upper middle income','Lower middle income','Low income', 
			'European Union')
		and infor.new_cases != 0
		group by infor.date;
	end;
$$ language plpgsql;

--2020
select avg(new_cases) avg_new_cases, avg(new_deaths) avg_new_deaths, 
	avg(daily_vaccinations) avg_daily_vaccinations, 
	avg(daily_people_vaccinated) avg_daily_people_vaccinated
	from by_date('2020-1-1','2020-12-31');

--2021
select avg(new_cases) avg_new_cases, avg(new_deaths) avg_new_deaths, 
	avg(daily_vaccinations) avg_daily_vaccinations, 
	avg(daily_people_vaccinated) avg_daily_people_vaccinated
	from by_date('2021-1-1','2021-12-31');

--2022
select avg(new_cases) avg_new_cases, avg(new_deaths) avg_new_deaths,
	avg(daily_vaccinations) avg_daily_vaccinations, 
	avg(daily_people_vaccinated) avg_daily_people_vaccinated
	from by_date('2022-1-1','2022-12-31');

--2023
select avg(new_cases) avg_new_cases, avg(new_deaths) avg_new_deaths, 
	avg(daily_vaccinations) avg_daily_vaccinations, 
	avg(daily_people_vaccinated) avg_daily_people_vaccinated
	from by_date('2023-1-1','2023-12-31');

--2024
select avg(new_cases) avg_new_cases, avg(new_deaths) avg_new_deaths, 
	avg(daily_vaccinations) avg_daily_vaccinations, 
	avg(daily_people_vaccinated) avg_daily_people_vaccinated
	from by_date('2024-1-1','2024-12-31');