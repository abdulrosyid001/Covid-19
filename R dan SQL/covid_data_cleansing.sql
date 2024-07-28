-- SEEING WHAT COLUMNS ARE IN THE TABLE
select * from covid_deaths;
select * from covid_vaccinations;
select * from benua;
select * from income;



-- SEEING LOCATIONS ARE THERE IN covid TABLE
select distinct dea.location 
from covid_deaths dea
left join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by dea.location asc;



-- MAKE A TEMP TABLE 
drop table if exists covid_information;
create temp table covid_information as
select dea.location, dea.date, ben.continent, inc.income_category,
	dea.new_cases, dea.new_deaths, 
	dea.total_cases, dea.total_deaths, vac.total_vaccinations, 
	vac.people_vaccinated, vac.people_fully_vaccinated, 
	vac.daily_vaccinations, vac.daily_people_vaccinated
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
order by dea.location asc, dea.date asc;



-- FILL THE NULL ROW IN continent COLUMN USING THIS FUNCTION
drop function if exists by_continent;
create or replace function by_continent(name_of_continent varchar (25), name_of_country varchar(25)[])
returns table(benua varchar(25),negara varchar(25))
as $$
begin
	update covid_information 
	set continent = name_of_continent
	where location = any (name_of_country);

	return query
	select continent, location from covid_information;
end;
$$ language plpgsql;



select * from by_continent('Africa',array['Burkina Faso','Eswatini','Reunion','Saint Helena']);

select * from by_continent('Asia',array['Myanmar','Palestine','Timor']);

select * from by_continent('Europe',array['Faeroe Islands','Gibraltar','Guernsey','Isle of Man',
	'Jersey','Kosovo','Mayotte','North Macedonia','Vatican']);

select * from by_continent('North America',array['Anguilla','Bermuda','British Virgin Islands',
	'Cayman Islands','Greenland','Guadeloupe','Martinique','Montserrat','Puerto Rico',
	'Saint Barthelemy','Saint Martin (French part)','Saint Pierre and Miquelon',
	'Sint Maarten (Dutch part)','Turks and Caicos Islands','United States Virgin Islands']);

select * from by_continent('Oceania',array['American Samoa','Cook Islands','French Polynesia','Guam',
	'Micronesia (country)','New Caledonia','Niue','Northern Mariana Islands',
	'Pitcairn','Tokelau','Wallis and Futuna']);

select * from by_continent('South America',array['Aruba','Bonaire Sint Eustatius and Saba','Curacao',
	'Falkland Islands','French Guiana']);



-- FILL THE NULL ROW IN income_category COOLUMN USING THIS FUNCTION
drop function if exists by_income_category;
create or replace function by_income_category(income varchar(25), country varchar(25) [])
returns table(negara varchar(25), kategori varchar(25))
as $$
begin
	update covid_information
	set income_category = income
	where location = any(country);

	return query
	select location, income_category from covid_information;
end;
$$ language plpgsql;



select distinct negara, kategori from by_income_category('High income', array['Brunei','Curacao',
	'Faeroe Islands','Russia','Saint Kitts and Nevis','Saint Martin (French part)','Slovakia']) 
	where kategori is null;

select * from by_income_category('Low income', array['Democratic Republic of Congo','Syria','Yemen']);

select * from by_income_category('Lower middle income', array['Cape Verde','Kyrgyzstan','Laos',
	'Micronesia (country)','Palestine','Sao Tome and Principe','Timor']);

select * from by_income_category('Upper middle income', array['Saint Lucia',
	'Saint Vincent and the Grenadines','Turkey']);



-- SET THE 'Cote d'Ivore' ROW
update covid_information 
set continent = 'Africa', income_category = 'Lower middle income'
where location ilike '%cote%';



-- FILL THE NULL ROW IN MOSTLY COLUMNS
create or replace procedure category(column_name varchar)
as $$
begin
    execute format('UPDATE covid_information SET %I = 0 WHERE %I IS NULL', column_name, column_name);
end;
$$ language plpgsql;

call category('new_cases');
call category('new_deaths');
call category('total_cases');
call category('total_deaths');
call category('total_vaccinations');
call category('people_vaccinated');
call category('people_fully_vaccinated');
call category('daily_vaccinations');
call category('daily_people_vaccinated');


	
-- SHOW A TEMP TABLE
select * from covid_information where income_category is not null order by 1,2;