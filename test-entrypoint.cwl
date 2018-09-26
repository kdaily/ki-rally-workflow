#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement

inputs:
  - id: inputfile
    type: File

steps:  
  coreWorkflow:
    run: sample-workflow.cwl
    in:
      - id: myfile
        source: "#inputfile"
    out:
      - id: stdout

outputs: []
