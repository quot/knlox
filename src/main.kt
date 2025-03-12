import file_util.readFile
import kotlin.system.exitProcess
import kotlin.ExperimentalSubclassOptIn

@kotlinx.cinterop.ExperimentalForeignApi
fun main(args: Array<String>) {
    if (args.size > 1) {
        print("Too many arguments passed!")
        exitProcess(64)
    } else if (args.size == 1) {
        runFile(args[0])
    } else {
        exitProcess(runPrompt())
    }
}

@kotlinx.cinterop.ExperimentalForeignApi
fun runFile(filePath: String) {
    val fileStr = readFile(filePath)
    val scanner = Scanner()

    fileStr.lines().forEach{ line: String -> scanner.scanTokens(line) }
}

fun runPrompt() : Int {
    var runPrompt = true

    while (runPrompt) {
        print("KNLox > ")
        val input: String? = readlnOrNull()

        if (input == null) {
            print("Exiting...")
            runPrompt = false
        } else {
            run(input)
        }
    }

    return 0
}

fun run(line: String) {
    val scanner: Scanner = Scanner()
    val tokens: Array<Token> = scanner.scanTokens(line)

    for (i in 0..tokens.size) {
        print(tokens[i])
    }
}

class Token(val tokenType: String) {
    override fun toString(): String { return "TOKEN: ${tokenType}" }
}

class Scanner() {
    fun scanTokens(line: String) : Array<Token> {
        println("SCANNING STRING: ${line}")
        return arrayOf(Token("TEST"))
    }
}

