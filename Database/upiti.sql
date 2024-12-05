CREATE TABLE Grad (
    GradID SERIAL PRIMARY KEY,
    Naziv VARCHAR(30) NOT NULL
);

CREATE TABLE Korisnik (
    KorisnikID SERIAL PRIMARY KEY,
    GradID INT REFERENCES Grad(GradID),
    Ime VARCHAR(30) NOT NULL,
    Adresa VARCHAR(50) NOT NULL,
    LoyaltyCard BOOLEAN
);

CREATE TABLE Uloga (
    UlogaID SERIAL PRIMARY KEY,  
    Naziv VARCHAR(30) NOT NULL   
);

CREATE TABLE Kategorija (
    KategorijaID SERIAL PRIMARY KEY,      
    Naziv VARCHAR(30) NOT NULL   
);

CREATE TABLE Jelo (
    JeloID SERIAL PRIMARY KEY,
    Naziv VARCHAR(30) NOT NULL,
    KategorijaID INT REFERENCES Kategorija(KategorijaID),
    Cijena DOUBLE PRECISION NOT NULL,
    Kcal DOUBLE PRECISION NOT NULL,
    Dostupno BOOLEAN NOT NULL
);

CREATE TABLE Jelovnik (
    JelovnikID SERIAL,
    Naziv VARCHAR(30),
    PRIMARY KEY (JelovnikID),
    CONSTRAINT unique_jelovnikid UNIQUE (JelovnikID)
);

CREATE TABLE Jelovnik_Jelo (
    JelovnikID INT,
    JeloID INT,
    PRIMARY KEY (JelovnikID, JeloID),
    CONSTRAINT fk_jelovnik FOREIGN KEY (JelovnikID) REFERENCES Jelovnik(JelovnikID),
    CONSTRAINT fk_jelo FOREIGN KEY (JeloID) REFERENCES Jelo(JeloID)
);

CREATE TABLE Osoblje (
    OsobljeID SERIAL PRIMARY KEY,
    UlogaID INT NOT NULL,
    Ime VARCHAR(30) NOT NULL,
    Prezime VARCHAR(30) NOT NULL,
    DatumRodjenja DATE NOT NULL,
    ImaVozackaDozvola BOOLEAN NOT NULL,
    CHECK (
        (UlogaID = 1 AND DATE_PART('year', AGE(DatumRodjenja)) >= 18) OR
        (UlogaID = 2 AND ImaVozackaDozvola = TRUE) OR
        UlogaID NOT IN (1, 2)
    )
);

CREATE TABLE Restoran (
    RestoranID SERIAL PRIMARY KEY,
    Naziv VARCHAR(30) NOT NULL,
    Kapacitet INT,
    RadnoVrijeme TIME,
    GradID INT,
    JelovnikID INT,
    CONSTRAINT fk_grad FOREIGN KEY (GradID) REFERENCES Grad(GradID),
    CONSTRAINT fk_jelovnik FOREIGN KEY (JelovnikID) REFERENCES Jelovnik(JelovnikID)
);

CREATE TABLE Restoran_Osoblje (
    RestoranID INT,
    OsobljeID INT,
    DatumZaposljena DATE,
    CONSTRAINT pk_restoran_osoblje PRIMARY KEY (RestoranID, OsobljeID),
    CONSTRAINT fk_restoran FOREIGN KEY (RestoranID) REFERENCES Restoran(RestoranID),
    CONSTRAINT fk_osoblje FOREIGN KEY (OsobljeID) REFERENCES Osoblje(OsobljeID)
);

CREATE TABLE Narudzba (
    NarudzbaID SERIAL PRIMARY KEY,
    KorisnikID INT,
    JeloID INT,
    CONSTRAINT fk_korisnik FOREIGN KEY (KorisnikID) REFERENCES Korisnik(KorisnikID),
    CONSTRAINT fk_jelo FOREIGN KEY (JeloID) REFERENCES Jelo(JeloID)
);

CREATE TABLE Restoran_Narudzbe (
    RestoranID INT,
    NarudzbaID INT,
    Ocjena INT CHECK (Ocjena >= 1 AND Ocjena <= 5),
    Datum DATE NOT NULL,
    Dostava BOOLEAN NOT NULL,
    ID_osoblje INT,
    IDkorisnik INT,
    CONSTRAINT pk_restoran_narudzbe PRIMARY KEY (RestoranID, NarudzbaID),
    CONSTRAINT fk_restoran FOREIGN KEY (RestoranID) REFERENCES Restoran(RestoranID),
    CONSTRAINT fk_narudzba FOREIGN KEY (NarudzbaID) REFERENCES Narudzba(NarudzbaID),
    CONSTRAINT fk_osoblje FOREIGN KEY (ID_osoblje) REFERENCES Osoblje(OsobljeID),
    CONSTRAINT fk_korisnik FOREIGN KEY (IDkorisnik) REFERENCES Korisnik(KorisnikID),
    CONSTRAINT chk_dostava_osoblje CHECK (
        (Dostava = TRUE AND ID_osoblje IS NOT NULL) OR
        (Dostava = FALSE AND ID_osoblje IS NULL)
    ),
    CONSTRAINT chk_dostava_korisnik CHECK (
        (Dostava = TRUE AND IDkorisnik IS NOT NULL) OR
        (Dostava = FALSE AND IDkorisnik IS NULL)
    )
);

ALTER TABLE Osoblje ADD CONSTRAINT chk_kuhar_dostavljac CHECK (
    (UlogaID = 1 AND DATE_PART('year', AGE(DatumRodjenja)) >= 18) OR
    (UlogaID = 2 AND ImaVozackaDozvola = TRUE) OR
    UlogaID NOT IN (1, 2)
);

-- Inserting initial data
INSERT INTO Uloga (UlogaID, Naziv) VALUES
    (1, 'Kuhar'),
    (2, 'Dostavljac'),
    (3, 'Konobar'),
    (4, 'Cistac');

INSERT INTO Kategorija (KategorijaID, Naziv) VALUES
    (1, 'Predjelo'),
    (2, 'Hladno Jelo'),
    (3, 'Glavno Jelo'),
    (4, 'Desert');

-- Modifying Restoran table's column type
ALTER TABLE Restoran ALTER COLUMN Naziv TYPE VARCHAR(100);

-- Insert Cooks into Osoblje table
DO $$ 
DECLARE
    max_osoblje_id INT;
BEGIN
    -- Get the current highest OsobljeID
    SELECT COALESCE(MAX(OsobljeID), 0) INTO max_osoblje_id FROM Osoblje;

    -- Insert new cooks
    INSERT INTO Osoblje (OsobljeID, UlogaID, Ime, Prezime, DatumRodjenja, ImaVozackaDozvola)
    VALUES 
        (max_osoblje_id + 1, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'John', 'Doe', '1980-01-01', FALSE),
        (max_osoblje_id + 2, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Jane', 'Smith', '1982-02-02', FALSE),
        (max_osoblje_id + 3, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Mark', 'Jones', '1984-03-03', FALSE),
        (max_osoblje_id + 4, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Emily', 'Davis', '1986-04-04', FALSE),
        (max_osoblje_id + 5, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Michael', 'Wilson', '1988-05-05', FALSE),
        (max_osoblje_id + 6, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Sarah', 'Taylor', '1990-06-06', FALSE),
        (max_osoblje_id + 7, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'David', 'Brown', '1992-07-07', FALSE),
        (max_osoblje_id + 8, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Laura', 'Anderson', '1994-08-08', FALSE),
        (max_osoblje_id + 9, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Chris', 'Thomas', '1996-09-09', FALSE),
        (max_osoblje_id + 10, (SELECT UlogaID FROM Uloga WHERE Naziv = 'Kuhar'), 'Anna', 'Moore', '1998-10-10', FALSE);

    -- Link Cooks to the Restaurant in the Restoran_Osoblje table
    INSERT INTO Restoran_Osoblje (RestoranID, OsobljeID, DatumZaposljena)
    VALUES 
        (31, max_osoblje_id + 1, '2023-01-01'),
        (31, max_osoblje_id + 2, '2023-02-02'),
        (31, max_osoblje_id + 3, '2023-03-03'),
        (31, max_osoblje_id + 4, '2023-04-04'),
        (31, max_osoblje_id + 5, '2023-05-05'),
        (31, max_osoblje_id + 6, '2023-06-06'),
        (31, max_osoblje_id + 7, '2023-07-07'),
        (31, max_osoblje_id + 8, '2023-08-08'),
        (31, max_osoblje_id + 9, '2023-09-09'),
        (31, max_osoblje_id + 10, '2023-10-10');
END $$;

-- Ensure Split is in the Grad table

select * from restoran_narudzbe


