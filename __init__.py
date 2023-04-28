# AGPLv3

from . import EstimatedEnergy

def getMetaData():
    return {}

def register(app):
    return {
        "extension": EstimatedEnergy.EstimatedEnergy()
    }
