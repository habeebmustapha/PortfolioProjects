
Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 3, 4

Select *
From PortfolioProject..CovidVaccinations
Where Continent is not null
Order by 3, 4


--Select Data that we are going to be using

Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From PortfolioProject..CovidDeaths
Order by 1, 2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if yoy contract covid in your country
Select Location, Date,  Total_Cases, Total_Deaths
, (cast(Total_Deaths As float) / Total_Cases) * 100 As PercentageOfDeath
From PortfolioProject..CovidDeaths
Where location like '%Nigeria'
and Continent is not null
Order by 1, 2

--Looking at Total cases vs Population
Select Location, Date, Population, Total_Cases, Total_Deaths
, (Total_Cases / Population) * 100 As PercentageOfDeath
From PortfolioProject..CovidDeaths
Where Continent is not null
--And location like '%Italy'
Order by 1, 2

--Looking at countries with highest infection rate compared to population
Select Location, Population, Max(Total_Cases) As HighestInfectionCount
, Max((Total_Cases / Population)) * 100 As PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
--and location like '%Italy'
Order by PercentageOfPopulationInfected desc

--Showing the countries with the highest death count per population
Select Location, Population, Max(cast(Total_Deaths As float)) As TotalDeathCount
, Max((cast(Total_Deaths As float) / Population)) * 100 As PercentageOfDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Location, Population
--And location like '%Italy'
Order by TotalDeathCount desc

--Breaking things down by continent
Select Location, Max(cast(Total_Deaths As float)) As TotalDeathCount
, Max((cast(Total_Deaths As float) / Population)) * 100 As PercentageOfDeathCount
From PortfolioProject..CovidDeaths
Where Continent is null
Group by Location
--And location like '%Italy'
Order by TotalDeathCount desc

--Showing the continent with the highest death count
Select Location, Max(cast(Total_Deaths As float)) As TotalDeathCount
, Max((cast(Total_Deaths As float) / Population)) * 100 As PercentageOfDeathCount
From PortfolioProject..CovidDeaths
Where Continent is null
Group by Location
--And location like '%Italy'
Order by TotalDeathCount desc


--Global Number

Select date, Sum(cast(Total_Cases As float)), Sum(cast(New_Deaths As float))
, Sum(cast(New_Deaths As float)) / Sum(cast(Total_Cases As float)) * 100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by date
--And location like '%Italy'
Order by 1, 2


Select Sum(cast(Total_Cases As float)), Sum(cast(New_Deaths As float))
, Sum(cast(New_Deaths As float)) / Sum(cast(Total_Cases As float)) * 100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
--Group by date
--And location like '%Italy'
Order by 1, 2



--Looking at Total Population vs Vaccination
Select dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations
, Sum(cast(vac.New_Vaccinations As float)) Over (Partition by dea.Location Order by 
Dea.Location, Dea.Date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
	Where dea.Continent is not null
order by 2,3


--Using CTE
WIth PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations
, RollingPeopleVaccinated)
As
(
Select dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations
, Sum(cast(vac.New_Vaccinations As float)) Over (Partition by dea.Location Order by 
Dea.Location, Dea.Date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
	Where dea.Continent is not null
--order by 2,3
)


Select *, (RollingPeopleVaccinated / Population)
From PopulationVsVaccination


--Using Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations
, Sum(cast(vac.New_Vaccinations As float)) Over (Partition by dea.Location Order by 
Dea.Location, Dea.Date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
	Where dea.Continent is not null
--order by 2,3



Select *, (RollingPeopleVaccinated / Population)
From #PercentPopulationVaccinated



--Create view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations
, Sum(cast(vac.New_Vaccinations As float)) Over (Partition by dea.Location Order by 
Dea.Location, Dea.Date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.Location = Vac.Location
	And Dea.Date = Vac.Date
	Where dea.Continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated