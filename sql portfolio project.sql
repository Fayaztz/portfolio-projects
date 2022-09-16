select * from [portfolio project]..all_season_summary
select distinct("""season""") from [portfolio project]..all_season_summary

--Total no. of matches played in each season
select """season""", count("""season""") from [portfolio project]..all_season_summary group by ["season"]

--max no. toss won by a team
select MAX("""toss_won""") from [portfolio project]..all_season_summary

--venue of most matches
select """venue_name""",count("""venue_name""") from [portfolio project]..all_season_summary group by """venue_name""" order by count("""venue_name""") desc  

--most matches won in a venue batting first
select """venue_name""",count("""winner""")from [portfolio project]..all_season_summary where """decision"""='"Bat First"' group by """venue_name""" order by count("""winner""") desc

--most matches won in a venue bowling first
select """venue_name""",count("""winner""")from [portfolio project]..all_season_summary where """decision"""='"Bowl First"' group by """venue_name""" order by count("""winner""") desc

--most matches won by a team batting first
select """winner""",count("""winner""")from [portfolio project]..all_season_summary where """decision"""='"Bat First"' group by """winner""" order by count("""winner""") desc

--most matches won by a team bowling first
select """winner""",count("""winner""")from [portfolio project]..all_season_summary where """decision"""='"Bowl First"' group by """winner""" order by count("""winner""") desc


--most matches won by a team that won the toss
select """winner""", COUNT("""winner""") from [portfolio project]..all_season_summary where """toss_won"""= """winner""" group by """winner""" order by count("""winner""") desc

--most matches won by a team 
select """winner""", COUNT("""winner""") from [portfolio project]..all_season_summary group by """winner""" order by count("""winner""") desc

--Rivalry MI VS CSK
select """winner""",count("""winner""") as count from [portfolio project]..all_season_summary where ["short_name"] in ('"CSK v MI"','"MI v CSK"') group by ["winner"] order by COUNT("""winner""") desc
