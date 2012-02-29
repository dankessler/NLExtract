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
        BAGConfig.logger.debug("postgresdb.initialiseer()")
        self.verbind()
        self.zet_schema()

        try:
            BAGConfig.logger.info("database script wordt gelezen")
            script = open(bestand, 'r').read()
            self.cursor.execute(script)
            self.connection.commit()
            BAGConfig.logger.info("database script uitgevoerd")
        except psycopg2.DatabaseError:
            e = sys.exc_info()[1]
            BAGConfig.logger.critical("'%s' tijdens het inlezen van '%s'" % (str(e), str(bestand)))
            sys.exit()


    def maak_database(self):
        BAGConfig.logger.debug("postgresdb.maak_database()")
        db_script = os.path.realpath(BAGConfig.config.bagextract_home + '/db/script/bag-db.sql')
        #
        self.initialiseer(db_script)

    def verbind(self):
        BAGConfig.logger.debug("postgresdb.verbind()")
        try:

            BAGConfig.logger.info('Verbinding maken met ' + self.config.database)
            self.connection = psycopg2.connect("dbname='%s' user='%s' host='%s' password='%s'" % (self.config.database,
                                                                                                  self.config.user,
                                                                                                  self.config.host,
                                                                                                 self.config.password))
            self.cursor = self.connection.cursor()
            BAGConfig.logger.info("Verbonden")

        except Exception:

            e = sys.exc_info()[1]
            BAGConfig.logger.critical("Verbinden mislukt: %s" % (str(e)))
            #TODO: Bepalen of hier connecties en cursors moeten worden gesloten
            sys.exit()

    def zet_schema(self):
        BAGConfig.logger.debug("postgresdb.zet_schema()")
        if self.config.schema != 'public':
            try:
                self.cursor.execute('SET search_path TO %s,public' % self.config.schema)

            except Exception:

                self.connection.rollback()
                BAGConfig.logger.warning('Schema %s bestaat nog niet en wordt gemaakt' % self.config.schema)

                try:

                    self.cursor.execute('CREATE SCHEMA %s;' % self.config.schema)
                    self.cursor.execute('SET search_path TO %s,public' % self.config.schema)
                    BAGConfig.logger.info("Schema %s is aangemaakt" % self.config.schema)

                except Exception:

                    self.connection.rollback()
                    e = sys.exc_info()[1]
                    BAGConfig.logger.error("Schema %s kon niet worden gemaakt: %s" % (self.config.schema,str(e)))

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
