# 🛒 Nexera (Scan & Go MVP)

Nexera is an innovative **Self-Checkout / Scan & Go** application designed to eliminate supermarket queues. It allows users to scan barcodes using their mobile phones, build a virtual shopping cart, process dummy payments, and walk out seamlessly.

<img src="https://raw.githubusercontent.com/ChilakaPankajDheeraj/Vision-Hackathon/main/app/assets/icon.png" width="150">

## 🚀 Key Features
- **Mobile Barcode Scanning:** Premium UI for scanning product barcodes instantly.
- **Global Database (OpenFoodFacts):** Scans real-world products and fetches live data from the internet automatically!
- **Virtual Cart Management:** Beautiful dark-themed UI to manage cart items and view totals.
- **Mock Payment Flow:** Simulated seamless checkout experience.

## 🛠️ Tech Stack
- **Frontend (Mobile App):** Flutter, Dart (Android/iOS/Web)
- **State Management:** Provider / Built-in State
- **Internet APIs:** OpenFoodFacts for real barcode decoding
- **UI Design:** Glassmorphism and premium dark themes

## 📂 Project Structure
```text
scan_and_go_mvp/
│
├── app/                  # Flutter Mobile App
│   ├── lib/
│   │   ├── models/       # Product and Cart logic (Internet API fallback)
│   │   ├── screens/      # Home, Scanner, and Cart UI
│   │   └── main.dart     # Entry point
│   ├── assets/           # App icon and images
│   └── pubspec.yaml
```

## 💻 How to Run Locally

### 1. Prerequisites
Make sure you have Flutter SDK installed on your machine.

### 2. Run the App
You can run the app in a web browser (Chrome) or directly on your Android/iOS phone.
```bash
cd app
flutter pub get
flutter run
```

## 📸 How to Demo the MVP
1. Open the App and click **"Start Scanning"**.
2. Scan a real product barcode (like a water bottle) — it will fetch the details from the internet and add it to your cart.
3. Go to the **Cart** to review your items.
4. Click **"PAY & VERIFY"**.
5. The app will simulate a payment and instantly approve your exit!
