<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Ai.aspx.cs" Inherits="Energy.ai" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>AI Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #0c2b4b;
            color: white;
            margin: 0;
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            background-color: #12263a;
            position: fixed;
            padding: 20px;
        }
        .sidebar h2 {
            color: #f7c331;
        }
        .sidebar ul {
            list-style-type: none;
            padding: 0;
        }
        .sidebar ul li {
            padding: 10px;
            border-bottom: 1px solid #334756;
        }
        .sidebar ul li a {
            color: white;
            text-decoration: none;
        }
        .content {
            margin-left: 270px;
            padding: 20px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .card {
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .metric {
            margin-bottom: 10px;
            font-size: 18px;
        }
        canvas {
            background-color: white;
            border-radius: 10px;
            padding: 10px;
        }
        .action-card {
            grid-column: span 2;
            text-align: center;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin: 10px;
            display: inline-block;
            background-color: #f7c331;
            color: #12263a;
            transition: background-color 0.3s ease;
        }
        .btn:hover {
            background-color: #d6a72b;
        }

        /* Checkbox Style */
        .checkbox-container {
            display: inline-flex;
            align-items: center;
            margin: 10px;
            cursor: pointer;
            font-weight: bold;
        }
        .checkbox-container input[type="checkbox"] {
            width: 18px;
            height: 18px;
            border: 2px solid #f7c331;
            border-radius: 4px;
            background-color: #fff;
            margin-right: 10px;
            position: relative;
        }
        .checkbox-container input[type="checkbox"]:checked {
            background-color: #f7c331;
        }
        .checkbox-container input[type="checkbox"]:checked::after {
            content: '✔';
            color: #12263a;
            font-size: 14px;
            position: absolute;
            top: -2px;
            left: 3px;
        }
        .checkbox-container label {
            color: white;
        }

/* Loading dots animation */
.loading-dots {
    font-size: 24px;
    color: red;
    font-weight: bold;
    display: inline-block;
}

@keyframes blinkDots {
    0% { content: "."; }
    25% { content: ".."; }
    50% { content: "..."; }
    75% { content: "...."; }
    100% { content: "."; }
}



    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="sidebar">
            <h2>GREEN PULSE</h2>
            <ul>
                <li><a href="Home.aspx">Dashboard</a></li>
                <li><a href="PCApps.aspx">Apps</a></li>
                <li><a href="Emissions.aspx">Emissions</a></li>
                <li><a href="Mobile.aspx">Mobile</a></li>
                <li><a href="Ai.aspx">AI</a></li>
                <li><a href="energyred.aspx">Ways to reduce energy</a></li>
            </ul>
        </div>

        <div class="content">
            <!-- Action Card -->
            <div class="card action-card">
                <asp:CheckBox ID="chkANN" runat="server" Text="ANN Model" ForeColor="white" />
                <asp:CheckBox ID="chkCNN" runat="server" Text="CNN Model" ForeColor="white" />
                <asp:CheckBox ID="chkRNN" runat="server" Text="RNN Model" ForeColor="white" />
                <br /><br />
                <asp:Button ID="btnRunModels" runat="server" Text="Run Selected Models" CssClass="btn" 
    OnClick="btnRunModels_Click" OnClientClick="showLoading();" />

            </div>
<!-- Shared Result Card -->
<div class="card">
    <h3>Model Results</h3>
    <div class="metric">Time Taken: <asp:Label ID="lblTime" runat="server" /></div>
    <div class="metric">RAM Used: <asp:Label ID="lblRAM" runat="server" /></div>
    <div class="metric">Energy Consumed: <asp:Label ID="lblEnergy" runat="server" /></div>
    <div id="loadingDots" class="loading-dots" style="display: none;"></div>

</div>


            <!-- Shared Graph Card -->
            <div class="card">
                <h3>Performance Graph</h3>
                <canvas id="aiChart" width="400" height="200"></canvas>
            </div>

            <!-- Action Card for uploading custom model -->
            <div class="card action-card">
                <h3>Upload Your Own Model</h3>
                <asp:FileUpload ID="fileUpload" runat="server" CssClass="file-upload" />
                <br />
                <asp:Button ID="btnUploadModel" runat="server" Text="Upload and Run Model" CssClass="btn" OnClick="btnUploadModel_Click" />
            </div>
        </div>

        <asp:HiddenField ID="hiddenTime" runat="server" />
        <asp:HiddenField ID="hiddenEnergy" runat="server" />
    </form>
    <script type="text/javascript">
        let dotInterval;

        function showLoading() {
            const loadingDiv = document.getElementById('loadingDots');
            loadingDiv.style.display = 'inline-block';

            let dots = 1;
            dotInterval = setInterval(() => {
                dots = (dots % 4) + 1;
                loadingDiv.textContent = "Loading" + ".".repeat(dots);
            }, 500);
        }

        function hideLoading() {
            clearInterval(dotInterval);
            document.getElementById('loadingDots').style.display = 'none';
        }
    </script>


    <script>
        function drawChart(timeArray, energyArray) {
            const ctx = document.getElementById('aiChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: timeArray,
                    datasets: [{
                        label: "Energy Consumption (Joules)",
                        data: energyArray,
                        borderColor: "red",
                        backgroundColor: "transparent",
                        fill: false
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        x: { display: true, title: { display: true, text: "Time (seconds)" } },
                        y: { display: true, title: { display: true, text: "Energy (Joules)" } }
                    }
                }
            });
        }

        function simulateEnergyFluctuations(timeTaken, energyConsumed) {
            let timeArray = [];
            let energyArray = [];
            let timeInterval = 0.5;  // Interval between time points
            let currentEnergy = 0;

            // Simulate energy fluctuations over time
            for (let time = 0; time <= timeTaken; time += timeInterval) {
                timeArray.push(time.toFixed(2)); // Time points
                // Energy fluctuates a bit around the final value
                currentEnergy = Math.min(energyConsumed, Math.random() * energyConsumed * 1.2);  // Random fluctuation
                energyArray.push(currentEnergy.toFixed(2)); // Energy points
            }

            drawChart(timeArray, energyArray);
        }

        window.onload = function () {
            const timeTaken = parseFloat(document.getElementById('<%= hiddenTime.ClientID %>').value);
        const energyConsumed = parseFloat(document.getElementById('<%= hiddenEnergy.ClientID %>').value);

            if (!isNaN(timeTaken) && !isNaN(energyConsumed)) {
                simulateEnergyFluctuations(timeTaken, energyConsumed);
            }
            // Simulate running lighting effect
            function startRunningLights() {
                const runningLights = document.getElementById('runningLights');
                let dots = "....";
                setInterval(function () {
                    dots = dots.slice(1) + dots[0];  // Rotate dots
                    runningLights.textContent = dots;
                }, 500);
            }

            // Trigger this function when the models are running
            startRunningLights();  // Call when models are running
        };
    </script>



</body>
</html>
