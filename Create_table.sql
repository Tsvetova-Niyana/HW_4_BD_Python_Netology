/*
Написать SQL-запросы, создающие спроектированную БД. 
Прислать ссылку на файл, содержащий SQL-запросы.
*/

----------------------Схема «Музыкальный сайт»----------------------

create database music_website;

set search_path to public;

create table genre(
	id_genre serial primary key,
	name_genre varchar(50) not null
);

create table executor(
	id_executor serial primary key,
	nickname_executor varchar(50) not null
);

create table album(
	id_album serial primary key,
	name_album varchar(50) not null,
	year_release int not null
);

create table collection(
	id_collection serial primary key,
	name_collection varchar(50) not null,
	year_release int not null
);

create table track(
	id_track serial primary key,
	name_track varchar(50) not null,
	duration_track time not null,
	id_album int references album(id_album)
);

create table executers_genres(
	id_eg serial primary key,
	id_executor int references executor(id_executor),
	id_genre int references genre(id_genre)
);

create table albums_executors(
	id_ae serial primary key,
	id_executor int references executor(id_executor),
	id_album int references album(id_album)
);

create table collections_tracks(
	id_ct serial primary key,
	id_collection int references collection(id_collection),
	id_track int references track(id_track)
);


----------------------Схема «Сотрудник»----------------------

create table department(
	id_department serial primary key,
	name_department varchar(50) not null
);

create table employee(
	id_employee serial primary key,
	name_employee varchar(50) not null,
	id_department int references department(id_department),
	id_director int references employee(id_employee)
);
