__author__ = "Matthijs van der Deijl"
__date__ = "$Dec 09, 2009 00:00:01 AM$"

"""
 Naam:         postgresdb.py
 Omschrijving: Generieke functies voor databasegebruik binnen BAG Extract+
 Auteur:       Milo van der Linden, Just van den Broecke, Matthijs van der Deijl (originele versie)

 Versie:       1.0
               - Deze database klasse is vanaf heden specifiek voor postgres/postgis
 Datum:        29 dec 2011
"""
import os
import sys
from bagconfig import BAGConfig
try:
   import psycopg2
except:
    BAGConfig.logger.critical("Python psycopg2 is niet geinstalleerd")
    sys.exit()



class Database:

    def __init__(self):
        # Lees de configuratie uit globaal BAGConfig object
        self.config = BAGConfig.config

    def initialiseer(self, bestand):
        BAGConfig.logger.info('Database verbinding wordt gemaakt')
        self.verbind(True)

        try:
            script = open(bestand, 'r').read()
            self.cursor.execute(script)
            self.connection.commit()

        except psycopg2.DatabaseError:
            e = sys.exc_info()[1]
            BAGConfig.logger.critical("'%s' tijdens het inlezen van '%s'" % (str(e), str(bestand)))
            sys.exit()

    def maak_database(self):
        db_script = os.path.realpath(BAGConfig.config.bagextract_home + '/db/script/bag-db.sql')
        BAGConfig.logger.info("De database wordt opnieuw ingericht")
        self.initialiseer(db_script)

    def verbind(self, initdb=False):
        try:
            self.connection = psycopg2.connect("dbname='%s' user='%s' host='%s' password='%s'" % (self.config.database,
                                                                                                  self.config.user,
                                                                                                  self.config.host,
                                                                                                 self.config.password))
            self.cursor = self.connection.cursor()

            if initdb:
                self.maak_schema()

            self.zet_schema()
            BAGConfig.logger.info("verbonden met database %s" % (self.config.database))
        except Exception:
            e = sys.exc_info()[1]
            BAGConfig.logger.critical("ik kan geen verbinding maken met database '%s' %s" % (self.config.database,str(e)))
            #TODO: Bepalen of hier connecties en cursors moeten worden gesloten
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
            BAGConfig.logger.error("fout %s voor query: %s met parameters %s" % (str(e), str(sql), str(parameters)))
            return self.cursor.rowcount

    def file_uitvoeren(self, sqlfile):
        try:
            BAGConfig.logger.info("SQL van file = %s uitvoeren..." % sqlfile)
            self.verbind()
            f = open(sqlfile, 'r')
            sql = f.read()
            self.uitvoeren(sql)
            self.connection.commit()
            f.close()
            BAGConfig.logger.info("SQL uitgevoerd OK")
        except (Exception):
            e = sys.exc_info()[1]
            BAGConfig.logger.fatal("ik kan dit script niet uitvoeren vanwege deze fout: %s" % (str(e)))
