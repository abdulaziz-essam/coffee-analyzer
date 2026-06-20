import numpy as np
import pandas as pd
import pickle
import os
import tensorflow as tf

OUTPUT_DIR = "output"
SCORE_COLS = [
    "Data.Scores.Aroma", "Data.Scores.Flavor", "Data.Scores.Aftertaste",
    "Data.Scores.Acidity", "Data.Scores.Body", "Data.Scores.Balance",
    "Data.Scores.Uniformity", "Data.Scores.Sweetness", "Data.Scores.Moisture",
]


def load_artifacts(output_dir=OUTPUT_DIR):
    with open(os.path.join(output_dir, "scaler.pkl"), "rb") as f:
        scaler = pickle.load(f)
    with open(os.path.join(output_dir, "label_encoder.pkl"), "rb") as f:
        le = pickle.load(f)
    model = tf.keras.models.load_model(os.path.join(output_dir, "coffee_model.keras"))
    return model, scaler, le


def predict_roast(scores_dict, model, scaler, le):
    """
    Predict the roast category for a given coffee defined by its scores.
    scores_dict: {column_name: value} for each SCORE_COLS entry.
    """
    row = np.array([[scores_dict.get(col, 0.0) for col in SCORE_COLS]], dtype=np.float32)
    row_scaled = scaler.transform(row)
    probs = model.predict(row_scaled, verbose=0)[0]
    pred_idx = np.argmax(probs)
    label = le.classes_[pred_idx]
    return label, dict(zip(le.classes_, probs.tolist()))


def recommend_top_coffees(preferred_roast, df, model, scaler, le, top_n=5):
    """Return top_n coffees from df whose predicted roast matches the preference."""
    df_clean = df.dropna(subset=SCORE_COLS).copy()
    X = scaler.transform(df_clean[SCORE_COLS].values.astype(np.float32))
    probs = model.predict(X, verbose=0)
    pred_labels = le.inverse_transform(np.argmax(probs, axis=1))
    df_clean["predicted_roast"] = pred_labels

    class_idx = list(le.classes_).index(preferred_roast)
    df_clean["roast_confidence"] = probs[:, class_idx]

    matches = df_clean[df_clean["predicted_roast"] == preferred_roast]
    top = matches.nlargest(top_n, "roast_confidence")[
        ["Data.Owner", "Location.Country", "Data.Type.Variety",
         "Data.Scores.Total", "predicted_roast", "roast_confidence"]
    ]
    return top


if __name__ == "__main__":
    model, scaler, le = load_artifacts()
    df = pd.read_csv("coffee.csv")

    # Example: predict a single sample
    sample = {
        "Data.Scores.Aroma": 8.5,
        "Data.Scores.Flavor": 8.2,
        "Data.Scores.Aftertaste": 7.9,
        "Data.Scores.Acidity": 8.3,
        "Data.Scores.Body": 7.6,
        "Data.Scores.Balance": 8.0,
        "Data.Scores.Uniformity": 10.0,
        "Data.Scores.Sweetness": 10.0,
        "Data.Scores.Moisture": 0.1,
    }
    label, probs = predict_roast(sample, model, scaler, le)
    print(f"Predicted roast: {label}")
    for cls, p in sorted(probs.items(), key=lambda x: -x[1]):
        print(f"  {cls}: {p:.3f}")

    print("\n=== Top 5 Light Roast recommendations ===")
    print(recommend_top_coffees("Light", df, model, scaler, le).to_string(index=False))

    print("\n=== Top 5 Dark Roast recommendations ===")
    print(recommend_top_coffees("Dark", df, model, scaler, le).to_string(index=False))
