/*Написать SELECT-запросы, которые выведут информацию согласно инструкциям ниже.

Внимание: результаты запросов не должны быть пустыми, при необходимости добавьте данные в таблицы.*/

--Количество исполнителей в каждом жанре.
select 
	g.name_genre, 	
	count(*) as count_executor
from executers_genres eg
join genre g on eg.id_genre = g.id_genre
group by eg.id_genre, g.name_genre
order by g.name_genre;

--Количество треков, вошедших в альбомы 2019–2020 годов.
-- вариант 1 без использования подзапросов
select 
	a.name_album, 
	a.year_release, 
	count(*) as count_track 
from track t
join album a on t.id_album = a.id_album and a.year_release between 2019 and 2020
group by t.id_album, a.name_album, a.year_release; 

-- вариант 2 с использованием подзапросов
select 
	a.name_album, 
	a.year_release, 
	count(*) as count_track 
from track t
join album a on t.id_album = a.id_album 
where t.id_album in (select a2.id_album from album a2 where a2.year_release between 2019 and 2020)
group by t.id_album, a.name_album, a.year_release;

-- Средняя продолжительность треков по каждому альбому.
select 
	t.id_album, 
	count(*) as count_track, 
	avg(t.duration_track) as avg_duration   
from track t
group by t.id_album
order by t.id_album; 

-- Все исполнители, которые не выпустили альбомы в 2020 году.

select * from executor e
where e.id_executor not in (select ae.id_executor from albums_executors ae 
							where ae.id_album in (select a.id_album from album a 
													where a.year_release = 2020 order by a.year_release));

--Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).
select 
	c.name_collection 
from collection c 
where c.id_collection in (select 
							ct.id_collection 
						from collections_tracks ct 
						join track t on ct.id_track = t.id_track
						join albums_executors ae on t.id_album = ae.id_album 
						join executor e on ae.id_executor = e.id_executor and e.nickname_executor = 'Коrsика');

--Названия альбомов, в которых присутствуют исполнители более чем одного жанра.
select 
	a.name_album 
from album a 
join albums_executors ae on ae.id_album = a.id_album 
where ae.id_executor in (select eg.id_executor from executers_genres eg 
						group by eg.id_executor
						having Count(*) > 1)	
order by a.name_album;

--Наименования треков, которые не входят в сборники.
select t.name_track from track t 
left join collections_tracks ct on t.id_track = ct.id_track
where ct.id_collection is null
order by t.name_track; 

-- Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, 
-- — теоретически таких треков может быть несколько.
--вариант 1 через join
select 
	e.id_executor, 
	e.nickname_executor
from executor e
join albums_executors ae on e.id_executor = ae.id_executor 
join track t on t.id_album = ae.id_album and t.duration_track in (select min(duration_track) from track t2); 

--вариант 2 через подзапросы
select 
	e.id_executor,
	e.nickname_executor 
from executor e 
where e.id_executor in (select ae.id_executor from albums_executors ae
						where ae.id_album in (select t.id_album from track t
												where t.duration_track in (select min(duration_track) from track t2)));

-- Названия альбомов, содержащих наименьшее количество треков.
-- вариант 1
select a.name_album from album a 
join track t on a.id_album = t.id_album 
group by t.id_album, a.name_album
having count(*) = (select distinct count(*) as count_track from track t 
					group by t.id_album	
					order by count(*)
					limit 1)
order by a.name_album											
											
-- вариант 2
select a.name_album from album a 
join track t on a.id_album = t.id_album 
group by t.id_album, a.name_album
having count(*) = (select min(t.count_track) from (select t.id_album, count(*) as count_track from track t 
								group by t.id_album		
								order by count(*)) t)
order by a.name_album

-- вариант 3 с использованием cte
with cte as(select t.id_album, count(*) as count_track from track t 
								group by t.id_album		
								order by count(*))
select a.name_album from cte
join album a on a.id_album = cte.id_album
where cte.count_track = (select min(cte.count_track) from cte)
order by a.name_album

