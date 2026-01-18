# Razer™ Razor

**A PowerShell utility to safely and completely remove residual Razer™ software components from Windows 10 and 11.**

---

### ⚠️ Disclaimer & Legal Notice

**THIS SOFTWARE IS NOT PRODUCED, ENDORSED, OR SUPPORTED BY RAZER, INC.**

"Razer", "Razer Synapse", "Razer Cortex", and the triple-headed snake logo are trademarks or registered trademarks of Razer Inc. and/or affiliated companies in the United States and other countries. All other trademarks cited herein are the property of their respective owners.

**Razer™ Razor** is a third-party, open-source utility created for system maintenance and troubleshooting purposes. It uses only standard Microsoft® Windows™ PowerShell administration commands to remove files and registry keys. It **does not** contain, distribute, modify, or reverse-engineer any proprietary code, binaries, or software owned by Razer, Inc.

The use of the trademarks "Razer", "Windows", and "PowerShell" in this repository is strictly for descriptive purposes (nominative fair use) to indicate compatibility and function.

---

### 📝 About

The official uninstallers for peripheral software can sometimes leave behind residual files, drivers, and registry keys. These remnants can cause conflicts when trying to reinstall the software or when switching to different peripherals.  In addition, some computing environments are inappropriate for Razer™ software presence, such as Healthcare, Finance, Government, or other sensitive sectors.
To provide a universal remedy that doesn't require any additional software installations, this script uses native PowerShell commands to perform all cleanup activities.

**Razer™ Razor** automates the manual cleanup process described in various support forums. It performs the following actions:
1.  **Stops** all active Razer processes and services.
2.  **Unregisters** scheduled tasks related to Razer updates.
3.  **Uninstalls** detected Razer applications via the Windows Package Manager.
4.  **Removes** residual drivers from the Windows Driver Store (`FileRepository`).
5.  **Cleans** leftover folders in `Program Files`, `AppData`, and `ProgramData`.
6.  **Purges** residual Registry keys in `HKLM` and `HKCU`.

### 🚀 Usage

**⚠️ WARNING: USE AT YOUR OWN RISK.**
This script deletes files and registry keys. While it prompts you to create a System Restore Point, you should always back up critical data before running system maintenance scripts.

1.  Download `RazerRazor.ps1`.
2.  Right-click the file and select **Run with PowerShell**.
    * *Note: You must run this script as Administrator.*
3.  Follow the interactive prompts.
    * The script will ask for confirmation before performing major actions.
    * A log file (`RazerRazorLog.txt`) will be saved to your Desktop.

### 📋 Requirements

* Windows 10 or Windows 11
* PowerShell 5.1 or later
* Administrator privileges

### 📄 License

This project is licensed under the [MIT License](LICENSE).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
