# SmileSage ML Model Notebooks

## Overview
This folder contains Jupyter notebooks for training and evaluating the dental condition detection model used in SmileSage.

## Contents
- `SmileSage_dental_scanner_implementation.ipynb`: Main notebook for data preprocessing, model training, evaluation, and TFLite export.

## Requirements
- Python 3.x
- Jupyter Notebook or Google Colab
- TensorFlow, Keras, NumPy, Pandas, Matplotlib, etc.
- See notebook cells for full requirements list

## Usage
1. Open the notebook in Jupyter or Colab
2. Follow the steps for data loading, preprocessing, training, and evaluation
3. Export the trained model to TFLite format for use in the Flutter app

## Tips
- Use Google Colab for GPU acceleration
- Store large datasets on Google Drive and mount in Colab

## Model Export & Deployment

After training and evaluating your model, export it as a `.keras` file:

```python
model.save('dental_model.keras')
```

Copy the exported model to the `dental_api/` folder. The FastAPI backend will use this model for inference. See `dental_api/README.md` for deployment instructions and API usage.

---

For integration details, see the main project README and `lib/services` in the Flutter app. 