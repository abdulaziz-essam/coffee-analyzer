"""
coffee_pipeline.py — convenience wrapper to run the full pipeline as a module.
Usage:  python coffee_pipeline.py
"""
import os
import sys
import shutil

sys.path.insert(0, os.path.dirname(__file__))

FLUTTER_ASSETS = os.path.join(
    os.path.dirname(__file__), "..", "flutter_cv", "assets", "models"
)


def run():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    print("=== Preprocess ===")
    import importlib
    preprocess = importlib.import_module("2_preprocess_data")
    preprocess.preprocess()

    print("\n=== Generate user ratings ===")
    ratings = importlib.import_module("3_generate_user_ratings")
    ratings.generate()

    print("\n=== Train model ===")
    train_mod = importlib.import_module("4_train_model")
    train_mod.train()

    print("\n=== Evaluate ===")
    eval_mod = importlib.import_module("6_evaluate_model")
    eval_mod.evaluate()

    # Copy to Flutter
    tflite_src = os.path.join("output", "coffee_model.tflite")
    if os.path.exists(tflite_src) and os.path.isdir(FLUTTER_ASSETS):
        dst = os.path.join(FLUTTER_ASSETS, "coffee_model.tflite")
        shutil.copy2(tflite_src, dst)
        print(f"\nTFLite model deployed to Flutter: {dst}")
    else:
        print(f"\nWarning: could not copy to Flutter assets. src={tflite_src}")


if __name__ == "__main__":
    run()
