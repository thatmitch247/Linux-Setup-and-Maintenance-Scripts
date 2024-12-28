Overview / Purpose:

1. Download the necessary files (manifest, list, SHA256SUMS, and SHA256SUMS.gpg) from the specified URL.
2. Verify the integrity of the downloaded files using the SHA256 checksums.
3. Use the manifest and file list found with the source ISO (on Canonical's Archive Servers) to check that the current system has not been tampered with.


The Step-by-Step Process:

1. Create a Temporary Directory: The script creates a temporary directory for downloaded files.
2. Download Files: Downloads the specified files (manifest, list, SHA256SUMS, and SHA256SUMS.gpg) from the URL.
3. Verify GPG Signature: Uses Ubuntu’s archive keyring to verify the SHA256SUMS file with the SHA256SUMS.gpg signature.
4. Verify Checksums: Verifies the downloaded files’ checksums against the values in SHA256SUMS.
5. System Integrity Check: Compares system files against the manifest’s checksums to detect any tampering.


Instructions For Use:

1. Save the Script: Save the script as verify_system.sh.

2. Make It Executable:	
$ chmod +x verify_system.sh

3. Run the Script with Root Privileges:	
$ sudo ./verify_system.sh

Upon exiting, the script will return a list of any discrepancies it found when comparing the 'known-good' manifest from Canonical's servers against your newly installed system.

Otherwise, you'll see a message that everything matched up correctly.
