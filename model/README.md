# Coffee Bean Classification Model

This directory contains the machine learning model for classifying coffee beans into four categories: Dark, Green, Light, and Medium.

## Prerequisites

- Python 3.8+
- pip (Python package manager)

## Setup

### 1. Install Dependencies

```bash
cd model
pip install -r requirements.txt
```

### 2. Download Dataset

The dataset (images and coffee.csv) is not included in the repository due to size constraints. You need to download it separately.

**Dataset Structure Required:**
```
model/
  └── data/
      └── raw/
          ├── Dark/       # Dark roast coffee bean images
          ├── Green/      # Green coffee bean images
          ├── Light/      # Light roast coffee bean images
          └── Medium/     # Medium roast coffee bean images
  └── coffee.csv          # Metadata file (optional)
```

**Steps to prepare the dataset:**

1. Download the coffee bean images dataset
2. Place images in the corresponding category folders under `model/data/raw/`
3. (Optional) Place `coffee.csv` in the `model/` directory if you have metadata

Example:
```bash
# Create the raw data directory structure
mkdir -p model/data/raw/Dark
mkdir -p model/data/raw/Green
mkdir -p model/data/raw/Light
mkdir -p model/data/raw/Medium

# Copy your downloaded images to the respective folders
# e.g., cp /path/to/dark/roast/images/* model/data/raw/Dark/
```

### 3. Split Dataset

Before training, you need to split the raw images into training, validation, and test sets.

Run the data splitting script:

```bash
cd model
python scripts/data_split.py
```

This will:
- Create three datasets: train (80%), validation (10%), test (10%)
- Organize images into `model/data/splits/train/`, `validation/`, and `test/`
- Each split will maintain the same category structure (Dark, Green, Light, Medium)

**Expected output structure after splitting:**
```
model/
  └── data/
      ├── raw/              # Original images (untouched)
      └── splits/
          ├── train/        # 80% of images
          │   ├── Dark/
          │   ├── Green/
          │   ├── Light/
          │   └── Medium/
          ├── validation/   # 10% of images
          │   ├── Dark/
          │   ├── Green/
          │   ├── Light/
          │   └── Medium/
          └── test/         # 10% of images
              ├── Dark/
              ├── Green/
              ├── Light/
              └── Medium/
```

## Usage

### Training the Model

```bash
python scripts/train.py
```

### Evaluating the Model

```bash
python scripts/evaluate.py
```

### Making Predictions

```bash
python api/predict.py --image path/to/image.jpg
```

## Directory Structure

```
model/
├── api/                  # API endpoints for model inference
├── checkpoints/          # Training checkpoints
├── data/                 # Dataset directory (not in git)
│   ├── raw/             # Original unprocessed images
│   ├── splits/          # Train/validation/test splits
│   └── processed/       # Any processed data
├── docs/                 # Documentation
├── evaluation/           # Evaluation scripts and results
├── notebooks/            # Jupyter notebooks for experimentation
├── saved_models/         # Trained model files
├── scripts/              # Utility scripts
│   └── data_split.py    # Dataset splitting script
├── coffee.csv           # Metadata (not in git)
└── requirements.txt     # Python dependencies
```

## Notes

- The `model/data/` directory is excluded from git (see `.gitignore`)
- Make sure to download and prepare the dataset before training
- The dataset split uses a random seed (42) for reproducibility
- Re-running the split script will recreate the train/validation/test folders

## Troubleshooting

**Error: "Source directory not found"**
- Ensure images are placed in `model/data/raw/` with the correct category folders

**Error: "No images found in category"**
- Check that image files are in supported formats (.jpg, .jpeg, .png, .gif)
- Verify images are in the correct category folders

**Permission errors**
- Ensure you have write permissions in the `model/data/` directory
