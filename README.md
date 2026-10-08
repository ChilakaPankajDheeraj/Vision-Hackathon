# 🛒 Nexera - AI-Powered Scan & Go

Nexera is an innovative **Self-Checkout / Scan & Go** ecosystem designed to eliminate supermarket queues and enhance retail security. It empowers users to scan barcodes using their mobile phones, build a virtual shopping cart, process payments, and walk out seamlessly. 

To prevent retail shrinkage (theft), the architecture includes a **Computer Vision AI Camera** at the exit that cross-verifies the physical items in the user's bag with their digital cart.

<p align="center">
  <img src="https://raw.githubusercontent.com/ChilakaPankajDheeraj/Vision-Hackathon/main/app/assets/icon.png" width="150">
</p>

## 🚀 Key Features
- **Mobile Barcode Scanning:** A premium, intuitive Flutter UI for instantly scanning product barcodes.
- **Real-Time Data (OpenFoodFacts API):** Dynamically fetches live product names and details from the global OpenFoodFacts API when real-world barcodes are scanned.
- **Virtual Cart Management:** Manage cart items and quantities with a seamless dark-themed interface.
- **AI Exit Verification (Python + YOLO):** A Python backend running YOLOv8 object detection to visually verify the user's items before they exit the store.
- **Frictionless Checkout:** 1-tap payment processing and exit approval.

## 🛠️ Tech Stack & Architecture

### Frontend (Mobile App)
- **Framework:** Flutter / Dart
- **Design:** Glassmorphism, Material 3 Dark Theme
- **State Management:** Provider / Built-in State

### Backend & AI Integrations
- **External API:** OpenFoodFacts REST API (for global barcode resolution)
- **AI Vision Server:** Python, FastAPI
- **Computer Vision Model:** YOLOv8 (Ultralytics), OpenCV
- **Database (Optional):** Supabase (PostgreSQL)

## 🔄 Complete System Process Flow

1. **Item Selection & Scan:** The customer picks up a physical product and scans its barcode using the Nexera mobile app's camera overlay.
2. **API Resolution:** The app queries the local database. If the item is new, it makes an HTTP GET request to the `OpenFoodFacts API` to fetch the real product data from the internet.
3. **Cart Building:** The item is securely added to the virtual cart. The user repeats this for all items.
4. **Checkout Initiation:** The user clicks "PAY & VERIFY". A secure payment gateway simulation processes the transaction.
5. **AI Verification Checkpoint:** 
   - The app communicates with the **Python FastAPI backend**.
   - The backend activates the store's exit camera (simulated via laptop webcam) using **OpenCV**, captures a frame, and runs it through the **YOLOv8** object detection model.
   - The objects detected by the AI are algorithmically matched against the digital cart array.
6. **Exit Approval:** If the physical items match the digital cart perfectly, the exit gates open (Payment Successful). If a mismatch is detected, the exit is blocked for manual staff review.

*(Note: For this specific MVP demo version, the payment and verification steps run locally on the app to ensure a smooth presentation flow without requiring the backend server to be live).*

## 📂 Project Structure
```text
scan_and_go_mvp/
│
├── app/                  # Flutter Mobile Frontend
│   ├── lib/
│   │   ├── models/       # OpenFoodFacts API & Cart State Logic
│   │   ├── screens/      # Mobile Scanner & Cart UI
│   │   └── main.dart     # Entry point
│   └── assets/           
│
└── backend/              # Python AI Verification Server
    ├── main.py           # FastAPI server with YOLOv8 integration
    └── requirements.txt  # Python dependencies (opencv, ultralytics, etc.)
```

## 💻 How to Run Locally (Frontend Demo)
Make sure you have the Flutter SDK installed.
```bash
cd app
flutter pub get
flutter run
```
