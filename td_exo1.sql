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

-- Exercice 5:
--1. Trouver les noms des étudiants qui sont des amis avec ‘Gabriel’:
select name
from student s1, student s2, friend f1
where s1.ID=F1.ID2 AND s2.ID=F1.ID1 and s2.name='Gabriel';

-- 2. Pour chaque étudiant qui aime un autre qui possède une note inferieur de 2 ou plus, retourne le nom et la note de cet étudiant, ainsi que le nom et la note de l’étudiant qui aime:
select S1.name, S1.mark, S2.name, S2.mark
from student S1, likes L1, student S2
where S1.ID=L1.ID1 and L1.ID2=S2.ID and (S1.mark>=S2.mark+2);

-- 3. Pour chaque pair des étudiants dont l’un aime l’autre, afficher le nom et la note des deux étudiants. Afficher chaque pair une seule fois en ordre alphabétique:
select H1.name, H1.mark, H2.name, H2.mark
from Likes L1, Likes L2, Student S1, Student S2
where S1.ID = L1.ID1 and S2.ID = L2.ID1 and L1.ID1 = L2.ID2 and L1.ID2 = L2.ID1
and H1.name < H2.name;

--Second solution
select S1.name, S1.mark, S2.name, S2.mark
from Student S1, Likes L1, Student S2
where S1.ID = L1.ID1 and L1.ID2 = S2.ID and S1.name < S2.name and ID2 in (
select ID1 from Likes where ID2 = L1.ID1)
order by S1.name;

-- 4. Trouver tous les étudiants qui n’apparaissent pas dans la table ‘Likes’ et retourne leurs noms et leurs notes. Trier les résultats par note, ensuite par nom:
select name, mark
from student
where ID not in (select ID1 from Likes) AND ID not in(select ID2 from likes)
order by mark,name;

-- 5. Pour chaque situation dont un étudiant A aime un étudiant B, mais on ne possède aucune information sur les étudiants aimés par l’étudiant B (c’est-à-dire, B n’apparait pas comme ID1 dans la table ‘Likes’), retourne les nomes et les notes de A et B:
select S1.mark, S1.name, S2.mark, S2.name
from Student S1, Student S2, Likes L1
where S1.ID=L1.ID1 and S2.ID=L.ID2 and ID2 not in (select ID1 from Likes)
order by S1.name; 

-- 6. Pour chaque étudiant A qui aime un étudiant B dont les deux ne sont pas des amis, trouver s’ils possèdent un ami C en commun. Pour ce trios, afficher le nom et la note de A, B et C:
select S1.nom,S1.mark,S2.nom,S2.mark,S3.nom,S3.mark
from Studen S1, Student S2, Student S3, Likes L, Friend F1, Friend F2
where S1.ID=L.ID1 and S2.ID=L.ID2 and S1.ID not in (select ID1 from Friend where ID2=S2.ID) AND S3.ID=F1.ID1 and S3.ID=F2.ID1 and F1.ID2=S1.ID and F2.ID2=S2.ID;

-- 7. Trouver la différence entre le nombre des étudiants à l’école et le nombre de diffèrent noms:
select count(*)-count(distinct name)) as "La différence"
from Student;

-- 8. Trouver le nom et la note de tous les étudiants qui sont aimés par plus d’un autre étudiant:
select name, mark
from student S, Likes L
where S.ID=L.ID2
group by ID2
having count(*)>1;











