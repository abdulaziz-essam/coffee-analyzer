import numpy as np
import os
import pickle
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight

OUTPUT_DIR = "output"
MODEL_INPUT_SIZE = 9  # number of score features


def build_model(num_classes):
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(MODEL_INPUT_SIZE,)),
        tf.keras.layers.Dense(64, activation="relu"),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(32, activation="relu"),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(num_classes, activation="softmax"),
    ])
    return model


def train(output_dir=OUTPUT_DIR):
    X = np.load(os.path.join(output_dir, "X.npy"))
    y = np.load(os.path.join(output_dir, "y.npy"))

    with open(os.path.join(output_dir, "label_encoder.pkl"), "rb") as f:
        le = pickle.load(f)

    num_classes = len(le.classes_)
    print(f"Classes: {list(le.classes_)}  |  Samples: {len(X)}")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # Handle class imbalance
    class_weights_arr = compute_class_weight("balanced", classes=np.unique(y_train), y=y_train)
    class_weights = dict(enumerate(class_weights_arr))
    print(f"Class weights: {class_weights}")

    y_train_cat = tf.keras.utils.to_categorical(y_train, num_classes)
    y_test_cat = tf.keras.utils.to_categorical(y_test, num_classes)

    model = build_model(num_classes)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    model.summary()

    callbacks = [
        tf.keras.callbacks.EarlyStopping(patience=15, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(patience=7, factor=0.5, min_lr=1e-5),
    ]

    history = model.fit(
        X_train, y_train_cat,
        validation_data=(X_test, y_test_cat),
        epochs=150,
        batch_size=32,
        class_weight=class_weights,
        callbacks=callbacks,
        verbose=1,
    )

    loss, acc = model.evaluate(X_test, y_test_cat, verbose=0)
    print(f"\nTest accuracy: {acc:.4f}  |  Test loss: {loss:.4f}")

    # Save Keras model
    keras_path = os.path.join(output_dir, "coffee_model.keras")
    model.save(keras_path)
    print(f"Keras model saved to {keras_path}")

    # Export to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    tflite_path = os.path.join(output_dir, "coffee_model.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
    print(f"TFLite model saved to {tflite_path}  ({len(tflite_model):,} bytes)")

    return model, history


if __name__ == "__main__":
    train()
