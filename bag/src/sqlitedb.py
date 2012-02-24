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
import sqlite3
from logging import Log
from bagconfig import BAGConfig

class Database:

    def __init__(self):
        # Lees de configuratie uit globaal BAGConfig object
        self.config = BAGConfig.config

    def initialiseer(self, bestand):
        Log.log.info('Probeer te verbinden...')
        self.verbind(True)

        Log.log.info('database script uitvoeren...')
        try:
            script = open(bestand, 'r').read()
            self.cursor.executescript(script)
            self.connection.commit()
            Log.log.info('script is uitgevoerd')
        except sqlite3.DatabaseError:
            e = sys.exc_info()[1]
            Log.log.fatal("ik krijg deze fout '%s' uit het bestand '%s'" % (str(e), str(bestand)))

    def verbind(self, initdb=False):
        try:
            self.connection = sqlite3.connect(":memory:")
            self.cursor = self.connection.cursor()

            if initdb:
                self.maak_schema()

            self.zet_schema()
            Log.log.info("verbonden met de database %s" % (self.config.database))
        except Exception:
            e = sys.exc_info()[1]
            #TODO: Deze code is niet zuiver. De werkelijke exception moet worden vermeld, of er
            # moet expliciet op een verbindingsfout worden gezocht
            Log.log.fatal("ik kan geen verbinding maken met database '%s' %s" % (self.config.database,str(e)))

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
            Log.log.error("fout %s voor query: %s met parameters %s" % (str(e), str(sql), str(parameters)))
            return self.cursor.rowcount

    def file_uitvoeren(self, sqlfile):
        try:
            Log.log.info("SQL van file = %s uitvoeren..." % sqlfile)
            self.verbind()
            f = open(sqlfile, 'r')
            sql = f.read()
            self.uitvoeren(sql)
            self.connection.commit()
            f.close()
            Log.log.info("SQL uitgevoerd OK")
        except (Exception):
            e = sys.exc_info()[1]
            Log.log.fatal("ik kan dit script niet uitvoeren vanwege deze fout: %s" % (str(e)))
