**File Writer Sender – Definitive Guide**

**Key Points**  
- The **File Writer Sender** outputs processed messages (via `MessageTemplate`) to a file on disk, supporting HL7, XML, JSON, CSV, Text, and Binary formats.  
- Use `${variables}` (e.g. `${WorkflowInstanceId}`, `${PatientID}`, `${Date:yyyyMMdd}`) in paths for safe, unique filenames — fixed names risk overwriting without proper configuration.  
- **MaxRecordsPerFile** is **only enforced** when `MoveIntoDirectoryOnComplete = true`; otherwise the file appends indefinitely (no rotation). When move is enabled, the file closes and moves on max records reached, filename change, or workflow stop.  
- Enable **MoveIntoDirectoryOnComplete** in production to guarantee complete files for downstream systems and automatic unique naming on move.  
- Workflows store these settings in **JSON** format; all properties are serialized directly from `FileWriterSenderSetting`.  

**Core Functionality**  
The sender appends the rendered `MessageTemplate` (after transformers and variable replacement) to the target file. CSV/Text support optional headers and multi-record batching; other formats are typically one-record-per-file. The move feature treats the write location as a “temp” spot and atomically relocates the completed file with uniqueness guaranteed (original name tried first; numeric/timestamp suffix added on conflict).  

**Recommended Quick-Start Configurations**  
- One message per file (HL7/XML/JSON/Binary): `MaxRecordsPerFile = 1`, `MoveIntoDirectoryOnComplete = false` (or true for archive), dynamic filename.  
- CSV batch export: `MaxRecordsPerFile = 5000`, `MoveIntoDirectoryOnComplete = true`, fixed base name + archive directory.  
- Always test with variables and verify move behavior in your workflow logs.  

---

# File Writer Sender – Definitive Guide for HL7 Soup / Integration Host (v3+)

**Version:** 1.0 (February 2026)  
**Author:** Compiled from source code, official tutorials, and developer notes  
**Purpose:** This is the single authoritative reference for configuring, understanding, and troubleshooting the File Writer Sender activity in workflow JSON files.

## 1. Overview and How the File Writer Works

The **File Writer Sender** (`FunctionProviderType`: `"HL7Soup.Functions.Senders.FileWriterSender"`, dialog: `HL7Soup.Dialogs.EditFileWriterSenderSetting`) is a sender activity that persists outbound messages to the Windows filesystem.

**Execution flow (runtime):**  
1. Render `MessageTemplateRuntimeValue` (after any transformers).  
2. Replace all `${variables}` using the current `WorkflowInstance`.  
3. Append the result to the file at `FilePathToWriteRuntimeValue`.  
4. If `MoveIntoDirectoryOnComplete == true` **and** any of these conditions are met:  
   - `MaxRecordsPerFile` reached (record count for current file),  
   - Runtime filename has changed (variables produced a new path),  
   - Workflow instance stops,  
   → close current file, move it to `DirectoryToMoveIntoRuntimeValue`, guarantee uniqueness inside target folder (tries original name; appends suffix if conflict).  
5. If move is **false**, the file simply keeps growing — `MaxRecordsPerFile` is **ignored** (no rotation or closing). This prevents accidental overwriting with fixed filenames.

**Key safety design (per developer note):**  
`MaxRecordsPerFile` only activates rotation/move logic when `MoveIntoDirectoryOnComplete` is true. Without the move flag, the writer will “just keep adding” forever to the same file — ideal only for very low-volume or debug scenarios.

**Message Type impact:**  
- CSV / Text → multi-record supported + optional header (via `MessageTypeOptions.Header`).  
- HL7 / XML / JSON / Binary → one record per file recommended (`MaxRecordsPerFile = 1`).  
- Binary → writes raw bytes (Base64 input is decoded automatically).

## 2. JSON Structure in Workflow Files

Workflows are stored as JSON (`.workflow` or exported files). Each activity is an object in the `Activities` array. The File Writer uses the concrete type `HL7Soup.Functions.Settings.Senders.FileWriterSenderSetting`.

### Full Example JSON Snippet (minimal production CSV batch)

```json
{
  "Id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "Name": "Write Daily CSV Report",
  "SettingType": "HL7Soup.Functions.Settings.Senders.FileWriterSenderSetting",
  "FunctionProviderType": "HL7Soup.Functions.Senders.FileWriterSender",
  "MessageTemplate": "${a1b2c3d4-e5f6-7890-abcd-ef1234567890 Inbound}",   // or custom CSV rows
  "MessageType": 5,                                                     // 5 = CSV
  "MessageTypeOptions": {
    "Header": "PatientID,FirstName,LastName,DOB,AdmissionDate"
  },
  "FilePathToWrite": "C:\\TempOut\\daily_report_${Date:yyyyMMdd}.csv",
  "MaxRecordsPerFile": 5000,
  "MoveIntoDirectoryOnComplete": true,
  "DirectoryToMoveInto": "C:\\Archive\\CSV\\${Date:yyyyMMdd}",
  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",
  "Enabled": true,
  "Details": "Write to file C:\\TempOut\\daily_report_...",
  // Inherited SenderSetting fields
  "ConnectionTypeName": "Sender",
  "UserCanEditTemplate": true,
  "InboundMessageNotAvailable": false
}
```

**Notes on JSON:**  
- All public properties of `FileWriterSenderSetting` + base `SenderSetting` are serialized (camelCase or as configured in JsonSerializer).  
- `MessageTypeOptions` is polymorphic (CSVMessageTypeOption or TextMessageTypeOption).  
- GUIDs for Filters/Transformers reference other workflow elements.  
- Variable syntax `${...}` is stored literally and resolved at runtime.

## 3. Property Reference (All Serializable Properties)

| Property                        | Type     | Default          | Required? | JSON Key                  | Description & Usage Rules |
|---------------------------------|----------|------------------|-----------|---------------------------|---------------------------|
| `FilePathToWrite`              | string   | ""               | Yes       | FilePathToWrite           | Full path + filename. Must include extension. Supports `${variables}`. Directory-only path triggers UI/runtime warning. |
| `MaxRecordsPerFile`            | int      | 5000             | Yes (>0)  | MaxRecordsPerFile         | **Only used when `MoveIntoDirectoryOnComplete = true`**. Number of records before rotation/move. Use 1 for one-per-file formats. |
| `MoveIntoDirectoryOnComplete`  | bool     | false            | No        | MoveIntoDirectoryOnComplete | Master switch for safe archival. When true → enforces max-records and guarantees unique name on move. |
| `DirectoryToMoveInto`          | string   | "c:\\"           | Conditional | DirectoryToMoveInto     | Required & validated only when move = true. Supports `${variables}`. Engine creates folder if missing. |
| `MessageTemplate`              | string   | (auto-bound)     | Yes       | MessageTemplate           | Exact content written. Usually `${Inbound}` or custom template. Preserved verbatim after transformers. |
| `MessageType`                  | enum (int) | 1 (HL7)        | Yes       | MessageType               | 1=HL7, 4=XML, 5=CSV, 11/13=JSON, 14=Text/Binary. Controls header visibility and multi-record support. |
| `MessageTypeOptions.Header`    | string   | ""               | No        | (nested)                  | Optional first line for CSV/Text only. Comma-separated for CSV. |
| `Name`                         | string   | (auto)           | No        | Name                      | Display name; auto-generated from path if blank. |
| `Id`                           | Guid     | (generated)      | Yes       | Id                        | Unique activity ID. |

**Runtime variants** (not set in JSON, computed):  
- `FilePathToWriteRuntimeValue(...)`  
- `DirectoryToMoveIntoRuntimeValue(...)`

## 4. Usage Scenarios & JSON Examples

### Scenario 1: One HL7 per File (Most Common)
```json
"FilePathToWrite": "C:\\HL7Out\\${WorkflowInstanceId}.hl7",
"MaxRecordsPerFile": 1,
"MoveIntoDirectoryOnComplete": true,
"DirectoryToMoveInto": "C:\\Processed\\HL7"
```

### Scenario 2: CSV Batch Export (5000 rows)
```json
"FilePathToWrite": "C:\\TempOut\\batch.csv",
"MaxRecordsPerFile": 5000,
"MoveIntoDirectoryOnComplete": true,
"DirectoryToMoveInto": "C:\\Archive\\${Date:yyyy-MM-dd}",
"MessageType": 5,
"MessageTypeOptions": { "Header": "ID,Name,DOB" }
```

### Scenario 3: Binary (PDF/image) Export
```json
"FilePathToWrite": "C:\\Documents\\${PatientID}.pdf",
"MaxRecordsPerFile": 1,
"MoveIntoDirectoryOnComplete": false,
"MessageType": 14   // Binary
```

### Scenario 4: Daily Dynamic Archive (No Move)
```json
"FilePathToWrite": "C:\\Archive\\reports_${Date:yyyyMMdd}.csv",
"MaxRecordsPerFile": 10000,   // ignored because move=false
"MoveIntoDirectoryOnComplete": false
```

## 5. Best Practices & Requirements

1. **Always use variables** for `FilePathToWrite` in production (WorkflowInstanceId is safest for uniqueness).  
2. **Enable MoveIntoDirectoryOnComplete** for any multi-record or long-running files — prevents partial-file reads by downstream systems.  
3. Set `MaxRecordsPerFile = 1` for non-CSV formats.  
4. Place write location in a “temp” or “working” directory; use move for the final “ready” folder.  
5. Test filename change detection: any variable that produces a new path triggers immediate move (if enabled).  
6. Header for CSV/Text: place in `MessageTypeOptions.Header` — appears only once at file creation.  
7. Validation (UI + runtime): file path required, max > 0, directory required when move=true. Directory-only paths show warning after 2-second delay.  
8. Performance: High-volume workflows benefit from move + unique naming to keep file handles short-lived.

**Common Pitfalls to Avoid**  
- Fixed filename + move=false + high volume → one ever-growing file.  
- Fixed filename + move=false + MaxRecordsPerFile set → still keeps adding (per developer rule).  
- Forgetting to clear default MessageTemplate when switching to CSV → malformed output.  
- Using date-only variables at high throughput → name collisions (use WorkflowInstanceId instead).

## 6. Validation & UI Behavior (from Dialog Source)

- Orange warning appears if path looks like a directory.  
- `Validate()` enforces all required fields and integer > 0.  
- Move checkbox dynamically shows/hides directory field.  
- Variable binding enabled on all text fields (outbound context).

This guide supersedes all prior tutorial snippets and is kept in sync with the `FileWriterSenderSetting` class implementation.

**Key Citations**  
- Official Processing Files Tutorial (integrationsoup.com) – detailed move, max-records, unique naming, and variable examples.  
- Integration Host Getting Started Guide (integrationsoup.com) – workflow designer File Writer configuration and CSV examples.  
- Integration Workflow Designer Tutorial (integrationsoup.com) – MessageTemplate and MessageType usage.  
- Source code of `EditFileWriterSenderSetting.cs`, `FileWriterSenderSetting.cs`, and `SenderSetting.cs` – exact property definitions, defaults, validation, and move conditions.  
- Developer clarification on MaxRecordsPerFile behavior when move=false.  

Copy this entire document into a `.md` file for internal use or team distribution. It is the complete, self-contained reference for all JSON-based workflow authoring involving the File Writer.