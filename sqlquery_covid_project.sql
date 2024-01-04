select * from covid_project..deaths
where continent is not null
order by 3,4;



select location,date,total_cases,new_cases,total_deaths,population
from covid_project..deaths
where continent is not null
order by 1,2;




--Total Cases VS Total Deaths


select location,date,total_cases,new_cases,total_deaths,
(CAST(total_deaths as numeric)/cast(total_cases as numeric)*100) as deathpercentge
from covid_project..deaths
where location like '%india%'
and continent is not null
order by 1,2;




--Total Cases VS population


SELECT 
    location,date,population,total_cases,
    ROUND(CONVERT(float, total_cases) / CONVERT(float, population) * 100, 4) as 
	percentage_of_population_infected
FROM 
    covid_project..deaths
WHERE  location LIKE '%states%'
and continent is not null
ORDER BY 
    1, 2;




--looking at countries with highest inflation rare compared to population


SELECT 
    location,
    population,
    max(cast(total_cases as int )) as max_total_cases,
    MAX((CONVERT(float, total_cases) / CONVERT(float, population)) * 100) as percentage_of_population_infected
FROM 
    covid_project..deaths
--WHERE  location LIKE '%india%'
where continent is not null
GROUP BY 
    location, population
ORDER BY 
   percentage_of_population_infected desc;




-- showing countries  with highest death count per population

SELECT 
    location,max(cast(total_deaths as int )) as total_death_count
	FROM 
    covid_project..deaths
--WHERE  location LIKE '%india%'
where continent is not null
GROUP BY location
ORDER BY total_death_count desc;
	



-- Let's break things down by continent


SELECT 
    continent,max(cast(total_deaths as int )) as total_death_count
	FROM 
    covid_project..deaths
--WHERE  location LIKE '%india%'
where continent is not null
GROUP BY continent
ORDER BY total_death_count desc;
	

--showing continents with highest death count

SELECT 
    continent,max(cast(total_deaths as int )) as total_death_count
	FROM 
    covid_project..deaths
--WHERE  location LIKE '%india%'
where continent is not null
GROUP BY continent
ORDER BY total_death_count desc;





--Global numbers


	SELECT --date,
	SUM(CAST(new_cases AS int)) AS total_new_cases,
    SUM(CAST(new_deaths AS int)) AS total_new_deaths,
    (SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float))) * 100 AS death_percentage
FROM 
    covid_project..deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 
    1,2;


--total population vs vaccinations

SELECT 
    dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
FROM 
    covid_project..deaths dea
JOIN 
    covid_project..vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    2,3;




-- use CTE



 WITH popvssac(continent, location, date, population, new_vaccinations, cumulative_vaccinations)
AS
(
    SELECT 
        dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
    FROM 
        covid_project..deaths dea
    JOIN 
        covid_project..vaccination vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    p.*, 
    ((CONVERT(int, p.new_vaccinations) / NULLIF(CONVERT(int, p.population), 2)) * 100) as population_vaccinated_till_date
FROM 
    popvssac p;

-- temp table

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)

-- Insert data into temporary table


INSERT INTO #percentpopulationvaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
FROM
    covid_project..deaths dea
JOIN
    covid_project..vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
SELECT
    *,
    ((CONVERT(int, new_vaccinations) / NULLIF(CONVERT(int, population), 2)) * 100) AS population_vaccinated_till_date
FROM
    #percentpopulationvaccinated;

