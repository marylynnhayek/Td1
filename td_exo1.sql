-- Td #1:
-- 1. Ecrire une requête qui va créer la table « Movie » avec des contraintes convenables.
-- 2. Ecrire une requête qui va créer la table « Reviewer » avec des contraintes convenables.
-- 3. Ecrire une requête qui va créer la table « Rating » avec des contraintes convenables.

-- You can insert as much data as you want, note that you should respect the links between the tables and the attributes types.
create table Movie(
  mID int NOT NULL,
  title varchar(50),
  year date,
  director varchar(50),
  primary key(mID)
  );

create table Reviewer(
    rID int NOT NULL,
    name varchar(50),
    primary key(rID)
  );

create table Rating(
  rID int NOT NULL,
  mID int NOT NULL,
  stars int,
  ratingDate date,
  primary key(rID,mID),
  foreign key(rID) references Reviewer(rID),
  foreign key(mID) references Movie(mID)
  );

-- Exercice 2:

-- 1- Trouver les titres des films réalisés par « James Cameron »:
select title 
from Movie
where director='James Cameron';

-- 2. Trouver les années possédant un film qui a reçu un classement de 4 ou 5 étoiles, en les triant par ordre décroissant:
select distinct year
from Movie M, Rating Ra
where M.mID=Ra.mID and (stars=4 or stars=5)
order by stars desc;

-- 3. Trouver les titres des films qui n’ont pas reçu un classement:
select title 
from Movie 
where mID NOT IN(select mID from Rating);

-- 4. Quelques examinateurs n’ont pas fournit une date avec leurs classement. Trouver les noms de tous les examinateurs qui n’ont pas fournit une date avec leurs classement:
select name
from Reviewer Re, Rating Ra
where Re.rID=Ra.rID and ratingDate is null;

-- We've never used the natural join command before..
-- 5. Ecrire une requête qui retourne les données classées dans un format plus lisible : nom de l’examinateur, titre du film, étoiles et la date de classement. Trier les données, premièrement par nom de l’examinateur, ensuite par titre du film et finalement par le nombre des étoiles reçu:
select name as 'Nom de lexaminateur', title as 'Titre du film', stars as 'étoiles', ratingDate as 'Date de Classment'
from (Reviewer natural join Rating) natural join Movie
order by name, title, stars;

-- 6. Pour les cas où le même examinateur a classé deux fois le même film en donnant un classement supérieur dans la deuxième fois, trouver le nom de l’examinateur et le nom du film:
select name, title
from Movie M, Reviewer Re, Rating Ra
where M.mID = Ra.mID and Re.rID = Ra.rID and Re.rID in (
select rID from Rating where Ra.mID = mID and stars < Ra.stars and ratingDate < Ra.ratingDate);

-- 7. Pour chaque film qui possède au moins un classement, trouver le nombre maximal des étoiles reçu par ce film. Afficher le titre du film et le nombre des étoiles. Trier les résultats par titre des films:
select title, max(stars)
from Rating Ra, Movie M
where Ra.mID=M.mID
group by M.mID
order by title;

-- 8. Pour chaque film, afficher le titre et la ‘propagation du classement’, c’est-à-dire, la différence entre le classement maximal et minimal donné pour ce film. Trier les résultats par ordre décroissant selon la ‘propagation du classement’.
select title, (max(stars)-min(stars)) as "Propagation du classement"
from Movie M, Rating Ra
where M.mID=Ra.mID
group by Ra.mID
order by max(stars)-min(stars) desc;

-- Exercice 3:
-- 1. Trouver les noms de tous les examinateurs qui ont classés ‘Gone with the Wind’.
select name
from Reviewer Re, Movie M, Rating Ra
where Re.rID=Ra.rID and M.mID=Ra.mID and title='Gone with the wind';

-- 2. Pour chaque classement dont l’examinateur est le réalisateur du film, retourne le nom de l’examinateur, le titre du film et le nombre des étoiles reçues.
select name as "Nom de lexaminateur", title as "Titre du film", stars as "nombre des étoiles reçues"
from Reviewer Re, Rating Ra, Movie M
where m.director=Re.name and Ra.mID=M.mID and Re.rID=Ra.rID;

-- 3. Trouver à la fois tous les examinateurs et les titres des films dans une seul liste, classée par ordre alphabétique.
select name as "NAME" from Reviewer where director is not null
union
select title as "NAME" from Movie where title is not null
order by NAME;

-- 4. Trouver les titres des films qui ne sont pas examinés par ‘Chris Jackson’.
-- My Method:
select title
from Movie M, Reviewer Re, Rating Ra
where M.mID=Ra.mID and Re.name<>'Chris Jackson';

--Other Method:
select title
from Movie
where mID not in (select mID from Rating R, Reviewer Re
where R.rID = Re.rID and name = 'Chris Jackson');

-- 5. Pour tous les pairs des examinateurs tels que les deux examinateurs classent le même film, retourne les noms des deux examinateurs. Eliminer les doublons, n’associez pas les examinateurs avec euxmêmes, inclure chaque pair une seule fois. Pour chaque pair, retourne les noms par ordre alphabétique.
select distinct R1.name, R2.name
from Reviewer R1, Reviewer R2, Rating Ra1, Rating Ra2
where R1.rID = Ra1.rID and R2.rID = Ra2.rID and Ra1.mID = Ra2.mID and R1.name < R2.name
order by R1.name, R2.name;

--Explication: Déclaration de 2 examinateurs distincts R1 et R2, le but c'est de voir si ces 2 examinateurs on classé le meme film, si oui: we return both their names, while having distinct values of reviewers, (don't return the same reviewer with himself (aka more than once). Each pair of reviewers (R1,R2) should be unique and returned only once. Order by name alphabetically. 

-- 6. Pour chaque classement dont le nombre des étoiles est le plus bas dans la base de données, retourne le nom de l’examinateur, le nom du film et le nombre des étoiles.
select name, title, stars
from Reviewer Re, Rating Ra, Movie M
where Re.rID=Ra.rID AND M.mID=Ra.mID AND stars=select(min(stars) from Rating);

-- 7. Trouver les titres des films et la moyenne des classement, du plus haut au plus bas classement. Si deux ou plus de films possèdent la même moyenne de classement, en procède à un classement par ordre alphabétique.
select title, avg(stars) as "Moyenne des classement"
from Movie M, Rating Ra
where M.mID=Ra.mID
group by Ra.mID
order by avg(stars),title;

-- 8. Trouver les noms de tous les examinateurs qui ont contribué à trois ou plus de classement.
select name
from Reviewer Re, Rating Ra
where Re.rID=Ra.rID
group by Ra.rID
having count(*)>=3;

-- 9. Quelques réalisateurs ont réalisés plus d’un film. Pour tous ces réalisateurs, trouver les titres de tous les films qui ont réalisés avec le nom du réalisateur. Classer les résultats par nom, ensuite par le titre du film.
select title, director
from Movie M1
where 1<(select count(*) from Movie M2 where M1.director = M2.director)
order by director,title;

-- 10. Pour chaque réalisateur, trouver son nom à la fois avec le titre(s) du film(s) réalisés et ont reçu le plus haut classement parmi tous ses films, et la valeur de ce classement. On ignore les films dont le réalisateur est NULL.
select director, title, max(stars)
from Movie M, Rating Ra
where M.mID=Ra.mID and director is NOT NULL
group by director;

-- Exercice 4
-- 1. Ajouter à la base de données l’examinateur ‘Roger Ebert’ avec un rID de 209:
insert into Reviewer values(209,'Roger Ebert');

-- 2. Insérer dans la base de données un classement de 5-étoiles donné par James Cameron pour tous les films. Laissez le champ ‘date’ NULL:
insert into Rating 
select(select rID from Reviewer where name='James Cameron') as James, mID,5,NULL
from Movie;
                          
-- 3. Pour tous les films possédant une moyenne de classement de 4-étoiles ou plus, ajouter 25 à l’année de production (mettre à jour les tuples):
update Movie
set year=year+25
where mID in(
select mID from Rating 
group by mID
having avg(stars)>=4);

-- 4. Supprimer tous les classement des films dont l’année de production est avant 1970 ou après 2000, et le classement est moins de 4 étoiles:
delete from Rating
where stars < 4 and mID in (select mID from Movie where year<1970or year>2000);

-- Partie 2
-- Student (ID, name, mark)
-- Friend (ID1, ID2)
-- Likes (ID1, ID2)

create table Student(
  ID int NOT NULL primary key,
  name varchar(50),
  mark int
 );
 
create table Friend(
  ID1 int NOT NULL,
  ID2 int NOT NULL,
  foreign key(ID1) references Student(ID),
  foreign key(ID2) references Student(ID),
  primary key(ID1,ID2)
 );
 
 create table Likes(
  ID1 int NOT NULL,
  ID2 int NOT NULL,
  foreign key(ID1) references Student(ID),
  foreign key(ID2) references Student(ID),
  primary key(ID1,ID2)
 );

 insert into Student values(1,'Joseph',90);
insert into Student values(2,'Mario',100);
insert into Student values(3,'Ralph',91);
insert into Student values(4,'Joe',92);
insert into Student values(5,'Maria',93);
insert into Student values(6,'Mira',94);
insert into Student values(7,'Perla',95);
insert into Student values(8,'Laury',96);
insert into Student values(9,'Joya',98);
insert into Student values(10,'Jad',90);
insert into Student values(11,'Elie',99);
insert into Student values(12,'Elia',99);
insert into Student values(13,'Gabriel',94);
insert into Student values(14,'Jean',93);
insert into Student values(15,'Tina',91);
insert into Student values(16,'Alain',93);













