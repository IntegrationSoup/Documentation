# Version 5 Extension Library deployment

Version 5 requires a bridge-enabled installer for each Extension Library. An
older installer with the same download filename does not establish version 5
compatibility. Use the release notes to verify its version; unpublished review
MSIs are for controlled testing, not production deployment.

The bridge-enabled MSI contains the version 4 DLL and a persistent isolated
runner for version 5. The DLL is installed in the three product `Custom Libraries`
folders; runner payloads are installed on Integration Host Server only. Install
using an administrator account. Provider registration is created during
installation, without first running a workflow. A subsequent host upgrade must
preserve these separately owned provider registrations.

Version 5 gets activity and transformer metadata from the server catalog. Saved
extension identifiers, parameter names, authored empty values and message
templates are preserved. Hiding a library from authoring is separate from
removing its provider connection; do not remove a provider required by a workflow.

The server service account needs access to the provider's protected manifest,
executable and the files or services used by the activity. HTML to PDF needs a
compatible installed browser. RTF to PDF needs LibreOffice. Validate HL7 uses the
installed version 5 parser/highlighter runtime and saved validation profiles.
Other library-specific prerequisites and installer links are on their library
pages and the [Extension Libraries directory](https://www.integrationsoup.com/ExtensionLibraries/index.html).

The local runners use named pipes, remain alive between requests and terminate
when their parent host exits. Cancellation does not guarantee that a file upload
or other external action was stopped; an uncertain call must not be automatically
replayed. Schedule installer upgrades during a maintenance window because the
host service can be restarted. Separate versioned payload folders prevent new
generations from relying on replacement of an executable held open by a runner.

Before production release, verify installation, repair, failed-upgrade rollback,
uninstallation isolation and a later host-v5 upgrade in a disposable environment.
Compilation or MSI database inspection alone does not prove these scenarios.
