SELECT * FROM Jelo WHERE Cijena < 15;

SELECT RN.RestoranID, RN.NarudzbaID, SUM(J.Cijena) AS UkupanIznos
FROM Restoran_Narudzbe RN
JOIN Narudzba N ON RN.NarudzbaID = N.NarudzbaID
JOIN Jelo J ON N.JeloID = J.JeloID
WHERE EXTRACT(YEAR FROM RN.Datum) = 2023
GROUP BY RN.RestoranID, RN.NarudzbaID
HAVING SUM(J.Cijena) > 50;

SELECT O.Ime, O.Prezime, COUNT(RN.NarudzbaID) AS BrojDostava
FROM Osoblje O
JOIN Restoran_Narudzbe RN ON O.OsobljeID = RN.ID_osoblje
WHERE O.UlogaID = (SELECT UlogaID FROM Uloga WHERE Naziv = 'Dostavljac') AND RN.Dostava = TRUE
GROUP BY O.OsobljeID
HAVING COUNT(RN.NarudzbaID) > 100;

SELECT O.Ime, O.Prezime
FROM Osoblje O
JOIN Restoran_Osoblje RO ON O.OsobljeID = RO.OsobljeID
JOIN Restoran R ON RO.RestoranID = R.RestoranID
JOIN Grad G ON R.GradID = G.GradID
WHERE O.UlogaID = (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar') AND G.Naziv = 'Zagreb';


SELECT R.Naziv AS Restoran, COUNT(N.NarudzbaID) AS BrojNarudzbi
FROM Restoran R
JOIN Grad G ON R.GradID = G.GradID
JOIN Restoran_Narudzbe RN ON R.RestoranID = RN.RestoranID
JOIN Narudzba N ON RN.NarudzbaID = N.NarudzbaID
WHERE G.Naziv = 'Split' AND EXTRACT(YEAR FROM RN.Datum) = 2023
GROUP BY R.Naziv;

SELECT J.Naziv, COUNT(N.NarudzbaID) AS BrojNarudzbi
FROM Jelo J
JOIN Kategorija K ON J.KategorijaID = K.KategorijaID
JOIN Narudzba N ON J.JeloID = N.JeloID
JOIN Restoran_Narudzbe RN ON N.NarudzbaID = RN.NarudzbaID
WHERE K.Naziv = 'Desert' AND EXTRACT(MONTH FROM RN.Datum) = 12 AND EXTRACT(YEAR FROM RN.Datum) = 2023
GROUP BY J.Naziv
HAVING COUNT(N.NarudzbaID) > 10;

SELECT K.Ime, COUNT(N.NarudzbaID) AS BrojNarudzbi
FROM Korisnik K
JOIN Narudzba N ON K.KorisnikID = N.KorisnikID
WHERE K.Ime LIKE 'M%'
GROUP BY K.Ime;  --sastavljao sam prvo bazu i tad nisam dodao prezime nego samo ime

SELECT R.Naziv, AVG(RN.Ocjena) AS ProsjecnaOcjena
FROM Restoran R
JOIN Grad G ON R.GradID = G.GradID
JOIN Restoran_Narudzbe RN ON R.RestoranID = RN.RestoranID
WHERE G.Naziv = 'Rijeka'
GROUP BY R.Naziv;

SELECT R.Naziv
FROM Restoran R
JOIN Restoran_Narudzbe RN ON R.RestoranID = RN.RestoranID
WHERE R.Kapacitet > 30 AND RN.Dostava = TRUE
GROUP BY R.Naziv;

DELETE FROM Jelovnik_Jelo
WHERE JeloID NOT IN (
    SELECT DISTINCT JeloID
    FROM Narudzba N
    JOIN Restoran_Narudzbe RN ON N.NarudzbaID = RN.NarudzbaID
    WHERE RN.Datum >= NOW() - INTERVAL '2 years'
);

UPDATE Korisnik
SET LoyaltyCard = FALSE
WHERE KorisnikID NOT IN (
    SELECT DISTINCT KorisnikID
    FROM Narudzba N
    JOIN Restoran_Narudzbe RN ON N.NarudzbaID = RN.NarudzbaID
    WHERE RN.Datum >= NOW() - INTERVAL '1 year'
);


