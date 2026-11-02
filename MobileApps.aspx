<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MobileApps.aspx.cs" Inherits="Energy.MobileApps" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Mobile Apps Monitor</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
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
            grid-template-columns: 1fr;
            gap: 20px;
        }

        .card {
            background-color: #1e3d5f;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }

        pre {
            background-color: #12263a;
            color: white;
            padding: 20px;
            border-radius: 10px;
            white-space: pre-wrap;
            word-wrap: break-word;
            margin-top: 20px;
            overflow-x: auto;
        }

        .search-box {
            margin-bottom: 20px;
            display: flex;
            justify-content: flex-end;
        }

        .search-box input {
            padding: 5px;
            font-size: 14px;
            border: 1px solid #334756;
            border-radius: 5px;
            background-color: #1e3d5f;
            color: white;
        }

        .search-results {
            background-color: #1e3d5f;
            border-radius: 10px;
            padding: 10px;
            margin-top: 20px;
            text-align: left;
        }

        .search-results h4 {
            margin-top: 0;
            color: #f7c331;
        }

        .search-results p {
            margin: 5px 0;
            font-size: 14px;
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
            <h3>Mobile Apps Energy Consumption</h3>

            <div class="search-box">
                <input type="text" id="searchInput" placeholder="Search output..." onkeyup="filterOutput()">
            </div>

            <pre id="outputDisplay">Loading...</pre>
            <p id="lastUpdate">Last updated: --</p>
        </div>

        <div class="search-results" id="searchResults">
            <h4>Search Results</h4>
            <div id="resultFields"></div>
        </div>
    </div>

    <script type="text/javascript">
        let fullOutput = "";
        let parsedFields = [];

        function fetchOutput() {
            $.ajax({
                type: "GET",
                url: "/api/mobileapps",
                dataType: "json",
                success: function (output) {
                    fullOutput = output.rawOutput.join("\n");
                    $('#outputDisplay').text(fullOutput);
                    $('#lastUpdate').text("Last updated: " + new Date().toLocaleTimeString());
                    parseOutput(fullOutput);
                    filterOutput();
                },
                error: function () {
                    $('#outputDisplay').text('Error fetching data');
                }
            });
        }

        function parseOutput(output) {
            parsedFields = [];
            const lines = output.split("\n");
            lines.forEach(line => {
                const fields = line.split(/\s+/);
                if (fields.length >= 10) {
                    parsedFields.push({
                        pid: fields[0],
                        user: fields[1],
                        pr: fields[2],
                        ni: fields[3],
                        virt: fields[4],
                        res: fields[5],
                        shr: fields[6],
                        sscpu: fields[7],
                        smem: fields[8],
                        time: fields[9],
                        args: fields.slice(10).join(" ")
                    });
                }
            });
        }

        function filterOutput() {
            var input = document.getElementById("searchInput").value.toLowerCase();
            if (input === "") {
                displaySearchResults(parsedFields);
            } else {
                var filteredFields = parsedFields.filter(field => {
                    return (
                        field.pid.toLowerCase().includes(input) ||
                        field.user.toLowerCase().includes(input) ||
                        field.pr.toLowerCase().includes(input) ||
                        field.ni.toLowerCase().includes(input) ||
                        field.virt.toLowerCase().includes(input) ||
                        field.res.toLowerCase().includes(input) ||
                        field.shr.toLowerCase().includes(input) ||
                        field.sscpu.toLowerCase().includes(input) ||
                        field.smem.toLowerCase().includes(input) ||
                        field.time.toLowerCase().includes(input) ||
                        field.args.toLowerCase().includes(input)
                    );
                });
                displaySearchResults(filteredFields);
            }
        }

        function displaySearchResults(filteredFields) {
            let resultContainer = document.getElementById("resultFields");
            resultContainer.innerHTML = "";

            // Constants for power estimation
            const CPU_POWER_PER_CORE_W = 1.5;         // Typical mobile value
            const MEMORY_POWER_PER_GB_W = 0.3;        // Typical mobile RAM wattage
            const DURATION_SECONDS = 1;
            const TOTAL_RAM_GB = 4;

            filteredFields.forEach(field => {
                let cpuStr = field.sscpu.replace(/[\[%\]]/g, '');
                let memStr = field.smem.replace('%', '');

                let cpuPercent = parseFloat(cpuStr) || 0;
                let memPercent = parseFloat(memStr) || 0;

                let cpuUsage = cpuPercent / 100;               // e.g., 60% → 0.6
                let memoryUsage = (memPercent / 100) * TOTAL_RAM_GB; // % of total GB

                let cpuEnergy = cpuUsage * CPU_POWER_PER_CORE_W * DURATION_SECONDS;
                let memoryEnergy = memoryUsage * MEMORY_POWER_PER_GB_W * DURATION_SECONDS;
                let totalEnergy = (cpuEnergy + memoryEnergy).toFixed(4); // Joules

                let resultItem = document.createElement("p");
                resultItem.innerHTML = `
            <strong>PID:</strong> ${field.pid} 
            <strong>USER:</strong> ${field.user} 
            <strong>PR:</strong> ${field.pr} 
            <strong>NI:</strong> ${field.ni} 
            <strong>VIRT:</strong> ${field.virt} 
            <strong>RES:</strong> ${field.res} 
            <strong>SHR:</strong> ${field.shr} 
            <strong>SSCPU:</strong> ${field.sscpu} 
            <strong>SMEM:</strong> ${field.smem} 
            <strong>TIME:</strong> ${field.time} 
            <strong>ARGS:</strong> ${field.args} 
            <strong>Energy Used:</strong> ${totalEnergy} Joules
        `;
                resultContainer.appendChild(resultItem);
            });
        }




        $(document).ready(function () {
            fetchOutput();
            setInterval(fetchOutput, 2000);
        });
    </script>
</body>
</html>
