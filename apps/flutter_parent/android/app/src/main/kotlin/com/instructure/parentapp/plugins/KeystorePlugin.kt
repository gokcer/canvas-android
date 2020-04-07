//// Copyright (C) 2020 - present Instructure, Inc.
////
//// This program is free software: you can redistribute it and/or modify
//// it under the terms of the GNU General Public License as published by
//// the Free Software Foundation, version 3 of the License.
////
//// This program is distributed in the hope that it will be useful,
//// but WITHOUT ANY WARRANTY; without even the implied warranty of
//// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//// GNU General Public License for more details.
////
//// You should have received a copy of the GNU General Public License
//// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//package com.instructure.parentapp.plugins
//
//import android.content.Context
//import android.os.Build
//import android.security.KeyPairGeneratorSpec
//import android.security.keystore.KeyGenParameterSpec
//import android.security.keystore.KeyProperties
//import android.util.Base64
//import android.util.Log
//import android.widget.Toast
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import java.io.ByteArrayOutputStream
//import java.security.KeyPairGenerator
//import java.security.KeyStore
//import java.security.KeyStoreException
//import java.security.interfaces.RSAPublicKey
//import javax.crypto.Cipher
//import javax.crypto.CipherOutputStream
//
//
/**
 * TODO: Redo all of this essentially. Instead of directly using the Keystore, we'll just use EncryptedSharedPreferences
 * which handles all the keystore usage behind the scenes for us. We just need to import the androidx.security library
 * and use it's MasterKeys class to get a secure alias key.
 */
//object KeystorePlugin {
//    private const val CHANNEL_KEYSTORE = "com.instructure.parentapp/KEYSTORE"
//
//    private const val METHOD_READ = "READ"
//    private const val METHOD_UPDATE = "UPDATE"
//    private const val METHOD_DELETE = "DELETE"
//
//    private const val PARAM_LOGIN_ID = "LOGIN_ID"
//    private const val PARAM_REFRESH_TOKEN = "REFRESH_TOKEN"
//    private const val PARAM_ACCESS_TOKEN = "ACCESS_TOKEN"
//
//    private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
//
//    private lateinit var keystore: KeyStore
//    private lateinit var context: Context
//
//    fun init(flutterEngine: FlutterEngine, context: Context) {
//        // Implement getAuthCode / JSoup support via MethodChannel
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_KEYSTORE).setMethodCallHandler(::handleCall)
//
//        this.context = context
//        initKeystore()
//    }
//
//    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
//        when (call.method) {
//            METHOD_READ -> readTokens(call, result)
//            METHOD_DELETE -> deleteTokens(call, result)
//            METHOD_UPDATE -> updateToken(call, result)
//            else -> result.notImplemented()
//        }
//    }
//
//    private fun initKeystore() {
//        keystore = KeyStore.getInstance(KEYSTORE_PROVIDER)
//        keystore.load(null)
//
//        // Although you can define your own key generation parameter specification, it's
//        // recommended that you use the value specified here.
//        // TODO: Gradle import 	androidx.security.crypto.MasterKeys
////        val keyGenParameterSpec = MasterKeys.AES256_GCM_SPEC
////        val masterKeyAlias = MasterKeys.getOrCreate(keyGenParameterSpec)
//    }
//
//    private fun deleteTokens(call: MethodCall, result: MethodChannel.Result) {
//        val alias = call.argument<String>(PARAM_LOGIN_ID)
//        try {
//            keystore.deleteEntry(alias)
//            result.success(null)
//        } catch (e: KeyStoreException) {
//            Log.e(this.javaClass.simpleName, Log.getStackTraceString(e))
//            result.error("500", e.message, null)
//        }
//    }
//
//    private fun updateToken(call: MethodCall, result: MethodChannel.Result) {
//        val kpg: KeyPairGenerator = KeyPairGenerator.getInstance(
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) KeyProperties.KEY_ALGORITHM_AES else "AES",
//            KEYSTORE_PROVIDER
//        )
//
//        val alias = call.argument<String>(PARAM_LOGIN_ID)
//            ?: return result.error("400", paramError(METHOD_UPDATE, PARAM_LOGIN_ID), null)
//        val paramSpec = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            KeyGenParameterSpec.Builder(
//                alias,
//                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
//            ).run {
//                setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
//                build()
//            }
//        } else {
//            // TODO: Figure out how to do right
//            KeyPairGeneratorSpec.Builder(context)
//                .setAlias(alias)
//                .build()
//        }
//        kpg.initialize(paramSpec)
//        val kp = kpg.generateKeyPair()
//
//        try {
//            val privateKeyEntry =
//                keystore.getEntry(alias, null) as KeyStore.PrivateKeyEntry
//            val publicKey: RSAPublicKey = privateKeyEntry.certificate.publicKey as RSAPublicKey
//
//            // Encrypt the text
//            val initialText = call.argument<String>(PARAM_ACCESS_TOKEN)
//            if (initialText.isNullOrBlank()) {
//                result.error("400", paramError(METHOD_UPDATE, PARAM_ACCESS_TOKEN), null)
//                return
//            }
//
//            val input: Cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding", "AndroidOpenSSL")
//            input.init(Cipher.ENCRYPT_MODE, publicKey)
//            val outputStream = ByteArrayOutputStream()
//            val cipherOutputStream = CipherOutputStream(
//                outputStream, input
//            )
//            cipherOutputStream.write(initialText.toByteArray(charset("UTF-8")))
//            cipherOutputStream.close()
//            val vals: ByteArray = outputStream.toByteArray()
//            encryptedText.setText(Base64.encodeToString(vals, Base64.DEFAULT))
//        } catch (e: Exception) {
//            result.error("500", e.message, null)
//            Log.e(this.javaClass.simpleName, Log.getStackTraceString(e))
//        }
//
//        // TODO: repeat for refresh/access tokens
//    }
//
//    private fun readTokens(call: MethodCall, result: MethodChannel.Result) {
//        /*
//         * Verify a signature previously made by a PrivateKey in our
//         * KeyStore. This uses the X.509 certificate attached to our
//         * private key in the KeyStore to validate a previously
//         * generated signature.
//         */
//        val ks = KeyStore.getInstance("AndroidKeyStore").apply {
//            load(null)
//        }
//        val alias = call.argument<String>(PARAM_LOGIN_ID)
//        val entry = ks.getEntry(alias, null) as? KeyStore.PrivateKeyEntry
//    }
//
//    private fun paramError(method: String, vararg params: String): String {
//        return "Method call ($method) Missing params: ${params.joinToString(",")}"
//    }
//}