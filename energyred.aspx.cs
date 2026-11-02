using System;
using System.Web.UI;
using System.Diagnostics;
using Newtonsoft.Json;

namespace Energy
{
    public partial class energyred : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnApply_Click(object sender, EventArgs e)
        {
            try
            {
                double energySaved = 0;

                // Adjust Brightness first
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "powershell.exe";
                psi.UseShellExecute = false;
                psi.RedirectStandardOutput = true;
                psi.CreateNoWindow = true;
                psi.Verb = "runas";

                if (chkBrightness.Checked)
                {
                    // Reduce Brightness to 30%
                    psi.Arguments = "-Command \"(Get-WmiObject -Namespace root/wmi -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 30)\"";
                    energySaved += 5; // Energy saved for brightness reduction
                }
                else
                {
                    // Set Brightness to 60%
                    psi.Arguments = "-Command \"(Get-WmiObject -Namespace root/wmi -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, 60)\"";
                }

                using (Process process = Process.Start(psi))
                {
                    process.WaitForExit();
                }

                // Apply Dark Mode (Battery Saver Mode)
                if (chkDarkMode.Checked)
                {
                    ProcessStartInfo darkModePsi = new ProcessStartInfo();
                    darkModePsi.FileName = "powershell.exe";
                    darkModePsi.Arguments = "-Command \"Set-ItemProperty -Path 'HKCU:\\Control Panel\\Desktop' -Name 'AppsUseLightTheme' -Value 0\"";
                    darkModePsi.UseShellExecute = false;
                    darkModePsi.CreateNoWindow = true;
                    darkModePsi.Verb = "runas";

                    using (Process process = Process.Start(darkModePsi))
                    {
                        process.WaitForExit();
                    }

                    energySaved += 0.2; // Energy saved for dark mode
                }

                // Lock the screen if checked
                if (chkLock.Checked)
                {
                    ProcessStartInfo lockPsi = new ProcessStartInfo();
                    lockPsi.FileName = "rundll32.exe";
                    lockPsi.Arguments = "user32.dll,LockWorkStation";
                    lockPsi.UseShellExecute = false;
                    lockPsi.CreateNoWindow = true;
                    lockPsi.Verb = "runas";

                    using (Process lockProc = Process.Start(lockPsi))
                    {
                        lockProc.WaitForExit();
                    }

                    energySaved += 0.3; // Energy saved for locking screen
                }

                // Apply Airplane Mode only if the checkbox is checked
                if (chkAirplaneMode.Checked)
                {
                    // Enable Airplane Mode by disabling network adapters (Wi-Fi, Ethernet)
                    ProcessStartInfo airplaneModeEnablePsi = new ProcessStartInfo();
                    airplaneModeEnablePsi.FileName = "powershell.exe";
                    airplaneModeEnablePsi.Arguments = "-Command \"(Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'}).Disable()\"";
                    airplaneModeEnablePsi.UseShellExecute = false;
                    airplaneModeEnablePsi.RedirectStandardOutput = true;
                    airplaneModeEnablePsi.CreateNoWindow = true;
                    airplaneModeEnablePsi.Verb = "runas";

                    using (Process process = Process.Start(airplaneModeEnablePsi))
                    {
                        process.WaitForExit();
                    }

                    energySaved += 0.7; // Energy saved for airplane mode
                }

                // Send the energy saved value to the frontend (via JavaScript)
                string script = $"updateEnergyDisplay({energySaved});";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "updateGraph", script, true);

                lblResult.Text = "✔ Energy saving settings applied.";
            }
            catch (Exception ex)
            {
                lblResult.Text = "❌ Failed to apply setting: " + ex.Message;
            }
        }
        protected void btnShowResults_Click(object sender, EventArgs e)
        {
            try
            {
                // Simulating energy saved for demo
                double energySaved = 20;  // You can calculate this based on your logic

                // Send the energy saved value to the frontend (via JavaScript)
                string script = $"updateGraph(); showResults({energySaved});";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "showResultsGraph", script, true);

                lblResult.Text = "✔ Results are displayed.";
            }
            catch (Exception ex)
            {
                lblResult.Text = "❌ Failed to display results: " + ex.Message;
            }
        }


    }
}
