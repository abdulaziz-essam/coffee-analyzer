import numpy as np
import pickle
import os
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split

OUTPUT_DIR = "output"


def evaluate(output_dir=OUTPUT_DIR):
    X = np.load(os.path.join(output_dir, "X.npy"))
    y = np.load(os.path.join(output_dir, "y.npy"))

    with open(os.path.join(output_dir, "label_encoder.pkl"), "rb") as f:
        le = pickle.load(f)

    num_classes = len(le.classes_)

    _, X_test, _, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # Evaluate Keras model
    model = tf.keras.models.load_model(os.path.join(output_dir, "coffee_model.keras"))
    y_test_cat = tf.keras.utils.to_categorical(y_test, num_classes)
    loss, acc = model.evaluate(X_test, y_test_cat, verbose=0)
    print(f"Keras model — Test accuracy: {acc:.4f}  |  Test loss: {loss:.4f}")

    y_pred_probs = model.predict(X_test, verbose=0)
    y_pred = np.argmax(y_pred_probs, axis=1)

    print("\n=== Classification Report ===")
    print(classification_report(y_test, y_pred, target_names=le.classes_))

    print("=== Confusion Matrix ===")
    cm = confusion_matrix(y_test, y_pred)
    col_width = max(len(c) for c in le.classes_) + 2
    header = " " * col_width + "  ".join(f"{c:>{col_width}}" for c in le.classes_)
    print(header)
    for i, row in enumerate(cm):
        row_str = f"{le.classes_[i]:<{col_width}}" + "  ".join(f"{v:>{col_width}}" for v in row)
        print(row_str)

    # Evaluate TFLite model
    tflite_path = os.path.join(output_dir, "coffee_model.tflite")
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    tflite_preds = []
    for sample in X_test:
        inp = sample.reshape(1, -1).astype(np.float32)
        interpreter.set_tensor(input_details[0]["index"], inp)
        interpreter.invoke()
        out = interpreter.get_tensor(output_details[0]["index"])
        tflite_preds.append(np.argmax(out))

    tflite_acc = np.mean(np.array(tflite_preds) == y_test)
    print(f"\nTFLite model accuracy: {tflite_acc:.4f}")
    print(f"TFLite file size: {os.path.getsize(tflite_path):,} bytes")


if __name__ == "__main__":
    evaluate()
