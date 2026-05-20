# 🚀 Rocketship Automatic

> **Headless batch wrapper for [ROCKETSHIP](https://github.com/petmri/ROCKETSHIP). Instead of clicking through the GUI for every patient (~2 min per run, lots of nerves), the full DCE-MRI pharmacokinetic pipeline runs unattended over entire cohorts.**

![MATLAB](https://img.shields.io/badge/MATLAB-R2018a-blue)
![Status](https://img.shields.io/badge/status-research--tool-orange)

[📺 Demo Video](https://www.youtube.com/watch?v=a_986KPguXM)

![Demo](vid.gif)

---

## 💡 Motivation

[ROCKETSHIP](https://github.com/petmri/ROCKETSHIP) is a well-established MATLAB toolkit for DCE-MRI analysis, but it is GUI-driven. For each patient you have to:

1. Upload data manually
2. Set parameters
3. Click through T1 mapping, AIF/VIF, pharmacokinetic fit one by one
4. Wait for each module to finish

For a cohort of 10+ patients this quickly becomes a full-day task with a high risk of human error from manual steps. **This repo solves exactly that problem**: the GUI is fully replaced by a script that scans the directory structure, auto-detects patients, and runs the complete pipeline with logging and error handling.

> ⚠️ **Note:** ROCKETSHIP itself is not part of this repo. This project is an **automation wrapper** that invokes ROCKETSHIP's modules headlessly.

---

## ⚙️ What the wrapper does

- 🔍 **Auto-discovery** of all patient directories in the data folder
- 🧬 **Pattern-based file detection** (`4DFlip02.nii`, `T1_map*.nii`, `moco_*`, `Hippo*.nii`, `VIF*.nii`, `AIF*.nii`)
- 💧 **Hematocrit lookup** via central Excel table, with fallback to a default value
- 🔀 **Parallel AIF and VIF analysis** with separate output folders
- 📊 **T1 mapping** with linear flip-angle fit (`t1_fa_linear_fit`)
- 📝 **Full logging** per patient & pipeline stage (success / error / skip)
- 🎛️ **Modular run flags** – individual ROCKETSHIP stages (A/B/D) can be toggled selectively
- 🐛 **DEBUG mode** – dry-run without actual computation
- 🛡️ **Robust error handling** – try/catch around every stage, a single failing patient does not stop the whole cohort

---

## 🔁 Pipeline

```
Patient folders (auto-scan)
        │
        ▼
  4DFlip02.nii  ──► calculateMap (T1 mapping)
        │
        ▼
  T1_map*.nii   ──► converted to real-valued
        │
        ▼
  moco_*        ──► motion-corrected DCE
        │
        ▼
  Hippo*.nii    ──► ROI for T1
        │
        ├─► VIF*.nii  ──► loadIMGVOL ► Run A ► Run B ► Run D
        │
        └─► AIF*.nii  ──► loadIMGVOL ► Run A ► Run B ► Run D
```

**ROCKETSHIP modules called headlessly:**
- `calculateMap_conf` – T1 mapping
- `loadIMGVOL_conf` – image volume loading & consistency check
- `A_make_R1maps_func_conf` – R1-map generation
- `B_AIF_fitting_func_conf` – AIF fitting
- `D_fit_voxels_func_conf` – voxel-wise pharmacokinetic fit (Patlak by default; Tofts / ex-Tofts / 2CXM / FXR / etc. configurable)

---

## 📋 Prerequisites

- **MATLAB R2018a** (tested version)
- **[ROCKETSHIP](https://github.com/petmri/ROCKETSHIP)** cloned locally
- Patient data in NIfTI format (`.nii` / `.nii.gz`)
- `hematocrit_table.xlsx` with patient IDs

---

## 📥 Installation

```bash
# 1. Clone ROCKETSHIP
git clone https://github.com/petmri/ROCKETSHIP.git

# 2. Clone this repo
git clone https://github.com/mendeltem/rocketship_automatic.git
cd rocketship_automatic
```

The following wrapper files must live in the same folder (already included in the repo):

```
rocket_ship_projekt.m       # Main script
A_make_R1maps_func_conf.m   # Headless Run-A wrapper
B_AIF_fitting_func_conf.m   # Headless Run-B wrapper
D_fit_voxels_func_conf.m    # Headless Run-D wrapper
loadIMGVOL_conf.m           # Headless loadIMGVOL wrapper
calculateMap_conf.m         # Headless T1 mapping wrapper
```

---

## 📁 Expected data structure

```
rocketship_data/
├── hematocrit_table.xlsx       # ID → hematocrit value
├── Patient_001/
│   ├── 4DFlip02.nii            # 4D flip-angle series for T1
│   ├── T1_map.nii              # T1 map (will be generated)
│   ├── moco_*.nii.gz           # Motion-corrected DCE
│   ├── Hippo_*.nii             # Hippocampus ROI
│   ├── VIF_*.nii               # Venous Input Function ROI
│   └── AIF_*.nii               # Arterial Input Function ROI
├── Patient_002/
│   └── ...
└── ...
```

**`hematocrit_table.xlsx` format:**

| ID          | Hematocrit |
|-------------|-----------|
| Patient_001 | 0.42      |
| Patient_002 | 0.38      |

Patients without an entry fall back to `standard_hematocrit` (default: `0.4`).

---

## 🎛️ Configuration

Edit `rocket_ship_projekt.m`:

```matlab
% ROCKETSHIP path
mfilepath = "../ROCKETSHIP/";

% Data path
data_path = "data/";

% Acquisition parameters
tr = '55';                 % TR in ms
fa = '25';                 % Flip angle in degrees
relaxivity = '5';
standard_hematocrit = '0.4';
time_resolution = 6.33;    % seconds per DCE frame
injection_duration = 5;

% Choose DCE model (set one to 1)
dce_model.patlak        = 1;   % Default: Patlak
dce_model.tofts         = 0;
dce_model.ex_tofts      = 0;
dce_model.two_cxm       = 0;
dce_model.tissue_uptake = 0;
dce_model.fxr           = 0;
% ...

% Selective execution
RUNCALCULATE = 1;    % T1 mapping
RUN_A = 1;           % R1 maps
RUN_B = 1;           % AIF fitting
RUN_D = 1;           % Voxel fit
RUN_FULL = 1;        % 0 = only 1 patient (test mode)
DEBUG = 0;           % 1 = dry run
```

---

## ▶️ Run it

In MATLAB:

```matlab
>> rocket_ship_projekt
```

Or headless:

```bash
matlab -batch "rocket_ship_projekt"
```

---

## 📤 Output & logs

For each patient, **two sub-folders** are created – one for VIF, one for AIF:

```
Patient_001/
├── Hippo_X_VIF_Y/      # VIF analysis
│   ├── A_results.mat
│   ├── B_results.mat
│   └── D_results.mat
└── Hippo_X_AIF_Y/      # AIF analysis
    ├── A_results.mat
    ├── B_results.mat
    └── D_results.mat
```

**Log file** (`data/log.txt`) records for every patient:

- Timestamp
- Which files were found / not found
- Success/error of every pipeline stage
- Hematocrit value used
- Injection times

---

## 📚 File overview

| File                           | Purpose                                                  |
|--------------------------------|----------------------------------------------------------|
| `rocket_ship_projekt.m`        | Main script. Orchestrates the entire batch pipeline      |
| `calculateMap_conf.m`          | Headless wrapper for ROCKETSHIP's T1 mapping             |
| `loadIMGVOL_conf.m`            | Headless wrapper for image volume loading                |
| `A_make_R1maps_func_conf.m`    | Headless wrapper for Run A (R1 map generation)           |
| `B_AIF_fitting_func_conf.m`    | Headless wrapper for Run B (AIF fitting)                 |
| `D_fit_voxels_func_conf.m`     | Headless wrapper for Run D (voxel-wise pharmacokinetics) |
| `fslstats_testautomatic.m`     | FSL stats helper script                                  |
| `test_single_fslstat.m`        | Single test run                                          |

---

## 🙏 Acknowledgements

- The original [ROCKETSHIP](https://github.com/petmri/ROCKETSHIP) toolkit. Without it there would be nothing to automate
- Charité – Universitätsmedizin Berlin, Center for Stroke Research Berlin (CSB)

---

## 📄 License

Note that ROCKETSHIP has its own license. Please refer to its repository for licensing terms.
