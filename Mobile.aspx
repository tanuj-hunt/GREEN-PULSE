<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Mobile.aspx.cs" Inherits="Energy.Mobile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Mobile Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #0c2b4b;
            color: white;
            margin: 0;
            display: flex;
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            background-color: #12263a;
            padding: 20px;
            position: fixed;
            color: white;
        }
        .sidebar h2 {
            color: #f7c331;
            margin-bottom: 20px;
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
            display: block;
        }
        .container {
            margin-left: 270px;
            width: calc(100% - 270px);
            background-color: #12263a;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.5);
        }
        .header {
            font-size: 24px;
            font-weight: bold;
            color: #f7c331;
            text-align: center;
            margin-bottom: 20px;
        }
        .status {
            font-size: 18px;
            margin-bottom: 10px;
            text-align: center;
            color: #f7c331;
        }
        .info-box {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 20px;
        }
        .info-item {
            background-color: #1e3d5f;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            color: white;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        .chart-box {
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        canvas {
            width: 100%;
            height: 250px;
            background-color: white;
            border-radius: 10px;
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
        }
        .connect-btn {
            background-color: #f7c331;
            color: #12263a;
        }
        .connect-btn:hover {
            background-color: #d6a72b;
        }
        .apps-btn {
            background-color: #4caf50;
            color: white;
            display: none;
        }
        .apps-btn:hover {
            background-color: #45a049;
        }
        .btn-container {
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>GREEN PULSE</h2>
        <ul>
            <li><a href="Home.aspx">Dashboard</a></li>
            <li><a href="PCApps.aspx">Apps</a></li>
            <li><a href="Emissions.aspx">Emissions</a></li>
            <li><a href="Mobile.aspx">Mobile</a></li>
            <li><a href="ai.aspx">AI</a></li>
            <li><a href="energyred.aspx">Ways to reduce energy</a></li>
        </ul>
    </div>
    <div class="container">
        <div class="header">YOUR MOBILE USAGE</div>
        <div class="btn-container">
            <button id="connect-btn" class="btn connect-btn">Connect</button>
            <button id="apps-btn" class="btn apps-btn" onclick="location.href='MobileApps.aspx'">Apps</button>
        </div>
        <div id="connection-status" class="status">Not connected</div>
        <div class="info-box">
            <div class="info-item">Energy Consumption: <span id="energy">0 Joules</span></div>
            <div class="info-item">CPU Usage: <span id="cpu">0%</span></div>
            <div class="info-item">RAM Usage: <span id="ram">0 MB</span></div>
            <div class="info-item">Battery Status: <span id="battery">Disconnected</span></div>
        </div>
        <div class="chart-box">
            <canvas id="energyChart"></canvas>
        </div>
    </div>

    <script>
        let connected = false;
        let interval;
        let energyChart = new Chart(document.getElementById("energyChart"), {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: "Energy Consumption (Joules)",
                    data: [],
                    borderColor: "#f7c331",
                    fill: false
                }]
            },
            options: {
                responsive: true,
                scales: {
                    x: { display: true },
                    y: { display: true }
                }
            }
        });

        document.getElementById("connect-btn").addEventListener("click", () => {
            if (connected) {
                fetch('/api/mobile/disconnect')
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            connected = false;
                        }
                    })
                    .catch(error => console.error("Error disconnecting:", error))
                    .finally(() => {
                        clearInterval(interval);
                        document.getElementById("connect-btn").innerText = "Connect";
                        document.getElementById("connection-status").innerText = "Disconnected";
                        document.getElementById("apps-btn").style.display = "none"; // Hides after disconnect
                    });
            } else {
                fetch('/api/mobile/connection')
                    .then(response => response.json())
                    .then(data => {
                        if (data.connected) {
                            connected = true;
                            document.getElementById("connection-status").innerText = "Phone connected via ADB";
                            document.getElementById("connect-btn").innerText = "Disconnect";
                            document.getElementById("apps-btn").style.display = "inline-block"; // Shows after connecting
                            interval = setInterval(updateStats, 2000);
                        } else {
                            document.getElementById("connection-status").innerText = "Connection failed!";
                        }
                    });
            }
        });



        function updateStats() {
            if (!connected) return;
            fetch('/api/mobile/stats')
                .then(response => response.json())
                .then(data => {
                    document.getElementById("cpu").innerText = `${data.cpu_usage}%`;
                    document.getElementById("ram").innerText = `${data.memory_usage} MB`;
                    document.getElementById("energy").innerText = `${data.energy} Joules`;
                    document.getElementById("battery").innerText = `${data.battery.battery} - ${data.battery.charging}`;

                    energyChart.data.labels.push(new Date().toLocaleTimeString());
                    energyChart.data.datasets[0].data.push(data.energy);
                    if (energyChart.data.labels.length > 10) {
                        energyChart.data.labels.shift();
                        energyChart.data.datasets[0].data.shift();
                    }
                    energyChart.update();
                })
                .catch(err => console.error("Error fetching stats:", err));
        }
    </script>
</body>
</html>
