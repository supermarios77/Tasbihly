# Additional Critical Issues Found

**Date:** 2024-11-23  
**Status:** 🔴 **3 CRITICAL ISSUES FOUND**

---

## 🔴 CRITICAL ISSUE #1: NotificationCenter Memory Leak

**File:** `TasbihApp/Managers/CounterManager.swift:71-87`  
**Severity:** CRITICAL - MEMORY LEAK  
**Issue:** `NotificationCenter.addObserver(forName:object:queue:using:)` returns an `NSObjectProtocol` token that must be stored and removed. The current `removeObserver(self)` in deinit does NOT work for observers added with this method.

**Impact:** 
- Memory leak - observers will never be removed
- Observers will continue to fire even after CounterManager is deallocated
- Potential crashes from accessing deallocated objects

**Current Code:**
```swift
NotificationCenter.default.addObserver(
    forName: UIApplication.willResignActiveNotification,
    ...
) { [weak self] _ in ... }

deinit {
    NotificationCenter.default.removeObserver(self) // ❌ DOESN'T WORK!
}
```

**Fix Required:** Store the observer tokens and remove them individually.

---

## 🔴 CRITICAL ISSUE #2: Array Bounds - Theme.swift

**File:** `TasbihApp/Theme/Theme.swift:333`  
**Severity:** CRITICAL - POTENTIAL CRASH  
**Issue:** `appThemes[0]` could crash if `appThemes` array is empty.

**Impact:** App crash on launch if themes array is empty (unlikely but possible).

**Fix Required:** Use `.first` with fallback or bounds checking.

---

## 🔴 CRITICAL ISSUE #3: Array Bounds - SettingsView

**File:** `TasbihApp/Views/SettingsView.swift:230, 238`  
**Severity:** CRITICAL - POTENTIAL CRASH  
**Issue:** `appThemes[index]` and `appThemes[selectedThemeIndex]` could crash if index is out of bounds.

**Impact:** App crash when accessing settings if theme index is invalid.

**Fix Required:** Add bounds checking before array access.

---

## Summary

- **Critical Memory Leak:** 1 (NotificationCenter observers)
- **Critical Crashes:** 2 (Array bounds)
- **Total Critical Issues:** 3

**Priority:** Fix immediately before production release.

