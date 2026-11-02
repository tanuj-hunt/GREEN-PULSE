<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>PC Emissions</title>
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
            display: flex;
            flex-direction: column;
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
            <li><a href="home.aspx">Dashboard</a></li>
            <li><a href="PCApps.aspx">Apps</a></li>
            <li><a href="emissions.aspx">Emissions</a></li>
            <li><a href="Mobile.aspx">Mobile</a></li>
            <li><a href="ai.aspx">AI</a></li>
            <li><a href="energyred.aspx">Ways to reduce energy</a></li>
        </ul>
    </div>
    <div class="content">
        <div class="card">
            <h3>Total CO₂ Emissions</h3>
            <p id="emissions">Loading...</p>
        </div>
        <div class="card">
            <h3>Real-Time Emissions</h3>
            <canvas id="emissionsChart" width="400" height="200"></canvas>
        </div>
    </div>
    <script>
        let emissionsChart = new Chart(document.getElementById("emissionsChart"), {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: "CO₂ Emissions (g)",
                    data: [],
                    borderColor: "green",
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

        function updateEmissions() {
            fetch('/api/emissionsStats')
                .then(response => response.json())
                .then(data => {
                    document.getElementById("emissions").innerText = `Total: ${data.co2} g`;
                    
                    emissionsChart.data.labels.push(new Date().toLocaleTimeString());
                    emissionsChart.data.datasets[0].data.push(data.co2);
                    
                    if (emissionsChart.data.labels.length > 10) {
                        emissionsChart.data.labels.shift();
                        emissionsChart.data.datasets[0].data.shift();
                    }
                    
                    emissionsChart.update();
                })
                .catch(error => console.error("Error fetching emissions stats:", error));
        }
        
        setInterval(updateEmissions, 2000);
    </script>
</body>
</html>
