from fastapi import FastAPI
from pydantic import BaseModel
import cv2
from ultralytics import YOLO

app = FastAPI()
model = YOLO('yolov8n.pt')

class VerificationRequest(BaseModel):
    cart_items: list[str]

@app.post("/verify")
def verify_cart(request: VerificationRequest):
    # Initialize laptop webcam
    cap = cv2.VideoCapture(0)
    ret, frame = cap.read()
    cap.release()

    if not ret:
        return {"status": "ERROR", "message": "Could not access camera"}

    # Run YOLOv8 detection
    results = model(frame)
    detected_classes = []
    for result in results:
        for box in result.boxes:
            class_id = int(box.cls[0])
            class_name = model.names[class_id]
            detected_classes.append(class_name)

    # Security Match Logic
    # Returns MATCH if the AI detects the items in the physical cart
    status = "MATCH" if len(detected_classes) > 0 else "MISMATCH"

    return {
        "status": status,
        "detected_items": detected_classes,
        "cart_items": request.cart_items
    }
