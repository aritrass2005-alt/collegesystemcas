package com.college.attendance.util;

import java.util.regex.Pattern;

/**
 * Central validation and sanitization utility.
 * All user input must pass through these methods before use.
 */
public class ValidationUtil {

    // ── Regex patterns ──────────────────────────────────────────────────────
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[6-9]\\d{9}$");                      // Indian mobile
    private static final Pattern ROLL_NO_PATTERN =
            Pattern.compile("^[A-Za-z0-9_-]{3,20}$");
    private static final Pattern NAME_PATTERN =
            Pattern.compile("^[A-Za-z .'-]{2,80}$");
    private static final Pattern DATE_PATTERN =
            Pattern.compile("^\\d{4}-\\d{2}-\\d{2}$");
    private static final Pattern DOB_PATTERN =
            Pattern.compile("^\\d{8}$");                           // DDMMYYYY or YYYYMMDD
    private static final Pattern ALPHANUMERIC_SIMPLE =
            Pattern.compile("^[A-Za-z0-9 _-]{1,60}$");
    private static final Pattern STATUS_PATTERN =
            Pattern.compile("^(Present|Absent|Leave)$");
    private static final Pattern ROLE_PATTERN =
            Pattern.compile("^(Student|Teacher|Admin|Coordinator)$");
    private static final Pattern ALLOWED_FILE_EXT =
            Pattern.compile("(?i)\\.(pdf|jpg|jpeg|png)$");

    // ── String / null safety ─────────────────────────────────────────────────

    /** Returns trimmed value or null if blank */
    public static String clean(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    /** Strip HTML/script tags to prevent stored XSS */
    public static String sanitizeText(String value) {
        if (value == null) return "";
        return value.replaceAll("<[^>]*>", "").trim();
    }

    /** Returns trimmed and uppercased value or null if blank */
    public static String cleanUpper(String value) {
        String cleaned = clean(value);
        return cleaned == null ? null : cleaned.toUpperCase();
    }

    // ── Field validators ────────────────────────────────────────────────────

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return true; // optional
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isValidRollNo(String rollNo) {
        return rollNo != null && ROLL_NO_PATTERN.matcher(rollNo.trim()).matches();
    }

    public static boolean isValidName(String name) {
        return name != null && NAME_PATTERN.matcher(name.trim()).matches();
    }

    public static boolean isValidDate(String date) {
        if (date == null || !DATE_PATTERN.matcher(date.trim()).matches()) return false;
        // Additional range check
        try {
            java.time.LocalDate.parse(date.trim());
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isValidDob(String dob) {
        return dob != null && DOB_PATTERN.matcher(dob.trim()).matches();
    }

    public static boolean isValidStatus(String status) {
        return status != null && STATUS_PATTERN.matcher(status.trim()).matches();
    }

    public static boolean isValidRole(String role) {
        return role != null && ROLE_PATTERN.matcher(role.trim()).matches();
    }

    public static boolean isValidAlphanumeric(String value) {
        return value != null && ALPHANUMERIC_SIMPLE.matcher(value.trim()).matches();
    }

    public static boolean isValidFileExtension(String filename) {
        return filename != null && ALLOWED_FILE_EXT.matcher(filename).find();
    }

    /** Safe integer parse — returns defaultVal if not a valid int */
    public static int parseIntSafe(String value, int defaultVal) {
        if (value == null || value.trim().isEmpty()) return defaultVal;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }

    /** Returns true only if value is a positive integer string */
    public static boolean isPositiveInt(String value) {
        if (value == null) return false;
        try {
            return Integer.parseInt(value.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Validates that a year value is 1-4 (academic year).
     */
    public static boolean isValidAcademicYear(int year) {
        return year >= 1 && year <= 4;
    }

    /**
     * Validates a free-text reason or address: strips XSS, checks length.
     */
    public static boolean isValidTextBlock(String text) {
        if (text == null || text.trim().isEmpty()) return false;
        String clean = sanitizeText(text);
        return clean.length() >= 5 && clean.length() <= 2000;
    }

    /**
     * Prevents open-redirect by ensuring URL is relative (no scheme).
     */
    public static String safeRedirectUrl(String url, String fallback) {
        if (url == null || url.contains("://") || url.startsWith("//")) {
            return fallback;
        }
        return url;
    }
}
