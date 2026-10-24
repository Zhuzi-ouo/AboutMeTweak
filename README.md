# AboutMeTweak

美化與現代化 iOS 設定中的「關於本機」（About）頁面。

將原生單調的清單式呈現，改造成具有現代感、色彩豐富的頂部卡片式介面，支援即時修改名稱、機型切換與序號快捷複製。

---

## ✨ 主要特色

* **現代化主漸層卡片**：
  * 大字體顯示 iOS 系統版本與 Build 編號膠囊。
  * 居中顯示硬體設備行銷名稱（如 iPhone 8）。
* **雙功能快速資訊卡**：
  * **裝置名稱**：點擊即可跳出提示框自訂修改名稱（即時寫入系統設定與 `lockdownd`）。
  * **儲存空間**：圖形化漸層進度條，清晰呈現已使用與總容量。
* **底部快捷卡片**：
  * **機型型號**：輕觸可在「銷售型號」（如 `MQ6G2TA/A`）與「硬體型號」（如 `A1905`）之間快速切換。
  * **序號卡片**：
    * 輕點切換序號部分遮蔽（保護隱私）。
    * 長按震動並直接複製完整序號至剪貼簿。
* **原生體驗**：
  * 自動過濾重複的原生 Specifier 項目，避免資訊重複顯示。

---

## 📱 相容性

* **支援架構**：`arm64`, `arm64e`
* **支援環境**：Rootless 越獄（Dopamine、Palera1n 等）
* **相容版本**：
  * **已測試確認**：iOS 16.7.7（iPhone 8）
  * **預期相容**：iOS 15.0 – 16.x
    > *註：iOS 15+ 設定頁架構相似（使用 `PSGAboutController` / `PSGAboutDataSource`），理論上皆可正常載入。iOS 17+ 尚未進行完整相容性測試。*

---

## 🛠 編譯與打包

本專案使用 [Theos](https://theos.dev/) 進行建構。

```bash
# 1. 複製專案
git clone https://github.com/Zhuzi-ouo/AboutMeTweak.git
cd AboutMeTweak

# 2. 開發除錯打包
make package

# 3. 正式發布打包 (開啟優化並去除除錯資訊)
make package FINALPACKAGE=1
```

編譯完成的 `.deb` 安裝包將位於 `packages/` 目錄中。

---

## 📂 專案架構

```
AboutMeTweak/
├── Headers/
│   └── AboutMeTweak.h          # 介面宣告與佈局常數定義
├── Classes/
│   ├── AboutMeHeaderView.m     # 自訂 Header 容器 (支援穿透點擊)
│   ├── AboutMeTweakManager.m   # 互動邏輯 (改名、切換、複製等)
│   └── AboutMeUIFactory.m      # 卡片 UI 工廠方法
├── Utils/
│   └── AboutMeSystemInfo.m     # 系統資訊讀取 (MobileGestalt)
├── layout/                     # 隨 deb 自動安裝的資源檔
│   └── var/jb/Library/MobileSubstrate/DynamicLibraries/
│       └── AboutMeTweakModels.plist # 裝置型號對照表
├── Tweak.x                     # Hook 與 Specifier 過濾核心
├── Makefile                    # Theos 編譯設定
└── control                     # Debian 軟體包資訊
```

---

## 📄 授權

本專案採用 MIT 授權條款，歡迎自由學習、修改或提交 PR。
