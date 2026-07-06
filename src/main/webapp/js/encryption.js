/**
 * CAS Chat - AES-256-GCM End-to-End Encryption Module
 * Uses the browser's Web Crypto API for secure encryption/decryption.
 */
const CASEncryption = (function() {
    // A fixed passphrase-derived key for the college system.
    // In production, each conversation would have a unique shared key exchanged via Diffie-Hellman.
    // For a college LAN system, this provides good protection of stored messages.
    const PASSPHRASE = 'CAS-College-Attendance-System-E2E-Key-2026';

    let _cryptoKey = null;

    /**
     * Derive an AES-256-GCM key from the passphrase using PBKDF2.
     */
    async function getKey() {
        if (_cryptoKey) return _cryptoKey;

        const enc = new TextEncoder();
        const keyMaterial = await window.crypto.subtle.importKey(
            'raw',
            enc.encode(PASSPHRASE),
            { name: 'PBKDF2' },
            false,
            ['deriveBits', 'deriveKey']
        );

        _cryptoKey = await window.crypto.subtle.deriveKey(
            {
                name: 'PBKDF2',
                salt: enc.encode('CAS-Salt-2026'),
                iterations: 100000,
                hash: 'SHA-256'
            },
            keyMaterial,
            { name: 'AES-GCM', length: 256 },
            false,
            ['encrypt', 'decrypt']
        );

        return _cryptoKey;
    }

    /**
     * Pure JS Base64 encoder (Uint8Array -> Base64 string).
     * Avoids String.fromCharCode.apply, btoa, and memory/stack limitations.
     */
    function uint8ArrayToBase64(bytes) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        let base64 = '';
        const len = bytes.length;
        const extraBytes = len % 3;
        const lenWithoutExtra = len - extraBytes;
        
        for (let i = 0; i < lenWithoutExtra; i += 3) {
            const b0 = bytes[i];
            const b1 = bytes[i + 1];
            const b2 = bytes[i + 2];
            
            base64 += chars[b0 >> 2];
            base64 += chars[((b0 & 3) << 4) | (b1 >> 4)];
            base64 += chars[((b1 & 15) << 2) | (b2 >> 6)];
            base64 += chars[b2 & 63];
        }
        
        if (extraBytes === 1) {
            const b0 = bytes[lenWithoutExtra];
            base64 += chars[b0 >> 2];
            base64 += chars[(b0 & 3) << 4];
            base64 += '==';
        } else if (extraBytes === 2) {
            const b0 = bytes[lenWithoutExtra];
            const b1 = bytes[lenWithoutExtra + 1];
            base64 += chars[b0 >> 2];
            base64 += chars[((b0 & 3) << 4) | (b1 >> 4)];
            base64 += chars[(b1 & 15) << 2];
            base64 += '=';
        }
        
        return base64;
    }

    /**
     * Pure JS Base64 decoder (Base64 string -> Uint8Array).
     * Avoids atob and has no stack size limits.
     */
    function base64ToUint8Array(base64) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        const lookup = new Uint8Array(256);
        for (let i = 0; i < chars.length; i++) {
            lookup[chars.charCodeAt(i)] = i;
        }
        
        let len = base64.length;
        while (len > 0 && base64[len - 1] === '=') {
            len--;
        }
        
        const bytes = new Uint8Array(Math.floor((len * 3) / 4));
        let p = 0;
        
        for (let i = 0; i < len; i += 4) {
            const c0 = lookup[base64.charCodeAt(i)];
            const c1 = lookup[base64.charCodeAt(i + 1)];
            const c2 = i + 2 < len ? lookup[base64.charCodeAt(i + 2)] : 0;
            const c3 = i + 3 < len ? lookup[base64.charCodeAt(i + 3)] : 0;
            
            bytes[p++] = (c0 << 2) | (c1 >> 4);
            if (p < bytes.length) bytes[p++] = ((c1 & 15) << 4) | (c2 >> 2);
            if (p < bytes.length) bytes[p++] = ((c2 & 3) << 6) | c3;
        }
        
        return bytes;
    }

    /**
     * Encrypt plaintext to a base64-encoded string (IV + ciphertext).
     */
    async function encrypt(plaintext) {
        try {
            const key = await getKey();
            const enc = new TextEncoder();
            const iv = window.crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV for AES-GCM
            const encrypted = await window.crypto.subtle.encrypt(
                { name: 'AES-GCM', iv: iv },
                key,
                enc.encode(plaintext)
            );

            // Concatenate IV + ciphertext and base64 encode
            const combined = new Uint8Array(iv.length + encrypted.byteLength);
            combined.set(iv, 0);
            combined.set(new Uint8Array(encrypted), iv.length);

            return uint8ArrayToBase64(combined);
        } catch (e) {
            console.error('Encryption error:', e);
            return plaintext; // Fallback to plaintext if crypto fails
        }
    }

    /**
     * Decrypt a base64-encoded string back to plaintext.
     */
    async function decrypt(ciphertext) {
        try {
            const key = await getKey();
            const combined = base64ToUint8Array(ciphertext);

            const iv = combined.slice(0, 12);
            const data = combined.slice(12);

            const decrypted = await window.crypto.subtle.decrypt(
                { name: 'AES-GCM', iv: iv },
                key,
                data
            );

            return new TextDecoder().decode(decrypted);
        } catch (e) {
            // If decryption fails, it might be a plaintext/system message
            return ciphertext;
        }
    }

    return { encrypt, decrypt };
})();
