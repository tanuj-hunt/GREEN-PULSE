<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Apps Energy Consumption</title>
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
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #12263a;
            color: white;
            text-align: left;
        }
        th, td {
            padding: 10px;
            border: 1px solid #334756;
        }
        th {
            background-color: #1e3d5f;
        }
        .clickable {
            color: #f7c331;
            cursor: pointer;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>GREEN PULSE</h2>
        <ul>
            <li><a href="Home.aspx">Dashboard</a></li>
            <li><a href="Apps.aspx">Apps</a></li>
            <li><a href="Emissions.aspx">Emissions</a></li>
            <li><a href="Mobile.aspx">Mobile</a></li>
            <li><a href="ai.aspx">AI</a></li>
        </ul>
    </div>
    <div class="content">
        <div class="card" style="grid-column: span 2;">
            <h3>Apps Energy Consumption</h3>
            <table>
                <thead>
                    <tr>
                        <th>Application</th>
                        <th>CPU Usage (%)</th>
                        <th>Memory Usage (MB)</th>
                        <th>Energy Consumption (Joules)</th>
                    </tr>
                </thead>
                <tbody id="appsTable">
                    <tr><td colspan="4">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function updateAppsStats() {
            fetch('/api/appsStats')
                .then(response => response.json())
                .then(data => {
                    let appsTable = document.getElementById("appsTable");
                    appsTable.innerHTML = "";

                    if (!data || data.length === 0) {
                        appsTable.innerHTML = "<tr><td colspan='4'>No data available</td></tr>";
                        return;
                    }

                    data.forEach(app => {
                        let row = document.createElement("tr");
                        row.innerHTML = `
                            <td><a href="appDetails.aspx?name=${encodeURIComponent(app.name)}" class="clickable">${app.name || "N/A"}</a></td>
                            <td>${app.cpu_usage || 0}%</td>
                            <td>${app.memory_usage || 0} MB</td>
                            <td>${app.energy || 0} J</td>
                        `;
                        appsTable.appendChild(row);
                    });
                })
                .catch(error => console.error("Error fetching apps data:", error));
        }

        setInterval(updateAppsStats, 2000);
        updateAppsStats();
    </script>
</body>
</html>
