# 📱 Android Appium Automation

[![Android Appium CI](https://github.com/raithdw/android-apidemo/actions/workflows/android-tests.yml/badge.svg)](https://github.com/raithdw/android-apidemo/actions/workflows/android-tests.yml)
[![Allure Report](https://img.shields.io/badge/Allure-Report-blue)](https://raithdw.github.io/android-apidemo/index.html)


## 🚀 Project Overview

This repository contains automated tests for the Android app using **Appium + WebdriverIO**.  
Tests can run **locally** or in **GitHub Actions CI** with full **Allure reporting**.

## 🛠 Features

✅ Local execution via PowerShell:

.\run-tests.ps1 -Headless

✅ GitHub Actions CI with headless emulator

✅ WebdriverIO tests integrated with Appium

✅ Allure reports generated automatically

✅ Allure history preserved (trend graph across builds)

✅ Build metadata:

- Build number

- Commit SHA

- Branch name

- App version (from package.json)

- Android API and device

✅ Reports deployed automatically to GitHub Pages

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
   npm ci

## 📊 How to View Allure Reports

After the CI workflow completes, your latest report is available at:

https://raithdw.github.io/android-apidemo/index.html

Open this link to see:

- Test results

- Environment metadata

- Trend graphs (Allure history)

- Build & commit links

## 📝 Local Usage

Make sure Android SDK is installed and your AVD exists.

Run:

- .\run-tests.ps1 -Headless
- .\run-tests.ps1 (Headed mode)

Allure results will be generated in ./allure-report and can be opened via:

- npx allure open ./allure-report

## 📈 CI Workflow Notes

Android emulator is headless (-no-window -no-audio -no-boot-anim)

Appium is started automatically by CI

Allure metadata includes build number, commit SHA, branch, app version, and Android info

CI uses caching for Node modules for faster builds