from datetime import date
from datetime import datetime
from os.path import expanduser
import json
import neovim
import os.path
import random

# This is a basic configuration that will be serialized to the configuration
# file if there is no configuration file detected.
EXAMPLE_CONFIGURATION = {
    "heap-sort": {
        "description": "A description.",
        "weight": 1
    }
}

# The date/time format that will be used for putting the start time and end
# time in the header of the kata exercizes.
DATETIME_FORMAT = '%b %d %Y %I:%M%p'

# The template to start the user with at the beginning of a kata. Just the
# basics. This would be better externalized from the plugin.
PYTHON_TEMPLATE = """#! /usr/bin/env python
#
# %s
#
# Start Time: %s
# End Time  :
# Duration  :
#

class %s(object):
    def __init__(self):
        pass

"""

# TODO: Pull this from a setting.
kataRootDir = os.path.join(expanduser("~"), "Developer", "jacob.simpson", "CodeKata")

@neovim.plugin
class Main(object):
    def __init__(self, vim):
        self.vim = vim

    @neovim.command('EndKata', sync=True)
    def endKata(self):
        self.vim.command('echo "%s"' % "All done.")
        if self.kataBuffer:
            startDateTime = datetime.strptime(self.kataBuffer[4][14:], DATETIME_FORMAT)
            endDateTime = datetime.now()
            self.kataBuffer[5] += " " + endDateTime.strftime(DATETIME_FORMAT)
            self.kataBuffer[6] += " " + str(endDateTime - startDateTime)

    @neovim.command('BeginKata', sync=True)
    def beginKata(self):
        kataConfig = self.loadConfiguration()

        selectedConfig = self.selectItem(kataConfig)

        kataFile = self.createKataFile(selectedConfig)

        self.vim.command('e %s' %kataFile)
        self.kataBuffer = self.vim.current.buffer

    def createKataFile(self, selectedConfig):
        if not os.path.exists(kataRootDir):
            os.makedirs(os.path.join(kataRootDir))

        kataDir = os.path.join(kataRootDir, date.today().strftime("%Y-%m-%d-") + selectedConfig['name'])
        if not os.path.exists(kataDir):
            os.makedirs(kataDir)

        self.vim.command('cd %s' % kataDir)

        kataFile = os.path.join(kataDir, "%s.py" % selectedConfig['name'])
        if not os.path.exists(kataFile):
            with open(kataFile, "w") as f:
                f.write(PYTHON_TEMPLATE % (
                    selectedConfig['description'] or 'No description, you are on your own.',
                    datetime.now().strftime(DATETIME_FORMAT),
                    selectedConfig['classname'] or 'KataClass'
                ))
        return kataFile

    def loadConfiguration(self):
        kataConfigFile = os.path.join(expanduser("~"), ".code-kata-problems.json")

        if not os.path.exists(kataConfigFile):
            with open(kataConfigFile, "w") as f:
                f.write(json.dumps(EXAMPLE_CONFIGURATION, indent = 4, sort_keys = True))

        with open(kataConfigFile) as f:
            return json.loads(f.read())

    def selectItem(self, kataConfig):
        # To account for the weight in randomly selecting, I'm going to sum the
        # weights and construct a kind of cumulative interval.
        intervals = []
        sum = 0
        for name, value in kataConfig.iteritems():
            sum += value.get('weight') or 1
            intervals.append((sum, name))
        selection = random.randint(0, sum-1)
        for weight, name in intervals:
            if selection < weight:
                selectedConfig = kataConfig[name]
                selectedConfig['name'] = name
                return selectedConfig

