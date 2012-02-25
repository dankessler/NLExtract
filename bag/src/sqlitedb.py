__author__ = "Milo van der Linden"
__date__ = "$Feb 24, 2012 00:00:01 AM$"

"""
 Naam:         sqlite.py
 Omschrijving: Generieke functies voor databasegebruik binnen BAG Extract+
 Auteur:       Milo van der Linden

 Versie:       1.0
               - Deze database klasse is vanaf heden specifiek voor sqlite/spatialite
 Datum:        24 feb 2012
"""
import sys
import os
import logging

try:
    import sqlite3
except:
    logging.critical("Python sqlite3 is niet geinstalleerd")
    sys.exit()

from bagconfig import BAGConfig

class Database:

    def __init__(self):
        # Lees de configuratie uit globaal BAGConfig object
        self.config = BAGConfig.config

    def initialiseer(self, bestand):
        logging.info('Probeer te verbinden...')
        self.verbind(True)

        logging.info('database script uitvoeren...')
        try:
            script = open(bestand, 'r').read()
            self.cursor.executescript(script)
            self.connection.commit()
            logging.info('script is uitgevoerd')
        except sqlite3.DatabaseError:
            e = sys.exc_info()[1]
            logging.critical("ik krijg deze fout '%s' uit het bestand '%s'" % (str(e), str(bestand)))
            sys.exit()

    def maak_database(self):
        db_script = os.path.realpath(BAGConfig.config.bagextract_home + '/db/script/sqlite/bag-db.sql')
        logging.info("alle database tabellen weggooien en opnieuw aanmaken...")
        self.initialiseer(db_script)

    def verbind(self, initdb=False):
        try:
            self.connection = sqlite3.connect(":memory:")
            self.cursor = self.connection.cursor()

            if initdb:
                self.maak_schema()

            self.zet_schema()
            logging.info("verbonden met de database %s" % (self.config.database))
        except Exception:
            e = sys.exc_info()[1]
            #TODO: Deze code is niet zuiver. De werkelijke exception moet worden vermeld, of er
            # moet expliciet op een verbindingsfout worden gezocht
            logging.critical("ik kan geen verbinding maken met database '%s' %s" % (self.config.database,str(e)))
            sys.exit()

    def maak_schema(self):
        # Public schema: no further action required
        if self.config.schema != 'public':
            # A specific schema is required create it and set the search path
            self.uitvoeren('''DROP SCHEMA IF EXISTS %s CASCADE;''' % self.config.schema)
            self.uitvoeren('''CREATE SCHEMA %s;''' % self.config.schema)
            self.connection.commit()

    def zet_schema(self):
        # Non-public schema set search path
        if self.config.schema != 'public':
            # Always set search path to our schema
            self.uitvoeren('SET search_path TO %s,public' % self.config.schema)
            self.connection.commit()

    def uitvoeren(self, sql, parameters=None):
        try:
            if parameters:
                self.cursor.execute(sql, parameters)
            else:
                self.cursor.execute(sql)
        except Exception:
            e = sys.exc_info()[1]
            logging.error("fout %s voor query: %s met parameters %s" % (str(e), str(sql), str(parameters)))
            return self.cursor.rowcount

    def file_uitvoeren(self, sqlfile):
        try:
            logging.info("SQL van file = %s uitvoeren..." % sqlfile)
            self.verbind()
            f = open(sqlfile, 'r')
            sql = f.read()
            self.uitvoeren(sql)
            self.connection.commit()
            f.close()
            logging.info("SQL uitgevoerd OK")
        except (Exception):
            e = sys.exc_info()[1]
            logging.critical("ik kan dit script niet uitvoeren vanwege deze fout: %s" % (str(e)))
