#!/usr/bin/env cwl-runner
#
# upload a file to Synapse and return the ID
# param's include the parentId (project or folder) to which the file is to be uploaded
# and the provenance information for the file
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: infile
    type: File
  - id: parentId
    type: string
  - id: usedEntity
    type: 
      type: record
      fields:
      - name: id
        type: string
      - name: version
        type: int
  - id: executedEntity
    type: string

arguments:
  - valueFrom: uploadFile.py
  - valueFrom: $(inputs.infile)
    prefix: -f
  - valueFrom: $(inputs.parentId)
    prefix: -p
  - valueFrom: $(inputs.usedEntity.id)
    prefix: -ui
  - valueFrom: $(inputs.usedEntity.version)
    prefix: -uv
  - valueFrom: $(inputs.executedEntity)
    prefix: -e
  - valueFrom: results.json
    prefix: -r

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - .synapseConfig
      - entryname: uploadFile.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          if __name__ == '__main__':
            parser = argparse.ArgumentParser()
            parser.add_argument("-f", "--infile", required=True, help="file to upload")
            parser.add_argument("-p", "--parentId", required=True, help="Synapse parent for file")
            parser.add_argument("-ui", "--usedEntityId", required=False, help="id of entity 'used' as input")
            parser.add_argument("-uv", "--usedEntityVersion", required=False, help="version of entity 'used' as input")
            parser.add_argument("-e", "--executedEntity", required=False, help="Syn ID of workflow which was executed")
            parser.add_argument("-r", "--results", required=True, help="Results of file upload")
            args = parser.parse_args()
            syn = synapseclient.Synapse(configPath=".synapseConfig")
            syn.login()
            file=synapseclient.File(path=args.infile, parent=args.parentId)
            file = syn.store(file, used={'reference':{'targetId':args.usedEntityId, 'targetVersionNumber':args.usedEntityVersion}}, executed=args.executedEntity)
            results = {'uploadedFileId':file.id,'uploadedFileVersion':file.versionNumber}
            with open(args.results, 'w') as o:
              o.write(json.dumps(results))
     
outputs:
  - id: uploadedFileId
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['uploadedFileId'])
  - id: uploadedFileVersion
    type: int
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['uploadedFileVersion'])


