<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Energy Dashboard</title>
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
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        .card {
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        canvas {
            background-color: white;
            border-radius: 10px;
            padding: 10px;
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
    <div class="content">
        <div class="card">
            <h3>Energy Consumption</h3>
            <p id="energy">Total: 0 Joules</p> 
        </div>
        <div class="card">
            <h3>CPU Usage</h3>
            <p id="cpu">Total: 0%</p> 
        </div>
        <div class="card">
            <h3>RAM Usage</h3>
            <p id="ram">Total: 0%</p> 
        </div>
        <div class="card">
            <h3>Battery Status</h3>
            <p id="battery">Loading...</p>
        </div>
        <div class="card" style="grid-column: span 2;">
            <h3>Real-Time Energy Consumption</h3>
            <canvas id="energyChart" width="400" height="200"></canvas>
        </div>
    </div>
    <script>
        let energyChart = new Chart(document.getElementById("energyChart"), {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: "Energy Consumption (Joules)",
                    data: [],
                    borderColor: "red",
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

        function updateStats() {
            fetch('/api/stats')
                .then(response => response.json())
                .then(data => {
                    document.getElementById("cpu").innerText = `Total: ${data.cpu_usage}%`;
                    document.getElementById("ram").innerText = `Total: ${data.memory_usage}%`;
                    document.getElementById("energy").innerText = `Total: ${data.energy} Joules`;
                    document.getElementById("battery").innerText = `Total: ${data.battery.battery} ${data.battery.charging}`;

                    energyChart.data.labels.push(new Date().toLocaleTimeString());
                    energyChart.data.datasets[0].data.push(data.energy);

                    if (energyChart.data.labels.length > 10) {
                        energyChart.data.labels.shift();
                        energyChart.data.datasets[0].data.shift();
                    }

                    energyChart.update();
                })
                .catch(error => {
                    console.error("Error fetching stats:", error);
                    document.getElementById("battery").innerText = "Battery status unavailable";
                });
        }

        setInterval(updateStats, 2000);
    </script>
</body>
</html>
