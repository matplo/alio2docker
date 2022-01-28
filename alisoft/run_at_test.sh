#!/bin/bash

if [ ! -f ./AO2D-tutorial.root ]; then
    curl -o ./AO2D-tutorial.root http://alimonitor.cern.ch/train-workdir/testdata/LFN/alice/data/2015/LHC15o/000245064/pass5_lowIR/PWGZZ/Run3_Conversion/242_20211215-1006_child_1/AOD/041/AO2D.root
fi

o2-analysistutorial-histograms --aod-file AO2D-tutorial.root

