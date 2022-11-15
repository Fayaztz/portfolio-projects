
select * from [portfolio project]..[Data 1]

select * from [portfolio project]..[Data 2]

--No. of rows in our data sets

select COUNT(*) from [portfolio project]..[Data 1]
select COUNT(*) from [portfolio project]..[Data 2]

--Dataset for TN and AP
select * from [portfolio project]..[Data 1] where State in ('Tamil Nadu','Andhra Pradesh')


--Total population of India
select SUM(Population) as TotPopulation from [portfolio project]..[Data 2]


--Avg Growth %
select Concat(AVG(Growth)*100, '%') as AvgGrowth from [portfolio project]..[Data 1]


--Avg Growth % by state in desc order
select state, Concat(AVG(Growth)*100, '%') as AvgGrowth from [portfolio project]..[Data 1] GROUP BY State ORDER BY AVG(Growth)*100 desc


--Avg Sex ratio by state in desc order
select state, Round(AVG(Sex_Ratio),0) as AvgSexRatio from [portfolio project]..[Data 1] GROUP BY State ORDER BY 2 DESC


--Avg Literacy ratio by state in desc order
select state,Round(AVG(Literacy),0) as AvgLiteracyRatio from [portfolio project]..[Data 1] GROUP BY State having Round(AVG(Literacy),0)>90 ORDER BY 2 DESC



--Top 3 Avg Growth % by state in desc order
select top 3 state, Concat(AVG(Growth)*100, '%') as AvgGrowth from [portfolio project]..[Data 1] GROUP BY State ORDER BY AVG(Growth)*100 DESC


--Bottom 3 Sex ratio by state 
select top 3 state, Round(AVG(Sex_Ratio),0) as AvgSexRatio from [portfolio project]..[Data 1] GROUP BY State ORDER BY 2 asc


--Top and bottom 3 states in literacy
--create temp table for top 3
drop table if exists #topstates
create table #topstates
(
State nvarchar(255),
topState Float
)
insert into #topstates
select state, Round(AVG(Literacy),0) as AvgLiteracyRatio from [portfolio project]..[Data 1] GROUP BY State ORDER BY AvgLiteracyRatio DESC

Select top 3 * from #topstates..#topstates order by #topstates.topState desc

--create temp table for top 3
drop table if exists #bottomstates
create table #bottomstates
(
State nvarchar(255),
bottomstate Float
)
insert into #bottomstates
select state, Round(AVG(Literacy),0) as AvgLiteracyRatio from [portfolio project]..[Data 1] GROUP BY State ORDER BY AvgLiteracyRatio asc

Select top 3 * from #bottomstates..#bottomstates order by #bottomstates.bottomstate asc


--using union to produce both top and bottom 3 literacy ratio

select * from (Select top 3 * from #topstates..#topstates order by #topstates.topState desc)a

union

select * from (Select top 3 * from #bottomstates..#bottomstates order by #bottomstates.bottomstate asc)b


--states that start with letter a and b
select distinct State from [portfolio project]..[Data 1] where lower(State) like 'a%' or lower(State) like 'b%'   (--use % after the letter, meaning starting with that letter)

--states that start with letter a and ending with m
select distinct State from [portfolio project]..[Data 1] where lower(State) like 'a%' and lower(State) like '%m'   (--use % before the letter, meaning ending with that letter)



--calculate no. of males and females

--(
--female/male = sex ratio ----- 1
 -- ma + fe = pop         -------2
 -- fe = pop - ma     ------sub in 1
 --(pop - ma) = sr * ma
 --pop = ma(sr + 1)
 --ma = pop/(sr + 1) ----- ***
 --fe = pop - pop/sr + 1
 --fe = pop(1 - 1/sr + 1)
 --fe = pop(sr)/sr + 1 ----***
 --)

 --join both tables
 
 select d.State, sum(d.Male) as TotMale, sum(d.Female) as TotFemale from 
 (select c.District, c.State as State, round(c.population/(c.Sex_Ratio + 1), 0) as Male, round((c.population * c.Sex_Ratio)/(c.Sex_Ratio + 1), 0) as Female, c.Population from 
 (select a.District, a.State, a.Sex_Ratio/100 as Sex_Ratio, b.Population from [portfolio project]..[Data 1] a  join [portfolio project]..[Data 2] b on a.District= b.District) c)d 
 group by d.State


 --No. of literates and llliterates

  select d.State, sum(d.literates) as TotLiterates, sum(d.illiterates) as TotIlliterates, sum(d.Population) TotPop from 
 ( select c.District, c.State, round(c.Literacy * c.population, 0) as literates, round((1-c.literacy) * c.population, 0) as illiterates, c.Population from
  (select a.District, a.State, a.Literacy/100 as Literacy, b.Population from [portfolio project]..[Data 1] a  join [portfolio project]..[Data 2] b on a.District= b.District) c)d
  group by d.State


  --Population according to previous census
  --( 
  -- prev pop + prev pop*growth = pop
  --prev pop  = pop/1+growth
--)


select sum(e.TotPrevPop) CompletePrevPop, sum(e.TotPop ) CompleteTotPop from
(select d.State, sum(d.PrevPop) TotPrevPop, sum(d.Population) TotPop from
(select c.District, c.State, round(c.Population/(1+C.Growth), 0) as PrevPop,  c.Population from
(select a.District, a.State, a.Growth , b.Population from [portfolio project]..[Data 1] a  join [portfolio project]..[Data 2] b on a.District= b.District)c)d
group by d.State)e


--Pop vs area

--Add a common column "Key" to join

select j.TotArea/j.CompletePrevPop as PrevPopVsArea, j.TotArea/j.CompleteTotPop as TotPopVsArea from
(select h.*, i.TotArea from       --cant have same columns so use TotArea instead of *
(select '1' as keyy, f.* from
(select sum(e.TotPrevPop) CompletePrevPop, sum(e.TotPop ) CompleteTotPop from
(select d.State, sum(d.PrevPop) TotPrevPop, sum(d.Population) TotPop from
(select c.District, c.State, round(c.Population/(1+C.Growth), 0) as PrevPop,  c.Population from
(select a.District, a.State, a.Growth , b.Population from [portfolio project]..[Data 1] a  join [portfolio project]..[Data 2] b on a.District= b.District)c)d
group by d.State)e)f)h
join 

(select '1' as keyy, g.* from
(select SUM(Area_Km2) as TotArea from [portfolio project]..[Data 2])g)i
on h.keyy=i.keyy)j


--Window Function (Top 3 Districts from eachh state with highest literacy rate)

select a.* from
(Select State, District, Literacy, rank() over(partition by State order by Literacy desc) as rank from [portfolio project]..[Data 1])a
where a.RANK in (1,2,3) order by State

