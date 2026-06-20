"""
Coffee Roast Classifier — full pipeline runner.
Runs all 6 steps in sequence and copies the trained TFLite model
to the Flutter app's assets folder.
"""
import os
import shutil
import sys

FLUTTER_ASSETS = os.path.join(
    os.path.dirname(__file__), "..", "flutter_cv", "assets", "models"
)


def run_step(name, fn):
    print(f"\n{'=' * 60}")
    print(f"  {name}")
    print("=" * 60)
    fn()


def main():
    # Step 1 – explore
    from importlib import import_module

    def step1():
        import pandas as pd
        import numpy as np
        df = pd.read_csv("coffee.csv")
        print(f"Shape: {df.shape}")
        print(df["Data.Color"].value_counts())

    run_step("Step 1: Explore data", step1)

    # Step 2 – preprocess
    run_step("Step 2: Preprocess data", lambda: __import__("2_preprocess_data", fromlist=[""]).preprocess())

    # Step 3 – generate ratings
    run_step("Step 3: Generate user ratings", lambda: __import__("3_generate_user_ratings", fromlist=[""]).generate())

    # Step 4 – train
    run_step("Step 4: Train model", lambda: __import__("4_train_model", fromlist=[""]).train())

    # Step 5 – recommendations (demo)
    run_step("Step 5: Make recommendations", lambda: None)  # run standalone for interactive demo

    # Step 6 – evaluate
    run_step("Step 6: Evaluate model", lambda: __import__("6_evaluate_model", fromlist=[""]).evaluate())

    # Copy TFLite to Flutter assets
    tflite_src = os.path.join("output", "coffee_model.tflite")
    if os.path.exists(tflite_src) and os.path.isdir(FLUTTER_ASSETS):
        dst = os.path.join(FLUTTER_ASSETS, "coffee_model.tflite")
        shutil.copy2(tflite_src, dst)
        print(f"\nCopied TFLite model to Flutter: {dst}")
    else:
        print(f"\nSkipped Flutter copy (src={tflite_src}, dst={FLUTTER_ASSETS})")

    print("\nPipeline complete.")


if __name__ == "__main__":
    # Allow importing numbered modules
    sys.path.insert(0, os.path.dirname(__file__))
    main()
