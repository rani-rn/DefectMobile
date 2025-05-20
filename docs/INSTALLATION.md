# ⚙️ Installation Guide

This guide explains how to set up the Defect Record on your local machine, including both the ASP.NET Web API and the Flutter mobile app.

---

## 🛠 Prerequisites

### ✅ General Requirements

- Git
- Visual Studio 2022 or later (for ASP.NET Core)
- Flutter SDK (3.0+)
- Android Studio (for Android emulator or physical device)
- Microsoft SQL Server 2019 or later
- Postman (optional, for testing APIs)

---

## 🌐 Backend: ASP.NET Web API

### 1. Open the Project

1. Navigate to the `DefectApi/` folder.
2. Open the solution using `DefectMobile.sln` in Visual Studio.

### 2. Configure the Database

- Ensure SQL Server is running.
- Update `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=YOUR_SERVER;Database=DB_NAME;User Id=USER;Password=PASSWORD;TrustServerCertificate=True;"
}

### 3. JWT Configuration

- Config ur Issuer domain in `appsettings.json`:
  "Jwt": {
    "Key": "ThisIsTheKeyForApiDefect12345678!!!",
    "Issuer": "http://10.83.34.109"
  }
- Replace "http://10.83.34.109" with your actual issuer domain or IP address.

### 4. Kestrel Server Port
- Update `Program.cs` to set yout IIS port
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.Listen(System.Net.IPAddress.Any, 5145); 
});
- or if run on IIS without manual Kestrel, delete this config and let IIS handle it

## 📱 Flutter Mobile App
### 1. Open the Project

1. Navigate to the `defect_report_mobile/` folder.
2. Open the project using your preferred IDE (such as android Studio or VS Code).

### 2. Configure API endpoint
- Open the lib/services/api_service.dart
- Update the `baseUrl` variable to match your backend API endpoint (e.g., `http://10.83.34.109:5145/api`)

### 3. install dependencies
- Open terminal and run `flutter pub get`

### 4. run app
- Open terminal and run `flutter run`

### build app
- Open terminal and run `flutter build android` or `flutter build ios`


FINAL CHECKLIST


SQL Server active            ✅ 
Backend run      (port 5145) ✅
Flutter SDK installed        ✅
Emulator/Device connected    ✅
API URL have configurated    ✅
