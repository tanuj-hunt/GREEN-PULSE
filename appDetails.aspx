<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="appDetails.aspx.cs" Inherits="Energy.appDetails" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>App Energy Consumption</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #0c2b4b;
            color: white;
            margin: 0;
        }
        .container {
            max-width: 600px;
            margin: auto;
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        canvas {
            background-color: white;
            border-radius: 10px;
            padding: 10px;
            width: 100%;
            max-height: 200px;
        }
        table {
            width: 100%;
            margin-top: 10px;
            border-collapse: collapse;
            background-color: #12263a;
            color: white;
            text-align: left;
        }
        th, td {
            padding: 8px;
            border: 1px solid #334756;
        }
        th {
            background-color: #1e3d5f;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2 id="appTitle">Energy Consumption</h2>
            <canvas id="energyChart"></canvas>

            <h3>Last 5 Data Points</h3>
            <table>
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Energy (J)</th>
                    </tr>
                </thead>
                <tbody id="dataTable">
                    <tr><td colspan="2">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </form>

    <script>
        function getQueryParam(param) {
            const urlParams = new URLSearchParams(window.location.search);
            return urlParams.get(param);
        }

        const appName = getQueryParam("name");
        document.getElementById("appTitle").innerText = `Energy Consumption: ${appName}`;

        let energyChart = new Chart(document.getElementById("energyChart"), {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: "Energy Consumption (J)",
                    data: [],
                    borderColor: "Blue",
                    fill: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                scales: {
                    x: { display: true },
                    y: { display: true }
                }
            }
        });

        let lastFiveData = [];

        function updateGraph() {
            fetch(`/api/appsStats`)
                .then(response => response.json())
                .then(data => {
                    let appData = data.find(app => app.name === appName);
                    if (!appData) return;

                    let time = new Date().toLocaleTimeString();
                    let energy = appData.energy;

                    if (energyChart.data.labels.length > 10) {
                        energyChart.data.labels.shift();
                        energyChart.data.datasets[0].data.shift();
                    }

                    energyChart.data.labels.push(time);
                    energyChart.data.datasets[0].data.push(energy);
                    energyChart.update();
                })
                .catch(error => console.error("Error fetching energy data:", error));
        }

        function updateTable() {
            fetch(`/api/appsStats`)
                .then(response => response.json())
                .then(data => {
                    let appData = data.find(app => app.name === appName);
                    if (!appData) return;

                    let time = new Date().toLocaleTimeString();
                    let energy = appData.energy;

                    lastFiveData.unshift({ time, energy });
                    if (lastFiveData.length > 5) lastFiveData.pop();

                    let tableBody = document.getElementById("dataTable");
                    tableBody.innerHTML = "";
                    lastFiveData.forEach(entry => {
                        let row = `<tr><td>${entry.time}</td><td>${entry.energy}</td></tr>`;
                        tableBody.innerHTML += row;
                    });
                })
                .catch(error => console.error("Error fetching energy data:", error));
        }

        setInterval(updateGraph, 2000); // Graph updates every 2 sec
        setInterval(updateTable, 2000); // Table updates every 5 sec

        updateGraph();
        updateTable();
    </script>
</body>
</html>
