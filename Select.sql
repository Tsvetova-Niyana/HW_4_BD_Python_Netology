/*Написать SELECT-запросы, которые выведут информацию согласно инструкциям ниже.

Внимание: результаты запросов не должны быть пустыми, при необходимости добавьте данные в таблицы.*/

--Количество исполнителей в каждом жанре.

/* нет необходимости группировать по айди. Здесь достаточно группировать по именам жанров.*/

select 
	g.name_genre, 	
	count(*) as count_executor
from executers_genres eg
join genre g on eg.id_genre = g.id_genre
group by g.name_genre
order by g.name_genre;

--Количество треков, вошедших в альбомы 2019–2020 годов.
/*
 * не реализуется в подзапросом и здесь не нужна группировка как и получение имени альбома с его годом. 
 * В задании сказано получить общее количество треков в заданном диапазоне альбомов. 
 */

select 
	count(*) as count_track 
from track t
join album a on t.id_album = a.id_album and a.year_release between 2019 and 2020; 

-- Средняя продолжительность треков по каждому альбому.
/*
 * реализован не совсем корректно. Необходимо получить имена альбомов и среднюю продолжительность по ним. 
 * Выводя только идентификационные номера, нет понимание о каких альбомах идет речь.
 */

select 
	a.name_album, 
	avg(t.duration_track) as avg_duration   
from track t
join album a on a.id_album = t.id_album 
group by t.id_album, a.name_album
order by t.id_album; 

-- Все исполнители, которые не выпустили альбомы в 2020 году.
/* реализован не совсем корректно. Второй уровень вложенности запроса здесь излишен.*/

select e.nickname_executor from executor e
where e.nickname_executor not in (select e2.nickname_executor  
									from executor e2
									join albums_executors ae on e2.id_executor = ae.id_executor
									join album a on ae.id_album = a.id_album 
									where a.year_release = 2020 )
order by e.nickname_executor;

--Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).
/*реализован не совсем корректно. 
 * Во-первых, отсутствует объединение с таблице альбомов. 
 * Во-вторых, вложенный запрос здесь не требуется. 
 * Достаточно объединить таблицы и в условии where найти конкретного исполнителя. */

select 
	distinct c.name_collection 
from collection c 
join collections_tracks ct on ct.id_collection = c.id_collection
join track t on ct.id_track = t.id_track
join album a on t.id_album = a.id_album
join albums_executors ae on a.id_album = ae.id_album 
join executor e on ae.id_executor = e.id_executor and e.nickname_executor = 'Коrsика';

--Названия альбомов, в которых присутствуют исполнители более чем одного жанра.

/*реализован не совсем корректно. Здесь нет необходимости в реализации вложенного запроса. */

select 
	distinct a.name_album 
from album a 
join albums_executors ae on ae.id_album = a.id_album
join executor e on ae.id_executor = e.id_executor
join executers_genres eg on e.id_executor = eg.id_executor 
group by a.name_album, e.nickname_executor  
having Count(*) > 1	
order by a.name_album;

--Наименования треков, которые не входят в сборники.
select t.name_track from track t 
left join collections_tracks ct on t.id_track = ct.id_track
where ct.id_collection is null
order by t.name_track; 

-- Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, 
-- — теоретически таких треков может быть несколько.

/*пропустили объединение с таблице альбомов.*/

select 
	e.id_executor, 
	e.nickname_executor
from executor e
join albums_executors ae on e.id_executor = ae.id_executor 
join album a on ae.id_album = a.id_album 
join track t on t.id_album = ae.id_album and t.duration_track in (select min(duration_track) from track t2); 

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

