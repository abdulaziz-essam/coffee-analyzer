import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
import pickle
import os

SCORE_COLS = [
    "Data.Scores.Aroma", "Data.Scores.Flavor", "Data.Scores.Aftertaste",
    "Data.Scores.Acidity", "Data.Scores.Body", "Data.Scores.Balance",
    "Data.Scores.Uniformity", "Data.Scores.Sweetness", "Data.Scores.Moisture",
]

def assign_roast_label(row):
    """
    Assign a roast category from score patterns, ensuring all 4 classes appear.
    Uses total score quartiles + score profile to distinguish roast levels.
    - Green: lowest total scores (raw/defective beans)
    - Light: high acidity relative to body
    - Dark: high body relative to acidity
    - Medium: balanced
    """
    total = row["Data.Scores.Total"]
    acidity = row["Data.Scores.Acidity"]
    body = row["Data.Scores.Body"]
    sweetness = row["Data.Scores.Sweetness"]
    aroma = row["Data.Scores.Aroma"]
    balance = row["Data.Scores.Balance"]

    # Green: very low total (bottom ~15%)
    if total < 82.5:
        return "Green"

    # Use acidity-body ratio to split Light / Dark / Medium
    ratio = acidity - body  # positive = more acidic (light), negative = more body (dark)
    sweetness_score = sweetness + balance

    if ratio > 0.3 and aroma >= 7.8:
        return "Light"
    elif ratio < -0.2 or (body >= 8.0 and sweetness_score < 15.5):
        return "Dark"
    else:
        return "Medium"


def preprocess(csv_path="coffee.csv", output_dir="output"):
    os.makedirs(output_dir, exist_ok=True)

    df = pd.read_csv(csv_path)

    # Drop rows with missing score values
    df = df.dropna(subset=SCORE_COLS + ["Data.Scores.Total"])

    # Assign labels
    df["roast_label"] = df.apply(assign_roast_label, axis=1)

    print("=== Label distribution ===")
    print(df["roast_label"].value_counts())

    # Features = score columns
    X = df[SCORE_COLS].values.astype(np.float32)
    y = df["roast_label"].values

    # Encode labels
    le = LabelEncoder()
    y_encoded = le.fit_transform(y)

    print(f"\nClasses: {list(le.classes_)}")
    print(f"Total samples: {len(X)}")

    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Save scaler and encoder for later use
    with open(os.path.join(output_dir, "scaler.pkl"), "wb") as f:
        pickle.dump(scaler, f)
    with open(os.path.join(output_dir, "label_encoder.pkl"), "wb") as f:
        pickle.dump(le, f)

    # Save preprocessed arrays
    np.save(os.path.join(output_dir, "X.npy"), X_scaled)
    np.save(os.path.join(output_dir, "y.npy"), y_encoded)

    print(f"\nSaved X.npy ({X_scaled.shape}), y.npy, scaler.pkl, label_encoder.pkl to {output_dir}/")
    return X_scaled, y_encoded, le, scaler


if __name__ == "__main__":
    preprocess()
