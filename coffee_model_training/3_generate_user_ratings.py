import pandas as pd
import numpy as np
import os

SCORE_COLS = [
    "Data.Scores.Aroma", "Data.Scores.Flavor", "Data.Scores.Aftertaste",
    "Data.Scores.Acidity", "Data.Scores.Body", "Data.Scores.Balance",
    "Data.Scores.Uniformity", "Data.Scores.Sweetness", "Data.Scores.Moisture",
]

ROAST_PREFERENCES = {
    "light_lover":  {"Data.Scores.Acidity": 1.5, "Data.Scores.Aroma": 1.2, "Data.Scores.Body": -0.5},
    "dark_lover":   {"Data.Scores.Body": 1.5, "Data.Scores.Aftertaste": 1.2, "Data.Scores.Acidity": -0.8},
    "balanced":     {col: 0.5 for col in SCORE_COLS},
    "sweet_tooth":  {"Data.Scores.Sweetness": 2.0, "Data.Scores.Balance": 1.0},
    "aroma_fan":    {"Data.Scores.Aroma": 2.0, "Data.Scores.Flavor": 1.0},
}

NUM_USERS = 50
RATINGS_PER_USER = 20
NOISE = 0.8


def generate(csv_path="coffee.csv", output_dir="output"):
    os.makedirs(output_dir, exist_ok=True)

    df = pd.read_csv(csv_path).dropna(subset=SCORE_COLS)
    df = df.reset_index(drop=True)

    rng = np.random.default_rng(42)
    records = []

    user_types = list(ROAST_PREFERENCES.keys())

    for user_id in range(NUM_USERS):
        user_type = user_types[user_id % len(user_types)]
        prefs = ROAST_PREFERENCES[user_type]

        sampled_indices = rng.choice(len(df), size=RATINGS_PER_USER, replace=False)

        for idx in sampled_indices:
            row = df.iloc[idx]
            score = 0.0
            for col in SCORE_COLS:
                weight = prefs.get(col, 0.3)
                score += weight * row[col]

            # Normalize to 1-5 rating and add noise
            score_norm = score / (sum(abs(v) for v in prefs.values()) * 10)
            rating = float(np.clip(score_norm * 5 + rng.normal(0, NOISE), 1, 5))
            rating = round(rating, 1)

            records.append({
                "user_id": user_id,
                "user_type": user_type,
                "coffee_idx": idx,
                "rating": rating,
            })

    ratings_df = pd.DataFrame(records)
    out_path = os.path.join(output_dir, "user_ratings.csv")
    ratings_df.to_csv(out_path, index=False)

    print(f"Generated {len(ratings_df)} ratings for {NUM_USERS} users")
    print(ratings_df.groupby("user_type")["rating"].mean().round(2))
    print(f"\nSaved to {out_path}")


if __name__ == "__main__":
    generate()
