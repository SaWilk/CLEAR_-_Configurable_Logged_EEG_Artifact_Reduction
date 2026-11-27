\#Paper structure (see JOSSS Example Paper: https://joss.readthedocs.io/en/latest/example\_paper.html); Citation style https://pandoc.org/MANUAL.html#extension-citations; example: Blah blah \[@doe99; @smith2000; @smith2004].

title: 'Clear: EEG Preprocessing Pipeline Configurable, Logged EEG Artifact Reduction '
tags:

Matlab

EEGLab

EEG preprocessing
authors:

name:  
orcid: 0000-0000-0000-0000
equal-contrib: true
affiliation: "1, 2" # (Multiple affiliations must be quoted)
affiliations:

name:
index:
ror:

date:
bibliography: paper.bib



Summary: description of functionality and Purpose for diverse, non-specialist audience

* EEG preprocessing for Task and resting state data
* BIDS Format, filtering, bad channel rejection and Interpolation, ICA, artifact rejection, epoching
* user-friendly and adaptive to research focus (single-Trial compatible, ERP, time frequency compatible)





Statement of Need: Research Purpose and context of related work; Problem solution Definition, target audience and relation to other work

* Preprocessing Pipeline that be harmonized across different sites, Analysis focus and research Question (within our RU, but also across working Groups)
* Still flexible to adjust Settings and Options for optimal preprocessing choices
* Detailed README, example data, explanations, tutorials and tests to check optimal usage
* Autmated with summary functions and detailed log-files including warnings and checks





State of the field: Comparison to other commonly-used packages, build vs. contribute justification and why alternatives are insufficient

* not specific for a Task or target group
* flexible for different Analysis types
* similar to CLEAR but with more options for settings to improve harmonized usage across projects





Software design: weighing trade-offs, Chosen design/architecture and connection to research; demonstrate meaningful design-thinking rather than code structure description

* Config file user-friendly 
* step-wise Architecture and data storage for maximal Control and data Quality checks
* Default settings and their Purpose
* MATLAB and toolboxes, BVR specific





Research impact Statement: evidence of realizied Impact (publications, external use, integrations) or credible near-term significance (community readiness Signals, benchmarks, reproducible materials)

* RU
* working Groups
* potential for more groups



Mention (if applicable) a representative set of past or ongoing research projects using the software and recent scholarly publications enabled by it.

Preregistrations RU?





Citations





Figures





AI usage disclosure

* Code Adjustments and review, Always critically reviewed and adjusted





Acknowledgements of any financial support

RU funding





References

