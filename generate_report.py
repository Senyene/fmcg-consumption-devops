# --- FACTORY DATA GENERATOR ---
import datetime

# 1. DATA LAYER: In a real factory, this data might come from 
# an Excel file, a database (SQL), or a consumption log.
factory_data = {
    "location": "Lagos, Nigeria",
    "status": "Online",
    "last_batch_weight": "2,851 kg",
    "efficiency": "98.5%"
}

# 2. PRESENTATION LAYER: We define the 'Look and Feel' using HTML/CSS.
# We use an 'f-string' to inject our Python data directly into the HTML.
html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FMCG Consumption Dashboard</title>
    <style>
        body {{ 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #f4f7f6; 
            display: flex; 
            justify-content: center; 
            padding: 50px; 
        }}
        .card {{ 
            background: white; 
            padding: 30px; 
            border-radius: 12px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1); 
            width: 400px; 
        }}
        h1 {{ color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }}
        .stat {{ margin: 15px 0; font-size: 1.1em; color: #34495e; }}
        .label {{ font-weight: bold; color: #7f8c8d; }}
        .footer {{ margin-top: 20px; font-size: 0.8em; color: #bdc3c7; }}
    </style>
</head>
<body>
    <div class="card">
        <h1>Factory Dashboard</h1>
        <div class="stat"><span class="label">Location:</span> {factory_data['location']}</div>
        <div class="stat"><span class="label">System Status:</span> <span style="color: #27ae60;">{factory_data['status']}</span></div>
        <div class="stat"><span class="label">Last Batch:</span> {factory_data['last_batch_weight']}</div>
        <div class="stat"><span class="label">Efficiency:</span> {factory_data['efficiency']}</div>
        
        <div class="footer">Last automated update: {datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</div>
    </div>
</body>
</html>
"""

# 3. FILE SYSTEM LAYER: Save the generated HTML to a file.
# The GitHub Action will later pick up this file and upload it to AWS.
with open("index.html", "w") as f:
    f.write(html_content)

print("SUCCESS: index.html has been generated with the latest factory logs.")
