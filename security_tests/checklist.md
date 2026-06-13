# FARMAI Security & Vulnerability Auditing Checklist

This checklist defines critical security practices and auditing rules for both the FARMAI Flutter client applications (Android and Web) and the Supabase PostgreSQL backend.

---

## 1. Authentication & Session Security

- [ ] **JWT Verification and Lifecycle**
  - Verify that JWT access tokens have a short expiration duration (recommended: 1 hour).
  - Verify that refresh tokens are stored securely in keychain/keystore on mobile, and in secure, HttpOnly, SameSite cookies or secure local storage on web.
- [ ] **Password Strength Rules**
  - Enforce minimum length of 8 characters, with a mix of uppercase, lowercase, numbers, and special characters.
  - Enforce complexity validation on the signup/register screens (`test/unit/register_unit_test.dart`).
- [ ] **Rate Limiting & Brute Force**
  - Enforce rate-limits on Auth API endpoints (configured on Supabase Auth settings to prevent automated credential stuffing).
- [ ] **Bypass Checks**
  - Ensure all private application routes (Home, Irrigation, Disease Detection, profile, etc.) redirect unauthenticated users back to the Login screen.

---

## 2. Supabase PostgreSQL & RLS (Row Level Security)

- [ ] **RLS Policy Enablement**
  - Confirm that every custom table has Row Level Security enabled (`ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;`).
  - *Never* leave tables in "public read/write" mode.
- [ ] **User Isolation Policies**
  - Verify that users can only select and insert their own records in `irrigation_records`, `disease_predictions`, and `pest_detections`:
    ```sql
    CREATE POLICY "Users can manage their own predictions" 
    ON disease_predictions 
    FOR ALL 
    USING (auth.uid() = user_id);
    ```
- [ ] **Service Role Keys**
  - Verify that the `service_role` key is **never** embedded in the client build or shipped to production. It bypasses all RLS policies and must only be used in secure backend scripts or Edge Functions.
- [ ] **SQL Injection Prevention**
  - Ensure all database queries utilize Supabase Postgrest API filters (which are automatically parameterized) or parameterized custom database RPC functions.

---

## 3. Storage Bucket Access Control

- [ ] **Private vs Public Buckets**
  - Verify that the `crop-images`, `pest-images`, and `profile-images` buckets are configured with appropriate access policies.
  - Set buckets as **Private** so that image object paths cannot be scanned or listed anonymously.
- [ ] **File Size & Type Enforcement**
  - Validate uploads via client-side size restrictions (e.g. max 5MB in `disease_detection_screen.dart`).
  - Restrict allowed MIME types (e.g., only `image/jpeg` or `image/png`) using Supabase Storage policies to prevent malicious file uploads (like HTML/JS scripts executing from storage domains).

---

## 4. Flutter Web Client Security

- [ ] **XSS (Cross-Site Scripting)**
  - Sanitize all community forum inputs (title and content) in `community_forum_screen.dart` before rendering them to the screen.
  - Ensure the browser escapes dynamic text inputs (default behavior in Flutter widgets).
- [ ] **API Endpoint Expose check**
  - Verify that the anon key is only allowed to access public API features. Avoid exposing unnecessary internal schema structures.
- [ ] **CORS Settings**
  - Limit allowed origins on Supabase API/Storage configurations to authorized production domains and local development environments.

---

## 5. Security & Vulnerability Auditing Commands

### Run Static Analysis for Code Quality and Potential Vulnerabilities
```bash
flutter analyze
```

### Run Automated Security Dependency Check
```bash
flutter pub pub run path_to_security_scanner (or check vulnerabilities in pubspec.lock)
```
