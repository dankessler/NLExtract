-- Tabellen voor BAGExtract+
-- Min of meer 1-1 met BAG model dus niet geoptimaliseerd
-- Te gebruiken als basis tabellen om specifieke tabellen
-- aan te maken via bijvoorbeeld views of SQL selecties.
--

-- TODO optimaliseren !!

-- Systeem tabellen
DROP TABLE IF EXISTS bagextractpluslog;
/*
-- Niet meer loggen in de database
CREATE TABLE bagextractpluslog (
    datum date,
    actie character varying(1000),
    bestand character varying(1000),
    logfile character varying(1000)
);
*/

DROP TABLE IF EXISTS bagextractinfo;
CREATE TABLE bagextractinfo (
    id serial,
    sleutel character varying (25),
    waarde character varying (100)
);
INSERT INTO bagextractinfo (sleutel,waarde) VALUES ('schema_versie', '1.0.1');
INSERT INTO bagextractinfo (sleutel,waarde) VALUES ('software_versie', '1.0.0');

-- BAG tabellen

DROP TABLE IF EXISTS adresseerbaarobjectnevenadres;

CREATE TABLE adresseerbaarobjectnevenadres (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    begindatum timestamp without time zone,
    nevenadres numeric(16,0),
    PRIMARY KEY (id)
);

DROP VIEW IF EXISTS ligplaatsactueelbestaand;
DROP VIEW IF EXISTS ligplaatsactueel;

DROP TABLE IF EXISTS ligplaats;
CREATE TABLE ligplaats (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    hoofdadres numeric(16,0),
    ligplaatsstatus character varying(80),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    geovlak geometry,
    PRIMARY KEY (id),
    CONSTRAINT enforce_dims_geometrie CHECK ((st_ndims(geovlak) = 3)),
    CONSTRAINT enforce_geotype_geometrie CHECK (((geometrytype(geovlak) = 'POLYGON'::text) OR (geovlak IS NULL))),
    CONSTRAINT enforce_srid_geometrie CHECK ((st_srid(geovlak) = 28992))
);
/*
CREATE VIEW ligplaatsactueel AS
    SELECT (ligplaats.oid)::character varying AS oid, ligplaats.identificatie, ligplaats.aanduidingrecordinactief, ligplaats.aanduidingrecordcorrectie, ligplaats.officieel, ligplaats.inonderzoek, ligplaats.documentnummer, ligplaats.documentdatum, ligplaats.hoofdadres, ligplaats.ligplaatsstatus, ligplaats.begindatum, ligplaats.einddatum, ligplaats.geovlak FROM ligplaats WHERE (((ligplaats.begindatum <= ('now'::text)::date) AND (ligplaats.einddatum >= ('now'::text)::date)) AND ((ligplaats.aanduidingrecordinactief)::text = 'N'::text));

CREATE VIEW ligplaatsactueelbestaand AS
    SELECT (ligplaats.oid)::character varying AS oid, ligplaats.identificatie, ligplaats.aanduidingrecordinactief, ligplaats.aanduidingrecordcorrectie, ligplaats.officieel, ligplaats.inonderzoek, ligplaats.documentnummer, ligplaats.documentdatum, ligplaats.hoofdadres, ligplaats.ligplaatsstatus, ligplaats.begindatum, ligplaats.einddatum, ligplaats.geovlak FROM ligplaats WHERE ((((ligplaats.begindatum <= ('now'::text)::date) AND (ligplaats.einddatum >= ('now'::text)::date)) AND ((ligplaats.aanduidingrecordinactief)::text = 'N'::text)) AND ((ligplaats.ligplaatsstatus)::text <> 'Plaats ingetrokken'::text));
*/
DROP VIEW IF EXISTS nummeraanduidingactueel;
DROP VIEW IF EXISTS nummeraanduidingactueelbestaand;

DROP TABLE IF EXISTS nummeraanduiding;
CREATE TABLE nummeraanduiding (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    huisnummer numeric(5,0),
    huisletter character varying(1),
    huisnummertoevoeging character varying(4),
    postcode character varying(6),
    nummeraanduidingstatus character varying(80),
    typeadresseerbaarobject character varying(20),
    gerelateerdeopenbareruimte numeric(16,0),
    gerelateerdewoonplaats numeric(16,0),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    PRIMARY KEY (id)
);
/*
CREATE VIEW nummeraanduidingactueel AS
    SELECT nummeraanduiding.identificatie, nummeraanduiding.aanduidingrecordinactief, nummeraanduiding.aanduidingrecordcorrectie, nummeraanduiding.officieel, nummeraanduiding.inonderzoek, nummeraanduiding.documentnummer, nummeraanduiding.documentdatum, nummeraanduiding.huisnummer, nummeraanduiding.huisletter, nummeraanduiding.huisnummertoevoeging, nummeraanduiding.postcode, nummeraanduiding.nummeraanduidingstatus, nummeraanduiding.typeadresseerbaarobject, nummeraanduiding.gerelateerdeopenbareruimte, nummeraanduiding.gerelateerdewoonplaats, nummeraanduiding.begindatum, nummeraanduiding.einddatum FROM nummeraanduiding WHERE (((nummeraanduiding.begindatum <= ('now'::text)::date) AND (nummeraanduiding.einddatum >= ('now'::text)::date)) AND ((nummeraanduiding.aanduidingrecordinactief)::text = 'N'::text));

CREATE VIEW nummeraanduidingactueelbestaand AS
    SELECT nummeraanduiding.identificatie, nummeraanduiding.aanduidingrecordinactief, nummeraanduiding.aanduidingrecordcorrectie, nummeraanduiding.officieel, nummeraanduiding.inonderzoek, nummeraanduiding.documentnummer, nummeraanduiding.documentdatum, nummeraanduiding.huisnummer, nummeraanduiding.huisletter, nummeraanduiding.huisnummertoevoeging, nummeraanduiding.postcode, nummeraanduiding.nummeraanduidingstatus, nummeraanduiding.typeadresseerbaarobject, nummeraanduiding.gerelateerdeopenbareruimte, nummeraanduiding.gerelateerdewoonplaats, nummeraanduiding.begindatum, nummeraanduiding.einddatum FROM nummeraanduiding WHERE ((((nummeraanduiding.begindatum <= ('now'::text)::date) AND (nummeraanduiding.einddatum >= ('now'::text)::date)) AND ((nummeraanduiding.aanduidingrecordinactief)::text = 'N'::text)) AND ((nummeraanduiding.nummeraanduidingstatus)::text <> 'Naamgeving ingetrokken'::text));
*/
DROP VIEW IF EXISTS openbareruimteactueel;
DROP VIEW IF EXISTS openbareruimteactueelbestaand;

DROP TABLE IF EXISTS openbareruimte;
CREATE TABLE openbareruimte (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    openbareruimtenaam character varying(80),
    openbareruimtestatus character varying(80),
    openbareruimtetype character varying(40),
    gerelateerdewoonplaats numeric(16,0),
    verkorteopenbareruimtenaam character varying(80),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    PRIMARY KEY (id)
);
/*
CREATE VIEW openbareruimteactueel AS
    SELECT openbareruimte.identificatie, openbareruimte.aanduidingrecordinactief, openbareruimte.aanduidingrecordcorrectie, openbareruimte.officieel, openbareruimte.inonderzoek, openbareruimte.documentnummer, openbareruimte.documentdatum, openbareruimte.openbareruimtenaam, openbareruimte.openbareruimtestatus, openbareruimte.openbareruimtetype, openbareruimte.gerelateerdewoonplaats, openbareruimte.verkorteopenbareruimtenaam, openbareruimte.begindatum, openbareruimte.einddatum FROM openbareruimte WHERE (((openbareruimte.begindatum <= ('now'::text)::date) AND (openbareruimte.einddatum >= ('now'::text)::date)) AND ((openbareruimte.aanduidingrecordinactief)::text = 'N'::text));

CREATE VIEW openbareruimteactueelbestaand AS
    SELECT openbareruimte.identificatie, openbareruimte.aanduidingrecordinactief, openbareruimte.aanduidingrecordcorrectie, openbareruimte.officieel, openbareruimte.inonderzoek, openbareruimte.documentnummer, openbareruimte.documentdatum, openbareruimte.openbareruimtenaam, openbareruimte.openbareruimtestatus, openbareruimte.openbareruimtetype, openbareruimte.gerelateerdewoonplaats, openbareruimte.verkorteopenbareruimtenaam, openbareruimte.begindatum, openbareruimte.einddatum FROM openbareruimte WHERE ((((openbareruimte.begindatum <= ('now'::text)::date) AND (openbareruimte.einddatum >= ('now'::text)::date)) AND ((openbareruimte.aanduidingrecordinactief)::text = 'N'::text)) AND ((openbareruimte.openbareruimtestatus)::text <> 'Naamgeving ingetrokken'::text));
*/
DROP VIEW IF EXISTS pandactueel;
DROP VIEW IF EXISTS pandactueelbestaand;

DROP TABLE IF EXISTS pand;
CREATE TABLE pand (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    pandstatus character varying(80),
    bouwjaar numeric(4,0),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    geovlak geometry,
    PRIMARY KEY (id),
    CONSTRAINT enforce_dims_geometrie CHECK ((st_ndims(geovlak) = 3)),
    CONSTRAINT enforce_geotype_geometrie CHECK (((geometrytype(geovlak) = 'POLYGON'::text) OR (geovlak IS NULL))),
    CONSTRAINT enforce_srid_geometrie CHECK ((st_srid(geovlak) = 28992))
);

/*
CREATE VIEW pandactueel AS
    SELECT (pand.oid)::character varying AS oid, pand.identificatie, pand.aanduidingrecordinactief, pand.aanduidingrecordcorrectie, pand.officieel, pand.inonderzoek, pand.documentnummer, pand.documentdatum, pand.pandstatus, pand.bouwjaar, pand.begindatum, pand.einddatum, pand.geometrie FROM pand WHERE (((pand.begindatum <= ('now'::text)::date) AND (pand.einddatum >= ('now'::text)::date)) AND ((pand.aanduidingrecordinactief)::text = 'N'::text));

CREATE VIEW pandactueelbestaand AS
    SELECT (pand.oid)::character varying AS oid, pand.identificatie, pand.aanduidingrecordinactief, pand.aanduidingrecordcorrectie, pand.officieel, pand.inonderzoek, pand.documentnummer, pand.documentdatum, pand.pandstatus, pand.bouwjaar, pand.begindatum, pand.einddatum, pand.geometrie FROM pand WHERE (((((pand.begindatum <= ('now'::text)::date) AND (pand.einddatum >= ('now'::text)::date)) AND ((pand.aanduidingrecordinactief)::text = 'N'::text)) AND ((pand.pandstatus)::text <> 'Niet gerealiseerd pand'::text)) AND ((pand.pandstatus)::text <> 'Pand gesloopt'::text));
*/
DROP VIEW IF EXISTS standplaatsactueel;
DROP VIEW IF EXISTS standplaatsactueelbestaand;

DROP TABLE IF EXISTS standplaats;
CREATE TABLE standplaats (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    hoofdadres numeric(16,0),
    standplaatsstatus character varying(80),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    geovlak geometry,
    PRIMARY KEY (id),
    CONSTRAINT enforce_dims_geometrie CHECK ((st_ndims(geovlak) = 3)),
    CONSTRAINT enforce_geotype_geometrie CHECK (((geometrytype(geovlak) = 'POLYGON'::text) OR (geovlak IS NULL))),
    CONSTRAINT enforce_srid_geometrie CHECK ((st_srid(geovlak) = 28992))
);
/*
CREATE VIEW standplaatsactueel AS
    SELECT (standplaats.oid)::character varying AS oid, standplaats.identificatie, standplaats.aanduidingrecordinactief, standplaats.aanduidingrecordcorrectie, standplaats.officieel, standplaats.inonderzoek, standplaats.documentnummer, standplaats.documentdatum, standplaats.hoofdadres, standplaats.standplaatsstatus, standplaats.begindatum, standplaats.einddatum, standplaats.geovlak FROM standplaats WHERE (((standplaats.begindatum <= ('now'::text)::date) AND (standplaats.einddatum >= ('now'::text)::date)) AND ((standplaats.aanduidingrecordinactief)::text = 'N'::text));

CREATE VIEW standplaatsactueelbestaand AS
    SELECT (standplaats.oid)::character varying AS oid, standplaats.identificatie, standplaats.aanduidingrecordinactief, standplaats.aanduidingrecordcorrectie, standplaats.officieel, standplaats.inonderzoek, standplaats.documentnummer, standplaats.documentdatum, standplaats.hoofdadres, standplaats.standplaatsstatus, standplaats.begindatum, standplaats.einddatum, standplaats.geovlak FROM standplaats WHERE ((((standplaats.begindatum <= ('now'::text)::date) AND (standplaats.einddatum >= ('now'::text)::date)) AND ((standplaats.aanduidingrecordinactief)::text = 'N'::text)) AND ((standplaats.standplaatsstatus)::text <> 'Plaats ingetrokken'::text));
*/
DROP VIEW IF EXISTS verblijfsobjectactueel;
DROP VIEW IF EXISTS verblijfsobjectactueelbestaand;

DROP TABLE IF EXISTS verblijfsobject;
CREATE TABLE verblijfsobject (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    hoofdadres numeric(16,0),
--    gerelateerdpand numeric(16,0),   IS RELATIE (multivalued)
--    gebruiksdoel character varying(50),      IS RELATIE (multivalued)
    verblijfsobjectstatus character varying(80),
    oppervlakteverblijfsobject numeric(6,0),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    geopunt geometry,
    geovlak geometry,
    PRIMARY KEY (id),
    CONSTRAINT enforce_dims_punt CHECK ((st_ndims(geopunt) = 3)),
    CONSTRAINT enforce_geotype_punt CHECK (((geometrytype(geopunt) = 'POINT'::text) OR (geopunt IS NULL))),
    CONSTRAINT enforce_srid_punt CHECK ((st_srid(geopunt) = 28992)),

    CONSTRAINT enforce_dims_vlak CHECK ((st_ndims(geovlak) = 3)),
    CONSTRAINT enforce_geotype_vlak CHECK (((geometrytype(geovlak) = 'POLYGON'::text) OR (geovlak IS NULL))),
    CONSTRAINT enforce_srid_vlak CHECK ((st_srid(geovlak) = 28992))
);

/*
CREATE VIEW verblijfsobjectactueel AS
    SELECT (verblijfsobject.oid)::character varying AS oid, verblijfsobject.identificatie, verblijfsobject.aanduidingrecordinactief, verblijfsobject.aanduidingrecordcorrectie, verblijfsobject.officieel, verblijfsobject.inonderzoek, verblijfsobject.documentnummer, verblijfsobject.documentdatum, verblijfsobject.hoofdadres, verblijfsobject.verblijfsobjectstatus, verblijfsobject.oppervlakteverblijfsobject, verblijfsobject.begindatum, verblijfsobject.einddatum, verblijfsobject.geopunt FROM verblijfsobject WHERE (((verblijfsobject.begindatum <= ('now'::text)::date) AND (verblijfsobject.einddatum >= ('now'::text)::date)) AND ((verblijfsobject.aanduidingrecordinactief)::text = 'N'::text));

CREATE VIEW verblijfsobjectactueelbestaand AS
    SELECT (verblijfsobject.oid)::character varying AS oid, verblijfsobject.identificatie, verblijfsobject.aanduidingrecordinactief, verblijfsobject.aanduidingrecordcorrectie, verblijfsobject.officieel, verblijfsobject.inonderzoek, verblijfsobject.documentnummer, verblijfsobject.documentdatum, verblijfsobject.hoofdadres, verblijfsobject.verblijfsobjectstatus, verblijfsobject.oppervlakteverblijfsobject, verblijfsobject.begindatum, verblijfsobject.einddatum, verblijfsobject.geopunt FROM verblijfsobject WHERE (((((verblijfsobject.begindatum <= ('now'::text)::date) AND (verblijfsobject.einddatum >= ('now'::text)::date)) AND ((verblijfsobject.aanduidingrecordinactief)::text = 'N'::text)) AND ((verblijfsobject.verblijfsobjectstatus)::text <> 'Niet gerealiseerd verblijfsobject'::text)) AND ((verblijfsobject.verblijfsobjectstatus)::text <> 'Verblijfsobject ingetrokken'::text));
*/
DROP TABLE IF EXISTS verblijfsobjectgebruiksdoel;

CREATE TABLE verblijfsobjectgebruiksdoel (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    begindatum timestamp without time zone,
    gebruiksdoelverblijfsobject character varying(50),
    PRIMARY KEY (id)
);


DROP TABLE IF EXISTS verblijfsobjectpand;

CREATE TABLE verblijfsobjectpand (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    begindatum timestamp without time zone,
    gerelateerdpand numeric(16,0),
    PRIMARY KEY (id)
);


DROP TABLE IF EXISTS woonplaats;
CREATE TABLE woonplaats (
    id serial,
    identificatie numeric(16,0),
    aanduidingrecordinactief boolean,
    aanduidingrecordcorrectie integer,
    officieel boolean,
    inonderzoek boolean,
    documentnummer character varying(20),
    documentdatum date,
    woonplaatsnaam character varying(80),
    woonplaatsstatus character varying(80),
    begindatum timestamp without time zone,
    einddatum timestamp without time zone,
    geovlak geometry,
    PRIMARY KEY (id),
    CONSTRAINT enforce_dims_geometrie CHECK ((st_ndims(geovlak) = 2)),
    CONSTRAINT enforce_geotype_geometrie CHECK (((geometrytype(geovlak) = 'MULTIPOLYGON'::text) OR (geovlak IS NULL))),
    CONSTRAINT enforce_srid_geometrie CHECK ((st_srid(geovlak) = 28992))
)WITH (
  OIDS=TRUE
);

-- Maak geometrie indexen
CREATE INDEX ligplaats_geom_idx ON ligplaats USING gist (geovlak);
CREATE INDEX pand_geom_idx ON pand USING gist (geovlak);
CREATE INDEX standplaats_geom_idx ON standplaats USING gist (geovlak);
CREATE INDEX verblijfsobject_punt_idx ON verblijfsobject USING gist (geopunt);
CREATE INDEX verblijfsobject_vlak_idx ON verblijfsobject USING gist (geovlak);
CREATE INDEX woonplaats_vlak_idx ON woonplaats USING gist (geovlak);

-- Unieke key indexen
CREATE UNIQUE INDEX ligplaats_idx ON ligplaats USING btree (identificatie,aanduidingrecordinactief,einddatum);
CREATE UNIQUE INDEX standplaats_idx ON standplaats USING btree (identificatie,aanduidingrecordinactief,einddatum);
CREATE UNIQUE INDEX verblijfsobject_idx ON verblijfsobject USING btree (identificatie,aanduidingrecordinactief,einddatum);
CREATE UNIQUE INDEX pand_idx ON pand USING btree (identificatie,aanduidingrecordinactief,einddatum);
-- met nummeraanduiding lijkt een probleem als unieke index
-- CREATE UNIQUE INDEX nummeraanduiding_idx ON nummeraanduiding USING btree (identificatie,aanduidingrecordinactief,einddatum);
CREATE  INDEX nummeraanduiding_idx ON nummeraanduiding USING btree (identificatie,aanduidingrecordinactief,einddatum);
CREATE UNIQUE INDEX openbareruimte_idx ON openbareruimte USING btree (identificatie,aanduidingrecordinactief,einddatum);
CREATE UNIQUE INDEX woonplaats_idx ON woonplaats USING btree (identificatie,aanduidingrecordinactief,einddatum);

-- Overige indexen
CREATE INDEX nummeraanduiding_postcode ON nummeraanduiding USING btree (postcode);
CREATE INDEX openbareruimte_naam ON openbareruimte USING btree (openbareruimtenaam);

--CREATE INDEX adresseerbaarobjectnevenadreskey ON adresseerbaarobjectnevenadres USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum, nevenadres);
--CREATE UNIQUE INDEX ligplaats_key ON ligplaats USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE UNIQUE INDEX nummeraanduiding_key ON nummeraanduiding USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE UNIQUE INDEX openbareruimte_key ON openbareruimte USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE UNIQUE INDEX pand_key ON pand USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE UNIQUE INDEX standplaats_key ON standplaats USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE INDEX verblijfsobjectgebruiksdoelkey ON verblijfsobjectgebruiksdoel USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum, gebruiksdoelverblijfsobject);
--CREATE UNIQUE INDEX woonplaatskey ON woonplaats USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE UNIQUE INDEX verblijfsobject_key ON verblijfsobject USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum);
--CREATE INDEX verblijfsobjectpandkey ON verblijfsobjectpand USING btree (identificatie, aanduidingrecordinactief, aanduidingrecordcorrectie, begindatum, gerelateerdpand);

DROP TABLE IF EXISTS gemeente_woonplaats;
CREATE TABLE gemeente_woonplaats (
	id serial,
	woonplaatsnaam character varying(80),
	woonplaatscode numeric(4),
	begindatum_woonplaats date,
	einddatum_woonplaats date,
	gemeentenaam character varying(80),
	gemeentecode numeric(4),
	begindatum_gemeente date,
	aansluitdatum_gemeente date,
	bijzonderheden text,
	gemeentecode_nieuw numeric(4),
	einddatum_gemeente date,
	behandeld character varying(1),
	PRIMARY KEY (id)
);

DROP TABLE IF EXISTS gemeente_provincie;
CREATE TABLE gemeente_provincie (
	id serial,
	gemeentecode numeric(4),
	gemeentenaam character varying(80),
	provinciecode numeric(4),
	provincienaam character varying(80),
	PRIMARY KEY (id)
);