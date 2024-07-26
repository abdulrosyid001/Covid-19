-- SEEING WHAT COLUMNS ARE IN THE TABLE
select * from covid_deaths;
select * from covid_vaccinations;
select * from benua;
select * from income;



-- SEEING LOCATIONS ARE THERE IN covid TABLE
select distinct dea.location 
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by dea.location asc;



-- MAKE A TEMP TABLE 
drop table if exists covid_information;
create temp table covid_information as
select dea.location, dea.date, dea.new_cases, dea.new_deaths, 
	dea.total_cases, dea.total_deaths, vac.total_vaccinations, 
	vac.people_vaccinated, vac.people_fully_vaccinated, vac.total_boosters, 
	vac.daily_vaccinations, vac.daily_people_vaccinated, ben.continent, inc.category
from covid_deaths dea
left join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
left join benua ben
	on dea.location = ben.country
left join income inc
	on dea.location = inc.country
where dea.location not in ('World', 'Africa', 'Asia', 'Australia', 'Europe', 
	'North America', 'Oceania','South America', 'High income',
	'Upper middle income','Lower middle income','Low income', 'European Union',
	'International')
order by dea.location asc, date asc;



-- FILL THE NULL ROW IN continent COLUMN
update covid_information
	set continent = 'Africa'
	where location in ('Burkina Faso','Eswatini','Reunion','Saint Helena')
	or location ilike '%cote%';

update covid_information
	set continent = 'Asia'
	where location in ('Myanmar','Palestine','Timor');

update covid_information
	set continent = 'Europe'
	where location in ('Faeroe Islands','Gibraltar','Guernsey','Isle of Man',
	'Jersey','Kosovo','Mayotte','North Macedonia','Vatican');

update covid_information
	set continent = 'North America'
	where location in ('Anguilla','Bermuda','British Virgin Islands','Cayman Islands',
	'Greenland','Guadeloupe','Martinique','Montserrat','Puerto Rico','Saint Barthelemy',
	'Saint Martin (French part)','Saint Pierre and Miquelon','Sint Maarten (Dutch part)',
	'Turks and Caicos Islands','United States Virgin Islands');

update covid_information
	set continent = 'Oceania'
	where location in ('American Samoa','Cook Islands','French Polynesia','Guam',
	'Micronesia (country)','New Caledonia','Niue','Northern Mariana Islands',
	'Pitcairn','Tokelau','Wallis and Futuna');

update covid_information
	set continent = 'South America'
	where location in ('Aruba','Bonaire Sint Eustatius and Saba','Curacao',
	'Falkland Islands','French Guiana');


	
-- FILL THE NULL ROW IN category COOLUMN
update covid_information
	set category = 'High income'
	where location in ('Brunei','Curacao','Faeroe Islands','Russia',
	'Saint Kitts and Nevis','Saint Martin (French part)','Slovakia')
	
update covid_information
	set category = 'Low income'
	where location in ('Democratic Republic of Congo','Syria','Yemen');

update covid_information
	set category = 'Lower middle income'
	where location in ('Cape Verde','Kyrgyzstan','Laos','Micronesia (country)',
	'Palestine','Sao Tome and Principe','Timor')
	or location ilike '%cote%';

update covid_information
	set category = 'Upper middle income'
	where location in ('Saint Lucia','Saint Vincent and the Grenadines','Turkey');



-- MAKE year COLUMN
alter table covid_information
add column year numeric;

update covid_information
set year = extract(year from date);



-- SHOW A TEMP TABLE
select * from covid_information order by 1, 2;
select distinct location, continent, category from covid_information where category is null;



-- EXPLORATION
-- WORLD'S avg_daily_vaccin
select avg(daily_vaccinations), avg(daily_people_vaccinated) 
from covid_information_global;

-- COUNTRY WITH AVG_DAILY OVER THE WORLD'S AVG
select location, avg(daily_vaccinations) as avg_daily_vaccinations, 
		avg(daily_people_vaccinated) as avg_daily_people_vaccinated
from covid_information_global
where daily_vaccinations > (select avg(daily_vaccinations) 
										from covid_information_global) 
	and daily_people_vaccinated > (select avg(daily_people_vaccinated) 
										from covid_information_global)
group by location
order by 2 desc,3 desc;



-- MAKE A FUNCTION SO YOU CAN CHOOSE sum_of_new_cases, sum_of_new_deaths, 
-- sum_of_daily_vaccinations, sum_of_daily_people_vaccinated WITH A SPECIFIC DATE (WEEKLY)
create or replace function by_date(awal date, akhir date)
returns table(tanggal date, new_cases numeric, 
	new_deaths numeric, daily_vaccinations numeric, 
	daily_people_vaccinated numeric) 
as $$
	begin
		return query 
		select infor.date, sum(infor.new_cases), sum(infor.new_deaths), 
			sum(infor.daily_vaccinations), sum(infor.daily_people_vaccinated)
		from covid_information_global infor
		where infor.date between awal and akhir
			and infor.new_cases != 0
		group by infor.date;
	end;
$$ language plpgsql;

--EXAMPLE
select avg(new_cases) avg_new_cases, avg(new_deaths) avg_new_deaths, 
	avg(daily_vaccinations) avg_daily_vaccinations, 
	avg(daily_people_vaccinated) avg_daily_people_vaccinated
from by_date('2021-1-1','2021-3-7');



-- BY YEAR
select year, sum(new_cases) new_cases, sum(new_deaths) new_deaths, 
	sum(total_cases) total_cases, sum(total_deaths) total_deaths, 
	sum(total_vaccinations) total_vaccinations, sum(people_vaccinated) people_vaccinated, 
	sum(people_fully_vaccinated) people_fully_vaccinated, sum(total_boosters) total_boosters, 
	sum(daily_vaccinations) daily_vaccinations, sum(daily_people_vaccinated) daily_people_vaccinated 
from covid_information_global 
group by year 
order by new_cases desc;
