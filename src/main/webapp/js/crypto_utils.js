const CryptoUtils = (function() {

    async function generateRSAKeyPair() {
        return await window.crypto.subtle.generateKey(
            {
                name: "RSA-OAEP",
                modulusLength: 2048,
                publicExponent: new Uint8Array([1, 0, 1]),
                hash: "SHA-256",
            },
            true,
            ["encrypt", "decrypt"]
        );
    }

    async function exportPublicKey(key) {
        const exported = await window.crypto.subtle.exportKey("spki", key);
        return btoa(String.fromCharCode(...new Uint8Array(exported)));
    }

    async function importPublicKey(pem) {
        const binaryDerString = window.atob(pem);
        const binaryDer = str2ab(binaryDerString);
        return await window.crypto.subtle.importKey(
            "spki",
            binaryDer,
            { name: "RSA-OAEP", hash: "SHA-256" },
            true,
            ["encrypt"]
        );
    }

    async function generateAESKey() {
        return await window.crypto.subtle.generateKey(
            { name: "AES-GCM", length: 256 },
            true,
            ["encrypt", "decrypt"]
        );
    }

    async function exportAESKey(key) {
        const exported = await window.crypto.subtle.exportKey("raw", key);
        return btoa(String.fromCharCode(...new Uint8Array(exported)));
    }

    async function importAESKey(base64) {
        const binary = str2ab(window.atob(base64));
        return await window.crypto.subtle.importKey(
            "raw",
            binary,
            { name: "AES-GCM" },
            true,
            ["encrypt", "decrypt"]
        );
    }

    async function encryptAESKeyWithRSA(aesKeyBase64, rsaPublicKey) {
        const encoded = new TextEncoder().encode(aesKeyBase64);
        const encrypted = await window.crypto.subtle.encrypt(
            { name: "RSA-OAEP" },
            rsaPublicKey,
            encoded
        );
        return btoa(String.fromCharCode(...new Uint8Array(encrypted)));
    }

    async function decryptAESKeyWithRSA(encryptedAESKeyBase64, rsaPrivateKey) {
        const encrypted = str2ab(window.atob(encryptedAESKeyBase64));
        const decrypted = await window.crypto.subtle.decrypt(
            { name: "RSA-OAEP" },
            rsaPrivateKey,
            encrypted
        );
        return new TextDecoder().decode(decrypted);
    }

    async function encryptMessage(message, aesKey) {
        const iv = window.crypto.getRandomValues(new Uint8Array(12));
        const encoded = new TextEncoder().encode(message);
        const ciphertext = await window.crypto.subtle.encrypt(
            { name: "AES-GCM", iv: iv },
            aesKey,
            encoded
        );
        return {
            encryptedContent: btoa(String.fromCharCode(...new Uint8Array(ciphertext))),
            iv: btoa(String.fromCharCode(...iv))
        };
    }

    async function decryptMessage(encryptedContentBase64, ivBase64, aesKey) {
        const ciphertext = str2ab(window.atob(encryptedContentBase64));
        const iv = str2ab(window.atob(ivBase64));
        try {
            const decrypted = await window.crypto.subtle.decrypt(
                { name: "AES-GCM", iv: new Uint8Array(iv) },
                aesKey,
                ciphertext
            );
            return new TextDecoder().decode(decrypted);
        } catch (e) {
            console.error("Decryption failed", e);
            return "[Encrypted Message]";
        }
    }

    function str2ab(str) {
        const buf = new ArrayBuffer(str.length);
        const bufView = new Uint8Array(buf);
        for (let i = 0, strLen = str.length; i < strLen; i++) {
            bufView[i] = str.charCodeAt(i);
        }
        return buf;
    }

    // --- IndexedDB for Key Storage ---
    function openDB() {
        return new Promise((resolve, reject) => {
            const req = indexedDB.open("ChatCryptoDB", 1);
            req.onupgradeneeded = e => {
                const db = e.target.result;
                if (!db.objectStoreNames.contains("keys")) {
                    db.createObjectStore("keys", { keyPath: "id" });
                }
            };
            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
        });
    }

    async function saveKeyToDB(id, keyObj) {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const tx = db.transaction("keys", "readwrite");
            tx.objectStore("keys").put({ id: id, key: keyObj });
            tx.oncomplete = () => resolve();
            tx.onerror = () => reject(tx.error);
        });
    }

    async function getKeyFromDB(id) {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const tx = db.transaction("keys", "readonly");
            const req = tx.objectStore("keys").get(id);
            req.onsuccess = () => resolve(req.result ? req.result.key : null);
            req.onerror = () => reject(req.error);
        });
    }

    return {
        generateRSAKeyPair,
        exportPublicKey,
        importPublicKey,
        generateAESKey,
        exportAESKey,
        importAESKey,
        encryptAESKeyWithRSA,
        decryptAESKeyWithRSA,
        encryptMessage,
        decryptMessage,
        saveKeyToDB,
        getKeyFromDB
    };
})();
