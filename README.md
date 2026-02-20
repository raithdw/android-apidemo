# 📱 Android Appium Automation

## 🚀 Project Overview

This repository contains automated tests for the Android app using **Appium + WebdriverIO**.  
Tests run **locally** with full **Allure reporting**.

## 🖥 Local Setup & Usage

### Prerequisites

1. **Node.js** v20+  
2. **PowerShell 7+** (if on Windows)  
3. **Android SDK** installed locally:
   - `emulator.exe` and `adb.exe` available
   - Environment variable `ANDROID_SDK` or set in `run-tests.ps1`
   - AVD already created (example: `Medium_Phone_API_36.1`)  
4. **Java JDK 17+**  
5. **NPM dependencies installed**:
   ```powershell
   npm install

## 📝 Local Usage and Allure Reports

Make sure Android SDK is installed and your AVD exists.

Run:

- .\run-tests.ps1 -Headless
- .\run-tests.ps1 (Headed mode)

Allure results will be generated in ./allure-report and can be opened via:

- npx allure open ./allure-report