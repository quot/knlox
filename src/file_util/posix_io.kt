package file_util

import kotlin.ExperimentalSubclassOptIn

import kotlinx.cinterop.memScoped
import kotlinx.cinterop.allocArray
import kotlinx.cinterop.toKString
import kotlinx.cinterop.ByteVar

import platform.posix.fopen
import platform.posix.fgets
import platform.posix.fclose

// From https://nequalsonelifestyle.com/2020/11/16/kotlin-native-file-io/
@kotlinx.cinterop.ExperimentalForeignApi
fun readFile(filePath: String): String {
    println("Reading file: ${filePath}")
    val fileContents = StringBuilder()
    val file = fopen(filePath, "r") ?: throw IllegalArgumentException("Cannot open file: ${filePath}")

    try {
        memScoped {
            val readBufferLength = 64 * 1024
            val buffer = allocArray<ByteVar>(readBufferLength)
            var line = fgets(buffer, readBufferLength, file)?.toKString()
            while (line != null) {
                fileContents.append(line)
                line = fgets(buffer, readBufferLength, file)?.toKString()
            }
        }
    } finally {
        fclose(file)
    }

    return fileContents.toString()
}
