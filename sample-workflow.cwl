#!/usr/bin/env cwl-runner
#
#  This sample workflow gets sprints for a rally
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: [bootstrap-rally-sprint, get-sprints]

requirements:
  - class: InlineJavascriptRequirement

hints:
  DockerRequirement:
      dockerPull: dailyk/hbgdki-bootstrap:latest

inputs:
  - id: myfile
    type: File
    inputBinding:
      loadContents: true
      position: 0
      prefix: --rallyNumber
      valueFrom: $(JSON.parse(self.contents)['rally'])

stdout: stdout.txt

outputs:
  - id: stdout
    type: File
    outputBinding:
      glob: stdout.txt
