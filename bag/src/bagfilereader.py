__author__ = "Milo van der Linden"
__date__ = "$Jun 11, 2011 3:46:27 PM$"

"""
 Naam:         BAGFileReader.py
 Omschrijving: Inlezen van BAG-gerelateerde files of directories

 Auteur:       Milo van der Linden Just van den Broecke

 Versie:       1.0
               - basis versie
 Datum:        22 december 2011


 OpenGeoGroep.nl
"""
import os
import logging

try:
    import zipfile
except:
    logging.critical("Python zipfile is vereist")
    sys.exit()

from processor import Processor
from xml.dom.minidom import parse
import csv


#from lxml import etree

#Onderstaand try/catch blok is vereist voor python2/python3 portabiliteit
try:
    from cStringIO import StringIO
except:
    try:
        from StringIO import StringIO
    except:
        from io import StringIO


class BAGFileReader:
    def __init__(self, file):
        self.file = file
        self.init = True
        self.processor = Processor()
        self.fileCount = 0
        self.recordCount = 0

    def process(self):
        Log.log.info("process file=" + self.file)
        if not os.path.exists(self.file):
            logging.critical("ik kan BAG-bestand of -directory: '" + self.file + "' ech niet vinden")
            return

        # TODO: Verwerk een directory
        if os.path.isdir(self.file) == True:
            self.readDir()
        elif zipfile.is_zipfile(self.file):
            self.zip = zipfile.ZipFile(self.file, "r")
            self.readzipfile()
        else:
            zipfilename = os.path.basename(self.file).split('.')
            ext = zipfilename[1]
            if ext == 'xml':
                xml = self.parseXML(self.file)
                self.processXML(zipfilename[0],xml)
            if ext == 'csv':
                fileobject = open(self.file, "rb")
                self.processCSV(zipfilename[0], fileobject)

    def readDir(self):
        for each in os.listdir(self.file):
            _file = os.path.join(self.file, each)
            if zipfile.is_zipfile(_file):
                self.zip = zipfile.ZipFile(_file, "r")
                self.readzipfile()
            else:
                if os.path.isdir(_file) != True:
                    zipfilename = each.split('.')
                    if len(zipfilename) == 2:
                        ext = zipfilename[1]
                        if ext == 'xml':
                            Log.log.info("==> XML File: " + each)
                            xml = self.parseXML(_file)
                            self.processXML(zipfilename[0],xml)
                        if ext == 'csv':
                            Log.log.info("==> CSV File: " + each)
                            fileobject = open(_file, "rb")
                            self.processCSV(zipfilename[0],fileobject)

    def readzipfile(self):
        tzip = self.zip
        logging.info("readzipfile content=" + str(tzip.namelist()))
        for naam in tzip.namelist():
            ext = naam.split('.')
            logging.info("readzipfile: " + naam)
            if len(ext) == 2:
                if ext[1] == 'xml':
                    xml = self.parseXML(StringIO(tzip.read(naam)))
                    #xml = etree.parse (StringIO(tzip.read(naam)))
                    self.processXML(naam, xml)
                elif ext[1] == 'zip':
                    self.readzipstring(StringIO(tzip.read(naam)))
                elif ext[1] == 'csv':
                    Log.log.info(naam)
                    fileobject = StringIO(tzip.read(naam))
                    self.processCSV(naam, fileobject)
                else:
                    Log.log.info("Negeer: " + naam)

    def readzipstring(self,naam):
        # logging.info("readzipstring naam=" + naam)
        tzip = zipfile.ZipFile(naam, "r")
        # logging.info("readzipstring naam=" + tzip.getinfo().filename)

        for nested in tzip.namelist():
            logging.info("readzipstring: " + nested)
            ext = nested.split('.')
            if len(ext) == 2:
                if ext[1] == 'xml':
                    xml = self.parseXML(StringIO(tzip.read(nested)))
                    #xml = etree.parse(StringIO(tzip.read(nested)))
                    self.processXML(nested, xml)
                elif ext[1] == 'csv':
                    #Log.log.info(nested)
                    fileobject = StringIO(tzip.read(nested))
                    self.processCSV(nested, fileobject)
                elif ext[1] == 'zip':
                    #Log.log.info(nested)
                    self.readzipstring(StringIO(tzip.read(nested)))
                else:
                    logging.info("Negeer: " + nested)

    def parseXML(self,naam):
        #Log.log.startTimer("parseXML")
        xml = parse(naam)
        #Log.log.endTimer("parseXML")
        return xml

    def processXML(self,naam, xml):
        logging.info("processXML: " + naam)
        xmldoc = xml.documentElement
        #xmldoc = xml.getroot()
        #de orm bepaalt of het een extract of een mutatie is
        self.processor.processDOM(xmldoc)
        #Log.log.info(document)
        xml.unlink()

    def processCSV(self,naam, fileobject):
        logging.info(naam)
        # TODO: zorg voor de verwerking van het geparste csv bestand
        # Maak er gemeente_woonplaats objecten van overeenkomstig de nieuwe
        # tabel woonplaats_gemeente
        myReader = csv.reader(fileobject, delimiter=';', quoting=csv.QUOTE_NONE)
        self.processor.processCSV(myReader)
