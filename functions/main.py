# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from google.cloud import firestore as google_firestore
from concurrent.futures import ThreadPoolExecutor
import base64
import datetime
from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, storage


# For cost control, you can set the maximum number of containers that can be
# running at the same time. This helps mitigate the impact of unexpected
# traffic spikes by instead downgrading performance. This limit is a per-function
# limit. You can override the limit for each function using the max_instances
# parameter in the decorator, e.g. @https_fn.on_request(max_instances=5).
set_global_options(max_instances=10)

# initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")

initialize_app()

def get_db():
    return firestore.client()

def get_bucket():
    return storage.bucket()

@https_fn.on_call()
def claim_note(req: https_fn.CallableRequest):
    db = get_db()
    bucket = get_bucket()

    share_id = req.data.get("shareId")

    if not share_id:
        raise https_fn.HttpsError("invalid-argument", "shareId required")

    doc_ref = db.collection("listas").document(share_id)

    @google_firestore.transactional
    def transaction_claim(transaction):

        snapshot = doc_ref.get(transaction=transaction)

        if not snapshot.exists:
            raise https_fn.HttpsError("not-found", "Note not found")

        data = snapshot.to_dict() or {}

        if data.get("claimedAt"):
            raise https_fn.HttpsError("failed-precondition", "Note already claimed")

        transaction.update(doc_ref, {
            "claimedAt": google_firestore.SERVER_TIMESTAMP
        })

        return data

    transaction = db.transaction()
    data = transaction_claim(transaction)

    # 🔥 Download images and convert them to base64
    final_items = []

    for item in data.get("list", []):

        image_base64 = None

        if item.get("image"):
            image_path = f"images/{item['id']}"

            blob = bucket.blob(image_path)

            if blob.exists():
                image_bytes = blob.download_as_bytes()
                image_base64 = base64.b64encode(image_bytes).decode("utf-8")

        final_items.append({
            "id": item.get("id"),
            "content": item.get("content"),
            "image": image_base64
        })
    print(f"DEBUG: Datos originales del doc: {data}")

    # 🔥 Delete images from Storage
    for item in data.get("list", []):
        if item.get("image"):
            image_path = f"images/{item['id']}"
            blob = bucket.blob(image_path)
            blob.delete()

    # 🔥 Delete document
    doc_ref.delete()

    return {
        "id": share_id,
        "descriptionList": data.get("description"),
        "from": data.get("from"),
        "itemList": final_items
    }

def upload_to_storage(item_id, base64_str):
    """Función auxiliar para subir una imagen a Storage"""
    if not base64_str: return False
    try:
        bucket = storage.bucket()
        blob = bucket.blob(f"images/{item_id}")
        image_data = base64.b64decode(base64_str)
        blob.upload_from_string(image_data, content_type='image/jpeg')
        return True
    except:
        return False


@https_fn.on_call()
def process_complete_upload(req: https_fn.CallableRequest):
    data = req.data
    device_id = data.get("device_id")
    db = firestore.client()

    # --- PASO 1: SEGURIDAD (Límite por ID de dispositivo) ---
    count_query = db.collection("listas").where("device_id", "==", device_id).count()
    if count_query.get()[0][0].value >= 10:
        raise https_fn.HttpsError(code="resource-exhausted", message="Límite de 10 listas alcanzado.")

    # --- PASO 2: PROCESAR IMÁGENES EN PARALELO ---
    items = data.get("items", [])
    # max_workers=3 es tu AsyncSemaphore(value: 3)
    with ThreadPoolExecutor(max_workers=3) as executor:
        for item in items:
            if "imageBase64" in item:
                executor.submit(upload_to_storage, item["id"], item["imageBase64"])

    # --- PASO 3: LIMPIAR DATOS Y GUARDAR EN FIRESTORE ---
    # Creamos la lista de items para Firestore (sin el Base64 pesado)
    clean_items = []
    for item in items:
        clean_items.append({
            "id": item.get("id"),
            "content": item.get("content"),
            "image": "imageBase64" in item
        })

    doc_data = {
        "device_id": device_id,
        "description": data.get("description"),
        "from": data.get("from"),
        "list": clean_items,
        "createdAt": datetime.datetime.now()
    }

    db.collection("listas").document(data.get("list_id")).set(doc_data)

    return {"status": "ok", "message": "Procesado correctamente"}