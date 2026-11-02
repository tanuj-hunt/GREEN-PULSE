using System;
using System.Diagnostics;
using System.Web.UI;

namespace Energy
{
    public partial class ai : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnRunModels_Click(object sender, EventArgs e)
        {
            // Trigger loading dots at the start
            ClientScript.RegisterStartupScript(this.GetType(), "showLoading", "showLoading();", true);

            if (chkANN.Checked)
                RunPythonModel("ann.py");

            if (chkCNN.Checked)
                RunPythonModel("cnn.py");

            if (chkRNN.Checked)
                RunPythonModel("rnn.py");

            // Stop loading animation after models are done
            ClientScript.RegisterStartupScript(this.GetType(), "hideLoading", "hideLoading();", true);
        }


        protected void btnUploadModel_Click(object sender, EventArgs e)
        {
            if (fileUpload.HasFile)
            {
                try
                {
                    // Save the uploaded model temporarily on the server
                    string modelPath = Server.MapPath("~/uploaded_models/" + fileUpload.FileName);
                    fileUpload.SaveAs(modelPath);

                    // Verify the file is saved
                    if (System.IO.File.Exists(modelPath))
                    {
                        // Run the uploaded model
                        RunPythonModel(fileUpload.FileName);
                    }
                    else
                    {
                        Response.Write("File upload failed.");
                    }
                }
                catch (Exception ex)
                {
                    // Handle errors (e.g., file save or execution failure)
                    Response.Write("Error: " + ex.Message);
                }
            }
            else
            {
                Response.Write("No file uploaded.");
            }
        }


        private void RunPythonModel(string scriptName)
        {
            string scriptPath = Server.MapPath("~/scripts/" + scriptName);

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "python",
                Arguments = $"\"{scriptPath}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            string[] outputLines;

            using (Process process = Process.Start(psi))
            {
                outputLines = process.StandardOutput.ReadToEnd().Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                process.WaitForExit();
            }

            if (outputLines.Length >= 3)
            {
                string time = outputLines[0];
                string ram = outputLines[1];
                string energy = outputLines[2];

                lblTime.Text = time + " sec";
                lblRAM.Text = ram + " MB";
                lblEnergy.Text = energy + " J";

                hiddenTime.Value = time;
                hiddenEnergy.Value = energy;

            }
        }
    }
}
