import pandas as pd
import numpy as np

df = pd.read_csv("coffee.csv")

print("=== Dataset Info ===")
print(df.info())
print("\n=== First 5 rows ===")
print(df.head())
print("\n=== Score columns stats ===")
score_cols = [
    "Data.Scores.Aroma", "Data.Scores.Flavor", "Data.Scores.Aftertaste",
    "Data.Scores.Acidity", "Data.Scores.Body", "Data.Scores.Balance",
    "Data.Scores.Uniformity", "Data.Scores.Sweetness", "Data.Scores.Moisture",
    "Data.Scores.Total",
]
print(df[score_cols].describe())
print("\n=== Color distribution ===")
print(df["Data.Color"].value_counts())
print("\n=== Species distribution ===")
print(df["Data.Type.Species"].value_counts())
print("\n=== Missing values ===")
print(df.isnull().sum())
