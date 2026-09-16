# ZIP Activities

The ZIP Activities Extension Library adds three activities to Integration Soup:

- **Create ZIP File**
- **Create ZIP Message**
- **Extract ZIP File**

Use them to package a directory for archiving or delivery, return an archive as a Binary response message, or extract an archive into a server directory.

## Download

- [IntegrationSoup.ZipActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.ZipActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/ZipActivities.html)

## Prerequisites

- Integration Soup or Integration Host on Windows
- Read permission for source directories and ZIP files
- Write permission for output ZIP paths and extraction directories
- Enough free disk space for file-based operations and enough memory for **Create ZIP Message**

The paths are resolved on the machine running the Integration Soup service. When a workflow runs as a service, its service account must be able to access local or network paths.

No separate ZIP application is required. The installer provides the activity DLL and its persistent out-of-process runner.

## Create ZIP File

**Create ZIP File** recursively adds the contents of a source directory to a ZIP archive on disk. Subdirectories and empty directories are included.

Parameters:

- **Source Directory**: full path to the directory to package
- **ZIP File Path**: full path of the ZIP file to create
- **Include Base Directory**: set to <code>true</code> to place the source directory itself at the root of the archive; leave it blank or <code>false</code> to put its contents at the root
- **Overwrite Existing File**: set to <code>true</code> to replace an existing ZIP file

The activity does not require an incoming activity message. It returns a Text response confirming the output path and the number of archived files and directories.

## Create ZIP Message

**Create ZIP Message** creates the same recursive archive in memory and returns it as a Binary response message.

Parameters:

- **Source Directory**: full path to the directory to package
- **Include Base Directory**: set to <code>true</code> to place the source directory itself at the root of the archive

Use the Binary response with a File Writer, SFTP activity, HTTP activity, cloud-storage activity, or another step that accepts file bytes. This form is convenient for workflow chaining, but **Create ZIP File** is preferable for very large directories because **Create ZIP Message** must hold the ZIP bytes and their named-pipe representation in memory.

## Extract ZIP File

**Extract ZIP File** recreates the files and directories from an archive under a destination directory.

Parameters:

- **ZIP File Path**: full path to the ZIP archive
- **Destination Directory**: full path to the directory that will receive the extracted contents
- **Overwrite Existing Files**: set to <code>true</code> to replace existing destination files; leave it blank or <code>false</code> to stop before extraction when a destination file already exists

The destination directory is created when needed. The activity returns a Text response confirming the archive path, destination, and extracted item counts.

The extractor rejects archive entries that would escape the destination directory, including <code>..</code> traversal paths and absolute paths.

## Runner behavior

The activity DLL stays lightweight and sends synchronous requests to a persistent ZIP runner over a named pipe. One request is processed at a time for this extension type, and each workflow caller remains blocked until its own ZIP operation finishes.

The runner process is installed only under the Integration Host Server <code>Custom Libraries\ZipActivitiesRunner</code> folder. It remains in memory for later requests and exits when its parent host process exits.

## Typical uses

- Package a directory of generated reports before SFTP or cloud delivery
- Create a Binary ZIP response and pass it directly to a File Writer
- Extract inbound partner archives into a directory for later scanning
- Preserve nested and empty directory structures in an archive
