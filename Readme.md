# Complaints Dashboard

This repository contains a Shiny dashboard for the **CSAC Safeguarding Performance Report**.  

It lets you upload a prepared safeguard extract dataset and interactively generate figures required for reporting.  

⚠️ **Note:** Raw safeguard data is **not** included in this repository for information governance reasons.  
You must request the latest extract from the TrackWise team and prepare it as described below.  

⚡ A step-by-step guide is also provided in **`Detailed_SOP.docx`** within this repository. ⚡  

---

## 📦 Requirements

Before you start, request installation of the following (via Service Now if applicable):

- [R]  
- [RStudio]  
- Git (x64)  

---

## 📂 Repository Structure

```
SG_dashboard/
│
├── Data/ # Safeguard extract data
│ └── old_data/ # Archive of previous data extracts
│
├── SafeguardApp/ # Shiny app code
│ ├── ui.R # User interface definition
│ └── server.R # Server logic & outputs
│
├── Load_packages.R # Installs & loads required packages (run once)
├── Rproj_Safeguard.Rproj # RStudio project file
├── README.md # This file (quick instructions)
├── Detailed_SOP.docx # Detailed setup/run SOP
└── .gitignore # Repository tracking rules
```

---

## 🚀 Setup Instructions

### 1. Clone the Repository
Open **RStudio** → `File` → `New Project` → `Version Control` → `Git`  
Enter the repository URL:  
`https://github.com/OhinUKHSA/SG_dashboard.git`  

Choose a project directory name (e.g., `SG_dashboard`) and location.  
✅ This creates a local copy of the repo with all scripts (but not the data).  

---

### 2. Install Packages (first-time only)

1. Open **`Load_packages.R`** in RStudio.  
2. Run all lines (`Ctrl + A` → `Ctrl + Enter`).  
3. This may take a while.  
4. When complete, you should see:  

`All required packages are installed. You can run report.`  

✅ You only need to do this once.  

---

### 3. Prepare the Data

1. Navigate to `SG_dashboard/data/`.  
2. If a data file already exists, move it to `SG_dashboard/data/old_data/`.  
   - Recommended: create a dated subfolder within `old_data/` for version control.  
3. Paste the new **Safeguard.xlsx** file received from the data controller into the `data` folder.  
   - ⚠️ Filename may vary — the name is not important.  
4. ⚠️ The raw Excel file is restricted and cannot be used directly. To prepare it:  
   - Open the received file.  
   - Select all contents (**Ctrl + A**, then **Ctrl + C**).  
   - Open a new blank Excel workbook and paste (**Ctrl + V**).  
   - Save this new workbook in the `data` folder (filename is not important).  
   - Delete the original restricted file.  

---

### 4. Run the Dashboard

1. Open **`Rproj_Safeguard.Rproj`** in RStudio.  
2. Open **`SafeguardApp/server.R`** (or `ui.R`).  
3. Click **Run App** (or press **`Ctrl`** + **`Shift`** + **`Enter`**).  
4. In the app window, click **Browse** and select the prepared Excel/CSV file in `data/`.  
5. Adjust titles, stratification, aggregation (Month/Quarter/Year), and figure size as needed.  

---

## ⚠️ Important Notes
- Always archive the previous month’s data in `data/old_data/` before replacing it.  
- Do not edit any of the scripts.  
- Data must always come from the data controller.  

---

## ✅ Quick Checklist
- [ ]  Clone repo in RStudio.  
- [ ]  Run `Load_packages.R` (once).  
- [ ]  Archive old data → `data/old_data/`.  
- [ ]  Request new safeguard extract, copy into clean Excel file, save in `data/`.  
- [ ]  Open project → `server.R`/`ui.R` → **Run App**.  
- [ ]  Upload new file via **Browse** in the dashboard.  
- [ ]  Customise plot as needed.