import langid
from googletrans import Translator
import pickle
import tensorflow as tf
from tensorflow.keras.layers import TextVectorization
from keras.models import load_model
import numpy as np


t = "നിന്നെ ഞാൻ കൊല്ലും."
translator = Translator()
x = translator.translate(t, dest="en")
print(x.text)


from_disk = pickle.load(
    open(
        "C:\\Users\\denny\\OneDrive\\Documents\\Projects\\toxic comment detection\\server\\vectorizer.pkl",
        "rb",
    )
)
new_v = TextVectorization.from_config(from_disk["config"])
new_v.set_weights(from_disk["weights"])
model = load_model("C:\\Users\\denny\\OneDrive\\Documents\\Projects\\toxic comment detection\\server\\toxicity.h5")

input_text = new_v(x.text)
# print(input_text[:7])

res = model.predict(np.expand_dims(input_text, 0))
if res[0][0] > 0.5:
    print('Comment is toxic')
else:
    print('Comment is not toxic')