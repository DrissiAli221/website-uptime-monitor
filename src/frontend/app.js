const API_URL =
  "https://2rfse0ixxg.execute-api.us-east-1.amazonaws.com/history";

async function loadDashboard() {
  try {
    const response = await fetch(API_URL);
    const data = await response.json();

    // Prepare data for the graph
    const labels = data.map((item) =>
      new Date(item.Timestamp).toLocaleTimeString()
    );
    const usData = data.map((item) => item["us-east-1"]?.Latency || 0);
    const euData = data.map((item) => item["eu-west-1"]?.Latency || 0);

    // chart
    const ctx = document.getElementById("latencyChart").getContext("2d");
    new Chart(ctx, {
      type: "line",
      data: {
        labels: labels.reverse(), // Show oldest to newest
        datasets: [
          {
            label: "US (Virginia)",
            data: usData.reverse(),
            borderColor: "#36a2eb",
            tension: 0.4,
          },
          {
            label: "EU (Ireland)",
            data: euData.reverse(),
            borderColor: "#ff6384",
            tension: 0.4,
          },
        ],
      },
      options: {
        responsive: true,
        plugins: { legend: { labels: { color: "white" } } },
        scales: {
          y: { grid: { color: "#444" }, ticks: { color: "white" } },
          x: { ticks: { color: "white" } },
        },
      },
    });

    // table
    const tableBody = document.querySelector("#historyTable tbody");
    // Take only the last 10 items for the table
    data.slice(0, 10).forEach((item) => {
      const row = document.createElement("tr");

      const usLat = item["us-east-1"]?.Latency || "N/A";
      const euLat = item["eu-west-1"]?.Latency || "N/A";
      const isSuccess =
        item["us-east-1"]?.Success && item["eu-west-1"]?.Success;

      row.innerHTML = `
                <td>${new Date(item.Timestamp).toLocaleString()}</td>
                <td class="latency">${usLat}ms</td>
                <td class="latency">${euLat}ms</td>
                <td class="${isSuccess ? "status-up" : "status-down"}">
                    ${isSuccess ? "UP" : "DOWN"}
                </td>
            `;
      tableBody.appendChild(row);
    });
  } catch (error) {
    console.error("Error loading dashboard:", error);
    alert("Failed to load data. Check console for details.");
  }
}

loadDashboard();
