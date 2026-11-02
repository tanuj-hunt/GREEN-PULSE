<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="energyred.aspx.cs" Inherits="Energy.energyred" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Energy Saving Options</title>
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
        }
        .card {
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .checkbox-list label {
            display: inline-block;
            margin-right: 10px;
            color: white;
        }
        .checkbox-list input[type="checkbox"] {
            margin-right: 10px;
        }
        .submit-btn {
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #f7c331;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            color: black;
            font-weight: bold;
        }
        .submit-btn:hover {
            background-color: #e6b800;
        }
        .result {
            margin-top: 20px;
            color: #f7c331;
            display: none;
        }
        .graph-box {
            margin-top: 20px;
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            display: none;
        }
        canvas {
            width: 100%;
            max-width: 500px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="sidebar">
            <h2>GREEN PULSE</h2>
            <ul>
                <li><a href="Home.aspx">Dashboard</a></li>
                <li><a href="Apps.aspx">Apps</a></li>
                <li><a href="Emissions.aspx">Emissions</a></li>
                <li><a href="Mobile.aspx">Mobile</a></li>
                <li><a href="ai.aspx">AI</a></li>
                <li><a href="energyred.aspx">Ways to reduce energy</a></li>
            </ul>
        </div>

        <div class="content">
            <div class="card">
                <h3>Energy Saving Settings</h3>
                <div class="checkbox-list">
                    <label>
                        <input type="checkbox" id="chkBrightness" runat="server" />
                        Reduce Brightness to 30%
                    </label><br />
                    <label>
                        <input type="checkbox" id="chkLock" runat="server" />
                        Lock Screen
                    </label><br />
                    <label>
                        <input type="checkbox" id="chkAirplaneMode" runat="server" />
                        Enable Airplane Mode
                    </label><br />
                    <label>
                        <input type="checkbox" id="chkDarkMode" runat="server" />
                        Enable Dark Mode
                    </label><br />
                </div>

                <asp:Button ID="btnApply" runat="server" Text="Apply Settings" CssClass="submit-btn" OnClick="btnApply_Click" />
                <button type="button" id="btnShowResults" class="submit-btn" onclick="showResults()">Show Results</button>

                <div class="result" id="lblResult">
                    <asp:Label ID="lblResult" runat="server" ForeColor="#f7c331" />
                </div>
                
                <div class="graph-box" id="graphBox">
                    <canvas id="energyChart" runat="server"></canvas>
                </div>
            </div>
        </div>
    </form>

    <script>
        let energyBefore = getRandomEnergyBefore();  // Get fluctuating energy value
        let energyAfter = 100;

        // Function to get a fluctuating energy value
        function getRandomEnergyBefore() {
            // Fluctuate between 90 to 120 energy units
            return Math.floor(Math.random() * 30) + 90;  // Random value between 90 and 120
        }

        // Function to update the chart with new energy values
        function updateGraph() {
            const ctx = document.getElementById('energyChart').getContext('2d');
            if (window.energyChartInstance) {
                window.energyChartInstance.destroy();
            }
            window.energyChartInstance = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['Before', 'After'],
                    datasets: [{
                        label: 'Energy Consumption (Joules)',
                        data: [energyBefore, energyAfter],
                        backgroundColor: ['#f7c331', '#00b894']
                    }]
                },
                options: {
                    plugins: {
                        legend: {
                            labels: { color: 'black' }
                        },
                        tooltip: {
                            bodyColor: 'black',
                            titleColor: 'black'
                        }
                    },
                    scales: {
                        y: { ticks: { color: 'black' } },
                        x: { ticks: { color: 'black' } }
                    }
                }
            });
        }

        // Function to simulate energy saving fluctuations
        function calculateFluctuatingEnergySaved() {
            let energySaved = 0;

            // Calculate fluctuating energy saved based on selected checkboxes
            if (document.getElementById('chkBrightness').checked) {
                // Energy saving fluctuates between 8-12% for brightness reduction
                energySaved += Math.floor(Math.random() * 5) + 8;  // Random saving between 8% and 12%
            }
            if (document.getElementById('chkLock').checked) {
                // Energy saving fluctuates between 4-6% for locking the screen
                energySaved += Math.floor(Math.random() * 3) + 4;  // Random saving between 4% and 6%
            }
            if (document.getElementById('chkAirplaneMode').checked) {
                // Energy saving fluctuates between 12-18% for enabling airplane mode
                energySaved += Math.floor(Math.random() * 7) + 12;  // Random saving between 12% and 18%
            }
            if (document.getElementById('chkDarkMode').checked) {
                // Energy saving fluctuates between 4-6% for enabling dark mode
                energySaved += Math.floor(Math.random() * 3) + 4;  // Random saving between 4% and 6%
            }

            return energySaved;
        }

        // Function to show result and graph
        function showResults() {
            let energySaved = calculateFluctuatingEnergySaved();  // Get fluctuating energy saved
            energyAfter = energyBefore - energySaved;  // Calculate energy after saving
            updateGraph();  // Update the graph with new energy values

            // Displaying the results and graph
            document.getElementById("lblResult").innerHTML = `
            <strong>Energy Before: </strong>${energyBefore} Joules<br>
            <strong>Energy After: </strong>${energyAfter} Joules<br>
            <strong>Energy Saved: </strong>${energySaved} Joules
        `;

            // Show result and graph
            document.getElementById("lblResult").style.display = "block";
            document.getElementById("graphBox").style.display = "block";
        }

        // Simulate energy saving and display results when button is clicked
        document.getElementById("btnShowResults").onclick = function () {
            showResults();  // Call the function to show results with fluctuating energy savings
        };
    </script>


</body>
</html>
