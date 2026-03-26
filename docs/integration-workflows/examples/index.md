# Examples

End-to-end workflow examples, including message templates and mappings.

## Tutorial Workflow Files

- [SenderExample.hl7workflow](SenderExample.hl7workflow)  
  Based on the Getting Started tutorial (Part 1): directory scan receiver (HL7 files) -> CSV file writer sender.

- [SenderExamplePart2.hl7workflow](SenderExamplePart2.hl7workflow)  
  Based on Getting Started Part 2: directory scan receiver (JSON files) -> MLLP sender (HL7) with mappings, variables, conditional logic, and foreach-driven RXA segment appends.

## Notes

- Import these files into Integration Soup Integration Host as workflow files.
- File paths and endpoints use tutorial-style placeholders and should be adjusted for your environment.
