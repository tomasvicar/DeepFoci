# DeepFoci Python Analysis - AI Coding Agent Instructions

## Project Overview
This is a **3-step pipeline** for analyzing microscopy images of DNA damage foci (53BP1/gH2AX) following irradiation. The workflow processes `.ics` microscopy files through detection/segmentation networks, extracts features, and generates visualizations.

## Architecture & Data Flow

### Pipeline Steps (Sequential)
1. **`analyse_results_step1.py`**: Feature extraction from microscopy images
   - Reads `.ics` files from `data_path` using `read_ics_file_ordered()`
   - Loads pre-computed detections from `_net_results` and segmentations from `_net_results_oldseg`/`_fociseg`
   - Extracts per-nucleus and per-foci features (intensities, volumes, correlations, counts)
   - Outputs: HDF5 files to `_tmp_results` directory with keys: `nuc_features`, `foci_features`, `foci_features_points_channel*`
   - **Error handling**: Catches exceptions per file, writes to `errors/` with zero-padded filenames

2. **`save_results_step2.py`**: Aggregation and Excel export
   - Reads all `*_features.h5` files from `_tmp_results`
   - Groups foci features by nucleus, handles missing nuclei (fills with NaN)
   - Extracts metadata from file paths (cell_type: gamma-rays/X-rays, dose: Gy, time: hours, nanoparticles)
   - Outputs: Single `results.xlsx` file with flattened per-nucleus rows

3. **`plt_results_step3.py`**: Visualization
   - Reads `results.xlsx` from `_tmp_results`
   - Generates boxplots per feature, stratified by `gy_nps` (dose|nanoparticles) and `time`
   - Outputs: PNG files named `boxplot_{feature}_{cell_type}.png`

### Critical Path Conventions
- **Base path**: All paths constructed from single `data_path` variable (e.g., `r"D:\martin_urgent\URGENT_Naoparticle Manuscript Toufar"`)
- **Derived paths**: `_net_results`, `_tmp_results`, etc. appended to `data_path`
- **File matching**: Uses `.replace()` to map between input/output directories (e.g., `fname.replace(data_path, detection_path)`)
- **Channel ordering**: Helper `determine_channel_order()` in `read_ics_file.py` maps channels to [53BP1/RAD51, gH2AX, DAPI/TOPRO] based on name matching

## Environment Setup

### Micromamba (Not Conda/Pip)
- **Creation**: Run `create_micromamba_env.bat` (downloads micromamba, creates env from `environment.yml`)
- **Activation**: Use `activate_micromamba_env.bat` before running Python scripts
- **Location**: Installs to `..\..\micromamba` relative to script directory
- **Key dependencies**: napari, scikit-image, aicsimageio, bioformats_jar (see `environment.yml`)

### Python Execution Pattern
```powershell
# Activate environment first
.\activate_micromamba_env.bat
# Then run scripts sequentially
python analyse_results_step1.py
python save_results_step2.py
python plt_results_step3.py
```

## Code Patterns & Conventions

### Feature Calculation Pattern
```python
# Standard regionprops + custom properties for 3D masks
properties = regionprops_table(label_image, intensity_image, 
                               properties=['max_intensity', 'mean_intensity'])
# Always rename columns with suffix (e.g., 'max_intensity_r')
```

### Metadata Extraction from Paths
- Uses string manipulation on file paths to extract experimental conditions
- Pattern: `if 'gamma-rays' in fname:` → extract cell_type
- Pattern: `if '1Gy' in fname.replace(' ', ''):` → extract dose
- Time encoded in folder names (e.g., `30min` → 0.5, `1h` → 1, `nonIR` → -1)

### HDF5 Storage Strategy
- Use pandas `to_hdf()` with named keys (not pickle/CSV)
- Mode `'w'` for first table, `'a'` for appending additional tables
- Dynamic channel keys: `f'foci_features_points_channel{channel}'`

### Error Tolerance
- Step 1 uses try-except per file (not global) to continue processing on failures
- Zero-padded file numbers in error logs: `str(fnum).zfill(5) + '_error.txt'`
- Check `errors/` directory for processing failures

## Key Variables & Dimensions
- `resized_img_size = [505, 681, 48]`: Detection network output size
- `voxel_size_um = [0.1650, 0.1650, 0.3]`: XYZ resolution in micrometers
- `output_detection_channels`: `['points_53BP1', 'points_gH2AX', 'points_53BP1_gH2AX_overlap']`
- Data shape: `[H, W, Z, C]` where C=3 (red=53BP1/RAD51, green=gH2AX, blue=DAPI)

## Troubleshooting
- **Import errors**: Verify micromamba environment is activated
- **Path errors**: Check `data_path` matches your directory structure
- **Shape mismatches**: Zoom operations use `[1, 1, z_resize_faktor]` for Z-axis anisotropy correction
- **Solidity calculation failures**: Step 1 has fallback `solidity_safe()` for degenerate masks
