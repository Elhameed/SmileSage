import tensorflow as tf

# Load TFLite model
interpreter = tf.lite.Interpreter(model_path="./assets/models/efficientnetb0_finetuned.tflite")
interpreter.allocate_tensors()

# Get input/output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input details:", input_details)
print("Output details:", output_details)

# Test inference
import numpy as np
input_data = np.array(np.random.random_sample(input_details[0]['shape']), 
                      dtype=np.float32)
interpreter.set_tensor(input_details[0]['index'], input_data)
interpreter.invoke()
output_data = interpreter.get_tensor(output_details[0]['index'])
print("Output shape:", output_data.shape)