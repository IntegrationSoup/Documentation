# **Global Variables**

## What Global Variables are

Global Variables are host-scoped named values that can be reused across workflows on the same workflow host.

They are typically used for:

- shared text values
- connection strings
- secrets such as passwords, API keys, and OAuth client secrets
- environment-specific values that should not be duplicated into many workflows

This page covers the public feature behavior, storage layout, and workflow host API.

For workflow-instance variables created during a workflow run, see [Variables](../variables.md).

## Purpose types

Global Variables have a `Purpose`.

API values:

- `Text`
- `Secret`
- `ConnectionString`

UI labels:

- `Text`
- `Secret`
- `Database` for `ConnectionString`

### Purpose behavior

| Purpose | Typical use | Shown in normal binding tree | Shown in generic “Insert Global Variable” menus |
|---|---|---|---|
| `Text` | shared plain text, URLs, names, IDs | Yes | Yes |
| `Secret` | passwords, client secrets, API keys | No | No |
| `ConnectionString` | database and transport connection strings | No | No |

Sensitive purposes are intentionally hidden from the normal binding tree and generic insert menus. They are selected through sensitive-field editors such as the `...` menu beside connection-string and secret fields.

## Storage locations

Global Variables also have a `StorageLocation`.

API values:

- `File`
- `Database`
- `AzureVault`

### `File`

- value is stored in a host file
- simplest option for local/shared host storage

### `Database`

- value is stored in the workflow host message log database
- useful when database-backed host storage is preferred

### `AzureVault`

- no local value is stored by Integration Soup
- the host reads the secret from Azure Key Vault using the Global Variable name as the secret name
- the Azure Vault URL is configured separately on the workflow host

## Where Global Variables are stored

Default Windows workflow host paths:

- definitions: `C:\ProgramData\Popokey\SharedSettings\GlobalVariables.json`
- file-backed values: `C:\ProgramData\Popokey\GlobalVariables\<Name>.txt`
- encryption key file: `C:\ProgramData\Popokey\SharedSettings\GlobalVariableProtection.key`

Notes:

- `GlobalVariables.json` stores definitions and metadata, not every value
- file-backed values are stored one file per variable
- `AzureVault` variables do not create local value files
- on non-Windows or containerized hosts, the same relative paths are used under the host ProgramData location

## Definition fields

The v2 Global Variable metadata API uses these fields:

```json
{
  "Name": "ApiClientSecret",
  "StorageLocation": 0,
  "Purpose": 1,
  "EncryptValue": true,
  "HasStoredValue": true,
  "Value": null,
  "Cache": true
}
```

Meaning:

- `Name`: Global Variable name
- `StorageLocation`: `0 = File`, `1 = Database`, `2 = AzureVault`
- `Purpose`: `0 = Text`, `1 = Secret`, `2 = ConnectionString`
- `EncryptValue`: whether file/database storage should be written in protected form
- `HasStoredValue`: whether a local stored value exists
- `Value`: returned for normal text variables in metadata calls; secure values are not exposed here
- `Cache`: whether the host should cache the resolved value in memory

## Encryption behavior

`EncryptValue` applies to `File` and `Database` storage.

When enabled:

- values written by the product are stored in a protected envelope
- the envelope starts with `HL7SOUPGV1:`
- the protected value includes a version marker, IV, and ciphertext
- the host uses the key file at `C:\ProgramData\Popokey\SharedSettings\GlobalVariableProtection.key`

Operational implications:

- back up the key file together with the ProgramData Global Variable files
- if the key file is lost, protected file/database values cannot be decrypted on that host
- restoring the ProgramData backup, including the key file, restores access

## Caching behavior

The `Cache` flag controls whether the resolved value is kept in memory after it is first read.

| Storage type | Cache = false | Cache = true |
|---|---|---|
| `File` | next read re-reads the `.txt` file | next read uses in-memory value until cache is invalidated or host restarts |
| `Database` | next read re-reads the database value | next read uses in-memory value until cache is invalidated or host restarts |
| `AzureVault` | next read calls the vault again | successful values are reused from memory |

Important behavior:

- updating a Global Variable through the UI or host API invalidates the cached value immediately
- editing the backing file or database directly does **not** invalidate the in-memory cache
- if `Cache = true`, direct external edits can remain invisible until restart or product-driven refresh

## Direct file editing

### Editing `GlobalVariables.json`

This file controls definitions such as:

- name
- purpose
- storage location
- cache
- encryption

Practical guidance:

- stop the workflow host before editing the file directly
- after saving the file, restart the workflow host so it reloads the definitions
- direct edits are not hot-reloaded automatically

### Editing file-backed values directly

File-backed values live in:

```text
C:\ProgramData\Popokey\GlobalVariables\<Name>.txt
```

Behavior:

- with `Cache = false`, the next lookup sees the new file contents
- with `Cache = true`, the host may keep using the old in-memory value until restart or a product-driven update clears the cache

### Editing encrypted file-backed values directly

If `EncryptValue = true`:

- values written by the product are normally stored in protected form
- the safest way to change them is through the UI or the stored-value API

Compatibility behavior:

- the host can still read plain text placed directly into the file
- the next save through the product rewrites the value in protected form again

## Azure Vault behavior

When `StorageLocation = AzureVault`:

- Integration Soup does not store a local value file
- the variable name is used as the Azure Key Vault secret name
- the host reads the secret from the configured Azure Vault URL
- `HasStoredValue` is false because there is no local stored value

If the vault secret cannot be read, the host returns an error value instead of a usable secret.

## Workflow Host API

All routes below are relative to the workflow host base URL.

## Legacy API

The legacy API exists for older clients and supports **Text** variables only.

Routes:

- `GET /GlobalVariableSetting`
- `GET /GlobalVariableSetting/{name}`
- `PUT /GlobalVariableSetting/{name}`
- `DELETE /GlobalVariableSetting/{name}`

Behavior:

- only `Text` variables are listed
- `Secret` and `ConnectionString` variables are hidden from these routes

## v2 capabilities

```http
GET /GlobalVariableSetting/Capabilities
```

Typical response:

```json
{
  "MetadataApiAvailable": true,
  "StoredValueApiAvailable": true,
  "SecurePurposesAvailable": true
}
```

## v2 metadata API

Routes:

- `GET /GlobalVariableSetting/Metadata`
- `GET /GlobalVariableSetting/Metadata/{name}`
- `PUT /GlobalVariableSetting/Metadata/{name}`

Use these routes to manage:

- name
- purpose
- storage location
- cache
- encryption

Metadata calls do not expose secure stored values.

## v2 stored-value API

Routes:

- `GET /GlobalVariableSetting/StoredValue/{name}`
- `PUT /GlobalVariableSetting/StoredValue/{name}`
- `DELETE /GlobalVariableSetting/StoredValue/{name}`

Typical payload:

```json
{
  "Value": "super-secret-value",
  "HasStoredValue": true
}
```

Use these routes to:

- read or update the current stored value
- clear the stored value

For `AzureVault`, these routes report no local stored value.

## Azure Vault URL API

Routes:

- `GET /GlobalVariableSetting/AzureVaultUrl`
- `PUT /GlobalVariableSetting/AzureVaultUrl/{*url}`

This configures the vault base URL used by `AzureVault` Global Variables.

## Workflow usage

Global Variables are referenced with standard variable syntax:

```text
${MyGlobalVariable}
```

Typical examples:

- `${SqlConnection}`
- `${AzureServiceBusConnection}`
- `${FhirApiClientSecret}`

UI behavior:

- `Text` variables appear in the normal binding tree
- `Secret` and `ConnectionString` variables are chosen through secure field editors instead

## Compatibility behavior

- new clients use the v2 metadata and stored-value APIs when available
- new clients fall back to the legacy Text-only API against older hosts
- older clients continue to work against newer hosts for `Text` variables
- secure variables remain hidden from older clients

## Best practices

- use `Secret` for passwords, API keys, and OAuth client secrets
- use `ConnectionString` for database and transport connection strings
- keep `Text` for ordinary shared values that should appear in the binding tree
- back up `GlobalVariables.json`, file-backed values, and `GlobalVariableProtection.key` together
- if you edit value files directly, prefer `Cache = false` or restart the host after the change
