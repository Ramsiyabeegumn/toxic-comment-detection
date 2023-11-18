from flask import Flask, request, jsonify
import jsonpickle
from googletrans import Translator
from tensorflow.keras.layers import TextVectorization
import pickle
from keras.models import load_model
import numpy as np


app = Flask(__name__)


@app.route("/api", methods=["GET"])
def commentDetection():
    d = {}
    inputchr = str(request.args["query"])
    translator = Translator()
    x = translator.translate(inputchr, dest="en")
    print(x.text)

    from_disk = pickle.load(
        open(
            "C:\\Users\\denny\\OneDrive\\Documents\\Projects\\toxic comment detection\\server\\vectorizer.pkl",
            "rb",
        )
    )
    new_v = TextVectorization.from_config(from_disk["config"])
    new_v.set_weights(from_disk["weights"])
    model = load_model(
        "C:\\Users\\denny\\OneDrive\\Documents\\Projects\\toxic comment detection\\server\\toxicity.h5"
    )

    input_text = new_v(x.text)
    # print(input_text[:7])

    res = model.predict(np.expand_dims(input_text, 0))
    if res[0][0] > 0.5:
        return jsonpickle.encode("toxic")
    else:
        return jsonpickle.encode("nottoxic")
